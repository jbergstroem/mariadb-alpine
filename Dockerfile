FROM alpine:3.8
MAINTAINER Johan Bergström <bugs@bergstroem.nu>

# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG VCS_REF
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="mariadb-alpine" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/jbergstroem/mariadb-alpine" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.license="Apache-2.0"

RUN  apk add --no-cache mariadb \
  && rm -rf /usr/data/test/db.opt /usr/share/mariadb/README* \
     /usr/share/mariadb/COPYING* /usr/share/mariadb/*.cnf \
     /usr/share/mariadb/install_spider.sql \
     /usr/share/mariadb/{mysqld_multi.server,mysql-log-rotate,mysql.server,install_spider.sql} \
  && find /usr/share/mariadb/ -mindepth 1 -type d  ! -name 'charsets' ! -name 'english' -print0 | xargs -0 rm -rf \
  && find /usr/share/terminfo/ -mindepth 1 -type d  ! -name x -print0 | xargs -0 rm -rf \
  && touch /usr/share/mariadb/mysql_system_tables_data.sql \
  && mkdir /run/mysqld \
  && chown mysql:mysql /run/mysqld \
  && sed -i -e '/^log-bin/d' \
            -e '/^binlog_format/d' \
            -e 's/#innodb_log_file_size/innodb_log_file_size/' \
            -e 's/#innodb_buffer_pool_size.*/innodb_buffer_pool_size = 10M\nlower_case_table_names = 1/' \
            -e '/\[mysqld\]/a skip_name_resolve' \
            /etc/mysql/my.cnf \
  && for p in aria* myisam* mysqld_* innochecksum  \
              mysqlslap replace resolveip wsrep* \
              resolve_stack_dump mysqlbinlog \
              $(cd /usr/bin; ls mysql_*| grep -v mysql_install_db); \
              do eval rm /usr/bin/${p}; done \
  && ln -s /var/lib/mariadb /var/lib/mysql
#    ^ backwards compatibility because alpine changed storage folders

COPY run.sh /run.sh

VOLUME ["/var/lib/mariadb"]
ENTRYPOINT ["/run.sh"]
EXPOSE 3306
