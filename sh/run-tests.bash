#!/usr/bin/env bash
set -euo pipefail

export IMAGE=${IMAGE:-jbergstroem/mariadb-alpine}
export VERSION=${VERSION:-latest}
export TEST_PREFIX="mariadb-alpine-bats-test"

DEFAULT_TMPDIR=${TMPDIR:-/tmp}

MY_TMPDIR=$(mktemp -d "${DEFAULT_TMPDIR}"/"${TEST_PREFIX}".XXXXXX)
export MY_TMPDIR

# Check prerequisites before starting
command -v docker  > /dev/null 2>&1
docker inspect "${IMAGE}":"${VERSION}" > /dev/null 2>&1

clean() {
  local filter="" running="" volumes=""
  filter="-f name=${TEST_PREFIX}"
  running=$(docker ps -q "${filter}")
  volumes=$(docker volume ls -q "${filter}")
  [ "${running}" == "" ] || echo "${running}" | xargs docker stop {} > /dev/null 2>&1
  [ "${volumes}" == "" ] || echo "${volumes}" | xargs docker volume rm -f {} > /dev/null 2>&1
}

# clean previous runs
clean
bats test/*.bats -j "$(nproc)"
clean
# remove temp folders. make sure this cannot be destructive if for instance
# ${MY_TMPDIR} would be "/"
SUFFIX=$(basename "${MY_TMPDIR}")
find "${DEFAULT_TMPDIR}" -type d -maxdepth 1 -name "${SUFFIX}" -delete > /dev/null 2>&1
