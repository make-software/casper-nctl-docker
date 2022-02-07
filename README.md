# Casper NCTL - Docker Container

[NCTL](https://github.com/casper-network/casper-node/tree/release-1.4.3/utils/nctl) is a CLI application to control one or multiple Casper networks locally. Many developers wish to spin up relatively small test networks to localize their testing before deploying to the blockchain.

## How to use this image

### Start a network with five nodes

To create a container with the NCTL image write:

```bash
docker run --rm -it --name mynctl -d -p 11101:11101 -p 14101:14101 -p 18101:18101 makesoftware/casper-nctl
```

where `mynctl` is the name of the container. The ports for the first node in the network are published to the host.

### Activate `nctl-*` commands

To activate `nctl-*` commands in your local host, run the following command in a bash console:

```bash
source nctl-activate.sh mynctl
```

In a Powershell terminal, run:

```bash
. .\nctl-activate.ps1 mynctl
```

where `mynctl` is the name of the container.

Now you can write in the host machine commands like `nctl-view-faucet-account`, `nctl-transfer-native`, etc. For a complete list of commands, visit [this page](https://github.com/casper-network/casper-node/blob/release-1.4.3/utils/nctl/docs/commands.md).

Sometimes you may need the secret key of the faucet, a node or one of the predefined users. After activating `nctl-*` commands you can execute the following commands:

```bash
nctl-view-faucet-secret-key
```

```bash
nctl-view-node-secret-key node=1
```

```bash
nctl-view-user-secret-key user=3
```

### Run the container with static account keys

Each time the container is started, nctl runs with a set of randomly generated account keys. To use a set of static and pregenerated account keys, run the container with an extra parameter:

```bash
docker run --rm -it --name mynctl -d -p 11101:11101 makesoftware/casper-nctl /bin/bash -c "/home/casper/restart-static-accounts.sh"
```

### Stop the container

To stop the container write:

```bash
docker stop mynctl
```

### Container shell access

The docker exec command allows you to run commands inside a Docker container. The following command line will give you a bash shell inside your nctl container:

$ docker exec -it mynctl bash

In the container shell you can use the `casper-client` tool as well as the `nctl-*` set of commands.


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
        image: makesoftware/casper-nctl:latest
        options: --name casper-nctl
        ports:
          # Opens RPC, REST and events ports on the host and service container
          - 11101:11101
          - 14101:14101
          - 18101:18101
          
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
