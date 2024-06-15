FROM alpine:latest
ARG TARGETARCH
ARG TARGETVARIANT

# 添加程序
ADD vnt-cli_$TARGETARCH$TARGETVARIANT /usr/bin/vnt-cli
ADD vn-link-cli_$TARGETARCH$TARGETVARIANT /usr/bin/vn-link-cli

# 设置程序为可执行
RUN chmod +x /usr/bin/vnt-cli /usr/bin/vn-link-cli

# 创建 run.sh 文件
RUN echo '#!/bin/sh' > /usr/bin/run.sh && \
    echo 'if [ "\$APP" = "vn-link-cli" ]; then' >> /usr/bin/run.sh && \
    echo '  exec /usr/bin/vn-link-cli "\$@"' >> /usr/bin/run.sh && \
    echo 'else' >> /usr/bin/run.sh && \
    echo '  exec /usr/bin/vnt-cli "\$@"' >> /usr/bin/run.sh && \
    echo 'fi' >> /usr/bin/run.sh

# 设置 run.sh 为可执行
RUN chmod +x /usr/bin/run.sh

# 设置 entrypoint
ENTRYPOINT ["/usr/bin/run.sh"]

