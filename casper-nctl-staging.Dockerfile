FROM makesoftware/casper-nctl:v158 AS v158

FROM makesoftware/casper-nctl:v200-rc4

WORKDIR /home/casper
RUN mkdir casper-node-v158
COPY --from=v158 --chown=casper:casper /home/casper/casper-node/target /home/casper/casper-node-v158/target
COPY --from=v158 --chown=casper:casper /home/casper/casper-node/resources /home/casper/casper-node-v158/resources
RUN mkdir casper-client-rs-v158
COPY --from=v158 --chown=casper:casper /home/casper/casper-client-rs/target /home/casper/casper-client-rs-v158/target
COPY --from=v158 --chown=casper:casper /home/casper/casper-client-rs/resources /home/casper/casper-client-rs-v158/resources
COPY --chown=casper:casper ./staging-condor/net-1-predefined-accounts-v158.tar.gz /home/casper/net-1-predefined-accounts.tar.gz
COPY --chown=casper:casper ./staging-condor/restart.sh .
COPY --chown=casper:casper ./staging-condor/settings-condor-staging.txt ./casper-nctl/sh/staging/settings-condor-staging.txt
COPY --chown=casper:casper ./staging-condor/setup_condor_staging.sh ./casper-nctl/sh/staging/setup_condor_staging.sh
COPY --chown=casper:casper ./staging-condor/setup_from_stage.sh ./casper-nctl/sh/assets/setup_from_stage.sh

EXPOSE 11101-11105 14101-14105 18101-18105 25101-25105

CMD ["/bin/bash", "-c", "source /home/casper/restart.sh"]