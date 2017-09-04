#!/bin/sh

touch /tmp/init

# no previous installation
if [ -z "$(ls -A /var/lib/mysql/)" ]; then
  # as far as i can tell cross-bootstrap and rpm basically decreases verbosity
  mysql_install_db --rpm --skip-name-resolve --skip-auth-anonymous-user --user=mysql --cross-bootstrap
  [[ -n "${MYSQL_DATABASE}" ]] && echo "create database if not exists \`${MYSQL_DATABASE}\` character set utf8 collate utf8_general_ci; " >> /tmp/init
  if [ -n "${MYSQL_USER}" -o -n "${MYSQL_DATABASE}" ]; then
    echo "grant all on \`${MYSQL_DATABASE}\`.* to '${MYSQL_USER}'@'%' identified by '${MYSQL_PASSWORD}'; " >> /tmp/init
  fi 
  echo "flush privileges;" >> /tmp/init
fi

/usr/bin/mysqld --user=mysql --debug-gdb --init-file=/tmp/init
