#!/bin/sh

version=$(awk '/^ENV RAPIDPRO_VERSION/ { print $3 }' rapidpro-docker/Dockerfile)

echo "$version" > image-params/tag
