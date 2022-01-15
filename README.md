# Casper NCTL - Docker Container

This repository contains instructions to prepare an image for a Docker container that runs Casper NCTL as a service.

### Build the Docker image

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

## Run the container

To run the container in your local environment, write:

```bash
docker run --rm -it --name mynctl -d -p 11101:11101 casper-nctl:latest
```

To activate `nctl-*` commands in your local host, run the following command in a bash console:

```bash
source nctl-activate.sh mynctl
```

In a Powershell terminal, run:

```bash
. .\nctl-activate.ps1 mynctl
```

where `mynctl` is the name of the container.

Now you can write just `nctl-view-faucet-account`, `nctl-stop`, etc.

Sometimes you may need the secret key of the faucet or one of the predefined users. After activating `nctl-*` commands you can run:

```bash
nctl-view-fauce-secret-key
```

```bash
nctl-view-user-secret-key user=3
```

```bash
nctl-view-node-secret-key node=5
```

## Use the Docker image in a GitHub action

An example of a GitHub Action running NCTL as a service container to execute integration tests.

```yaml
name: CI

on:
  # Allows you to run this workflow manually from the Actions tab
  workflow_dispatch:

jobs:
  integration-test:
    # The type of runner that the job will run on
    runs-on: ubuntu-latest
    
    # Service containers to run with `runner-job`
    services:
      # Label used to access the service container
      casper-nctl:
        # Docker Hub image
        image: davidatwhiletrue/casper-nctl:v143rev4
        options: --name casper-nctl
        ports:
          # Opens tcp port 6379 on the host and service container
          - 11101:11101
          
    steps:
      - uses: actions/checkout@v2
      - name: Setup .NET
        uses: actions/setup-dotnet@v1
        with:
          dotnet-version: 5.0.x
      - name: Obtain faucet secret key from container
        run: docker exec -t casper-nctl cat /home/casper/casper-node/utils/nctl/assets/net-1/faucet/secret_key.pem > Casper.Network.SDK.Test/TestData/faucetact.pem
      - name: Restore dependencies
        run: dotnet restore
      - name: Build
        run: dotnet build --no-restore
      - name: Test
        run: dotnet test --no-build --verbosity normal --settings Casper.Network.SDK.Test/test.runsettings --filter="TestCategory=NCTL" 
```


## Use the Docker image with Gitpod

Create a workspace in Gitpod based on this repository. In your browser, navigate to:

```
https://gitpod.io/#https://github.com/make-software/casper-nctl-docker
```

When the workspace is ready, start NCTL executing the following commands:

```bash
su casper
cd
source casper-node/utils/nctl/activate
nctl-assets-setup
nctl-start
exit
```

NCTL is up and running when the REST service returns the node status:

```bash
curl localhost:14101/status
```
