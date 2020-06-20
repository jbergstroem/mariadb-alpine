#!/usr/bin/env bats

load test_helper

@test "should output mysqld version" {
  run docker run --rm --entrypoint mysqld "${IMAGE}":"${VERSION}" --version
  [[ "${status}" -eq 0 ]]
  local grepopt
  grepopt="-E"
  if [[ $(uname -s) == "Linux" ]]; then
    grepopt="-P"
  fi
  run grep "${grepopt}" '^mysqld\s+Ver\s+\d+\.\d+\.\d+-MariaDB*' <<< "${output}"
  [[ "${status}" -eq 0 ]]
}
