# 客户端vnt - mipsel
<p align="center">
  <img alt="GitHub Created At" src="https://img.shields.io/github/created-at/lmq8267/vnt?logo=github&label=%E5%88%9B%E5%BB%BA%E6%97%A5%E6%9C%9F">
<a href="https://hits.seeyoufarm.com"><img src="https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2Flmq8267%2Fvnt&count_bg=%2395C10D&title_bg=%23555555&icon=github.svg&icon_color=%238DC409&title=%E8%AE%BF%E9%97%AE%E6%95%B0&edge_flat=false"/></a>
<a href="https://github.com/lmq8267/vnt/releases"><img src="https://img.shields.io/github/downloads/lmq8267/vnt/total?logo=github&label=%E4%B8%8B%E8%BD%BD%E9%87%8F"/></a>
<a href="https://github.com/lmq8267/vnt/graphs/contributors"><img src="https://img.shields.io/github/contributors-anon/lmq8267/vnt?logo=github&label=%E8%B4%A1%E7%8C%AE%E8%80%85"/></a>
<a href="https://github.com/lmq8267/vnt/releases/"><img src="https://img.shields.io/github/v/release/lmq8267/vnt?logo=github&label=%E7%A8%B3%E5%AE%9A%E7%89%88"/></a>
  <a href="https://github.com/lmq8267/vnt/releases/"><img src="https://img.shields.io/github/v/tag/lmq8267/vnt-cli?logo=github&label=%E6%9C%80%E6%96%B0%E7%89%88%E6%9C%AC"/></a>
<a href="https://github.com/lmq8267/vnt/issues"><img src="https://img.shields.io/github/issues-raw/lmq8267/vnt?logo=github&label=%E9%97%AE%E9%A2%98"/></a>
<a href="https://github.com/lmq8267/vnt/discussions"><img src="https://img.shields.io/github/discussions/lmq8267/vnt?logo=github&label=%E8%AE%A8%E8%AE%BA"/></a>
<a href="GitHub repo size"><img src="https://img.shields.io/github/repo-size/lmq8267/vnt?logo=github&label=%E4%BB%93%E5%BA%93%E5%A4%A7%E5%B0%8F"/></a>
<a href="https://github.com/lmq8267/vnt/actions?query=workflow%3ABuild"><img src="https://img.shields.io/github/actions/workflow/status/lmq8267/vnt/多版本.yml?branch=main&logo=github&label=%E6%9E%84%E5%BB%BA%E7%8A%B6%E6%80%81" alt="Build status"/></a>
<a href="https://hub.docker.com/r/lmq8267/vnt"><img src="https://img.shields.io/docker/v/lmq8267/vnt?label=%E9%95%9C%E5%83%8F%E6%9C%80%E6%96%B0%E7%89%88%E6%9C%AC&link=https%3A%2F%2Fhub.docker.com%2Fr%2Flmq8267%2Fvnt&logo=docker"/></a>
<a href="https://hub.docker.com/r/lmq8267/vnt"><img src="https://img.shields.io/docker/pulls/lmq8267/vnt?color=%2348BB78&logo=docker&label=%E6%8B%89%E5%8F%96%E9%87%8F" alt="Downloads"/></a>
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
