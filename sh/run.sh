#!/bin/sh
# shellcheck shell=dash
set -eo pipefail

touch /tmp/init

# Check if a user is mounting their own config
if [ -z "$(ls -A /etc/my.cnf.d/* 2>/dev/null)" ]; then
  # This needs to be run both for initialization and general startup
  # sed into /tmp/ since the user won't have access to create new
  # files in /etc/
  cp /tmp/my.cnf /etc/my.cnf.d/
  [ -n "${SKIP_INNODB}" ] || [ -f "/var/lib/mysql/noinnodb" ] &&
    sed -i -e '/\[mariadb\]/a skip_innodb = yes\ndefault_storage_engine = Aria\ndefault_tmp_storage_engine = Aria' \
      -e '/^innodb/d' /etc/my.cnf.d/my.cnf
fi

MARIADBD_OPTS="--user=mysql"
MARIADBD_OPTS="${MARIADBD_OPTS} --skip-name-resolve"
MARIADBD_OPTS="${MARIADBD_OPTS} --skip-host-cache"
MARIADBD_OPTS="${MARIADBD_OPTS} --skip-slave-start"
# Listen to signals, most importantly CTRL+C
MARIADBD_OPTS="${MARIADBD_OPTS} --debug-gdb"

# No previous installation of mariadb founnd
if [ -z "$(ls -A /var/lib/mysql/ 2>/dev/null)" ]; then
  [ -n "${SKIP_INNODB}" ] && touch /var/lib/mysql/noinnodb
  [ -f "/run/secrets/MYSQL_ROOT_PASSWORD" ] && MYSQL_ROOT_PASSWORD="$(cat /run/secrets/MYSQL_ROOT_PASSWORD)"
  [ -n "${MYSQL_ROOT_PASSWORD}" ] &&
    echo "set password for 'root'@'%' = PASSWORD('${MYSQL_ROOT_PASSWORD}');" >>/tmp/init

  INSTALL_OPTS="--user=mysql"
  INSTALL_OPTS="${INSTALL_OPTS} --cross-bootstrap"
  INSTALL_OPTS="${INSTALL_OPTS} --rpm"
  # https://github.com/MariaDB/server/commit/b9f3f068
  INSTALL_OPTS="${INSTALL_OPTS} --auth-root-authentication-method=normal"
  INSTALL_OPTS="${INSTALL_OPTS} --skip-test-db"
  INSTALL_OPTS="${INSTALL_OPTS} --datadir=/var/lib/mysql"
  eval /usr/bin/mariadb-install-db "${INSTALL_OPTS}"

  if [ -n "${MYSQL_DATABASE}" ]; then
    [ -n "${MYSQL_CHARSET}" ] || MYSQL_CHARSET="utf8"
    [ -n "${MYSQL_COLLATION}" ] && MYSQL_COLLATION="collate '${MYSQL_COLLATION}'"
    echo "create database if not exists \`${MYSQL_DATABASE}\` character set '${MYSQL_CHARSET}' ${MYSQL_COLLATION}; " >>/tmp/init
  fi
  if [ -n "${MYSQL_USER}" ] && [ "${MYSQL_DATABASE}" ]; then
    [ -f "/run/secrets/MYSQL_PASSWORD" ] && MYSQL_PASSWORD="$(cat /run/secrets/MYSQL_PASSWORD)"
    echo "grant all on \`${MYSQL_DATABASE}\`.* to '${MYSQL_USER}'@'%' identified by '${MYSQL_PASSWORD}'; " >>/tmp/init
  fi
  echo "flush privileges;" >>/tmp/init

  # Execute custom scripts provided by a user. This will spawn mariadbd and
  # pass scripts to it. Since we're already up an running we might as well
  # pass the init script and avoid it later.
  if [ "$(ls -A /docker-entrypoint-initdb.d 2>/dev/null)" ]; then
    MARIADB_CMD="mariadb -h 127.0.0.1"
    MARIADBD_OUTPUT=/tmp/mariadbd_output
    mariadbd --user=mysql --silent-startup >"${MARIADBD_OUTPUT}" 2>&1 &
    PID="$!"

    # wait for mariadbd to accept connections
    until tail "${MARIADBD_OUTPUT}" | grep -q "Version:"; do
      sleep 0.2
    done

    # Run the init script
    echo "init: updating system tables"
    eval "${MARIADB_CMD}" </tmp/init

    # Default scope is our newly created database
    MARIADB_CMD="${MARIADB_CMD} ${MYSQL_DATABASE} "

    for f in /docker-entrypoint-initdb.d/*; do
      case "${f}" in
      *.sh)
        echo "init: executing ${f}"
        grep -q bash "${f}" && echo "Bash shell scripts are not supported - use busybox sh syntax instead." && exit 1
        /bin/sh "${f}"
        ;;
      *.sql)
        echo "init: adding ${f}"
        eval "${MARIADB_CMD}" <"${f}"
        ;;
      *.sql.gz)
        echo "init: adding ${f}"
        gunzip -c "${f}" | eval "${MARIADB_CMD}"
        ;;
      *) echo "init: ignoring ${f}: not a recognized format" ;;
      esac
    done

    # shutdown temporary mariadbd
    kill -s TERM "${PID}"
    wait "${PID}"

  else
    MARIADBD_OPTS="${MARIADBD_OPTS} --init-file=/tmp/init"
  fi
fi

# make sure directory permissions are correct before starting up
# https://github.com/jbergstroem/mariadb-alpine/issues/54
chown -R mysql:mysql /var/lib/mysql

eval exec /usr/bin/mariadbd "${MARIADBD_OPTS}"
