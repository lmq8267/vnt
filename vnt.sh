#!/bin/sh
rustup target add mipsel-unknown-linux-musl
cd /opt/vnt
cargo build --package vnt-cli --target=mipsel-unknown-linux-musl --release
