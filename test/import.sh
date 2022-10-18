#!/usr/bin/env bash_unit

# shellcheck source=_helper.sh
. _helper.bash

suite_name="import"
TMPDIR=""
TMPDIR_A=""

setup_suite() {
  cleanup "${suite_name}"
  TMPDIR=$(mktemp -d "${suite_name}.XXXX")
  TMPDIR_A=$(realpath "${TMPDIR}")
}

teardown_suite() {
  cleanup "${suite_name}"
  rmdir "${TMPDIR}"
}

test_import_sql() {
  local name="${suite_name}_import_sql"
  mkdir "${TMPDIR_A}/${name}"
  echo "create database mydatabase;" >"${TMPDIR_A}/${name}/mydatabase.sql"
  ip=$(create "${name}" false "-e SKIP_INNODB=1 -v ${TMPDIR_A}/${name}:/docker-entrypoint-initdb.d")
  assert "${CLIENT} -h ${ip} --database=mydatabase -e 'select 1;'"
  cd "${TMPDIR}" && rm -rf "${name}"
  stop "${name}"
}

test_import_compressed_sql() {
  local name="${suite_name}_import_gz_sql"
  mkdir "${TMPDIR_A}/${name}"
  echo "create database mydatabase2;" >"${TMPDIR_A}/${name}/mydatabase.sql"
  gzip "${TMPDIR_A}/${name}/mydatabase.sql"
  ip=$(create "${name}" false "-e SKIP_INNODB=1 -v ${TMPDIR_A}/${name}:/docker-entrypoint-initdb.d")
  assert "${CLIENT} -h ${ip} --database=mydatabase2 -e 'select 1;'"
  cd "${TMPDIR}" && rm -rf "${name}"
  stop "${name}"
}

test_run_shell_script() {
  local name="${suite_name}_shell_script"
  mkdir "${TMPDIR_A}/${name}"
  echo "mariadb -e \"create database mydatabase3;\"" >"${TMPDIR_A}/${name}/custom.sh"
  ip=$(create "${name}" false "-e SKIP_INNODB=1 -v ${TMPDIR_A}/${name}:/docker-entrypoint-initdb.d")
  assert "${CLIENT} -h ${ip} --database=mydatabase3 -e 'select 1;'"
  cd "${TMPDIR}" && rm -rf "${name}"
  stop "${name}"
}
