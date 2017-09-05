# [dimaip/docker-neos-apline](https://hub.docker.com/r/dimaip/docker-neos-alpine/) &middot; [![](https://images.microbadger.com/badges/image/dimaip/docker-neos-alpine.svg)](https://microbadger.com/images/dimaip/docker-neos-alpine "Neos Alpine") [![](https://images.microbadger.com/badges/version/dimaip/docker-neos-alpine.svg)](https://microbadger.com/images/dimaip/docker-neos-alpine "Neos Alpine") [![](https://circleci.com/gh/psmb/docker-neos-alpine.svg?style=shield)](https://circleci.com/gh/psmb/docker-neos-alpine/)

[**Image info**](https://microbadger.com/images/dimaip/docker-neos-alpine)

Opinionated [Neos CMS](https://neos.io) docker image based on **Alpine** linux with **nginx** + **php-fpm 7.1** + **s6** process manager, packing everything needed for development and production usage of Neos in under 100mb.

The image does a few things:
1. Automatically install and provision a Neos website, based on environment vars documented below
2. Pack a few useful things like XDEBUG integration, git, beard etc.
3. Be ready to be used in production and serve as a rolling deployment target with this Ansible script https://github.com/psmb/ansible-deploy

Check out [this shell script](https://github.com/psmb/docker-neos-alpine/blob/master/root/etc/cont-init.d/10-init-neos) to see what exactly this image can do for you.

## Usage

This image supports following environment variable for automatically configuring Neos at container startup:

| Docker env variable | Description |
|---------|-------------|
|REPOSITORY_URL|Link to Neos website distribution|
|VERSION|Git repository branch, commit SHA or release tag, defaults to `master`|
|SITE_PACKAGE|Neos website package with exported website data to be imported, optional|
|ADMIN_PASSWORD|If set, would create a Neos `admin` user with such password, optional|
|BASE_URI|If set, set the `baseUri` option in Settings.yaml, optional|
|XDEBUG_CONFIG|Pass xdebug config string, e.g. `idekey=PHPSTORM remote_enable=1`. If no config provided the Xdebug extension will be disabled (safe for production), off by default|
|IMPORT_GITHUB_PUB_KEYS|Will pull authorized keys allowed to connect to this image from your Github account(s).|
|DB_DATABASE|Database name, defaults to `db`|
|DB_HOST|Database host, defaults to `db`|
|DB_PASS|Database password, defaults to `pass`|
|DB_USER|Database user, defaults to `admin`|


In addition to these settings, if you place database sql dump at `Data/Persistent/db.sql`, it would automatically be imported on first container launch.
If `beard.json` file is present, your distribution will get [bearded](https://github.com/mneuhaus/Beard).

Example docker-compose.yml configuration:

```
...
web:
  image: dimaip/docker-neos-alpine:latest
  ports:
    - '80'
  links:
    - db:db
  volumes:
    - /data
  environment:
    REPOSITORY_URL: 'https://github.com/neos/neos-development-distribution'
    SITE_PACKAGE: 'Neos.Demo'
    VERSION: '2.0'
    ADMIN_PASSWORD: 'password'
    BASE_URI: 'https://demo.com/'
    IMPORT_GITHUB_PUB_KEYS: 'your-github-user-name'
    DB_HOST: db
    DB_DATABASE: 'neos-db'
    DB_USER: 'neos-user'
    DB_PASS: 'password'
db:
  image: mariadb:latest
  expose:
    - 3306
  volumes:
    - /data
  environment:
    MYSQL_DATABASE: 'neos-db'
    MYSQL_USER: 'neos-user'
    MYSQL_PASSWORD: 'password'
    MYSQL_RANDOM_ROOT_PASSWORD: 'yes'
```
