#!/usr/bin/env bash_unit

# shellcheck source=_helper.sh
. _helper.bash

suite_name="innodb"

setup_suite() {
  cleanup "${suite_name}"
}

teardown_suite() {
  cleanup "${suite_name}"
}

test_default_innodb_no_password() {
  local name="${suite_name}_no_password"
  ip=$(create "${name}" true "")
  assert "${CLIENT} -h ${ip} -e \"SHOW ENGINE INNODB STATUS;\""
  stop "${name}"
}

# https://github.com/jbergstroem/mariadb-alpine/issues/1
test_innodb_no_volume_issue_1() {
  local name="${suite_name}_no_volume"
  ip=$(create "${name}" false "")
  assert "${CLIENT} -h ${ip} -e \"select 1;\""
  stop "${name}"
}
