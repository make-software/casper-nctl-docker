#!/bin/bash

## Get path to chainspec and config files from ENV variables or use the default ones
##
PATH_TO_CHAINSPEC=${PATH_TO_CHAINSPEC:-"${NCTL_CASPER_HOME}/resources/local/chainspec.toml.in"}
PATH_TO_CONFIG_TOML=${PATH_TO_CONFIG_TOML:-"${NCTL_CASPER_HOME}/resources/local/config.toml"}

source $NCTL/sh/staging/setup_condor_staging.sh stage=1; \
source $NCTL/sh/assets/setup_from_stage.sh stage=1; \
if [ "$PREDEFINED_ACCOUNTS" = "true" ]; then
    tar -zxvf net-1-predefined-accounts.tar.gz -C $NCTL/assets/net-1/;
fi
source $NCTL/sh/node/start.sh; \
alias casper-client=~/casper-nctl/assets/net-1/bin/casper-client; \
tail -f $NCTL/assets/net-1/nodes/node-1/logs/stderr.log
