# 客户端vnt - mipsel
<p align="center">
<a href="https://github.com/lmq8267/vnt/releases"><img src="https://img.shields.io/github/downloads/lmq8267/vnt/total"/></a
<a href="https://github.com/lmq8267/vnt/graphs/contributors"><img src="https://img.shields.io/github/contributors-anon/lmq8267/vnt"/></a
<a href="https://github.com/lmq8267/vnt/releases/"><img src="https://img.shields.io/github/release/lmq8267/vnt"/></a
<a href="https://github.com/lmq8267/vnt/issues"><img src="https://img.shields.io/github/issues-raw/lmq8267/vnt"/></a
<a href="https://github.com/lmq8267/vnt/discussions"><img src="https://img.shields.io/github/discussions/lmq8267/vnt"/></a
<a href="GitHub repo size"><img src="https://img.shields.io/github/repo-size/lmq8267/vnt?color=red&style=flat-square"/></a
<a href="https://github.com/lmq8267/vnt/actions?query=workflow%3ABuild"><img src="https://img.shields.io/github/actions/workflow/status/lmq8267/vnt/多版本.yml?branch=main" alt="Build status"/></a
<a href="https://hub.docker.com/r/lmq8267/vnt"><img src="https://img.shields.io/docker/pulls/lmq8267/vnt?color=%2348BB78&logo=docker&label=pulls" alt="Downloads"/></a
</p>

服务端 https://github.com/lmq8267/vnts

下载 点右边的releases

docker运行的话
```shell
#以下只演示加了一个参数 -k  其他参数直接在后面添加即可
docker run --name vnt-cli --net=host --privileged --restart=always -d lmq8267/vnt -k test123
```
像群晖等需要先安装或者加载好tun模块才能使用，vnt客户端依赖tun ，[解决群晖 NAS 无法使用 TUN / TAP 的问题 ](https://www.moewah.com/archives/2750.html)
警告：群晖等nas重要设备开启ssh或者执行下述命令加载tun或者参考网上教程添加脚本等可能会有无法预估的风险，除非你清楚这些命令或脚本是什么意思，否则自行承担数据损坏丢失的风险。
```shell
#检查是否安装了 tun 模块：
lsmod | grep tun
#或者
ls /dev/net/tun

#如果上述结果为空，请尝试加载它：
sudo modprobe tun
#或者
sudo insmod /lib/modules/tun.ko

#上述方法只测试在我的黑裙DSM7.2里是可以成功运行并且访问组网设备的
#加载后还是没有可能需要你自行百度一下如何安装tun模块了，每个系统不一样
```

更新说明https://github.com/lbl8603/vnt/releases
