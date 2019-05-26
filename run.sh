#!/bin/sh
set -eo pipefail

touch /tmp/init

# This needs to be run both for initialization and general startup
[[ -n "${SKIP_INNODB}" ]] || [[ -f "/var/lib/mysql/noinnodb" ]] &&
  sed -i -e '/\[mariadb\]/a skip_innodb = yes\ndefault_storage_engine = MyISAM\ndefault_tmp_storage_engine = MyISAM' \
         -e '/^innodb/d' /etc/my.cnf

MYSQLD_OPTS="--user=mysql"
MYSQLD_OPTS="${MYSQLD_OPTS} --skip-name-resolve"
MYSQLD_OPTS="${MYSQLD_OPTS} --skip-host-cache"
MYSQLD_OPTS="${MYSQLD_OPTS} --skip-slave-start"
# Listen to signals, most importantly CTRL+C
MYSQLD_OPTS="${MYSQLD_OPTS} --debug-gdb"

# No previous installation
if [ -z "$(ls -A /var/lib/mysql/)" ]; then
  ROOTPW="''"
  [[ -n "${SKIP_INNODB}" ]] && touch /var/lib/mysql/noinnodb
  [[ -n "${MYSQL_ROOT_PASSWORD}" ]] && ROOTPW="PASSWORD('${MYSQL_ROOT_PASSWORD}')"
  echo "INSERT INTO user VALUES ('%','root',${ROOTPW},'Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','','','','',0,0,0,0,'','','N', 'N','', 0);" > /usr/share/mariadb/mysql_system_tables_data.sql

  INSTALL_OPTS="--user=mysql"
  INSTALL_OPTS="${INSTALL_OPTS} --cross-bootstrap"
  INSTALL_OPTS="${INSTALL_OPTS} --rpm"
  # https://github.com/MariaDB/server/commit/b9f3f068
  INSTALL_OPTS="${INSTALL_OPTS} --auth-root-authentication-method=normal"
  INSTALL_OPTS="${INSTALL_OPTS} --skip-test-db"
  INSTALL_OPTS="${INSTALL_OPTS} --datadir=/var/lib/mysql"
  /usr/bin/mysql_install_db ${INSTALL_OPTS}

  [[ -n "${MYSQL_DATABASE}" ]] && echo "create database if not exists \`${MYSQL_DATABASE}\` character set utf8 collate utf8_general_ci; " >> /tmp/init
  if [ -n "${MYSQL_USER}" -a -n "${MYSQL_DATABASE}" ]; then
    echo "grant all on \`${MYSQL_DATABASE}\`.* to '${MYSQL_USER}'@'%' identified by '${MYSQL_PASSWORD}'; " >> /tmp/init
  fi 
  echo "flush privileges;" >> /tmp/init

  # Execute custom scripts provided by a user. This will spawn a mysqld and
  # pass scripts to it. Since we're already up an running we might as well
  # pass the init script and avoid it later.
  if [ "$(ls -A /docker-entrypoint-initdb.d)" ]; then
    # Download the mysql client since we will need it to feed data to our server.
    # This kind of sucks but seems unavoidable since using --init-file
    # has size restrictions:
    #   ERROR: 1105  Boostrap file error. Query size exceeded 20000 bytes near <snip>
    # The other option is to embed the client, but since one of the goals is to
    # Strive for the smallest possible size, this seems to be the only option.
    echo "init: installing mysql client"
    apk add -q --no-cache mariadb-client

    SOCKET="/run/mysqld/mysql.sock"
    MYSQL_CMD="mysql --protocol=socket -u root -h localhost --socket=${SOCKET}"

    # Start a mysqld we will use to pass init stuff to
    mysqld --user=mysql --silent-startup --skip-networking --socket=${SOCKET} &> /dev/null &
    PID="$!"

    # perhaps trap this to avoid issues on slow systems?
    sleep 1

    # Run the init script
    echo "init: updating system tables"
    eval ${MYSQL_CMD} < /tmp/init

    # Default scope is our newly created database
    MYSQL_CMD="${MYSQL_CMD} ${MYSQL_DATABASE} "

    for f in /docker-entrypoint-initdb.d/*; do
      case "${f}" in
        *.sh)     echo "init: executing ${f}"; . "${f}" ;;
        *.sql)    echo "init: adding ${f}"; eval ${MYSQL_CMD} < "$f" ;;
        *.sql.gz) echo "init: adding ${f}"; gunzip -c "$f" | eval ${MYSQL_CMD} ;;
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

/usr/bin/mysqld ${MYSQLD_OPTS}
