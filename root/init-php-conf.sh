#!/usr/bin/with-contenv /bin/bash

set -e

echo "date.timezone=${PHP_TIMEZONE:-UTC}" > $PHP_INI_DIR/conf.d/date_timezone.ini
echo "memory_limit=${PHP_MEMORY_LIMIT:-4096M}" > $PHP_INI_DIR/conf.d/memory_limit.ini
echo "upload_max_filesize=${PHP_UPLOAD_MAX_FILESIZE:-1024M}" > $PHP_INI_DIR/conf.d/upload_max_filesize.ini
echo "post_max_size=${PHP_UPLOAD_MAX_FILESIZE:-1024M}" > $PHP_INI_DIR/conf.d/post_max_size.ini
echo "allow_url_include=${PHP_ALLOW_URL_INCLUDE:-1}" > $PHP_INI_DIR/conf.d/allow_url_include.ini
echo "max_execution_time=${PHP_MAX_EXECUTION_TIME:-240}" > $PHP_INI_DIR/conf.d/max_execution_time.ini
echo "max_input_vars=${PHP_MAX_INPUT_VARS:-1500}" > $PHP_INI_DIR/conf.d/max_input_vars.ini
rm -rf /var/cache/apk/*
apk update && apk add tzdata
cp /usr/share/zoneinfo/${PHP_TIMEZONE:-UTC} /etc/localtime
apk del tzdata
rm -rf /var/cache/apk/*
