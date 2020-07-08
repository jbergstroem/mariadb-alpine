#!/usr/bin/env bash

set -euo pipefail

create() {
  # $1: volume and container name
  # $2: environment variables
  run docker volume create "${TEST_PREFIX}-${1}"
  run eval docker run -d --rm --name "${TEST_PREFIX}-${1}" -v "${TEST_PREFIX}-${1}":/var/lib/mysql "${2}" "${IMAGE}":"${VERSION}"
}

client_query() {
  # $1: name of container
  # $2: query to run
  ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "${TEST_PREFIX}-${1}")
  eval docker run --rm jbergstroem/mariadb-client-alpine:latest -h "${ip}" "${2}"
}

# for local testing cleaning up makes sense
stop() {
  # $1: volume and container name
  run docker stop "${TEST_PREFIX}-${1}"
}
