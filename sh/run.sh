#!/bin/sh
set -eo pipefail

touch /tmp/init

# Check if a user is mounting their own config
if [ -z "$(ls -A /etc/my.cnf.d/* 2> /dev/null)" ]; then
  # This needs to be run both for initialization and general startup
  # sed into /tmp/ since the user won't have access to create new
  # files in /etc/
  cp /tmp/my.cnf /etc/my.cnf.d/
  [ -n "${SKIP_INNODB}" ] || [ -f "/var/lib/mysql/noinnodb" ] &&
    sed -i -e '/\[mariadb\]/a skip_innodb = yes\ndefault_storage_engine = MyISAM\ndefault_tmp_storage_engine = MyISAM' \
        -e '/^innodb/d' /etc/my.cnf.d/my.cnf
fi

MYSQLD_OPTS="--user=mysql"
MYSQLD_OPTS="${MYSQLD_OPTS} --skip-name-resolve"
MYSQLD_OPTS="${MYSQLD_OPTS} --skip-host-cache"
MYSQLD_OPTS="${MYSQLD_OPTS} --skip-slave-start"
# Listen to signals, most importantly CTRL+C
MYSQLD_OPTS="${MYSQLD_OPTS} --debug-gdb"

# No previous installation
if [ -z "$(ls -A /var/lib/mysql/ 2> /dev/null)" ]; then
  [ -n "${SKIP_INNODB}" ] && touch /var/lib/mysql/noinnodb
  [ -n "${MYSQL_ROOT_PASSWORD}" ] && \
    echo "set password for 'root'@'%' = PASSWORD('${MYSQL_ROOT_PASSWORD}');" >> /tmp/init

  INSTALL_OPTS="--user=mysql"
  INSTALL_OPTS="${INSTALL_OPTS} --cross-bootstrap"
  INSTALL_OPTS="${INSTALL_OPTS} --rpm"
  # https://github.com/MariaDB/server/commit/b9f3f068
  INSTALL_OPTS="${INSTALL_OPTS} --auth-root-authentication-method=normal"
  INSTALL_OPTS="${INSTALL_OPTS} --skip-test-db"
  INSTALL_OPTS="${INSTALL_OPTS} --datadir=/var/lib/mysql"
  eval /usr/bin/mysql_install_db "${INSTALL_OPTS}"

  if [ -n "${MYSQL_DATABASE}" ]; then
    [ -n "${MYSQL_CHARSET}" ] || MYSQL_CHARSET="utf8"
    [ -n "${MYSQL_COLLATION}" ] && MYSQL_COLLATION="collate '${MYSQL_COLLATION}'"
    echo "create database if not exists \`${MYSQL_DATABASE}\` character set '${MYSQL_CHARSET}' ${MYSQL_COLLATION}; " >> /tmp/init
  fi
  if [ -n "${MYSQL_USER}" ] && [ "${MYSQL_DATABASE}" ]; then
    echo "grant all on \`${MYSQL_DATABASE}\`.* to '${MYSQL_USER}'@'%' identified by '${MYSQL_PASSWORD}'; " >> /tmp/init
  fi 
  echo "flush privileges;" >> /tmp/init

  # Execute custom scripts provided by a user. This will spawn a mysqld and
  # pass scripts to it. Since we're already up an running we might as well
  # pass the init script and avoid it later.
  if [ "$(ls -A /docker-entrypoint-initdb.d 2> /dev/null)" ]; then
    # Download the mysql client since we will need it to feed data to our server.
    # This kind of sucks but seems unavoidable since using --init-file
    # has size restrictions:
    #   ERROR: 1105  Boostrap file error. Query size exceeded 20000 bytes near <snip>
    # The other option is to embed the client, but since one of the goals is to
    # Strive for the smallest possible size, this seems to be the only option.
    echo "init: installing mysql client"
    apk add -q --no-cache mariadb-client

    SOCKET="/run/mysqld/mysqld.sock"
    MYSQL_CMD="mysql"

    # Start a mysqld we will use to pass init stuff to. Can't use the same options
    # as a standard instance; pass them manually.
    mysqld --user=mysql --silent-startup --skip-networking --socket=${SOCKET} > /dev/null 2>&1 &
    PID="$!"

    # perhaps trap this to avoid issues on slow systems?
    sleep 1

    # Run the init script
    echo "init: updating system tables"
    eval "${MYSQL_CMD}" < /tmp/init

    # Default scope is our newly created database
    MYSQL_CMD="${MYSQL_CMD} ${MYSQL_DATABASE} "

    for f in /docker-entrypoint-initdb.d/*; do
      case "${f}" in
        *.sh)     echo "init: executing ${f}"; /bin/sh "${f}" ;;
        *.sql)    echo "init: adding ${f}"; eval "${MYSQL_CMD}" < "${f}" ;;
        *.sql.gz) echo "init: adding ${f}"; gunzip -c "${f}" | eval "${MYSQL_CMD}" ;;
        *)        echo "init: ignoring ${f}: not a recognized format" ;;
      esac
    done

    # Clean up
    kill -s TERM "${PID}"
    echo "init: removing mysql client"
    apk del -q --no-cache mariadb-client
  else
    MYSQLD_OPTS="${MYSQLD_OPTS} --init-file=/tmp/init"
  fi
fi

eval exec /usr/bin/mysqld "${MYSQLD_OPTS}"
