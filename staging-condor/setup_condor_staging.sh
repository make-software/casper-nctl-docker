#!/usr/bin/env bash

source "$NCTL/sh/utils/main.sh"

#######################################
# Stages assets.
# Arguments:
#   Path to stage node source code folder.
#   Path to stage client source code folder.
#   Path to stage folder.
#######################################
function set_stage_files_from_repo()
{
    local PATH_TO_NODE_SOURCE=${1}
    local PATH_TO_CLIENT_SOURCE=${2}
    local PATH_TO_SIDECAR_SOURCE=${3}
    local PATH_TO_STAGE=${4}

    # Stage binaries.
    if [ "$NCTL_COMPILE_TARGET" = "debug" ]; then
        cp "$PATH_TO_CLIENT_SOURCE/target/debug/casper-client" \
           "$PATH_TO_STAGE"
        cp "$PATH_TO_NODE_SOURCE/target/debug/casper-node" \
           "$PATH_TO_STAGE"
        cp "$NCTL_CASPER_NODE_LAUNCHER_HOME/target/debug/casper-node-launcher" \
           "$PATH_TO_STAGE"
        cp "$PATH_TO_SIDECAR_SOURCE/target/debug/casper-sidecar" \
           "$PATH_TO_STAGE"
    else
        cp "$PATH_TO_CLIENT_SOURCE/target/release/casper-client" \
           "$PATH_TO_STAGE"
        cp "$PATH_TO_NODE_SOURCE/target/release/casper-node" \
           "$PATH_TO_STAGE"
        cp "$NCTL_CASPER_NODE_LAUNCHER_HOME/target/release/casper-node-launcher" \
           "$PATH_TO_STAGE"
        cp "$PATH_TO_SIDECAR_SOURCE/target/release/casper-sidecar" \
           "$PATH_TO_STAGE"
    fi

    # Stage wasm.
    for CONTRACT in "${NCTL_CONTRACTS_CLIENT_AUCTION[@]}"
    do
        cp "$PATH_TO_NODE_SOURCE/target/wasm32-unknown-unknown/release/$CONTRACT" \
           "$PATH_TO_STAGE"
    done
    for CONTRACT in "${NCTL_CONTRACTS_CLIENT_SHARED[@]}"
    do
        cp "$PATH_TO_NODE_SOURCE/target/wasm32-unknown-unknown/release/$CONTRACT" \
           "$PATH_TO_STAGE"
    done
    for CONTRACT in "${NCTL_CONTRACTS_CLIENT_TRANSFERS[@]}"
    do
        cp "$PATH_TO_NODE_SOURCE/target/wasm32-unknown-unknown/release/$CONTRACT" \
           "$PATH_TO_STAGE"
    done

    # Stage chainspec.
    cp "$PATH_TO_NODE_SOURCE/resources/local/chainspec.toml.in" \
       "$PATH_TO_STAGE/chainspec.toml"

    # Stage node config.
    cp "$PATH_TO_NODE_SOURCE/resources/local/config.toml" \
       "$PATH_TO_STAGE"

    # Stage sidecar config.
    cp "$PATH_TO_SIDECAR_SOURCE/resources/example_configs/default_rpc_only_config.toml" \
       "$PATH_TO_STAGE/sidecar.toml"
}

#######################################
# Prepares assets for staging.
# Arguments:
#   Scenario ordinal identifier.
#######################################
function _main()
{
    local STAGE_ID=${1}
    local PATH_TO_TEMPLATE
    local PATH_TO_STAGE
    local PATH_TO_STAGE_SETTINGS
    local PROTOCOL_VERSION
    local ASSET_SOURCE
    local STAGE_TARGET
    local IFS=':'

    PATH_TO_TEMPLATE="$NCTL/sh/staging/settings-condor-staging.txt"
    PATH_TO_STAGE="$(get_path_to_stage "$STAGE_ID")"
    PATH_TO_STAGE_SETTINGS="$PATH_TO_STAGE/settings.sh"

    # Set directory.
    if [ -d "$PATH_TO_STAGE" ]; then
        rm -rf "$PATH_TO_STAGE"
    fi
    mkdir -p "$PATH_TO_STAGE"

    # Set settings.
    cp -r "$PATH_TO_TEMPLATE" "$PATH_TO_STAGE_SETTINGS"

    # Import stage settings.
    source "$(get_path_to_stage_settings "$STAGE_ID")"    

    # For each protocol version build a stage.
    for STAGE_TARGET in "${NCTL_STAGE_TARGETS[@]}"
    do
        read -ra STAGE_TARGET <<< "$STAGE_TARGET"
        PROTOCOL_VERSION="${STAGE_TARGET[0]}"
        STAGE_NCTL_CASPER_HOME="${STAGE_TARGET[1]}"
        STAGE_NCTL_CASPER_CLIENT_HOME="${STAGE_TARGET[2]}"

        log "setting stage $STAGE_ID from $STAGE_SOURCE @ $PROTOCOL_VERSION -> STARTS"

        PATH_TO_STAGE="$(get_path_to_stage "$STAGE_ID")/$PROTOCOL_VERSION"
        if [ ! -d "$PATH_TO_STAGE" ]; then
            mkdir -p "$PATH_TO_STAGE"
        fi

        set_stage_files_from_repo "$STAGE_NCTL_CASPER_HOME" "$STAGE_NCTL_CASPER_CLIENT_HOME" "$NCTL_CASPER_SIDECAR_HOME" "$PATH_TO_STAGE"

        log "setting stage $STAGE_ID from $STAGE_SOURCE @ $PROTOCOL_VERSION -> COMPLETE"                                           
    done
}

# ----------------------------------------------------------------
# ENTRY POINT
# ----------------------------------------------------------------

unset STAGE_ID

for ARGUMENT in "$@"
do
    KEY=$(echo "$ARGUMENT" | cut -f1 -d=)
    VALUE=$(echo "$ARGUMENT" | cut -f2 -d=)
    case "$KEY" in
        stage) STAGE_ID=${VALUE} ;;
        *)
    esac
done

STAGE_ID="${STAGE_ID:-1}"

_main "$STAGE_ID"

