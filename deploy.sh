#!/bin/bash

set -ex

docker tag "$1" "$1:$2"
docker push "$1:$2"
