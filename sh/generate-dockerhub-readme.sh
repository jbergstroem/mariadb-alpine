#!/usr/bin/env bash
# shellcheck shell=bash
set -euo pipefail

URL="https://github.com/jbergstroem/mariadb-alpine"

sed \
  -e '/href="#/d' \
  -e '/<\/\{0,1\}picture>/d' \
  -e '/<source/d' \
  -e '/docs\/development.md/d' \
  -e "s|docs/|${URL}/blob/main/docs/|g" \
  README.md >dockerhub.md
