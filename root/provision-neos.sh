#!/usr/bin/env bash
set -ex

# Provision conainer at first run
if [ -f /data/www/composer.json ] || [ -z "$REPOSITORY_URL" ]
then
	echo "Do nothing, initial provisioning done"
else
    # Make sure to init xdebug, not to slow-down composer
    /init-xdebug.sh

    # Layout default directory structure
    mkdir -p /data/www
    mkdir -p /data/logs
    mkdir -p /data/tmp/nginx

    ###
    # Install into /data/www
    ###
    cd /data/www
    git clone -b $VERSION $REPOSITORY_URL .
    composer install --prefer-source

    # Apply beard patches
    if [ -f /data/www/beard.json ]
        then
            beard patch
    fi

    ###
    # Copy DB connection settings
    ###
    mkdir -p /data/www/Configuration
    cp /Settings.yaml /data/www/Configuration/

    # Set permissions
    chown www-data:www-data -R /tmp/
	chown www-data:www-data -R /data/
	chmod g+rwx -R /data/

	# Set ssh permissions
	if [ -z "/data/.ssh/authorized_keys" ]
		then
			chown www-data:www-data -R /data/.ssh
			chmod go-w /data/
			chmod 700 /data/.ssh
			chmod 600 /data/.ssh/authorized_keys
	fi
fi
