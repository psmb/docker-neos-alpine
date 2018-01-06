#!/usr/bin/env bash
set -ex

mysqldump -u $DB_USER -p$DB_PASS -h $DB_HOST $DB_DATABASE > /data/shared/Data/Persistent/db.sql
if [ -z "$AWS_RESOURCES_ARN" ]
  then
    echo "AWS_RESOURCES_ARN not set, skipping"
  else
    aws s3 cp /data/shared/Data/Persistent/db.sql ${AWS_RESOURCES_ARN}db.sql
fi
