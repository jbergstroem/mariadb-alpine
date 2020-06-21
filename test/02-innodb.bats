#!/usr/bin/env bats

load test_helper

# InnoDB is slow to initialize; penalize this with a 5 second wait
@test "start a default server with InnoDB and no password" {
  local name="default-startup"
  create ${name} ""
  sleep 5
  run client_query "${name}" "-e 'SHOW ENGINE INNODB STATUS;'"
  [[ "$status" -eq 0 ]]
  decommission "${name}"
}
