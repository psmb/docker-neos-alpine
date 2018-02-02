#!/usr/bin/with-contenv bash
set -ex

echo "This script will overwrite the DB with the one from backups! Use with care!"

if [ -z "$AWS_BACKUP_ARN" ]
then
  echo "AWS_BACKUP_ARN not set"
else
  if [ -z "$AWS_ENDPOINT" ]
    then
      aws s3 cp ${AWS_BACKUP_ARN}db.sql /data/www/Data/Persistent/db.sql
    else
      aws s3 --endpoint-url=$AWS_ENDPOINT cp ${AWS_BACKUP_ARN}db.sql /data/www/Data/Persistent/db.sql
  fi
  mysql -u $DB_USER -p$DB_PASS -h $DB_HOST $DB_DATABASE < /data/www/Data/Persistent/db.sql
  echo "Downloaded DB dump from AWS and imported"
fi
