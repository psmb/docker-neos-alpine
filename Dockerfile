# Inspired by https://gitlab.ttree.ch/ttree/flowapp/blob/master/7.1/Dockerfile

FROM php:7.1-fpm-alpine

MAINTAINER Dmitri Pisarev <dimaip@gmail.com>

ARG PHP_REDIS_VERION="3.1.1"
ARG PHP_YAML_VERION="2.0.0"

ENV FLOW_CONTEXT Development
ENV FLOW_PATH_TEMPORARY_BASE /tmp
ENV FLOW_REWRITEURLS 1

ENV COMPOSER_VERSION 1.2.2
ENV COMPOSER_HOME /composer
ENV PATH /composer/vendor/bin:$PATH
ENV COMPOSER_ALLOW_SUPERUSER 1

# Basic build-time metadata as defined at http://label-schema.org
LABEL org.label-schema.docker.dockerfile="/Dockerfile" \
      org.label-schema.license="MIT" \
      org.label-schema.name="Neos Bare Docker Image" \
      org.label-schema.url="https://github.com/psmb/docker-neos-bare" \
      org.label-schema.vcs-url="https://github.com/psmb/docker-neos-bare" \
      org.label-schema.vcs-type="Git"

RUN set -x \
    && mkdir -p /data/logs \
    && mkdir -p /data/tmp/nginx \
    && apk update \
	&& apk add --no-cache tar curl openssl sed bash libbz2 libxslt bzip2 libmcrypt libuuid icu-dev gettext-dev curl-dev libxml2-dev openldap-dev libpng libjpeg-turbo yaml libuuid pcre-dev mysql-client git openssh-client nginx \
    && apk add --no-cache --virtual .phpize-deps $PHPIZE_DEPS libxslt-dev bzip2-dev libmcrypt-dev imagemagick-dev libtool freetype-dev libpng-dev libjpeg-turbo-dev yaml-dev \
    && docker-php-ext-configure gd \
      --with-gd \
      --with-freetype-dir=/usr/include/ \
      --with-png-dir=/usr/include/ \
      --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install \
      gd \
      pdo \
      pdo_mysql \
      mbstring \
      opcache \
      intl \
      exif \
      gettext \
      curl \
      json \
      bcmath \
      mcrypt \
      zip \
      bz2 \
      tokenizer \
      fileinfo \
      pcntl \
      xsl \
      xml \
      soap \
      sockets \
    && docker-php-ext-configure ldap --with-libdir=lib/ \
    && docker-php-ext-install ldap \
    && pecl install imagick redis-${PHP_REDIS_VERION} yaml-${PHP_YAML_VERION} uuid \
    && docker-php-ext-enable imagick \
    && docker-php-ext-enable redis \
    && docker-php-ext-enable yaml \
    && docker-php-ext-enable uuid \
    && apk add --virtual .imagick-runtime-deps imagemagick \
    && apk del .phpize-deps \
    && curl -o /tmp/composer-setup.php https://getcomposer.org/installer \
    && php /tmp/composer-setup.php --no-ansi --install-dir=/usr/local/bin --filename=composer --version=${COMPOSER_VERSION} && rm -rf /tmp/composer-setup.php \
    && curl -s http://beard.famelo.com/ > /usr/local/bin/beard \
    && chmod +x /usr/local/bin/beard \
    && git config --global user.email "server@server.com" \
    && git config --global user.name "Server"

# Copy configuration
COPY root /

# Configure PHP
RUN echo "date.timezone=${PHP_TIMEZONE:-UTC}" > $PHP_INI_DIR/conf.d/date_timezone.ini \
    && echo "memory_limit=${PHP_MEMORY_LIMIT:-2048M}" > $PHP_INI_DIR/conf.d/memory_limit.ini \
    && echo "upload_max_filesize=${PHP_UPLOAD_MAX_FILESIZE:-512M}" > $PHP_INI_DIR/conf.d/upload_max_filesize.ini \
    && echo "post_max_size=${PHP_UPLOAD_MAX_FILESIZE:-512M}" > $PHP_INI_DIR/conf.d/post_max_size.ini \
    && echo "allow_url_include=${PHP_ALLOW_URL_INCLUDE:-1}" > $PHP_INI_DIR/conf.d/allow_url_include.ini \
    && echo "max_execution_time=${PHP_MAX_EXECUTION_TIME:-240}" > $PHP_INI_DIR/conf.d/max_execution_time.ini \
    && echo "max_input_vars=${PHP_MAX_INPUT_VARS:-1500}" > $PHP_INI_DIR/conf.d/max_input_vars.ini \
	&& sed -i -e "s#/home/www-data:/bin/false#/data:/bin/bash#" /etc/passwd && rm -Rf /home/www-data \
    && sed -i -e "s#listen = \[::\]:9000#listen = /var/run/php-fpm.sock#" /usr/local/etc/php-fpm.d/zz-docker.conf \
    && echo "listen.owner = www-data" >> /usr/local/etc/php-fpm.d/zz-docker.conf \
    && echo "listen.group = www-data" >> /usr/local/etc/php-fpm.d/zz-docker.conf \
    && echo "listen.mode = 0660" >> /usr/local/etc/php-fpm.d/zz-docker.conf \
	&& chmod +x /entrypoint.sh

# Expose ports
EXPOSE 80

# Define working directory
WORKDIR /data

# Define entrypoint and command
ENTRYPOINT ["/bin/bash", "-c", "/entrypoint.sh"]
