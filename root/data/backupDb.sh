#!/usr/bin/with-contenv bash
set -ex

mysqldump -u $DB_USER -p$DB_PASS -h $DB_HOST $DB_DATABASE > /data/www/Data/Persistent/db.sql
if [ -z "$AWS_BACKUP_ARN" ]
  then
    echo "AWS_BACKUP_ARN not set, skipping"
  else
    if [ -z "$AWS_ENDPOINT" ]
      then
        aws s3 cp /data/www/Data/Persistent/db.sql ${AWS_BACKUP_ARN}db.sql
      else
        aws s3 --endpoint-url=${AWS_ENDPOINT} cp /data/www/Data/Persistent/db.sql ${AWS_BACKUP_ARN}db.sql
    fi
fi
