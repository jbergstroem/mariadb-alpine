FROM alpine:3.16

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

SHELL ["/bin/ash", "-euo", "pipefail", "-c"]

RUN \
  apk add --no-cache mariadb=10.6.8-r0 && \
  TO_KEEP=$(echo " \
    etc/ssl/certs/ca-certificates.crt$ \
    usr/bin/mariadbd$ \
    usr/bin/mariadb$ \
    usr/bin/getconf$ \
    usr/bin/getent$ \
    usr/bin/my_print_defaults$ \
    usr/bin/mariadb-install-db$ \
    usr/share/mariadb/charsets \
    usr/share/mariadb/english \
    usr/share/mariadb/mysql_system_tables.sql$ \
    usr/share/mariadb/mysql_performance_tables.sql$ \
    usr/share/mariadb/mysql_system_tables_data.sql$ \
    usr/share/mariadb/maria_add_gis_sp_bootstrap.sql$ \
    usr/share/mariadb/mysql_sys_schema.sql$ \
    usr/share/mariadb/fill_help_tables.sql$" | \
    tr -d " \t\n\r" | sed -e 's/usr/|usr/g' -e 's/^.//') && \
  INSTALLED=$(apk info -q -L mariadb-common mariadb linux-pam ca-certificates | grep "\S") && \
  for path in $(echo "${INSTALLED}" | grep -v -E "${TO_KEEP}"); do \
    eval rm -rf "${path}"; \
  done && \
  touch /usr/share/mariadb/mysql_test_db.sql && \
  # this file is removed since we remove most things from mariadb-common
  echo "!includedir /etc/my.cnf.d" > /etc/my.cnf && \
  # allow anyone to connect by default
  sed -ie 's/127.0.0.1/%/' /usr/share/mariadb/mysql_system_tables_data.sql && \
  mkdir /run/mysqld && \
  chown mysql:mysql /etc/my.cnf.d/ /run/mysqld /usr/share/mariadb/mysql_system_tables_data.sql

# The one installed by MariaDB was removed in the clean step above due to its large footprint
COPY sh/resolveip.sh /usr/bin/resolveip
COPY sh/run.sh /run.sh
# Used in run.sh as a default config
COPY my.cnf /tmp/my.cnf

# This is not super helpful; mysqld might be running but not accepting connections.
# Since we have no clients, we can't really connect to it and check.
#
# Below is in my opinion better than no health check.
HEALTHCHECK --start-period=5s CMD pgrep mariadbd

VOLUME ["/var/lib/mysql"]
ENTRYPOINT ["/run.sh"]
EXPOSE 3306
