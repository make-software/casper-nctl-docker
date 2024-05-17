#!/bin/bash
cd /home/casper

mkdir -p casper-node/target/release && mv bucket/casper-node/casper-node casper-node/target/release/casper-node
mkdir -p casper-node/target/wasm32-unknown-unknown/release && mv bucket/casper-node/*.wasm casper-node/target/wasm32-unknown-unknown/release
cp -r bucket/casper-node/resources/ casper-node/

mkdir -p casper-sidecar/target/release && mv bucket/casper-sidecar/casper-sidecar casper-sidecar/target/release/casper-sidecar
cp -r bucket/casper-sidecar/resources casper-sidecar

mkdir -p casper-node-launcher/target/release && mv bucket/casper-node-launcher/casper-node-launcher casper-node-launcher/target/release/casper-node-launcher
cp -r bucket/casper-node-launcher/resources casper-node-launcher

mkdir -p casper-client-rs/target/release && mv bucket/casper-client-rs/casper-client casper-client-rs/target/release/casper-client
cp -r bucket/casper-client-rs/resources casper-client-rs