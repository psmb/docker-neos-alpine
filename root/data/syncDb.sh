#!/usr/bin/env bash
set -ex

echo "This script will overwrite the DB with the one from backups! Use with care!"

if [ -z "$AWS_RESOURCES_ARN"]
then
  echo "AWS_RESOURCES_ARN not set"
else
  aws s3 cp ${AWS_RESOURCES_ARN}db.sql /data/shared/Data/Persistent/db.sql
  mysql -u $DB_USER -p$DB_PASS -h $DB_HOST $DB_DATABASE < /data/shared/Data/Persistent/db.sql
  echo "Downloaded DB dump from AWS and imported"
fi
