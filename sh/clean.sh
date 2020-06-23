#!/bin/sh
set -euo pipefail

TO_KEEP=$(echo "
  usr/bin/mysql$
  usr/bin/mysqld$
  usr/bin/mariadb$
  usr/bin/getconf$
  usr/bin/getent$
  usr/bin/my_print_defaults$
  usr/bin/mysql_install_db$
  usr/share/mariadb/charsets
  usr/share/mariadb/english
  usr/share/mariadb/mysql_system_tables.sql$
  usr/share/mariadb/mysql_performance_tables.sql$
  usr/share/mariadb/mysql_system_tables_data.sql$
  usr/share/mariadb/maria_add_gis_sp_bootstrap.sql$
  usr/share/mariadb/fill_help_tables.sql$" |
  tr -d " \t\n\r" | sed -e 's/usr/|usr/g' -e 's/^.//')

INSTALLED_FILES="$(apk info -q -L mariadb-client | tail -n +2)
$(apk info -q -L mariadb-common | tail -n +2)
$(apk info -q -L mariadb | tail -n +2)"

for path in $(echo "${INSTALLED_FILES}" | grep -v -E "${TO_KEEP}"); do
  eval rm -rf "${path}"
done
