FROM alpine:latest
ARG TARGETARCH
ARG TARGETVARIANT

ADD vnt-cli_$TARGETARCH$TARGETVARIANT /usr/bin/vnt-cli
RUN chmod +x /usr/bin/vnt-cli && \
    mkdir -p /dev/net && \
    mknod /dev/net/tun c 10 200 && \
    chmod 0666 /dev/net/tun 
ENTRYPOINT ["/usr/bin/vnt-cli"]
