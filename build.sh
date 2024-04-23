#!/usr/bin/env bash

# Check if docker exists on the host
if ! [ -x "$(command -v docker)" ]; then
  echo 'Error: docker is not installed.' >&2
  exit 1
fi

docker build \
  --tag proxmox-packer-image-builder:latest \
  --file Dockerfile \
  .

docker run \
  --volume $(pwd):/work \
  --user $(id -u):$(id -g) \
  -p 8080:8080 \
  proxmox-packer-image-builder:latest \
  "${@}"