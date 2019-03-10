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
  /usr/bin/mysql_install_db --user=mysql --cross-bootstrap --rpm --skip-test-db --datadir=/var/lib/mysql
  [[ -n "${MYSQL_DATABASE}" ]] && echo "create database if not exists \`${MYSQL_DATABASE}\` character set utf8 collate utf8_general_ci; " >> /tmp/init
  if [ -n "${MYSQL_USER}" -o -n "${MYSQL_DATABASE}" ]; then
    echo "grant all on \`${MYSQL_DATABASE}\`.* to '${MYSQL_USER}'@'%' identified by '${MYSQL_PASSWORD}'; " >> /tmp/init
  fi 
  echo "flush privileges;" >> /tmp/init
fi

/usr/bin/mysqld --skip-name-resolve --user=mysql --debug-gdb --init-file=/tmp/init
