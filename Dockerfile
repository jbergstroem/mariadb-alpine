FROM alpine:3.9

# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG VCS_REF
LABEL maintainer="Johan Bergström <bugs@bergstroem.nu>" \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="mariadb-alpine" \
      org.label-schema.description="A MariaDB container suitable for development" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/jbergstroem/mariadb-alpine" \
      org.label-schema.schema-version="1.0.0-rc.1" \
      org.label-schema.license="Apache-2.0"

COPY clean.sh /tmp/clean.sh

# We need to keep cache since `clean.sh` uses `apk show` until its finished
# hadolint ignore=DL3019 
RUN apk add mariadb=10.3.15-r0 \
  && /tmp/clean.sh \
  && mkdir /run/mysqld \
  && chown mysql:mysql /run/mysqld \
  && rm -rf /tmp/clean.sh /var/cache/apk /usr/share/apk

COPY run.sh /usr/local/bin/start
COPY my.cnf /etc/

VOLUME ["/var/lib/mysql"]
ENTRYPOINT ["start"]
EXPOSE 3306
