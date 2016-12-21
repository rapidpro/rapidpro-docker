#!/bin/bash

set -ex

echo "Tagging $1:$2"
docker tag "$1" "$1:$2"
echo "Pushing $1:$2 to Docker Hub"
docker push "$1:$2"
echo "Done"
