#!/bin/bash
set -ex

REPOSITORY_URL=${REPOSITORY_URL:=""}
BASE_URI=${BASE_URI:=${BASE_URI:=""}}

if [ -f /data/releases/current/composer.json ] || [ -z "$REPOSITORY_URL" ]
then
	echo "Do nothing, Neos distr is already there or REPOSITORY_URL env variable not set"
else
	mkdir -p /data/transfer
	mkdir -p /data/releases
	mkdir -p shared/Data/Logs
	mkdir -p shared/Data/Persistent
	mkdir -p shared/Configuration
	mkdir -p shared/Web/_Resources


	###
	# Generate Settings.yaml
	###
	SETTINGS_SOURCE_FILE="/Settings.yaml"
	SETTINGS_WITH_BASE_URI_SOURCE_FILE="/SettingsWithBaseUri.yaml"
	SETTINGS_TARGET_FILE="/data/shared/Configuration/Settings.yaml"
	# Only proceed if file DOES NOT exist...
	if [ -f $SETTINGS_TARGET_FILE ]
	then
		echo "Settings.yaml exists, no need to generate it"
	else
		mkdir -p $(dirname $SETTINGS_TARGET_FILE)
		if [[ -z "$BASE_URI" ]]; then
			cat $SETTINGS_SOURCE_FILE > $SETTINGS_TARGET_FILE
			echo "Configuration file $SETTINGS_TARGET_FILE created."
		else
			cat $SETTINGS_WITH_BASE_URI_SOURCE_FILE > $SETTINGS_TARGET_FILE
			sed -i -r "1,/baseUri:/s~baseUri: .+?~baseUri: '$BASE_URI'~g" $SETTINGS_TARGET_FILE
			echo "Configuration file $SETTINGS_TARGET_FILE with baseUri set to $BASE_URI created."
		fi
	fi


	###
	# Install into /data/transfer and link shared
	# Needed to serve as a deployment target
	###
	cd /data/transfer
	git clone $REPOSITORY_URL .
	composer install

	cp -RPp /data/transfer /data/releases/current
	rm -rf /data/releases/current/Web/_Resources
	ln -s /data/shared/Data/Logs /data/releases/current/Data/Logs
	ln -s /data/shared/Data/Persistent /data/releases/current/Data/Persistent
	ln -s /data/shared/Configuration/Settings.yaml /data/releases/current/Configuration/Settings.yaml
	ln -s /data/shared/Web/_Resources /data/releases/current/Web/_Resources


	###
	# Create and import DB
	###
	echo "CREATE DATABASE IF NOT EXISTS db" | mysql -u admin -ppass -h db
	if [ -f /data/shared/Data/Persistent/db.sql ]
		then
			mysql -u admin -ppass -h db db < /data/shared/Data/Persistent/db.sql
	fi


	###
	# Run final commands on the installed website
	###
	cd /data/releases/current

	if [ -f /data/releases/current/beard.json ]
		then
			beard patch
	fi

	./flow doctrine:migrate

	if [ -z "$SITE_PACKAGE" ]
		then
			echo "SITE_PACKAGE not set"
		else
			./flow site:import --package-key=$SITE_PACKAGE
	fi

	if [ -z "$ADMIN_PASSWORD" ]
		then
			echo "No ADMIN_PASSWORD set"
		else
			./flow user:create --roles='Administrator' --username='admin' --password=$ADMIN_PASSWORD --first-name='UpdateMe' --last-name='Now'
	fi

	./flow resource:publish

	chown www-data:www-data -R /data/
	chmod g+rwx -R /data/
	chown www-data:www-data -R /tmp/
fi










###
# Self-made supervisor. TODO: replace with smth real.
###
set +x
php-fpm -y /usr/local/etc/php-fpm.conf -R &
status=$?
if [ $status -ne 0 ]; then
	echo "Failed to start php-fpm: $status"
	exit $status
fi

nginx &
status=$?
if [ $status -ne 0 ]; then
	echo "Failed to start nginx: $status"
	exit $status
fi

# Naive check runs checks once a minute to see if either of the processes exited.
while /bin/true; do
	pidof nginx >/dev/null
	NGINX_RUNNING=$?

	pidof php-fpm >/dev/null
	FPM_RUNNING=$?

	if [ "$NGINX_RUNNING" -ne 0 -o "$FPM_RUNNING" -ne 0 ]; then
		echo "One of the processes has already exited."
		exit -1
	fi
	sleep 60
done
