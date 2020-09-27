FROM fedora:rawhide AS builder

ARG BUILD_DATE
ARG VCS_REF
ARG MARIADB_VERSION

# https://github.com/opencontainers/image-spec/blob/master/annotations.md
LABEL org.opencontainers.image.created=$BUILD_DATE \
  org.opencontainers.image.title="mariadb" \
  org.opencontainers.image.description="A minimalist MariaDB container" \
  org.opencontainers.image.authors="Johan Bergström <bugs@bergstroem.nu>" \
  org.opencontainers.image.revision=$VCS_REF \
  org.opencontainers.image.source="https://github.com/jbergstroem/mariadb-alpine" \
  org.opencontainers.image.url="https://github.com/jbergstroem/mariadb-alpine" \
  org.opencontainers.image.schema-version="1.0.0-rc.1" \
  org.opencontainers.image.license="MIT"

WORKDIR /var/tmp/build

RUN rm -f /etc/yum.repos.d/fedora-cisco-openh264.repo && \
    dnf update -y && \
    dnf install -y bison gcc-c++ ninja-build cmake busybox \
        ncurses-devel pcre-devel openssl-devel libxml2-devel \
        libaio-devel libedit-devel zlib-devel && \
    mkdir ../mariadb && \
    curl -L https://downloads.mariadb.org/interstitial/mariadb-${MARIADB_VERSION}/source/mariadb-${MARIADB_VERSION}.tar.gz | tar -xz  --strip-components=1 -C ../mariadb && \
    # Avoid building things not in use
    sed -i -e '/INCLUDE(mariadb_connector_c)/d' \
        -e '/ADD_SUBDIRECTORY(client)/d' \
        -e '/ADD_SUBDIRECTORY(tests)/d' \
        -e '/ADD_SUBDIRECTORY(mysql-test/d' \
        -e '/ADD_SUBDIRECTORY(sql-bench)/d' \
        ../mariadb/CMakeLists.txt && \
    cmake -GNinja ../mariadb \
        -DWITH_SSL=system \
        -DWITH_PCRE=system \
        -DCMAKE_INSTALL_PREFIX=/ \
        -DMYSQL_DATADIR=/var/lib/mysql \
        -DBUILD_CONFIG=mysql_release \
        -DCMAKE_BUILD_TYPE=MinSizeRel \
        -DDAEMON_NAME=mariadb \
        -DFEATURE_SET="community" \
        -DSYSCONFDIR=/etc \
        -DSYSCONF2DIR=/etc/my.cnf.d \
        -DMYSQL_UNIX_ADDR=/run/mysqld/mysqld.sock \
        -DDEFAULT_CHARSET=utf8mb4 \
        -DDEFAULT_COLLATION=utf8mb4_general_ci \
        -DTMPDIR=/tmp \
        -DCONNECT_WITH_MYSQL=ON \
        -DCONNECT_WITH_LIBXML2=system \
        -DCONNECT_WITH_ODBC=OFF \
        -DCONNECT_WITH_JDBC=OFF \
        -DCONNECT_WITH_MONGO=OFF \
        -DCONNECT_WITH_REST=OFF \
        -DCONNECT_WITH_VCT=OFF \
        -DCONNECT_WITH_XMAP=OFF \
        -DCONNECT_WITH_ZIP=OFF \
        -DPLUGIN_ARCHIVE=NO \
        -DPLUGIN_AUDIT_NULL=NO \
        -DPLUGIN_AUTH_0X0100=NO \
        -DPLUGIN_AUTH_ED25519=NO \
        -DPLUGIN_AUTH_PAM=NO \
        -DPLUGIN_AUTH_SOCKET=STATIC \
        -DPLUGIN_AUTH_TEST_PLUGIN=NO \
        -DPLUGIN_BLACKHOLE=NO \
        -DPLUGIN_CONNECT=NO \
        -DPLUGIN_DAEMON_EXAMPLE=NO \
        -DPLUGIN_DEBUG_KEY_MANAGEMENT=NO \
        -DPLUGIN_DIALOG_EXAMPLES=NO \
        -DPLUGIN_DISKS=NO \
        -DPLUGIN_EXAMPLE=NO \
        -DPLUGIN_EXAMPLE_KEY_MANAGEMENT=NO \
        -DPLUGIN_FEDERATED=NO \
        -DPLUGIN_FEDERATEDX=NO \
        -DPLUGIN_FEEDBACK=NO \
        -DPLUGIN_FILE_KEY_MANAGEMENT=NO \
        -DPLUGIN_FTEXAMPLE=NO \
        -DPLUGIN_HANDLERSOCKET=NO \
        -DPLUGIN_INNOBASE=STATIC \
        -DPLUGIN_LOCALES=NO \
        -DPLUGIN_METADATA_LOCK_INFO=NO \
        -DPLUGIN_MROONGA=NO \
        -DPLUGIN_PARTITION=STATIC \
        -DPLUGIN_PERFSCHEMA=STATIC \
        -DPLUGIN_QA_AUTH_CLIENT=NO \
        -DPLUGIN_QA_AUTH_INTERFACE=NO \
        -DPLUGIN_QA_AUTH_SERVER=NO \
        -DPLUGIN_QUERY_CACHE_INFO=NO \
        -DPLUGIN_QUERY_RESPONSE_TIME=NO \
        -DPLUGIN_ROCKSDB=NO \
        -DPLUGIN_SEQUENCE=STATIC \
        -DPLUGIN_SERVER_AUDIT=NO \
        -DPLUGIN_SIMPLE_PASSWORD_CHECK=NO \
        -DPLUGIN_SPHINX=NO \
        -DPLUGIN_SPIDER=NO \
        -DPLUGIN_SQL_ERRLOG=NO \
        -DPLUGIN_TEST_SQL_DISCOVERY=NO \
        -DPLUGIN_TEST_VERSIONING=NO \
        -DPLUGIN_TOKUDB=NO \
        -DPLUGIN_USER_VARIABLES=STATIC \
        -DPLUGIN_WSREP_INFO=NO \
        -DWITH_INNODB_AHI=ON \
        -DWITH_INNODB_BZIP2=OFF \
        -DWITH_INNODB_DISALLOW_WRITES=ON \
        -DWITH_INNODB_EXTRA_DEBUG=OFF \
        -DWITH_INNODB_LZ4=OFF \
        -DWITH_INNODB_LZMA=ON \
        -DWITH_INNODB_LZO=OFF \
        -DWITH_INNODB_ROOT_GUESS=ON \
        -DWITH_INNODB_SNAPPY=OFF \
        -DGRN_EMBED=OFF \
        -DWITH_MARIABACKUP=OFF \
        -DWITH_DBUG_TRACE=OFF \
        -DENABLED_PROFILING=OFF \
        -DWITH_SYSTEMD=no \
        -DWITH_WSREP=OFF \
        -DWITH_UNIT_TESTS=NO \
        -DDISABLE_SHARED=ON \
        -DAWS_SDK_EXTERNAL_PROJECT=OFF \
        -DUPDATE_SUBMODULES=OFF \
        -DWITH_JEMALLOC=OFF \
        -DWITH_ZLIB=system && \
    DESTDIR=../out ninja install

RUN strip /var/tmp/out/bin/{mysqld,my_print_defaults}

FROM scratch

COPY --from=builder /etc/ssl/certs/ca-bundle.crt /etc/ssl/certs/ca-bundle.crt
COPY --from=builder /usr/sbin/busybox \
                    /var/tmp/out/bin/my_print_defaults \
                    /var/tmp/out/scripts/mysql_install_db \
                    /var/tmp/out/bin/mysqld /bin/
# output from `ldd`'ing mysqld. Not sure how to automate since `COPY` doesn't
# allow input from for instance scripts. Might just be a template thing.
COPY --from=builder /usr/lib64/libpthread.so.0 \
                    /usr/lib64/liblzma.so.5 \
                    /usr/lib64/libaio.so.1 \
                    /usr/lib64/libz.so.1 \
                    /usr/lib64/libpcre.so.1 \
                    /usr/lib64/libcrypt.so.2 \
                    /usr/lib64/libssl.so.1.1 \
                    /usr/lib64/libcrypto.so.1.1 \
                    /usr/lib64/libdl.so.2 \
                    /usr/lib64/libstdc++.so.6 \
                    /usr/lib64/libm.so.6 \
                    /usr/lib64/libgcc_s.so.1 \
                    /usr/lib64/libc.so.6 \
                    /usr/lib64/ld-linux-x86-64.so.2 \
                    /lib64/
COPY --from=builder /var/tmp/out/share/english /var/tmp/out/share/charsets \
    /var/tmp/out/share/mysql_system_tables* /var/tmp/out/share/mysql_performance_tables.sql \
    /var/tmp/out/share/maria_add_gis_sp_bootstrap.sql /share/
COPY sh/resolveip.sh /bin/resolveip
COPY sh/run.sh /run.sh
COPY my.cnf /tmp/my.cnf
RUN ["/bin/busybox", "--install", "-s", "/bin/"]
RUN echo 'root:x:0:' > /etc/group && \
    echo 'root:x:0:0:root:/root:/bin/sh' > /etc/passwd && \
    echo $'[mysqld]\n!includedir /etc/my.cnf.d' > /etc/my.cnf && \
    mkdir -p /etc/my.cnf.d/ /run/mysqld && \
    touch /share/mysql_test_db.sql /share/fill_help_tables.sql && \
    sed -i -e 's/127.0.0.1/%/' /share/mysql_system_tables_data.sql

# This is not super helpful – mysqld might be running but not accepting
# connections (yet). Since we have no clients, we can't really connect
# to it and check. At least better than no health check.
HEALTHCHECK --start-period=5s CMD pgrep mysqld

VOLUME ["/var/lib/mysql"]
ENTRYPOINT ["/run.sh"]
EXPOSE 3306
