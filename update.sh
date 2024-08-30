#!/bin/sh

curltest=`which curl`
user_agent='Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36'
proxys="
https://github.moeyy.xyz/
https://gh.ddlc.top/
https://gh.llkk.cc/
https://mirror.ghproxy.com/
https://ghproxy.net/
https://dl.cnqq.cloudns.ch/
"

log () {
   echo -e "\033[36;1m【$(TZ=UTC-8 date -R +%Y年%m月%d月\ %X)】 : \033[0m\033[35;1m$1 \033[0m"
  echo "【$(TZ=UTC-8 date -R +%Y年%m月%d月\ %X)】 : $1 " >>/tmp/vnt_update
}

check () {
   vnt_cli=`uci -q get vnt.@vnt-cli[0].clibin`
   vnts=`uci -q get vnt.@vnts[0].vntsbin`
   size=$(df -k /usr/bin | awk 'NR==2 {print $(NF-2) }')
      size_m=$(df -m /usr/bin | awk 'NR==2 {print $(NF-2) }')
   if [ ! -f /usr/lib/lua/luci/model/cbi/vnt.lua ] ; then
      echo -e "\033[31m此脚本只适合更新已安装luci-app-vnt的程序！ \033[0m" 
      exit 0
   fi
   if [ -z "$vnt_cli" ] ; then
      if [ "$size" -gt 4000 ] ; then
        vnt_cli="/usr/bin/vnt-cli"
        uci -q set vnt.@vnt-cli[0].clibin="$vnt_cli"
      else
                log "当前内部可用空间剩余${size_m}M 不足以存储vnt-cli程序，已更改到内存/tmp/vnt-cli" vnt
                vnt_cli="/tmp/vnt-cli"
                uci -q set vnt.@vnt-cli[0].clibin="$vnt_cli"
            fi
   fi
   if [ -z "$vnts" ] ; then
      if [ "$size" -gt 4000 ] ; then
         vnts="/usr/bin/vnts"
         uci -q set vnt.@vnts[0].vntsbin="$vnts"
      else
         log "当前内部可用空间剩余${size_m}M 不足以存储vnts程序，已更改到内存/tmp/vnts" vnts
         vnts="/tmp/vnts"
         uci -q set vnt.@vnts[0].vntsbin="$vnts"
      fi
   fi
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
}

vnt () {
   echo "" >/tmp/vnt_update
   check
   ver="$($vnt_cli -h | grep version | awk -F ':' {'print $2'})"
   log "开始更新vnt-cli客户端程序..." vnt
   if [ -z "$1" ] ; then
   if [ -z "$curltest" ] || [ ! -s "`which curl`" ] ; then
       tag="$( wget -T 5 -t 3 --user-agent "$user_agent" --max-redirect=0 --output-document=-  https://api.github.com/repos/vnt-dev/vnt/releases/latest  2>&1 | grep 'tag_name' | cut -d\" -f4 )"
       [ -z "$tag" ] && tag="$( wget -T 5 -t 3 --user-agent "$user_agent" --quiet --output-document=-  https://api.github.com/repos/vnt-dev/vnt/releases/latest  2>&1 | grep 'tag_name' | cut -d\" -f4 )"
       [ -z "$tag" ] && tag="$( wget --no-check-certificate -T 5 -t 3 --user-agent "$user_agent" --quiet --output-document=-  https://dl.cnqq.cloudns.ch/https://api.github.com/repos/vnt-dev/vnt/releases/latest  2>&1 | grep 'tag_name' | cut -d\" -f4 )"
   else
       tag="$( curl --connect-timeout 3 --user-agent "$user_agent"  https://api.github.com/repos/vnt-dev/vnt/releases/latest  2>&1 | grep 'tag_name' | cut -d\" -f4 )"
       [ -z "$tag" ] && tag="$( curl -L --connect-timeout 3 --user-agent "$user_agent" -s  https://api.github.com/repos/vnt-dev/vnt/releases/latest  2>&1 | grep 'tag_name' | cut -d\" -f4 )"
       [ -z "$tag" ] && tag="$( curl -Lk --connect-timeout 5 --user-agent "$user_agent" -s  https://dl.cnqq.cloudns.ch/https://api.github.com/repos/vnt-dev/vnt/releases/latest  2>&1 | grep 'tag_name' | cut -d\" -f4 )"
   fi
   else
   tag="$1"
   fi
   [ -z "$tag" ] &&  log "无法从github获取到最新版本，退出更新！" vnt && exit 0
   if [ ! -z "$cpucore" ] ; then
       if [ ! -z "$ver" ] && [ ! -z "$tag" ] ; then
           if [ "$ver"x = "$tag"x ] ; then
               log "当前版本 ${ver} 已是最新版本，无需更新！" vnt && exit 0
	   else
	       log "当前版本 ${ver} 最新版本 ${tag} " vnt
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
    curl -Lkso /tmp/vnt-cli.tar.gz "${proxy}https://github.com/vnt-dev/vnt/releases/download/${tag}/vnt-${url}-${tag}.tar.gz" || wget --no-check-certificate -q -O /tmp/vnt-cli.tar.gz "${proxy}https://github.com/vnt-dev/vnt/releases/download/${tag}/vnt-${url}-${tag}.tar.gz"
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
   rm -rf /tmp/vnt*.tag /tmp/vnt*.newtag >/dev/null 2>&1
exit 0
}

vnts () {
   echo "" >/tmp/vnt_update
   check
    ver="$($vnts -V | awk '{print $2}')"
   log "开始更新vnts服务端程序..." vnts
   if [ -z "$1" ] ; then
   if [ -z "$curltest" ] || [ ! -s "`which curl`" ] ; then
       tag="$( wget -T 5 -t 3 --user-agent "$user_agent" --max-redirect=0 --output-document=-  https://api.github.com/repos/vnt-dev/vnts/releases/latest  2>&1 | grep 'tag_name' | cut -d\" -f4 )"
       [ -z "$tag" ] && tag="$( wget -T 5 -t 3 --user-agent "$user_agent" --quiet --output-document=-  https://api.github.com/repos/vnt-dev/vnts/releases/latest  2>&1 | grep 'tag_name' | cut -d\" -f4 )"
       [ -z "$tag" ] && tag="$( wget --no-check-certificate -T 5 -t 3 --user-agent "$user_agent" --quiet --output-document=-  https://dl.cnqq.cloudns.ch/https://api.github.com/repos/vnt-dev/vnts/releases/latest  2>&1 | grep 'tag_name' | cut -d\" -f4 )"
   else
       tag="$( curl --connect-timeout 3 --user-agent "$user_agent"  https://api.github.com/repos/vnt-dev/vnts/releases/latest  2>&1 | grep 'tag_name' | cut -d\" -f4 )"
       [ -z "$tag" ] && tag="$( curl -L --connect-timeout 3 --user-agent "$user_agent" -s  https://api.github.com/repos/vnt-dev/vnts/releases/latest  2>&1 | grep 'tag_name' | cut -d\" -f4 )"
       [ -z "$tag" ] && tag="$( curl -Lk --connect-timeout 5 --user-agent "$user_agent" -s  https://dl.cnqq.cloudns.ch/https://api.github.com/repos/vnt-dev/vnts/releases/latest  2>&1 | grep 'tag_name' | cut -d\" -f4 )"
   fi
   else
   tag="$1"
   fi
   [ -z "$tag" ] &&  log "无法从github获取到最新版本，退出更新！" vnts && exit 0
   if [ ! -z "$cpucore" ] ; then
       if [ ! -z "$ver" ] && [ ! -z "$tag" ] ; then
           if [ "$ver"x = "$tag"x ] ; then
               log "当前版本 ${ver} 已是最新版本，无需更新！" vnts && exit 0
	   else
	       log "当前版本 ${ver} 最新版本 ${tag} " vnts
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
    curl -Lkso /tmp/vnts.tar.gz "${proxy}https://github.com/vnt-dev/vnts/releases/download/${tag}/vnts-${url}-${tag}.tar.gz" || wget --no-check-certificate -q -O /tmp/vnts.tar.gz "${proxy}https://github.com/vnt-dev/vnts/releases/download/${tag}/vnts-${url}-${tag}.tar.gz"
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
   rm -rf /tmp/vnt*.tag /tmp/vnt*.newtag >/dev/null 2>&1
exit 0
}

luci () {
   echo "" >/tmp/vnt_update
   ver="$(opkg info luci-app-vnt | awk '/Version:/ {print $2}')"
   [ -z "$ver" ] &&  log "无法获取本设备的luci-app-vnt版本号，退出更新！" luci && exit 0
   log "开始更新luci-app-vnt ..." luci
   if [ -z "$1" ] ; then
   if [ -z "$curltest" ] || [ ! -s "`which curl`" ] ; then
       tag="$( wget -T 5 -t 3 --user-agent "$user_agent" --max-redirect=0 --output-document=-  https://api.github.com/repos/lmq8267/luci-app-vnt/releases/latest  2>&1 | grep 'tag_name' | cut -d\" -f4 )"
       [ -z "$tag" ] && tag="$( wget -T 5 -t 3 --user-agent "$user_agent" --quiet --output-document=-  https://api.github.com/repos/lmq8267/luci-app-vnt/releases/latest  2>&1 | grep 'tag_name' | cut -d\" -f4 )"
       [ -z "$tag" ] && tag="$( wget --no-check-certificate -T 5 -t 3 --user-agent "$user_agent" --quiet --output-document=-  https://dl.cnqq.cloudns.ch/https://api.github.com/repos/lmq8267/luci-app-vnt/releases/latest  2>&1 | grep 'tag_name' | cut -d\" -f4 )"
   else
       tag="$( curl --connect-timeout 3 --user-agent "$user_agent"  https://api.github.com/repos/lmq8267/luci-app-vnt/releases/latest  2>&1 | grep 'tag_name' | cut -d\" -f4 )"
       [ -z "$tag" ] && tag="$( curl -L --connect-timeout 3 --user-agent "$user_agent" -s  https://api.github.com/repos/lmq8267/luci-app-vnt/releases/latest  2>&1 | grep 'tag_name' | cut -d\" -f4 )"
       [ -z "$tag" ] && tag="$( curl -Lk --connect-timeout 5 --user-agent "$user_agent" -s  https://dl.cnqq.cloudns.ch/https://api.github.com/repos/lmq8267/luci-app-vnt/releases/latest  2>&1 | grep 'tag_name' | cut -d\" -f4 )"
   fi
   else
   tag="$1"
   fi
   [ -z "$tag" ] &&  log "无法从github获取到最新版本，退出更新！" luci && exit 0
   if [ "$ver"x != "$tag"x ] ; then
       log "当前版本 ${ver} 最新版本 ${tag} " luci
       log "开始下载https://github.com/lmq8267/luci-app-vnt/releases/download/${tag}/luci-app-vnt_all.ipk" luci
       for proxy in $proxys ; do
           curl -Lkso /tmp/luci-app-vnt.ipk "${proxy}https://github.com/lmq8267/luci-app-vnt/releases/download/${tag}/luci-app-vnt_all.ipk" || wget --no-check-certificate -q -O /tmp/luci-app-vnt.ipk "${proxy}https://github.com/lmq8267/luci-app-vnt/releases/download/${tag}/luci-app-vnt_all.ipk"
           if [ "$?" = 0 ] ; then
               log "下载完成，开始更新 luci-app-vnt ..." luci
	       rm /var/lock/opkg.lock >/dev/null 2>&1
	       opkg install --force-reinstall --force-overwrite --force-depends /tmp/luci-app-vnt.ipk >/dev/null 2>&1
               ver="$(opkg info luci-app-vnt | awk '/Version:/ {print $2}')"
	    if [ "$ver"x = "$tag"x ] ; then
	        log "luci-app-vnt  ${ver}更新${tag}成功！" luci
                log "请退出登录路由器管理页面，重新登录，进入VNT配置页面修改配置后重新启动！" luci
                break
	    else
	        log "更新失败！" luci
	    fi
         fi
      done
   else
      log "当前版本 ${ver} 已是最新版本，无需更新！" luci && exit 0
   fi
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
luci) 
	luci $2
	;;
*)
        exit 0
	;;
esac
