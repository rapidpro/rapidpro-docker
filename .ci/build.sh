#!/bin/sh

opkg-install curl

curl -o /usr/bin/jq http://stedolan.github.io/jq/download/linux64/jq && chmod +x /usr/bin/jq

version=$(curl -s https://api.github.com/repos/praekeltfoundation/rapidpro/tags  | jq -r '.[0].name')

VERSION_SUFFIX=${VERSION_SUFFIX+.$VERSION_SUFFIX}

echo "$version$VERSION_SUFFIX" > image-params/tag
