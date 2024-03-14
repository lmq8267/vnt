FROM alpine:latest
ARG TARGETARCH
ARG TARGETVARIANT

ADD vnt-cli_$TARGETARCH$TARGETVARIANT /usr/bin/vnt-cli
RUN chmod +x /usr/bin/vnt-cli && \
    mkdir -p /lib/modules/$(uname -r) && \
    touch /lib/modules/$(uname -r)/modules.dep && \
    apk add --no-cache iproute2 openvpn && \
    modprobe tun
ENTRYPOINT ["/usr/bin/vnt-cli"]
