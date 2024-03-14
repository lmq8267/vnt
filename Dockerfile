FROM alpine:latest
ARG TARGETARCH
ARG TARGETVARIANT

ADD vnt-cli_$TARGETARCH$TARGETVARIANT /usr/bin/vnt-cli
RUN chmod +x /usr/bin/vnt-cli 
ENTRYPOINT ["/usr/bin/vnt-cli"]
