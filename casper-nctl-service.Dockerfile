FROM casper-nctl:base

LABEL maintainer="MAKE Technology LLC <hello@make.services>"
LABEL description="Container with Casper NCTL running as a service."

USER casper
SHELL ["/bin/bash", "-c"] 
WORKDIR /home/casper

ENV NCTL="/home/casper/casper-node/utils/nctl"
ENV NCTL_CASPER_HOME="/home/casper/casper-node"
RUN echo "source casper-node/utils/nctl/activate" >> .bashrc

COPY --chown=casper:casper ./restart.sh .

EXPOSE 11101-11105 14101-14105 18101-18105

HEALTHCHECK CMD casper-client get-block --node-address http://localhost:11101/rpc | jq 'has("result")'

CMD ["/bin/bash", "-c", "source /home/casper/restart.sh"]
