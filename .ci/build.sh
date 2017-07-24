#!/bin/sh

apk add --no-cache curl jq

version=$(curl -s https://api.github.com/repos/praekeltfoundation/rapidpro/tags  | jq -r '.[0].name')

VERSION_SUFFIX=${VERSION_SUFFIX+.$VERSION_SUFFIX}

echo "$version$VERSION_SUFFIX" > image-params/tag
echo "latest$VERSION_SUFFIX" > image-params/additional_tags

echo '{"RAPIDPRO_VERSION":"'$version'","RAPIDPRO_REPO":"praekeltfoundation/rapidpro"}' > image-params/build-args.json

echo "Building RapidPro: $version"
