#!/bin/sh

version=$(curl -s https://api.github.com/repos/praekeltfoundation/rapidpro/tags  | jq -r '.[0].name')

echo "$version.local" > image-params/tag
