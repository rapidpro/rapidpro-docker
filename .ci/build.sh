#!/bin/sh

apk install curl jq

version=$(curl -s https://api.github.com/repos/praekeltfoundation/rapidpro/tags  | jq -r '.[0].name')

VERSION_SUFFIX=${VERSION_SUFFIX+.$VERSION_SUFFIX}

echo "$version$VERSION_SUFFIX" > image-params/tag
