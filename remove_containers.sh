#!/bin/sh

docker ps --all | awk 'NR > 1 {print $1}' | xargs -I {} docker rm "{}"
docker image ls | awk 'NR > 1 {print $3}' | xargs -I {} docker image rm "{}"
