# Casper NCTL - Docker Container

## Build the Docker image

First, build a base image. This downloads and compiles the `casper-node-launcher` and `casper-node` repositories from GitHub.

```bash
docker build -f casper-nctl-base.Dockerfile -t casper-nctl:base .
```

Optionally, use the argument `GITBRANCH` to indicate which branch from the `casper-node` repository download and build:

```bash
docker build -f casper-nctl-base.Dockerfile --build-arg GITBRANCH=release-1.4.4 -t casper-nctl:base .
```


Now, extend the base image with a start service script:

```bash
docker build -f casper-nctl-service.Dockerfile -t casper-nctl:v144 .
```

The image is tagged as v144, which is the latest `casper-node` version at the moment of writing these instructions. To keep other scripts independent of the version, tag the image also as `latest`.

```bash
docker tag casper-nctl:v144 casper-nctl:latest
```
