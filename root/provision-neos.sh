#!/usr/bin/with-contenv /bin/bash
set -ex

# Provision conainer at first run
if [ -f /data/transfer/composer.json ] || [ -z "$REPOSITORY_URL" ]
then
	echo "Do nothing, initial provisioning done"
else
    # Make sure to init xdebug, not to slow-down composer
    /etc/cont-init.d/00-init-xdebug

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
