FROM ubuntu:focal

# DEBIAN_FRONTEND required for tzdata dependency install
RUN apt-get update \
      && DEBIAN_FRONTEND="noninteractive" \
      apt-get install -y sudo tzdata curl gnupg gcc git ca-certificates \
              protobuf-compiler libprotobuf-dev supervisor jq \
              pkg-config libssl-dev make build-essential gettext-base lsof \
      && rm -rf /var/lib/apt/lists/*

SHELL ["/bin/bash", "-c"] 

# install cmake
RUN curl -Ls https://github.com/Kitware/CMake/releases/download/v3.17.3/cmake-3.17.3-Linux-x86_64.tar.gz | sudo tar -C /usr/local --strip-components=1 -xz

# install rust nigthly and rustup
RUN curl -f -L https://static.rust-lang.org/rustup.sh -O \
    && sh rustup.sh -y 
ENV PATH="$PATH:/root/.cargo/bin"

RUN cargo install --git https://github.com/paritytech/cachepot

# set few environment variables needed for the nctl build scripts
ENV NCTL="/root/casper-node/utils/nctl"
ENV NCTL_CASPER_HOME="/root/casper-node"
ENV NCTL_CASPER_NODE_LAUNCHER_HOME="/root/casper-node-launcher"
ENV NCTL_CASPER_CLIENT_HOME="/root/casper-client-rs"
ENV NCTL_CASPER_SIDECAR_HOME="/root/casper-sidecar"
ENV NCTL_COMPILE_TARGET="release"

# copy the casper-node repo from host machine and build binaries
RUN git clone -b feat-2.0 https://github.com/casper-network/casper-node.git /root/casper-node
RUN source ~/casper-node/ci/nctl_compile.sh 
RUN source ~/casper-nctl/sh/assets/compile_sidecar.sh
RUN source ~/casper-nctl/sh/assets/compile_node_launcher.sh
RUN source ~/casper-nctl/sh/assets/compile_client.sh

# save built binaries and resources folders to a temp folder to 
# copy them back in the second stage
COPY ./save-builds-n-resources.sh .
RUN chmod +x save-builds-n-resources.sh
RUN ./save-builds-n-resources.sh

## Second stage. Leave behind build tools and:
## (1) reinstall needed dependencies to run NCTL nodes.
## (2) copy binaries built in first stage.
## (3) add scripts and predefined accounts.
##
FROM ubuntu:focal

RUN apt-get update \
      && apt-get install -y --no-install-recommends sudo curl git ca-certificates jq supervisor lsof python3-pip \
      && apt-get clean && \
      rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN useradd -ms /bin/bash casper && echo "casper:casper" | chpasswd && adduser casper sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER casper

SHELL ["/bin/bash", "-c"]

WORKDIR /home/casper

RUN python3 -m pip install toml

COPY --from=0 --chown=casper:casper /root/bucket ./bucket
COPY --from=0 --chown=casper:casper /root/casper-nctl ./casper-nctl
COPY --chown=casper:casper ./copy-builds-n-resources.sh .
RUN chmod +x ./copy-builds-n-resources.sh && \
    ./copy-builds-n-resources.sh && \
    rm ./copy-builds-n-resources.sh && \
    rm -r ./bucket

ENV NCTL="/home/casper/casper-nctl"
ENV NCTL_CASPER_HOME="/home/casper/casper-node"
ENV NCTL_CASPER_NODE_LAUNCHER_HOME="/home/casper/casper-node-launcher"
ENV NCTL_CASPER_CLIENT_HOME="/home/casper/casper-client-rs"
ENV NCTL_CASPER_SIDECAR_HOME="/home/casper/casper-sidecar"
RUN echo "source casper-nctl/activate" >> .bashrc
RUN echo "alias casper-client=/home/casper/casper-client-rs/target/release/casper-client" >> .bashrc

COPY --chown=casper:casper ./restart.sh .
COPY --chown=casper:casper ./net-1-predefined-accounts.tar.gz .

EXPOSE 11101-11105 14101-14105 18101-18105

HEALTHCHECK CMD /home/casper/casper-client-rs/target/release/casper-client get-block --node-address http://localhost:11101/rpc | jq 'has("result")'

CMD ["/bin/bash", "-c", "source /home/casper/restart.sh"]
#CMD ["tail", "-f", "/dev/null"]
