#!/bin/sh
# shellcheck shell=dash
set -euo pipefail

[ -z "${1:-}" ] && exit 1

if echo "${1}" | grep -q "^[0-9]"; then
  echo "Host name of ${1} is localhost, localhost"
else
  echo "IP address of ${1} is 127.0.0.1"
fi
