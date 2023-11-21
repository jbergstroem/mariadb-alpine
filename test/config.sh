#!/usr/bin/env bash_unit
# shellcheck shell=bash

# shellcheck source=test/_helper.bash
. _helper.bash

suite_name="config"

setup_suite() {
  cleanup "${suite_name}"
}

teardown_suite() {
  cleanup "${suite_name}"
}

test_no_innodb_ariadb_default() {
  local name="${suite_name}_no_innodb"
  ip=$(create "${name}" true "-e SKIP_INNODB=1")
  # innodb should not be available
  ret=$(${CLIENT} -h "${ip}" -N -e "select Support from information_schema.Engines where Engine='InnoDB';")
  assert_equals "NO" "${ret}"
  # and aria is our default engine
  ret=$(${CLIENT} -h "${ip}" -N -e "select Engine from information_schema.Engines where Support='default';")
  assert_equals "Aria" "${ret}"
  # ..but things still work
  assert "${CLIENT} -h ${ip} -e \"select 1;\""
  stop "${name}"
}

test_custom_root_password() {
  local name="${suite_name}_custom_root_pwd"
  ip=$(create "${name}" false "-e SKIP_INNODB=1 -e MYSQL_ROOT_PASSWORD=secret")
  assert "${CLIENT} -h ${ip} --password=secret -e \"select 1;\""
  stop "${name}"
}

test_custom_database() {
  local name="${suite_name}_custom_db"
  ip=$(create "${name}" false "-e SKIP_INNODB=1 -e MYSQL_DATABASE=db")
  assert "${CLIENT} -h ${ip} --database=db -e 'select 1;'"
  stop "${name}"
}

test_custom_dsn() {
  local name="${suite_name}_dsn"
  ip=$(create "${name}" false "-e SKIP_INNODB=1 -e MYSQL_USER=foo -e MYSQL_DATABASE=bar -e MYSQL_PASSWORD=baz")
  assert "${CLIENT} -h ${ip} --user=foo --database=bar --password=baz -e 'select 1;'"
  stop "${name}"
}

test_custom_charset_collation() {
  local name="${suite_name}_charset_collation"
  ip=$(create "${name}" false "-e SKIP_INNODB=1 -e MYSQL_DATABASE=bar -e MYSQL_CHARSET=utf8mb4 -e MYSQL_COLLATION=utf8mb4_bin")
  # default character set for database is set properly
  ret=$(${CLIENT} -h "${ip}" -N --database=bar -e "select @@character_set_database;")
  assert_equals "utf8mb4" "${ret}"
  # so is collation
  ret=$(${CLIENT} -h "${ip}" -N --database=bar -e "select @@collation_database;")
  assert_equals "utf8mb4_bin" "${ret}"
  stop "${name}"
}

test_custom_timezone() {
  local name="${suite_name}_timezone"
  ip=$(create "${name}" false "-e SKIP_INNODB=1 -e MYSQL_DATABASE=bar -e TZ=CET")
  # timezone is set properly
  ret=$(${CLIENT} -h "${ip}" -N --database=bar -e "SELECT GLOBAL_VALUE FROM INFORMATION_SCHEMA.SYSTEM_VARIABLES WHERE VARIABLE_NAME LIKE 'system_time_zone';")
  assert_equals "CET" "${ret}"
  stop "${name}"
}

test_mount_custom_config() {
  local name="${suite_name}_mount_custom_config"
  ip=$(create "${name}" false "-e SKIP_INNODB=1 -v $(pwd)/fixtures/user-my.cnf:/etc/my.cnf.d/my.cnf")
  ret=$(${CLIENT} -h "${ip}" -N -e "select @@key_buffer_size;")
  assert_equals "1048576" "${ret}"
  stop "${name}"
}
