#!/usr/bin/env bash
# shellcheck shell=bash
set -euo pipefail

IMAGE=${IMAGE:-jbergstroem/mariadb-alpine}
SHORT_SHA=$(git rev-parse --short HEAD)
DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
MARIADB_VERSION="$(sed -rn 's/^ARG APK_VERSION=\"([0-9]+\.[0-9]+\.[0-9]+).*\"$/\1/p' Dockerfile)"
VERSION=${VERSION:-${SHORT_SHA}}

docker image build \
  --build-arg BUILD_DATE="${DATE}" \
  --build-arg BUILD_REF="${SHORT_SHA}" \
  --build-arg BUILD_VERSION="${MARIADB_VERSION}" \
  -t "${IMAGE}:${VERSION}" .
