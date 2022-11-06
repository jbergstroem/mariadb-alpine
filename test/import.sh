#!/usr/bin/env bash_unit

# shellcheck source=test/_helper.bash
. _helper.bash

suite_name="import"

setup_suite() {
  cleanup "${suite_name}"
}

teardown_suite() {
  cleanup "${suite_name}"
}

test_import_sql() {
  local name="${suite_name}_sql"
  ip=$(create "${name}" false "-e SKIP_INNODB=1 -v $(pwd)/fixtures/sql:/docker-entrypoint-initdb.d")
  assert "${CLIENT} -h ${ip} --database=mydatabase -e 'select 1;'"
  stop "${name}"
}

test_import_compressed_sql() {
  local name="${suite_name}_gz_sql"
  ip=$(create "${name}" false "-e SKIP_INNODB=1 -v $(pwd)/fixtures/sqlgz:/docker-entrypoint-initdb.d")
  assert "${CLIENT} -h ${ip} --database=mydatabasegz -e 'select 1;'"
  stop "${name}"
}

test_run_shell_script() {
  local name="${suite_name}_shell_script"
  ip=$(create "${name}" false "-e SKIP_INNODB=1 -v $(pwd)/fixtures/sh:/docker-entrypoint-initdb.d")
  assert "${CLIENT} -h ${ip} --database=mydatabasefromclient -e 'select 1;'"
  stop "${name}"
}
