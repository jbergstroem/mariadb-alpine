#!/usr/bin/env bats

load test_helper

@test "start a server without InnoDB" {
  local name="skip-innodb-startup"
  create ${name} "-e SKIP_INNODB=1"
  sleep 2
  run client_query "${name}" "-e 'SHOW ENGINE INNODB STATUS;'"
  [[ "$status" -eq 1 ]]
  run client_query "${name}" "-e 'select 1;'"
  [[ "$status" -eq 0 ]]
  decommission "${name}"
}

@test "start a server with a custom root password" {
  local name="root-password"
  create ${name} "-e SKIP_INNODB=1 -e MYSQL_ROOT_PASSWORD=secretsauce"
  sleep 2
  run client_query "${name}"  "--password=secretsauce -e 'select 1;'"
  [[ "$status" -eq 0 ]]
  decommission "${name}"
}

@test "start a server with a custom database" {
  local name="custom-db"
  create ${name} "-e SKIP_INNODB=1 -e MYSQL_DATABASE=bar"
  sleep 2
  run client_query "${name}" "--database=bar -e 'select 1;'"
  [[ "$status" -eq 0 ]]
  decommission "${name}"
}

@test "start a server with a custom database, user and password" {
  local name="custom-user-password"
  create ${name} "-e SKIP_INNODB=1 -e MYSQL_USER=foo -e MYSQL_DATABASE=bar -e MYSQL_PASSWORD=baz"
  sleep 2
  run client_query "${name}" "--user=foo --database=bar --password=baz -e 'select 1;'"
  [[ "$status" -eq 0 ]]
  decommission "${name}"
}

@test "verfiy that binary logging is turned off" {
  local name="no-log-bin"
  create ${name} "-e SKIP_INNODB=1"
  sleep 2
  run client_query "${name}" "-e 'select 1 where @@log_bin = 1;'"
  [[ "$status" -eq 0 ]]
  decommission "${name}"
}

@test "should allow a user to pass a custom config" {
  local name="custom-config"
  create ${name} "-e SKIP_INNODB=1 -v ${BATS_TEST_DIRNAME}/fixtures/user-my.cnf:/etc/my.cnf.d/my.cnf"
  sleep 2
  run client_query "${name}" "-s -N -e 'select @@key_buffer_size;'"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "1048576" ]]
  decommission "${name}"
}
