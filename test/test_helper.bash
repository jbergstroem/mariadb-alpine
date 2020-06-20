#!/usr/bin/env bash

set -euo pipefail

IMAGE=${IMAGE:-jbergstroem/mariadb-alpine}
VERSION=${VERSION:-latest}
TEST_PREFIX="mariadb-alpine-bats-test"

setup() {
  # no explanataion needed
  run command -v docker
  [[ "$status" -eq 0 ]]

  # the test suite assumes that the image is built
  run docker inspect "${IMAGE}":"${VERSION}"
   [[ "$status" -eq 0 ]]
}

create() {
  # $1: volume and container name
  # $2: environment variables
  run docker volume create "${TEST_PREFIX}-${1}"
  run docker run -d --rm --name "${TEST_PREFIX}-${1}" -v "${TEST_PREFIX}-${1}":/var/lib/mysql ${2} "${IMAGE}":"${VERSION}"
}

run_with_client() {
  # $1: query to run
  echo foo
}

# for local testing cleaning up makes sense
decommission() {
  # $1: volume and container name
  run docker stop "${TEST_PREFIX}-${1}"
  run docker volume rm "${TEST_PREFIX}-${1}"
}

# get the ip of a running server
get_ip() {
  run docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "${TEST_PREFIX}-${1}"
  echo "${output}"
}
