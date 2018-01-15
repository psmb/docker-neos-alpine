#!/usr/bin/env bash

#
# Source: https://github.com/rtlong, https://gist.github.com/rtlong/6790049
# Usage: /github-keys.sh | bash -s <github username>
#
IFS="$(printf '\n\t')"

user=$1
api_response=$(curl -sSLi https://api.github.com/users/$user/keys)
remaining_rate_limit=$(echo "$api_response" | grep -o -E "X-RateLimit-Remaining:\s[0-9]+" | awk '{print $2}')
keys=$(echo $api_response | grep -o -E 'ssh-\w+\s+[^\"]+')

if [ $remaining_rate_limit -eq 0 ]; then
  echo "WARNING: Github API rate limit exceeded. No key(s) added to `whoami` account."
else
  if [ -z "$keys" ]; then
    echo "WARNING: GitHub doesn't have any keys for '$user' user."
  else
    echo "Importing $user's GitHub pub key(s) to `whoami` account..."

    [ -d ~/.ssh ] || mkdir ~/.ssh
    [ -f ~/.ssh/authorized_keys ] || touch ~/.ssh/authorized_keys

    for key in $keys; do
      echo "Imported GitHub $user key: $key"
      grep -q "$key" ~/.ssh/authorized_keys || echo "$key ${user}@github" >> ~/.ssh/authorized_keys
    done
  fi
fi