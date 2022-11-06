#!/usr/bin/env bash_unit

# shellcheck source=test/_helper.bash
. _helper.bash

suite_name="basic"

setup_suite() {
  cleanup "${suite_name}"
}

teardown_suite() {
  cleanup "${suite_name}"
}

test_connect_and_version_output() {
  assert_matches "mariadbd  Ver [0-9]+.[0-9]+.[0-9]+-MariaDB*" "$(docker run --rm --entrypoint mariadbd jbergstroem/mariadb-alpine:${IMAGE_VERSION} --version)" "MariaDB should output a version"
}

test_verify_no_default_binlog() {
  local name="${suite_name}_no_default_binlog"
  ip=$(create "${name}" false "-e SKIP_INNODB=1")
  ret=$(${CLIENT} -h "${ip}" -N -e "select @@log_bin;")
  assert_equals "0" "${ret}"
  stop "${name}"
}
