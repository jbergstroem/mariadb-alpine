#!/bin/sh
# shellcheck shell=dash
set -euo pipefail

# Stack overflow'ed
# TODO Rewrite parsing config ini in awk or even shell for readability
sed -n \
  '/^[ \t]*\[mariadb\]/,/\[/s/^[ \t]*\([^#; \t][^ \t=]*\).*=[ \t]*\(.*\)/--\1=\2/p' \
  /etc/my.cnf.d/* | sed 's:#.*$::g'
