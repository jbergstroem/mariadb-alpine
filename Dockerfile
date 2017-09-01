FROM alpine:3.6
MAINTAINER Johan Bergström <bugs@bergstroem.nu>

ENV LC_ALL C.UTF-8

RUN  apk update \
  && apk add mariadb \
  && rm -rf /var/lib/apk/* /usr/data/test/db.opt \
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
#CMD ["/usr/bin/mysqld_safe", "--console"]
EXPOSE 3306

STOPSIGNAL SIGQUIT