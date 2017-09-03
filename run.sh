#!/bin/sh

touch /tmp/init

# no previous installation
if [ -z "$(ls -A /var/lib/mysql/)" ]; then
  mysql_install_db --rpm --skip-name-resolve --skip-auth-anonymous-user --user=mysql
  # allow all hosts, not just localhost over TCP
  echo "update mysql.user set Host = '%' where Host = '127.0.0.1';" >> /tmp/init
  [[ -n "${MYSQL_DATABASE}" ]] && echo "create database if not exists ${MYSQL_DATABASE} character set utf8 collate utf8_general_ci; " >> /tmp/init
  if [ -n "${MYSQL_USER}" -o -n "${MYSQL_DATABASE}" ]; then
    echo "grant all on `${MYSQL_DATABASE}`.* to '${MYSQL_USER}'@'%' identified by '${MYSQL_PASSWORD}'; " >> /tmp/init
  fi 
  echo "flush privileges;" >> /tmp/init
fi

/usr/bin/mysqld --user=mysql --debug-gdb --init-file=/tmp/init
