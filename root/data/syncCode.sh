#!/usr/bin/with-contenv bash
set -ex

echo "This script should never be used in production! Use a proper deployment script instead!"

cd /data/www

git pull
if [ -f /data/www/beard.json ]
  then
    beard reset
    composer install --prefer-source
    beard patch
  else
    composer install --prefer-source
fi
rm -rf Data/Temporary
./flow doctrine:migrate
./flow resource:publish --collection static
