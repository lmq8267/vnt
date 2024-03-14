FROM alpine:latest
ARG TARGETARCH
ARG TARGETVARIANT

ADD vnt-cli_$TARGETARCH$TARGETVARIANT /usr/bin/vnt-cli
RUN chmod +x /usr/bin/vnt-cli 
ENTRYPOINT ['echo "需要在特权模式运行（最高权限root），并且宿主机提前加载好tun模块（加载命令：sudo modprobe tun）"; /usr/bin/vnt-cli']
