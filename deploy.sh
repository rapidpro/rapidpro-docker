#!/bin/bash

set -ex

docker tag "$image:$version"
docker push "$image:$version"
