#!/bin/sh
set -eo pipefail

touch /tmp/init

# this needs to be run both for initialization and general startup
[[ -n "${SKIP_INNODB}" ]] || [[ -f "/var/lib/mysql/noinnodb" ]] &&
  sed -i -e '/\[mariadb\]/a skip_innodb = yes \ndefault_storage_engine = MyISAM\ndefault_tmp_storage_engine = MyISAM' \
         -e '/^innodb/d' /etc/my.cnf

# no previous installation
if [ -z "$(ls -A /var/lib/mysql/)" ]; then
  ROOTPW="''"
  [[ -n "${SKIP_INNODB}" ]] && touch /var/lib/mysql/noinnodb
  [[ -n "${MYSQL_ROOT_PASSWORD}" ]] && ROOTPW="PASSWORD('${MYSQL_ROOT_PASSWORD}')"
  echo "INSERT INTO user VALUES ('%','root',${ROOTPW},'Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','','','','',0,0,0,0,'','','N', 'N','', 0);" > /usr/share/mariadb/mysql_system_tables_data.sql

  INSTALL_OPTS="--user=mysql"
  INSTALL_OPTS="${INSTALL_OPTS} --cross-bootstrap"
  INSTALL_OPTS="${INSTALL_OPTS} --rpm"
  # https://github.com/MariaDB/server/commit/b9f3f06857ac6f9105dc65caae19782f09b47fb3
  INSTALL_OPTS="${INSTALL_OPTS} --auth-root-authentication-method=normal"
  INSTALL_OPTS="${INSTALL_OPTS} --skip-test-db"
  INSTALL_OPTS="${INSTALL_OPTS} --datadir=/var/lib/mysql"
  /usr/bin/mysql_install_db ${INSTALL_OPTS}

  [[ -n "${MYSQL_DATABASE}" ]] && echo "create database if not exists \`${MYSQL_DATABASE}\` character set utf8 collate utf8_general_ci; " >> /tmp/init
  if [ -n "${MYSQL_USER}" -a -n "${MYSQL_DATABASE}" ]; then
    echo "grant all on \`${MYSQL_DATABASE}\`.* to '${MYSQL_USER}'@'%' identified by '${MYSQL_PASSWORD}'; " >> /tmp/init
  fi 
  echo "flush privileges;" >> /tmp/init
fi

MYSQLD_OPTS="--user=mysql"
MYSQLD_OPTS="${MYSQLD_OPTS} --skip-name-resolve"
MYSQLD_OPTS="${MYSQLD_OPTS} --skip-host-cache"
MYSQLD_OPTS="${MYSQLD_OPTS} --skip-slave-start"
# listen to signals, most importantly CTRL+C
MYSQLD_OPTS="${MYSQLD_OPTS} --debug-gdb"
MYSQLD_OPTS="${MYSQLD_OPTS} --init-file=/tmp/init"
/usr/bin/mysqld ${MYSQLD_OPTS}
