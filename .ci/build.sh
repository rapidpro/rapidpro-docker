#!/bin/sh

version=$(curl -s https://api.github.com/repos/praekeltfoundation/rapidpro/tags  | jq -r '.[0].name')
suffix=${1:-local}

echo "$version.$suffix" > image-params/tag
