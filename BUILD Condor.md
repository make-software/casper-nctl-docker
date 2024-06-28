## Build NCTL Docker image with Condor

Steps:

1. Clone the casper-nctl-docker image and checkout `feat-2.0` branch

```
git clone https://github.com/make-software/casper-nctl-docker.git
cd casper-nctl-docker
git checkout feat-2.0
````

2. Clone the casper-node repo (inside casper-nctl-docker folder) and checkout `feat-2.0` branch

```
git clone https://github.com/casper-network/casper-node.git
git checkout feat-2.0
```

3. Modify casper-node/ci/ci.json file to set the right branches for other repos used during build.

```
{
    "external_deps": {
        "casper-client-rs": {
            "github_repo_url": "https://github.com/casper-ecosystem/casper-client-rs.git",
            "branch": "feat-track-node-2.0"
        },
        "casper-node-launcher": {
            "github_repo_url": "https://github.com/casper-network/casper-node-launcher.git",
            "branch": "main"
        },
        "casper-sidecar": {
            "github_repo_url": "https://github.com/casper-network/casper-sidecar",
            "branch": "feat-2.0"
        },
        "casper-nctl": {
            "github_repo_url": "https://github.com/casper-network/casper-nctl",
            "branch": "dev"
        }
    },
    "nctl_upgrade_tests": {
        "protocol_1": "1.4.13"
    }
}
```

4. Build the image

```
docker build -f casper-nctl-condor.Dockerfile -t casper-nctl:rc3 .
```