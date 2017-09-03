FROM alpine:3.6
MAINTAINER Johan Bergström <bugs@bergstroem.nu>

ENV LC_ALL C.UTF-8

RUN  apk update \
  && apk add mariadb \
  && rm -rf /var/lib/apk/* /var/cache/apk/* /usr/data/test/db.opt /usr/share/mysql/{COPYING*,*.cnf,README*} \
  && find /usr/share/mysql/ -mindepth 1 -type d  ! -name 'charsets' ! -name 'english' -print0 | xargs -0 rm -rf \
  && find /usr/share/terminfo/ -mindepth 1 -type d  ! -name x -print0 | xargs -0 rm -rf \
  && mkdir /run/mysqld \
  && chown mysql:mysql /run/mysqld \
  && sed -i -e '/^log-bin/d' \
            -e '/^binlog_format/d' \
            -e 's/#innodb_log_file_size/innodb_log_file_size/' \
            -e 's/#innodb_buffer_pool_size.*/innodb_buffer_pool_size = 10M\ninnodb_empty_free_list_algorithm = legacy/' \
            -e '/\[mysqld\]/a skip_name_resolve' \
            /etc/mysql/my.cnf \
  && for p in aria* myisam* mysqltest_embedded innochecksum  \
              mysqlslap mysqltest replace resolveip perror \
              resolve_stack_dump mariabackup mbstream mysqlbinlog \
              $(cd /usr/bin; ls mysql_* | grep -v mysql_install_db); \
              do eval rm /usr/bin/${p}; done

COPY run.sh /run.sh

VOLUME ["/var/lib/mysql"]
ENTRYPOINT ["/run.sh"]
EXPOSE 3306

