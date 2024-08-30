#!/bin/sh

vnt_cli=`uci -q get vnt.@vnt-cli[0].clibin`
vnts=`uci -q get vnt.@vnts[0].vntsbin`
curltest=`which curl`
user_agent='Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36'
cputype=$(uname -ms | tr ' ' '_' | tr '[A-Z]' '[a-z]')
[ -n "$(echo $cputype | grep -E "linux.*armv.*")" ] && cpucore="arm" 
[ -n "$(echo $cputype | grep -E "linux.*armv7.*")" ] && [ -n "$(cat /proc/cpuinfo | grep vfp)" ] && [ ! -d /jffs/clash ] && cpucore="armv7" 
[ -n "$(echo $cputype | grep -E "linux.*aarch64.*|linux.*armv8.*")" ] && cpucore="aarch64" 
[ -n "$(echo $cputype | grep -E "linux.*86.*")" ] && cpucore="i386" 
[ -n "$(echo $cputype | grep -E "linux.*86_64.*")" ] && cpucore="x86_64" 
if [ -n "$(echo $cputype | grep -E "linux.*mips.*")" ] ; then
    mipstype=$(echo -n I | hexdump -o 2>/dev/null | awk '{ print substr($2,6,1); exit}') 
    [ "$mipstype" = "0" ] && cpucore="mips" || cpucore="mipsle" 
fi
proxys="
https://github.moeyy.xyz/
https://gh.ddlc.top/
https://gh.llkk.cc/
https://mirror.ghproxy.com/
https://ghproxy.net/
https://dl.cnqq.cloudns.ch/
"
[ ! -f /usr/lib/lua/luci/model/cbi/vnt.lua ] && echo -e "\033[31m此脚本只适合更新已安装luci-app-vnt的程序！ \033[0m" ; exit 0

log () {
   echo -e "\033[36;1m【$(TZ=UTC-8 date -R +%Y年%m月%d月\ %X)】 : \033[0m\033[35;1m$1 \033[0m"
   if [ "$2" = "vnt" ] ; then
   echo "【$(TZ=UTC-8 date -R +%Y年%m月%d月\ %X) 】: $1 " >>/tmp/vnt-cli_update
   fi
   if [ "$2" = "vnts" ] ; then
   echo "【$(TZ=UTC-8 date -R +%Y年%m月%d月\ %X)】 : $1 " >>/tmp/vnts_update
   fi
}

vnt () {
   echo "" >/tmp/vnt-cli_update
   ver="$($vnt_cli -h | grep version | awk -F ':' {'print $2'})"
   log "开始更新vnt-cli客户端程序..." vnt
   if [ -z "$1" ] ; then
   if [ -z "$curltest" ] || [ ! -s "`which curl`" ] ; then
       tag="$( wget -T 5 -t 3 --user-agent "$user_agent" --max-redirect=0 --output-document=-  https://api.github.com/repos/vnt-dev/vnt/releases/latest  2>&1 | grep 'tag_name' | cut -d\" -f4 )"
       [ -z "$tag" ] && tag="$( wget -T 5 -t 3 --user-agent "$user_agent" --quiet --output-document=-  https://api.github.com/repos/vnt-dev/vnt/releases/latest  2>&1 | grep 'tag_name' | cut -d\" -f4 )"
   else
       tag="$( curl --connect-timeout 3 --user-agent "$user_agent"  https://api.github.com/repos/vnt-dev/vnt/releases/latest  2>&1 | grep 'tag_name' | cut -d\" -f4 )"
       [ -z "$tag" ] && tag="$( curl -L --connect-timeout 3 --user-agent "$user_agent" -s  https://api.github.com/repos/vnt-dev/vnt/releases/latest  2>&1 | grep 'tag_name' | cut -d\" -f4 )"
   fi
   else
   tag="$1"
   fi
   [ -z "$tag" ] &&  log "无法从github获取到最新版本，退出更新！" vnt && exit 0
   if [ ! -z "$cpucore" ] ; then
       if [ ! -z "$ver" ] && [ ! -z "$tag" ] ; then
           if [ "$ver"x = "$tag"x ] ; then
               log "当前版本 ${ver} 已是最新版本，无需更新！" vnt && exit 0
	   fi
       fi
       log "当前CPU架构 ${cpucore} 获取到最新版本vnt-${cpucore}-unknown-linux-musl-${tag}.tar.gz" vnt
       case "${cpucore}" in 
             "mipsle") url="mipsle-unknown-linux-musl"
	     ;;
	     "mips") url="mips-unknown-linux-musl"
	     ;;
	     "x86_64") url="x86_64-unknown-linux-musl"
	     ;;
	     "i386") url="i686-unknown-linux-musl"
	     ;;
	     "aarch64") url="aarch64-unknown-linux-musl"
	     ;;
	     "armv7") url="armv7-unknown-linux-musleabi"
	     ;;
	     "arm") url="arm-unknown-linux-musleabi"
	     ;;
	     esac
   else
       log "无法识别当前CPU架构，退出更新！" vnt && exit 0
   fi
   log "开始下载https://github.com/vnt-dev/vnt/releases/download/${tag}/vnt-${url}-${tag}.tar.gz" vnt 
   for proxy in $proxys ; do
    curl -Lkso /tmp/vnt-cli.tar.gz "${proxy}https://github.com/vnt-dev/vnt/releases/download/${tag}/vnt-${url}-${tag}.tar.gz"
    if [ "$?" = 0 ] ; then
        log "下载完成，开始解压/tmp/vnt-cli.tar.gz到/tmp/目录里..." vnt 
	rm /tmp/vnt-cli >/dev/null 2>&1
        tar -zxf /tmp/vnt-cli.tar.gz -C /tmp/
	rm /tmp/vnt-cli.tar.gz /tmp/vn-link-cli /tmp/README.md >/dev/null 2>&1
	chmod +x /tmp/vnt-cli
	dlmd5=$(md5sum /tmp/vnt-cli | awk '{print $1}')
	if [ $(($(/tmp/vnt-cli -h | wc -l))) -gt 3 ] ; then
	    log "解压完成，替换/tmp/vnt-cli 到${vnt_cli}" vnt 
	    #/etc/init.d/vnt stop 
	    mv -f /tmp/vnt-cli ${vnt_cli}
            #/etc/init.d/vnt start 
	    md5=$(md5sum "$vnt_cli" | awk '{print $1}')
	    if [ "$dlmd5"x = "$md5"x ] ; then
	        log "${vnt_cli}更新${tag}成功！" vnt 
                break
	    fi
        fi
    fi
   done
exit 0
}

vnts () {
   echo "" >/tmp/vnts_update
    ver="$($vnts -V | awk '{print $2}')"
   log "开始更新vnts服务端程序..." vnts
   if [ -z "$1" ] ; then
   if [ -z "$curltest" ] || [ ! -s "`which curl`" ] ; then
       tag="$( wget -T 5 -t 3 --user-agent "$user_agent" --max-redirect=0 --output-document=-  https://api.github.com/repos/vnt-dev/vnts/releases/latest  2>&1 | grep 'tag_name' | cut -d\" -f4 )"
       [ -z "$tag" ] && tag="$( wget -T 5 -t 3 --user-agent "$user_agent" --quiet --output-document=-  https://api.github.com/repos/vnt-dev/vnts/releases/latest  2>&1 | grep 'tag_name' | cut -d\" -f4 )"
   else
       tag="$( curl --connect-timeout 3 --user-agent "$user_agent"  https://api.github.com/repos/vnt-dev/vnts/releases/latest  2>&1 | grep 'tag_name' | cut -d\" -f4 )"
       [ -z "$tag" ] && tag="$( curl -L --connect-timeout 3 --user-agent "$user_agent" -s  https://api.github.com/repos/vnt-dev/vnts/releases/latest  2>&1 | grep 'tag_name' | cut -d\" -f4 )"
   fi
   else
   tag="$1"
   fi
   [ -z "$tag" ] &&  log "无法从github获取到最新版本，退出更新！" vnts && exit 0
   if [ ! -z "$cpucore" ] ; then
       if [ ! -z "$ver" ] && [ ! -z "$tag" ] ; then
           if [ "$ver"x = "$tag"x ] ; then
               log "当前版本 ${ver} 已是最新版本，无需更新！" vnts && exit 0
	   fi
       fi
       log "当前CPU架构 ${cpucore} 获取到最新版本vnts-${cpucore}-unknown-linux-musl-${tag}.tar.gz" vnts
       case "${cpucore}" in 
             "mipsle") url="mipsle-unknown-linux-musl"
	     ;;
	     "mips") url="mips-unknown-linux-musl"
	     ;;
	     "x86_64") url="x86_64-unknown-linux-musl"
	     ;;
	     "i386") log "当前CPU架构 ${cpucore} 截止更新到v1.2.11版本已不再支持，退出更新！" vnts && exit 0
	     ;;
	     "aarch64") url="aarch64-unknown-linux-musl"
	     ;;
	     "armv7") url="armv7-unknown-linux-musleabi"
	     ;;
	     "arm") url="arm-unknown-linux-musleabi"
	     ;;
	     esac
   else
       log "无法识别当前CPU架构，退出更新！" vnts && exit 0
   fi
   log "开始下载https://github.com/vnt-dev/vnts/releases/download/${tag}/vnts-${url}-${tag}.tar.gz" vnts
   for proxy in $proxys ; do
    curl -Lkso /tmp/vnts.tar.gz "${proxy}https://github.com/vnt-dev/vnts/releases/download/${tag}/vnts-${url}-${tag}.tar.gz"
    if [ "$?" = 0 ] ; then
        log "下载完成，开始解压/tmp/vnts.tar.gz到/tmp/目录里..." vnts 
	rm /tmp/vnts >/dev/null 2>&1
        tar -zxf /tmp/vnts.tar.gz -C /tmp/
	rm /tmp/vnts.tar.gz >/dev/null 2>&1
	chmod +x /tmp/vnts
	dlmd5=$(md5sum /tmp/vnts | awk '{print $1}')
	if [ $(($(/tmp/vnts -h | wc -l))) -gt 3 ] ; then
	    log "解压完成，替换/tmp/vnts 到${vnts}" vnts 
	    #/etc/init.d/vnt stop 
	    mv -f /tmp/vnts ${vnts}
            #/etc/init.d/vnt start 
	    md5=$(md5sum "$vnts" | awk '{print $1}')
	    if [ "$dlmd5"x = "$md5"x ] ; then
	        log "${vnts}更新${tag}成功！" vnts 
                break
	    fi
        fi
    fi
   done
exit 0
}

case $1 in
vnt-cli)
        vnt $2
	;;
vnt)
        vnt $2
	;;
vnts) 
	vnts $2
	;;
*)
        exit 0
	;;
esac
