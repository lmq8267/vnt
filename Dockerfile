FROM alpine:latest
ARG TARGETARCH
ARG TARGETVARIANT

# 添加程序
ADD vnt-cli_$TARGETARCH$TARGETVARIANT /usr/bin/vnt-cli
ADD vn-link-cli_$TARGETARCH$TARGETVARIANT /usr/bin/vn-link-cli
RUN apk update && \
    apk add iptables-legacy && \ 
    ln -sf /usr/sbin/iptables-legacy /usr/sbin/iptables && \
    ln -sf /usr/sbin/ip6tables-legacy /usr/sbin/ip6tables

# 设置中文环境变量
ENV LANG=zh_CN.UTF-8 
ENV LANGUAGE=zh_CN:zh

# 设置程序为可执行
RUN chmod +x /usr/bin/vnt-cli /usr/bin/vn-link-cli

# 创建 run.sh 文件
RUN echo '#!/bin/sh' > /usr/bin/run.sh && \
    echo 'if [ "$APP" = "vn-link-cli" ]; then' >> /usr/bin/run.sh && \
    echo '  echo "当前运行程序为 vn-link-cli 无需特权模式和tun模块。"' >> /usr/bin/run.sh && \
    echo '  exec /usr/bin/vn-link-cli "$@"' >> /usr/bin/run.sh && \
    echo 'else' >> /usr/bin/run.sh && \
    echo '  echo "当前运行程序为 vnt-cli 需要特权模式和tun模块。"' >> /usr/bin/run.sh && \
    echo '  echo "如需运行vn-link-cli或无法使用特权模式和tun的，请在添加容器的时候使用环境变量 APP=vn-link-cli"' >> /usr/bin/run.sh && \
    echo '  exec /usr/bin/vnt-cli "$@"' >> /usr/bin/run.sh && \
    echo 'fi' >> /usr/bin/run.sh

# 设置 run.sh 为可执行
RUN chmod +x /usr/bin/run.sh

# 设置 entrypoint
ENTRYPOINT ["/usr/bin/run.sh"]

