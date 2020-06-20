#!/usr/bin/env bats

load test_helper

@test "start a server without InnoDB" {
  local name="skip-innodb-startup"
  create ${name} "-e SKIP_INNODB=1"
  sleep 2
  run docker run --rm jbergstroem/mariadb-client-alpine -h "$(get_ip ${name})" -e "SHOW ENGINE INNODB STATUS;"
  [[ "$status" -eq 1 ]]
  run docker run --rm jbergstroem/mariadb-client-alpine -h "$(get_ip ${name})" -e "select 1;"
  [[ "$status" -eq 0 ]]
  decommission "${name}"
}

@test "start a server with a custom root password" {
  local name="root-password"
  create ${name} "-e SKIP_INNODB=1 -e MYSQL_ROOT_PASSWORD=secretsauce"
  sleep 2
  run docker run --rm jbergstroem/mariadb-client-alpine -h "$(get_ip ${name})" --password=secretsauce -e "select 1;"
  [[ "$status" -eq 0 ]]
  decommission "${name}"
}

@test "start a server with a custom database, user and password" {
  local name="custom-user-password"
  create ${name} "-e SKIP_INNODB=1 -e MYSQL_USER=foo -e MYSQL_DATABASE=bar -e MYSQL_PASSWORD=baz"
  sleep 2
  run docker run --rm jbergstroem/mariadb-client-alpine -h "$(get_ip ${name})" --user=foo --database=bar --password=baz -e "select 1;"
  [[ "$status" -eq 0 ]]
  decommission "${name}"
}

@test "verfiy that binary logging is turned off" {
  local name="no-log-bin"
  create ${name} "-e SKIP_INNODB=1"
  sleep 2
  run docker run --rm jbergstroem/mariadb-client-alpine -h "$(get_ip ${name})" -e 'select 1 where @@log_bin = 1;'
  [[ "$status" -eq 0 ]]
  decommission "${name}"
}
