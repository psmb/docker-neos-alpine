#!/usr/bin/env bash
set -ex

# Provision conainer at first run
if [ -f /data/transfer/composer.json ] || [ -z "$REPOSITORY_URL" ]
then
	echo "Do nothing, initial provisioning done"
else
    # Make sure to init xdebug, not to slow-down composer
    /init-xdebug.sh

    mkdir -p /data/transfer
    mkdir -p /data/releases
    mkdir -p /data/shared/Data/Logs
    mkdir -p /data/shared/Data/Persistent
    mkdir -p /data/shared/Configuration
    mkdir -p /data/shared/Web/_Resources

    ###
    # Install into /data/transfer and link shared
    # Needed to serve as a deployment target
    ###
    cd /data/transfer
    git clone -b $VERSION $REPOSITORY_URL .
    composer install --prefer-source

    if [ -f /data/transfer/beard.json ]
        then
            beard patch
    fi
fi
