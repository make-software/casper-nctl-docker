## Build NCTL Docker image with Condor

Steps:

1. Clone the casper-nctl-docker image and checkout `feat-2.0` branch

```
git clone https://github.com/make-software/casper-nctl-docker.git
cd casper-nctl-docker
git checkout feat-2.0
````

2. Build the image

```
docker build -f casper-nctl-condor.Dockerfile -t casper-nctl:v200-rc4 .
```

3. Run a container

```
docker-compose up casper-nctl
```

### NCTL Explorer (beta)

NCTL Explorer is a simple web block explorer for NCTL. It listens to the SSE channel and shows lists of Blocks, Steps and Transaction events. It also allows to query data from the RPC interface. 

To start the NCTL explorer together with the network run:

```
docker-compose up casper-nctl nctlexplorer
```

Browse to `http://localhost:8080/`.

### Using `casper-client`

The docker image contains `casper-client` command line tool. You can use it from a docker container bash terminal. Or, from your local machine activating the nctl-* scripts.

In a separate terminal window run:

```
source nctl-activate.sh casper-nctl

casper-client get-node-status --node-address http://127.0.0.1:11101
```

## Build NCTL Docker image with v158 and Condor

In some cases you may want to start a network with version 1.5.8, operate with,
and at some point in time, upgrade it to Condor.

Steps:

1. Build the `casper-nctl:rc4` image following the steps in the previous section.

2. Build the staging image. This image depends on `v158` (from docker hub) and `rc4` (local) images. It copies binaries from both images to a new staging image.

```
docker build -f casper-nctl-staging.Dockerfile -t casper-nctl-staging:v200-rc4 .
```

3. Run a container:

```
docker-compose -f staging-condor/docker-compose.yml up casper-nctl
```

This will start the network on protocol version v1.5.6. Interact with the network for as many blocks as needed. When you want to stage the upgrade to 2.0.0, run the command in step 4.

4. Activate `nctl-*` and `casper-client`

```
source nctl-activate.sh casper-nctl-staging
```

5. Stage the upgrade to 2.0.0:

```
nctl-assets-upgrade-from-stage
```

The output of this command tells you in which era the upgrade will take place. For example:

```
2024-07-03T08:15:30.729907 [INFO] [1366] NCTL :: stage 1 :: upgrade assets -> 2_0_0 @ era 32
```

You can check the upgrade has been staged correctly getting the status of a node:

```
nctl-view-node-status node=1
```

In the output, you'll see the activation point (it may take some seconds to appear after the upgrade command):

```
  "next_upgrade": {
    "activation_point": 32,
    "protocol_version": "2.0.0"
  },
```

