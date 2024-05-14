#!/usr/bin/env bash

ORIGINAL_ARGS="${@}"
DOCKER_IMAGE_NAME="proxmox-packer-image-builder:latest"


run() {
  docker run \
    --volume "$(pwd):/work" \
    --user "$(id -u):$(id -g)" \
    -p 8080:8080 \
    "${DOCKER_IMAGE_NAME}" \
    "${@}"
}

usage() {
  echo "
usage: $(basename "${0}") [OPTIONS]
-b, --build          Build: (Default=false) Build the container with the given options. Cannot run build commands with this option - will only build the container.
-h, --help           Help: prints usage.

examples:
  $(basename "${0}") -b
  "
  run help
  exit 1
}

for arg in "${@}"; do
  shift
  case "${arg}" in
    '-build'|'--build')       set -- "$@" "-b" ;;
    'help'|'-help'|'--help')  set -- "$@" "-h" ;;
    *)                        set -- "$@" "${arg}"
  esac
done

# Default options
BUILD=false

while getopts ':bh' 'option'; do
  case "${option}" in
    'b') BUILD='true' ;;
    'h') usage ;;
    *) ;;
  esac
done


# Check if docker exists on the host
if ! [ -x "$(command -v docker)" ]; then
  echo 'Error: docker is not installed.' >&2
  exit 1
fi


if [ "${BUILD}" = 'true' ]; then
  docker buildx build \
    --tag "${DOCKER_IMAGE_NAME}" \
    --file Dockerfile \
    .
else
  run "${ORIGINAL_ARGS}"
fi
