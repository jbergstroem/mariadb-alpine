#!/bin/sh
set -eo pipefail

#
# Clean MariaDB files we don't need
#
# Use `apk` to list package contents and selectively choose what we want
#

# General stuff that can go. `mysqld_safe` gets picked up by grep;
# so we need to remove it manually. Not sure how to work around this.
GENERAL="
	/usr/share/terminfo
	/usr/bin/mysqld_safe"

# Pointless plugins we want to remove because they're somewhat
# bigger than most other ones. Also, remove examples
PLUGINS="
    /usr/lib/mariadb/plugin/dialog_examples.so
    /usr/lib/mariadb/plugin/example_key_management.so
	/usr/lib/mariadb/plugin/ha_connect.so
    /usr/lib/mariadb/plugin/ha_example
    /usr/lib/mariadb/plugin/ha_spider.so
    /usr/lib/mariadb/plugin/handlersocket.so
    /usr/lib/mariadb/plugin/libdaemon_example.so"

# Things we'd like to keep. Double sed since busybox sed doesn't seem to
# support '2g' which would skip the first match.
KEEP=$(echo "usr/bin/mysqld
	usr/bin/getconf
	usr/bin/getent
	usr/bin/my_print_defaults
	usr/bin/mysql_install_db
	usr/share/mariadb/charsets
	usr/share/mariadb/english
	usr/share/mariadb/fill_help_tables.sql
	usr/share/mariadb/maria_add_gis_sp_bootstrap.sql
	usr/share/mariadb/mysql_test_db.sql
	usr/share/mariadb/mysql_performance_tables.sql
	usr/share/mariadb/mysql_system_tables.sql
	usr/share/mariadb/errmsg-utf8.txt
	usr/lib/mariadb" | sed -e 's/usr/|usr/g' -e 's/^.//' | tr -d " \t\n\r")


# Retrieve a list of files from `apk`, remove the header and finally 
# exclude files/folders in $KEEP
FILES="$(apk info -L mariadb | tail -n +2 | grep -v -E "${KEEP}")
	$(apk info -L mariadb-common | tail -n +2 | grep -v -E "${KEEP}")
	${PLUGINS}
	${GENERAL}"

# Finally, remove it all.
#
# Note: some path in packages are not absolute. By using readlink
# we either get full path to a file/directory or nothing at all
# echo:ing the content makes output more loop-friendly
cd /
for path in ${FILES}; do
	eval rm -rf "$(readlink -f "${path}")"
done

# Replace resolveip with a oneliner to shave some size
printf "#!/bin/sh\necho \"IP address of \${1} is 127.0.0.1\"" > /usr/bin/resolveip
chmod +x /usr/bin/resolveip
