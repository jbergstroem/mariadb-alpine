#!/usr/bin/env bash
# shellcheck shell=bash
set -x
set -euo pipefail

IMAGE=${IMAGE:-jbergstroem/mariadb-alpine}
IMAGE_VERSION=${IMAGE_VERSION:-latest}
TEST_PREFIX="mariadb-alpine-test"

# shellcheck disable=SC2034
CLIENT="docker run --rm jbergstroem/mariadb-client-alpine:latest"

if ((BASH_VERSINFO[0] < 4)); then
  echo "You need Bash 4 or newer to run this test suite"
  exit 1
fi

cleanup() {
  # $1: suite name
  local filter="" running="" volumes=""
  filter="-f name=${TEST_PREFIX}-${1}"
  running=$(docker ps -q "${filter}")
  volumes=$(docker volume ls -q "${filter}")
  [ "${running}" == "" ] || echo "${running}" | xargs docker stop {} >/dev/null 2>&1
  [ "${volumes}" == "" ] || echo "${volumes}" | xargs docker volume rm -f {} >/dev/null 2>&1
}

create() {
  # $1: container name
  # $2 create volume?
  # $3: environment variables
  local volume=""
  if ${2}; then
    docker volume create "${TEST_PREFIX}-${1}" >/dev/null
    volume="-v ${TEST_PREFIX}-${1}:/var/lib/mysql"
  fi
  eval docker run -d --rm --name "${TEST_PREFIX}-${1}" "${volume}" "${3}" "${IMAGE}":"${IMAGE_VERSION}" >/dev/null
  until docker logs --tail 1 "${TEST_PREFIX}-${1}" 2>&1 | grep -q "Version:"; do
    sleep 0.2
  done
  docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "${TEST_PREFIX}-${1}"
}

stop() {
  # $1: volume and container name
  docker stop "${TEST_PREFIX}-${1}" >/dev/null
}
