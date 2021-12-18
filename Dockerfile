FROM alpine:3.12

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
  apk add --no-cache mariadb=10.4.22-r0 && \
  TO_KEEP=$(echo " \
    usr/bin/mysqld$ \
    usr/bin/mariadb$ \
    usr/bin/getconf$ \
    usr/bin/getent$ \
    usr/bin/my_print_defaults$ \
    usr/bin/mysql_install_db$ \
    usr/share/mariadb/charsets \
    usr/share/mariadb/english \
    usr/share/mariadb/mysql_system_tables.sql$ \
    usr/share/mariadb/mysql_performance_tables.sql$ \
    usr/share/mariadb/mysql_system_tables_data.sql$ \
    usr/share/mariadb/maria_add_gis_sp_bootstrap.sql$ \
    usr/share/mariadb/fill_help_tables.sql$" | \
    tr -d " \t\n\r" | sed -e 's/usr/|usr/g' -e 's/^.//') && \
  INSTALLED=$(apk info -q -L mariadb-common mariadb linux-pam | grep "\S") && \
  for path in $(echo "${INSTALLED}" | grep -v -E "${TO_KEEP}"); do \
    echo "remove ${path}";\
    eval rm -rf "${path}"; \
  done && \
  touch /usr/share/mariadb/mysql_test_db.sql && \
  # this file is removed since we remove most things from mariadb-common
  echo "!includedir /etc/my.cnf.d" > /etc/my.cnf && \
  # allow anyone to connect by default
  sed -ie 's/127.0.0.1/%/' /usr/share/mariadb/mysql_system_tables_data.sql && \
  mkdir /run/mysqld && \
  chown mysql:mysql /etc/my.cnf.d/ /run/mysqld /usr/share/mariadb/mysql_system_tables_data.sql && \
  rm /etc/my.cnf.d/* -rf

# The one installed by MariaDB was removed in the clean step above due to its large footprint
COPY sh/resolveip.sh /usr/bin/resolveip
COPY sh/run.sh /run.sh
# Used in run.sh as a default config
COPY my.cnf /tmp/my.cnf

# This is not super helpful; mysqld might be running but not accepting connections.
# Since we have no clients, we can't really connect to it and check.
#
# Below is in my opinion better than no health check.
HEALTHCHECK --start-period=5s CMD pgrep mysqld

VOLUME ["/var/lib/mysql"]
ENTRYPOINT ["/run.sh"]
EXPOSE 3306


# docker login
# docker build ./ -f Dockerfile -t mysql:1
# docker tag mysql:1 yorkane/alpine-mariadb:10.4.22
# docker push yorkane/alpine-mariadb:10.4.22