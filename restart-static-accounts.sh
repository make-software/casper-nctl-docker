#!/bin/bash
source $NCTL/activate
alias casper-client=/home/casper/casper-node/target/release/casper-client
source $NCTL/sh/assets/teardown.sh
source $NCTL/sh/assets/setup.sh
tar -zxvf net-1-static-accounts.tar.gz -C /home/casper/casper-node/utils/nctl/assets/net-1/
source $NCTL/sh/node/start.sh
tail -f /home/casper/casper-node/utils/nctl/assets/net-1/nodes/node-1/logs/stderr.log 
