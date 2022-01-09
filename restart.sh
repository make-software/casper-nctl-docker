#!/bin/bash
source $NCTL/activate
alias casper-client=/home/casper/casper-node/target/release/casper-client
source $NCTL/sh/assets/teardown.sh
source $NCTL/sh/assets/setup.sh
source $NCTL/sh/node/start.sh
tail -f /home/casper/casper-node/utils/nctl/assets/net-1/nodes/node-1/logs/stderr.log 
