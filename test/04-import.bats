#!/usr/bin/env bats

load test_helper

# Since we're downloading the client, wait a bit longer
# for these tests

@test "should import a .sql file and execute it" {
  local name="sql-import"
  local tmpdir="${MY_TMPDIR}/${name}"
  mkdir -p "${tmpdir}"
  echo "create database mydatabase;" > "${tmpdir}/mydatabase.sql"
  create "${name}" "-e SKIP_INNODB=1 -v ${tmpdir}:/docker-entrypoint-initdb.d"
  sleep 5
  run client_query "${name}" "--database=mydatabase -e 'select 1;'"
  [[ "${status}" -eq 0 ]]
  rm -rf "${tmpdir}"
  stop "${name}"
}

@test "should import a compressed file and execute it" {
  local name="sql-import-gz"
  local tmpdir="${MY_TMPDIR}/${name}"
  mkdir -p "${tmpdir}"
  echo "create database mydatabase;" > "${tmpdir}/mydatabase.sql"
  # if you seemingly get stuck here, it's because gzip is attempting to overwrite
  # the existing file. This means your previous run didn't execute successfully
  # and for some reason the temp directory wasn't properly cleaned.
  gzip  "${tmpdir}/mydatabase.sql"
  create "${name}" "-e SKIP_INNODB=1 -v ${tmpdir}:/docker-entrypoint-initdb.d"
  sleep 5
  run client_query "${name}" "--database=mydatabase -e 'select 1;'"
  [[ "${status}" -eq 0 ]]
  rm -rf "${tmpdir}"
  stop "${name}"
}

@test "should execute an imported shell script" {
  local name="sh-import"
  local tmpdir="${MY_TMPDIR}/${name}"
  mkdir -p "${tmpdir}"
  echo "mysql -e \"create database mydatabase;\"" > "${tmpdir}/custom.sh"
  create "${name}" "-e SKIP_INNODB=1 -v ${tmpdir}:/docker-entrypoint-initdb.d"
  sleep 5
  run client_query "${name}" "--database=mydatabase -e 'select 1;'"
  [[ "${status}" -eq 0 ]]
  rm -rf "${tmpdir}"
  stop "${name}"
}
