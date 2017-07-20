#!/bin/sh

version=$(curl -s https://api.github.com/repos/praekeltfoundation/rapidpro/tags  | jq -r '.[0].name')
postfix=${1:-local}

echo "$version.$postfix" > image-params/tag
