#!/usr/bin/env bats

load test_helper

@test "start a server without InnoDB" {
  local name="skip-innodb-startup"
  create ${name} "-e SKIP_INNODB=1"
  wait_until_up "${name}"
  run client_query "${name}" "-e 'SHOW ENGINE INNODB STATUS;'"
  [[ "$status" -eq 1 ]]
  run client_query "${name}" "-e 'select 1;'"
  [[ "$status" -eq 0 ]]
  stop "${name}"
}

@test "default to Aria when InnoDB is turned off" {
  local name="skipinnodb-ariadb-default"
  create ${name} "-e SKIP_INNODB=1"
  wait_until_up "${name}"
  run client_query "${name}" "-s -N -e 'SELECT ENGINE FROM INFORMATION_SCHEMA.ENGINES where SUPPORT=\"DEFAULT\";'"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "Aria" ]]
  stop "${name}"
}

@test "start a server with a custom root password" {
  local name="root-password"
  create ${name} "-e SKIP_INNODB=1 -e MYSQL_ROOT_PASSWORD=secretsauce"
  wait_until_up "${name}"
  run client_query "${name}"  "--password=secretsauce -e 'select 1;'"
  [[ "$status" -eq 0 ]]
  stop "${name}"
}

@test "start a server with a custom database" {
  local name="custom-db"
  create ${name} "-e SKIP_INNODB=1 -e MYSQL_DATABASE=bar"
  wait_until_up "${name}"
  run client_query "${name}" "--database=bar -e 'select 1;'"
  [[ "$status" -eq 0 ]]
  stop "${name}"
}

@test "start a server with a custom database, user and password" {
  local name="custom-user-password"
  create ${name} "-e SKIP_INNODB=1 -e MYSQL_USER=foo -e MYSQL_DATABASE=bar -e MYSQL_PASSWORD=baz"
  wait_until_up "${name}"
  run client_query "${name}" "--user=foo --database=bar --password=baz -e 'select 1;'"
  [[ "$status" -eq 0 ]]
  stop "${name}"
}

@test "should allow to customize the database charset" {
  local name="custom-charset"
  create ${name} "-e SKIP_INNODB=1 -e MYSQL_DATABASE=bar -e MYSQL_CHARSET=hebrew"
  wait_until_up "${name}"
  run client_query "${name}" "-s -N --database=bar -e 'select @@character_set_database;'"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "hebrew" ]]
  stop "${name}"
}

@test "should allow to customize the database collation" {
  local name="custom-collation"
  create ${name} "-e SKIP_INNODB=1 -e MYSQL_DATABASE=bar -e MYSQL_CHARSET=utf8mb4 -e MYSQL_COLLATION=utf8mb4_bin"
  wait_until_up "${name}"
  run client_query "${name}" "-s -N --database=bar -e 'select @@collation_database;'"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "utf8mb4_bin" ]]
  stop "${name}"
}

@test "verify that binary logging is turned off" {
  local name="no-log-bin"
  create ${name} "-e SKIP_INNODB=1"
  wait_until_up "${name}"
  run client_query "${name}" "-s -N -e 'select @@log_bin;'"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "0" ]]
  stop "${name}"
}

@test "should allow a user to pass a custom config" {
  local name="custom-config"
  create ${name} "-e SKIP_INNODB=1 -v ${BATS_TEST_DIRNAME}/fixtures/user-my.cnf:/etc/my.cnf.d/my.cnf"
  wait_until_up "${name}"
  run client_query "${name}" "-s -N -e 'select @@key_buffer_size;'"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "1048576" ]]
  stop "${name}"
}
