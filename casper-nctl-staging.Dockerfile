FROM makesoftware/casper-nctl:v156 as v156

FROM casper-nctl:rc3

WORKDIR /home/casper
RUN mkdir casper-node-v156
COPY --from=v156 --chown=casper:casper /home/casper/casper-node/target /home/casper/casper-node-v156/target
COPY --from=v156 --chown=casper:casper /home/casper/casper-node/resources /home/casper/casper-node-v156/resources
RUN mkdir casper-client-rs-v156
COPY --from=v156 --chown=casper:casper /home/casper/casper-client-rs/target /home/casper/casper-client-rs-v156/target
COPY --from=v156 --chown=casper:casper /home/casper/casper-client-rs/resources /home/casper/casper-client-rs-v156/resources
COPY --chown=casper:casper ./staging-condor/net-1-predefined-accounts-v156.tar.gz /home/casper/net-1-predefined-accounts.tar.gz
COPY --chown=casper:casper ./staging-condor/restart.sh .
COPY --chown=casper:casper ./staging-condor/settings-condor-staging.txt ./casper-nctl/sh/staging/settings-condor-staging.txt
COPY --chown=casper:casper ./staging-condor/setup_condor_staging.sh ./casper-nctl/sh/staging/setup_condor_staging.sh
COPY --chown=casper:casper ./staging-condor/setup_from_stage.sh ./casper-nctl/sh/assets/setup_from_stage.sh

EXPOSE 11101-11105 14101-14105 18101-18105 25101-25105

CMD ["/bin/bash", "-c", "source /home/casper/restart.sh"]