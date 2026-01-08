#!/bin/sh 

SCRIPT_DIR="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

SERVER_ADDRESS=${1:-localhost}

CONFIG_DIR=${2:-$SCRIPT_DIR/../config}

#Replace server address in JS configuration files
$SCRIPT_DIR/replace.server.address.sh $CONFIG_DIR/configs/ $SERVER_ADDRESS localhost

echo Mono tenant configuration is done.
