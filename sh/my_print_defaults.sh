#!/bin/sh
# shellcheck shell=dash
set -euo pipefail

# Stack overflow'ed - should rewrite in awk or even shell for readability
sed -n \
  '/^[ \t]*\[mariadb\]/,/\[/s/^[ \t]*\([^#; \t][^ \t=]*\).*=[ \t]*\(.*\)/--\1=\2/p' \
  /etc/my.cnf.d/* | sed 's:#.*$::g'
