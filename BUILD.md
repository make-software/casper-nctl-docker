# Casper NCTL - Docker Container

## Build the Docker image locally

To build the NCTL docker image run `docker build` as follows:

```bash
docker build -f casper-nctl.Dockerfile --build-arg NODE_GITBRANCH=release-1.5.6 --build-arg CLIENT_GITBRANCH=release-2.0.0 -t casper-nctl:v156 .
```

The argument `NODE_GITBRANCH` indicates which branch from the `casper-node` repository docker 
will download and build.

The argument `CLIENT_GITBRANCH` indicates which branch from the `casper-client-rs` repository docker 
will download and build.

In the command above, the image is tagged as v156, which is the latest `casper-node` version 
at the moment of writing these instructions. To keep other scripts independent of the version, 
tag the image also as `latest` once the first build completes.

```bash
docker tag casper-nctl:v156 casper-nctl:latest
```

## Test the docker image

You can test the new image with `pytest`. First, install it with `pip`:

```bash
python -m pip install --upgrade pip
pip install pytest testinfra
```

Then, run `pytest` indicating the name of the docker image to test:

```
pytest --image casper-nctl:v156
```

## Configure Docker Hub Automated Builds

Docker Hub can automatically build and push a new image when a specific event happens in 
the source code repository (e.g. a new commit in a branch or a new tag).

As an example, to build automatically an image when there is a new version tag applied to 
the source code repository,
configure a Build Rule in Docker Hub as follows:

| Field               | Value                           |
|---------------------|:--------------------------------|
| Source Type         | Tag                             |
| Source              | `/v([0-9.]+)$/`                 |
| Docker Tag          | `v{\1}`                         |
| Dockerfile location | `./casper-nctl.Dockerfile`      |
| Build context       | `/`                             |

More information: [Set up Automated Builds](https://docs.docker.com/docker-hub/builds/) 