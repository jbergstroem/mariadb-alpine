#!/usr/bin/env bats
# shellcheck shell=bash

load test_helper

@test "should output mariadbd version" {
  run docker run --rm --entrypoint mariadbd "${IMAGE}":"${VERSION}" --version
  [[ "${status}" -eq 0 ]]
  local grepopt
  grepopt="-E"
  if [[ $(uname -s) == "Linux" ]]; then
    grepopt="-P"
  fi
  run grep "${grepopt}" '^mariadbd\s+Ver\s+\d+\.\d+\.\d+-MariaDB*' <<<"${output}"
  [[ "${status}" -eq 0 ]]
}
