# 客户端vnt - mipsel
服务端 https://github.com/lmq8267/vnts

下载 点右边的releases

docker运行的话
```shell
#以下只演示加了一个参数 -k  其他参数直接在后面添加即可
docker run --name vnt-cli --net=host --privileged --restart=always -d lmq8267/vnt -k test123
```
像群晖等需要先安装或者加载好tun模块才能使用，vnt客户端依赖tun ，[解决群晖 NAS 无法使用 TUN / TAP 的问题 ](https://www.moewah.com/archives/2750.html)
```shell
#检查是否安装了 tun 模块：
lsmod | grep tun
#或者
ls /dev/net/tun

#如果上述结果为空，请尝试加载它：
sudo modprobe tun
#或者
sudo insmod /lib/modules/tun.ko

#加载后还是没有可能需要你自行百度一下如何安装tun模块了，每个系统不一样
```

更新说明https://github.com/lbl8603/vnt/releases
