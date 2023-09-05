#!/bin/sh
rustup target add mipsel-unknown-linux-musl
cd /opt/vnt
 cat >>~/.cargo/config <<EOF
[source.crates-io]
registry = "https://github.com/rust-lang/crates.io-index"
replace-with = 'ustc'
[source.ustc]
registry = "git://mirrors.ustc.edu.cn/crates.io-index"

[build]
target = "mipsel-unknown-linux-musl"
[target.mipsel-unknown-linux-musl]
linker = "mipsel-linux-gnu-gcc"
rustflags = ["-C", "target-feature=+crt-static","-C", "strip=symbols","--cfg","aes_armv8"]
EOF
cargo build --package vnt-cli --target=mipsel-unknown-linux-musl --release
