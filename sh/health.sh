#!/bin/sh
# shellcheck shell=dash
set -eo pipefail

CHECK="mariadb"

# prefer root if available
if [ -n "${MYSQL_ROOT_PASSWORD}" ]; then
  CHECK="${CHECK} --user=root --password=${MYSQL_ROOT_PASSWORD}"
else
  [ -n "${MYSQL_DATABASE}" ] && CHECK="${CHECK} --database=${MYSQL_DATABASE}"
  [ -n "${MYSQL_USERNAME}" ] && CHECK="${CHECK} --user=${MYSQL_USERNAME}"
  [ -n "${MYSQL_PASSWORD}" ] && CHECK="${CHECK} --password=${MYSQL_PASSWORD}"
fi
CHECK="${CHECK} -e 'select 1;'"

eval ${CHECK}
