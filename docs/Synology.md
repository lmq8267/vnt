<div align="center">
  <a href="https://rustvnt.com"><img height="100px" alt="logo" src="https://cdn.jsdelivr.net/gh/vnt-dev/VntApp@master/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png"/></a>
  <h1><p><em>VNT 一个简便高效的异地组网、内网穿透工具。</em></p></h1>
	<a href="https://github.com/vnt-dev/vnt/releases"><img src="https://img.shields.io/github/downloads/vnt-dev/vnt/total"></a>
  <a href="https://github.com/vnt-dev/vnt/graphs/contributors"><img src="https://img.shields.io/github/contributors-anon/vnt-dev/vnt"></a>
  <a href="https://github.com/vnt-dev/vnt/releases/"><img src="https://img.shields.io/github/release/vnt-dev/vnt"></a>
  <a href="https://github.com/vnt-dev/vnt/issues"><img src="https://img.shields.io/github/issues-raw/vnt-dev/vnt"></a>
  <a href="https://github.com/vnt-dev/vnt/discussions"><img src="https://img.shields.io/github/discussions/vnt-dev/vnt"></a>
  <a href="GitHub repo size"><img src="https://img.shields.io/github/repo-size/vnt-dev/vnt?color=red&style=flat-square"></a>
  <a href="https://github.com/vnt-dev/vnt/actions?query=workflow%3ABuild"><img src="https://img.shields.io/github/actions/workflow/status/vnt-dev/vnt/rust.yml?branch=main" alt="Build status"></a>
  <a href="https://hub.docker.com/r/lubeilin/vnt"><img src="https://img.shields.io/docker/pulls/lubeilin/vnt?color=%2348BB78&logo=docker&label=pulls" alt="Downloads"></a>
</div>


# 群晖 Synology 篇 （以DSM 7.2 为例）

## [部署vnt-cli客户端](https://github.com/lmq8267/vnt/blob/main/docs/Synology.md#%E4%B8%80%E5%89%8D%E6%8F%90%E9%9C%80%E8%A6%81%E5%85%88%E7%A1%AE%E5%AE%9A%E5%B7%B2%E5%8A%A0%E8%BD%BD%E5%A5%BDtun%E6%A8%A1%E5%9D%97%E5%A6%82%E6%9E%9C%E6%B2%A1%E6%9C%89tun%E6%A8%A1%E5%9D%97%E7%9A%84%E5%88%99%E5%8F%AA%E8%83%BD%E4%BD%BF%E7%94%A8vn-link-cli)：
1.[Docker部署](https://github.com/lmq8267/vnt/blob/main/docs/Synology.md#1docker%E8%BF%90%E8%A1%8C%E6%9C%89tun%E6%A8%A1%E5%9D%97%E4%BD%BF%E7%94%A8%E7%89%B9%E6%9D%83%E6%A8%A1%E5%BC%8F)<br>
2.[第三方套件运行](https://github.com/lmq8267/vnt/blob/main/docs/Synology.md#2%E7%AC%AC%E4%B8%89%E6%96%B9%E5%A5%97%E4%BB%B6%E8%BF%90%E8%A1%8C)<br>
3.[ssh二进制运行](https://github.com/lmq8267/vnt/blob/main/docs/Synology.md#3ssh%E4%BA%8C%E8%BF%9B%E5%88%B6%E8%BF%90%E8%A1%8C)
## [部署vnts服务端]()：

<br>

### 一、前提需要先确定已加载好tun模块，如果没有tun模块的则只能使用vn-link-cli

#### ①启用群晖的ssh功能，打开ssh输入下述命令查看是否已加载好tun模块
```bash
#检查是否安装了 tun 模块：
lsmod | grep tun
#或者
ls /dev/net/tun
```
![](./img/群晖确定是否有tun.png)
#### ②如上图输出信息则是有tun模块，
#### 如果没有输出，可执行下述命令加载，再使用上述命令检测是否加载成功
```bash
#如果上述结果为空，请尝试加载它：
sudo modprobe tun
#或者
sudo insmod /lib/modules/tun.ko
```
#### ③如果须手动加载tun的还需要设置开机自动加载tun模块，打开群晖的任务计划，
![](./img/群晖触发任务.png)
#### 使用root用户添加开机启动命令，
![](./img/群晖开机触发任务.png)
#### 填写开机加载tun的命令，其中的`mypassword`改成你的root密码
```bash
sudo -S ls >/dev/null 2>&1 << EOF
mypassword
EOF
sudo insmod /lib/modules/tun.ko >/dev/null 2>&1 &

```
![](./img/群晖创建开机加载tun任务.png)
#### 或参考[解决群晖 NAS 无法使用 TUN / TAP 的问题 ](https://www.moewah.com/archives/2750.html)

### 1.Docker运行（有tun模块，使用特权模式）
#### ①打开群晖管理页面，打开docker套件
![](./img/群晖打开docker套件.png)
#### ②打开注册表搜索vnt，找到vnt镜像双击拉取，
![](./img/群晖注册表搜索.png)
#### 如果拉取失败，点击[离线镜像包](https://github.com/lmq8267/vnt-cli/releases)下载对应平台架构docker的离线镜像包docker.tar上传安装，
![](./img/群晖下载离线镜像.png)
#### 选择刚下载的离线镜像.tar的上传进去
![](./img/群晖导入离线镜像.png)
#### ③打开容器，创建一个新的额容器，选择刚刚上传的镜像，
![](./img/群晖创建容器.png)
![](./img/群晖特权模式.png)
![](./img/群晖host网络.png)
![](./img/群晖docker创建命令.png)
![](./img/群晖docker成功日志.png)
#### 至此docker部署完成，另附docker-compose.yml 参考
```bash
version: '3.9'
services:
    #用于自动更新vnt-cli镜像，若不需要请删除这部分
    watchtower: 
         command: --interval 3600 --cleanup --label-enable
         container_name: watchtower
         environment:
               - TZ=Asia/Shanghai
               - WATCHTOWER_NO_STARTUP_MESSAGE
         image: containrrr/watchtower
         restart: always
         volumes:
               - /var/run/docker.sock:/var/run/docker.sock
   #若不需要请删除这部分
    vnt:
        #vnt-cli的启动命令参数下方修改为你的
        command: '-k test123 --ip 10.26.0.3 -d 10.26.0.3 -o 0.0.0.0/0'
        image: lmq8267/vnt
        restart: always
        privileged: true
        network_mode: host
        container_name: vnt-cli

```

### 2.第三方套件运行
#### ①打开群晖管理界面-套件中心，添加第三方套件源（[我不是矿神](https://imnks.com/)  DSM7 地址：https://spk7.imnks.com），
![](./img/群晖添加第三方套件源.png)
![](./img/群晖搜索套件.png)
![](./img/群晖套件权限.png)
`sudo sed -i 's/package/root/g' /var/packages/RustVNT/conf/privilege`
#### 这里建议使用第一个方法，每次开机自动赋予权限
![](./img/群晖套件修改配置.png)
#### [配置文件模板](https://github.com/vnt-dev/vnt/blob/main/vnt-cli/README.md#-f-conf)参考，
![](./img/群晖套件停用再启动.png)
#### 可以打开ssh输入命令来查看启动状态，
![](./img/群晖套件查看启动状态.png)
#### 如上表示启动成功，日志路径在`/var/packages/RustVNT/var/RustVNT.log` 配置文件路径在`/var/packages/RustVNT/var/config.yaml` 至此套件部署完成~

### 3.ssh二进制运行
#### ①[检测是否有tun](https://github.com/lmq8267/vnt/blob/main/docs/Synology.md#%E4%B8%80%E5%89%8D%E6%8F%90%E9%9C%80%E8%A6%81%E5%85%88%E7%A1%AE%E5%AE%9A%E5%B7%B2%E5%8A%A0%E8%BD%BD%E5%A5%BDtun%E6%A8%A1%E5%9D%97%E5%A6%82%E6%9E%9C%E6%B2%A1%E6%9C%89tun%E6%A8%A1%E5%9D%97%E7%9A%84%E5%88%99%E5%8F%AA%E8%83%BD%E4%BD%BF%E7%94%A8vn-link-cli)
#### ②启用群晖的ssh功能，前往[vnt项目](https://github.com/vnt-dev/vnt/releases)项目地址下载适合自己平台架构的程序，注意群晖是linux系统，
![](./img/群晖ssh下载程序.png)
#### ③解压出vnt-cli二进制程序，上传到群晖的目录里，我上传到`/volume1/8267/bin/vnt/vnt-cli`
![](./img/群晖ssh上传二进制.png)
#### ④打开ssh终端输入启动命令测试
![](./img/群晖ssh命令行启动.png)
#### ⑤启动成功那么需要设置开机自动启动，我设置每五分钟检测一次进程，不存在则启动，
![](./img/群晖ssh定时任务新增.png)
![](./img/群晖ssh定时任务新增2.png)
![](./img/群晖ssh定时任务新增3.png)
![](./img/群晖ssh定时任务新增4.png)
#### 至此ssh运行二进制部署完成



### 二、服务端部署：

### 1.Docker运行

### 2.ssh二进制运行

