#!/bin/sh

version=$(curl -s https://api.github.com/repos/praekeltfoundation/rapidpro/tags  | jq -r '.[0].name')
suffix=$version_suffix

echo "$version.$suffix" > image-params/tag
