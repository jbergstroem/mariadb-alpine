# Tests

This container image is tested with [`bash_unit`][1] - a bash testing framework.
You can find installation instructions in [their repository][2]
(using homebrew: `brew install bash_unit`). To test:

```console
$ sh/build-image.sh
<snip>
$ IMAGE_VERSION=8c43ec9 bash_unit test/*.sh
Running tests in test/basic.sh
  Running test_connect_and_version_output ... SUCCESS ✓
  Running test_verify_no_default_binlog ... SUCCESS ✓
Running tests in test/compose.sh
  Running test_root_password_secret ... SUCCESS ✓
  Running test_user_password_secret_override ... SUCCESS ✓
Running tests in test/config.sh
  Running test_custom_charset_collation ... SUCCESS ✓
  Running test_custom_database ... SUCCESS ✓
  Running test_custom_dsn ... SUCCESS ✓
  Running test_custom_root_password ... SUCCESS ✓
  Running test_mount_custom_config ... SUCCESS ✓
  Running test_no_innodb_ariadb_default ... SUCCESS ✓
Running tests in test/import.sh
  Running test_import_compressed_sql ... SUCCESS ✓
  Running test_import_sql ... SUCCESS ✓
  Running test_run_shell_script ... SUCCESS ✓
Running tests in test/innodb.sh
  Running test_default_innodb_no_password ... SUCCESS ✓
  Running test_innodb_no_volume_issue_1 ... SUCCESS ✓
Overall result: SUCCESS ✓
```

[1]: https://github.com/pgrange/bash_unit
[2]: https://github.com/pgrange/bash_unit#how-to-install-bash_unit
