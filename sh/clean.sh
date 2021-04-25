#!/bin/sh
set -euo pipefail

TO_KEEP=$(echo "
  usr/bin/mariadbd$
  usr/bin/mysqld$
  usr/bin/getconf$
  usr/bin/getent$
  usr/bin/my_print_defaults$
  usr/bin/mariadb-install-db$
  usr/share/mariadb/charsets
  usr/share/mariadb/english
  usr/share/mariadb/mysql_system_tables.sql$
  usr/share/mariadb/mysql_performance_tables.sql$
  usr/share/mariadb/mysql_system_tables_data.sql$
  usr/share/mariadb/maria_add_gis_sp_bootstrap.sql$
  usr/share/mariadb/fill_help_tables.sql$" |
  tr -d " \t\n\r" | sed -e 's/usr/|usr/g' -e 's/^.//')

# Only keep the output certificate from ca-certificates
cp /etc/ssl/certs/ca-certificates.crt /tmp/

# We don't use pam to authenticate but its listed as a dependency
INSTALLED_FILES="$(apk info -q -L mariadb-client)
$(apk info -q -L mariadb-common)
$(apk info -q -L mariadb)
$(apk info -q -L linux-pam)
$(apk info -q -L ca-certificates)"

# move certificate back into place
rm -f /etc/ssl/certs/*
mv /tmp/ca-certificates.crt /etc/ssl/certs/

for path in $(echo "${INSTALLED_FILES}" | grep -v -E "${TO_KEEP}"); do
  eval rm -rf "${path}"
done
