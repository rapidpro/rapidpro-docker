#!/bin/sh

apt-get -qq update
apt-get -qq -y install curl

curl -o /usr/bin/jq http://stedolan.github.io/jq/download/linux64/jq && chmod +x /usr/bin/jq

version=$(curl -s https://api.github.com/repos/praekeltfoundation/rapidpro/tags  | jq -r '.[0].name')

echo "$version.$VERSION_SUFFIX" > image-params/tag
