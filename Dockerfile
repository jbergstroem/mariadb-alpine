FROM alpine:3.11

# https://github.com/opencontainers/image-spec/blob/master/annotations.md
ARG BUILD_DATE
ARG VCS_REF
LABEL org.opencontainers.image.created=$BUILD_DATE \
      org.opencontainers.image.title="mariadb-alpine" \
      org.opencontainers.image.description="A MariaDB container suitable for development" \
      org.opencontainers.image.authors="Johan Bergström <bugs@bergstroem.nu>" \
      org.opencontainers.image.revision=$VCS_REF \
      org.opencontainers.image.source="https://github.com/jbergstroem/mariadb-alpine" \
      org.opencontainers.image.url="https://github.com/jbergstroem/mariadb-alpine" \
      org.opencontainers.image.schema-version="1.0.0-rc.1" \
      org.opencontainers.image.license="MIT"

COPY run.sh /run.sh
COPY my.cnf /tmp/

RUN apk add --no-cache mariadb=10.4.13-r0 \
  && rm -rf /etc/my.cnf.d/* /etc/my.cnf.apk-new /usr/data/test/db.opt /usr/share/mariadb/README* \
     /usr/share/mariadb/COPYING* /usr/share/mariadb/*.cnf /usr/share/terminfo \
     /usr/share/mariadb/{binary-configure,mysqld_multi.server,mysql-log-rotate,mysql.server,install_spider.sql} \
  && find /usr/share/mariadb/ -mindepth 1 -type d ! -name 'charsets' ! -name 'english' -print0 | xargs -0 rm -rf \
  # We need to allow anyone connect as root and need to do this while building the container
  # since we can't modify this file at a later stage.
  && sed -i -e 's/127.0.0.1/%/' /usr/share/mariadb/mysql_system_tables_data.sql \
  && mkdir /run/mysqld \
  && chown mysql:mysql /etc/my.cnf.d/ /run/mysqld /usr/share/mariadb/mysql_system_tables_data.sql \
  && for p in aria* myisam* mysqld_* innochecksum \
              mysqlslap replace wsrep* msql2mysql sst_dump \
              resolve_stack_dump mysqlbinlog myrocks_hotbackup test-connect-t \
              $(cd /usr/bin; ls mysql_*| grep -v mysql_install_db); \
              do eval rm /usr/bin/${p}; done

USER mysql

# This is not super helpful; mysqld might be running but not accepting connections.
# Since we have no clients, we can't really connect to it and check.
#
# Below is in my opinion better than no health check.
HEALTHCHECK --start-period=3s CMD pgrep mysqld

VOLUME ["/var/lib/mysql"]
ENTRYPOINT ["/run.sh"]
EXPOSE 3306
