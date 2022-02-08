FROM casper-nctl:base

LABEL maintainer="MAKE Technology LLC <hello@make.services>"
LABEL description="Container with Casper NCTL running as a service."

USER casper
SHELL ["/bin/bash", "-c"] 
WORKDIR /home/casper

ENV NCTL="/home/casper/casper-node/utils/nctl"
ENV NCTL_CASPER_HOME="/home/casper/casper-node"
ENV NCTL_CASPER_NODE_LAUNCHER_HOME="/home/casper/casper-node-launcher"
RUN echo "source casper-node/utils/nctl/activate" >> .bashrc
RUN echo "alias casper-client=/home/casper/casper-node/target/release/casper-client" >> .bashrc

COPY --chown=casper:casper ./restart.sh .
COPY --chown=casper:casper ./restart-with-predefined-accounts.sh .
COPY --chown=casper:casper ./net-1-predefined-accounts.tar.gz .

EXPOSE 11101-11105 14101-14105 18101-18105

HEALTHCHECK CMD casper-client get-block --node-address http://localhost:11101/rpc | jq 'has("result")'

CMD ["/bin/bash", "-c", "source /home/casper/restart.sh"]
