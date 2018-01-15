#!/usr/bin/env bash
set -ex

echo "This script should never be used in production! Use a proper deployment script instead!"

cd /data/releases/current

git pull
if [ -f /data/releases/current/beard.json ]
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
