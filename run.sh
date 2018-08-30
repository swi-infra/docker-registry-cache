#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 ssl_directory cache_directory [extra_docker_args]"
    exit 1
fi

SSL_DIRECTORY="$1"
CACHE_DIRECTORY="$2"
shift 2

docker run --rm \
           -p 443:443 \
           --name registry-cache \
           -v ${SSL_DIRECTORY}:/etc/ssl/private \
           -v ${CACHE_DIRECTORY}:/cache \
           $* \
           registry-cache:latest
