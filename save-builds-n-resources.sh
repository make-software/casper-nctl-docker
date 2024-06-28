#!/bin/bash
cd /root
mkdir -p bucket/casper-node
mv casper-node/target/release/casper-node bucket/casper-node/
mv casper-node/target/release/global-state-update-gen bucket/casper-node/
mv casper-node/target/wasm32-unknown-unknown/release/*.wasm bucket/casper-node/
mv casper-node/resources bucket/casper-node/

mkdir -p bucket/casper-sidecar
mv casper-sidecar/target/release/casper-sidecar bucket/casper-sidecar/
mv casper-sidecar/resources bucket/casper-sidecar/

mkdir -p bucket/casper-node-launcher
mv casper-node-launcher/target/release/casper-node-launcher bucket/casper-node-launcher/
mv casper-node-launcher/resources bucket/casper-node-launcher/

mkdir -p bucket/casper-client-rs
mv casper-client-rs/target/release/casper-client bucket/casper-client-rs/
mv casper-client-rs/resources bucket/casper-client-rs/
