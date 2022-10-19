<p align="center">
  <br>
  <picture>
    <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/jbergstroem/mariadb-alpine/main/mariadb-alpine.svg">
    <img width="480" alt="mariadb-alpine" src="https://raw.githubusercontent.com/jbergstroem/mariadb-alpine/main/mariadb-alpine-light.svg">
  </picture>
</p>
<p align="center">
  <img src="https://img.shields.io/docker/v/jbergstroem/mariadb-alpine?style=flat&color=999&sort=semver">
  <img src="https://img.shields.io/docker/image-size/jbergstroem/mariadb-alpine?style=flat&color=999&sort=semver">
  <img src="https://img.shields.io/docker/pulls/jbergstroem/mariadb-alpine?style=flat&color=999&sort=semver">
</p>
<p align="center">
  <a href="#a-tiny-mariadb-image">About</a> |
  <a href="#features">Features</a> |
  <a href="#usage">Usage</a> |
  <a href="#testing">Testing</a> |
  <a href="#benchmarks">Benchmarks</a>
</p>

---

# A tiny MariaDB container

The goal of this project is to achieve a high quality, bite-sized, fast startup docker image for [MariaDB][1].
It is built on the excellent, container-friendly Linux distribution [Alpine Linux][2].

The container makes certain compromises to achieve arguably the smallest and fastest starting MariaDB. Should you run into problems, feel free to [open an issue][8].

Licensed under [MIT][7].

## Features

- Lightning fast startup. Everything is built with performance in mind.
- Test suite: Each PR is tested to make sure that things stay working
- No bin-logging: Not relevant for most deployments
- Conveniently skip InnoDB: Gain a few seconds on startup
- Reduce default settings for InnoDB: production deployments should have their on `my.cnf`
- Simple and fast shutdowns: Both `CTRL+C` in interactive mode and `docker stop` does the job
- Your feature here: File an issue or PR

## Usage

"Default" startup:

```console
$ docker run -it --rm -p 3306:3306 --name=mariadb \
    jbergstroem/mariadb-alpine
```

Disable InnoDB (faster startup):

```console
$ docker run -it --rm --name=mariadb \
    -e SKIP_INNODB=yes \
    jbergstroem/mariadb-alpine
```

Create a database with a user/password to access it:

```console
$ docker run -it --rm --name=mariadb \
    -e MYSQL_USER=foo \
    -e MYSQL_DATABASE=bar \
    -e MYSQL_PASSWORD=baz \
    jbergstroem/mariadb-alpine
```

The `root` user is intentionally left password-less. To set it, define `MYSQL_ROOT_PASSWORD` at initialization stage:

```console
$ docker run -it --rm --name=mariadb \
    -e MYSQL_ROOT_PASSWORD=secret \
    jbergstroem/mariadb-alpine
```

Using a volume to persist your storage across restarts:

```console
$ docker volume create db
db
$ docker run -it --rm --name=mariadb \
    -v db:/var/lib/mysql \
    jbergstroem/mariadb-alpine
```

Using a volume and a different port (3307) to access the container:

```console
$ docker volume create db
db
$ docker run -it --rm --name=mariadb \
    -v db:/var/lib/mysql \
    -p 3307:3306 \
    jbergstroem/mariadb-alpine
```

### Customizing your deployment

You can override default behavior by passing environment variables or providing custom configs. **All flags are unset unless provided**.

Pass any of below as you would other environment variable to a container (below example uses `MYSQL_DATABASE`):

```console
$ docker run -it --rm --name=mariadb \
    -e MYSQL_DATABASE=mydatabase \
    jbergstroem/mariadb-alpine
```

| Variable                | Description                                                                                                                                   |
| ----------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| **MYSQL_DATABASE**      | Create a database with provided name                                                                                                          |
| **MYSQL_CHARSET**       | Define charset for provided database                                                                                                          |
| **MYSQL_COLLATION**     | Set default collation for provided database                                                                                                   |
| **MYSQL_USER**          | Create a user with owner permissions. Will be owner of the optionally provided database                                                       |
| **MYSQL_PASSWORD**      | Set a password of the provided user                                                                                                           |
| **MYSQL_ROOT_PASSWORD** | Set a root password. Will be unset otherwise                                                                                                  |
| **SKIP_INNODB**         | If set, disable InnoDB which shaves off both time and disk allocation size. If you mount a persistent volume this setting will be remembered. |

#### Adding a custom config

You can add your custom `my.cnf` with various settings (be it for production or tuning InnoDB).
You can also add other `.cnf` files in `/etc/my.cnf.d/`, which will be [included by MariaDB on start][5].
Note: If you mount your own configs, defaults and custom logic like `SKIP_INNODB` will be ignored.

```console
$ docker run -it --rm --name=mariadb \
    -v $(pwd)/config/my.cnf:/etc/my.cnf.d/my.cnf:ro \
    jbergstroem/mariadb-alpine
```

#### Executing custom sql on startpu

When a database is empty, the `mysql_install_db` script will be invoked. As part of this, you can pass custom input via the commonly used `/docker-entrypoint-initdb.d` convention. This will not be run when an existing database is found.

```console
$ mkdir init && echo "create database mydatabase;" > init/mydatabase.sql
$ echo "#\!/bin/sh\necho Hello from script" > init/custom.sh
$ docker volume create db
db
$ docker run -it --rm -e SKIP_INNODB=1 -v db:/var/lib/mysql -v $(pwd)/init:/docker-entrypoint-initdb.d jbergstroem/mariadb-alpine:latest
init: installing mysql client
init: updating system tables
init: executing /docker-entrypoint-initdb.d/custom.sh
Hello from script
init: adding /docker-entrypoint-initdb.d/mydatabase.sql
init: removing mysql client
2022-10-14 12:09:24 0 [Note] /usr/bin/mariadbd (server 10.6.9-MariaDB) starting as process 1 ...
2022-10-14 12:09:24 0 [Note] Plugin 'InnoDB' is disabled.
2022-10-14 12:09:24 0 [Note] Plugin 'FEEDBACK' is disabled.
2022-10-14 12:09:24 0 [Note] Server socket created on IP: '0.0.0.0'.
2022-10-14 12:09:24 0 [Note] /usr/bin/mariadbd: ready for connections.
Version: '10.6.9-MariaDB'  socket: '/run/mysqld/mysqld.sock'  port: 3306  MariaDB Server
```

The procedure is similar to how other images implements it; shell scripts are executed (`.sh`), optionally compressed sql (`.sql` or `.sql.gz`) is piped to mysqld as part of it starting up. Any sql will use the scope of `MYSQL_DATABASE` if provided.

Shell scripts will have the `mariadb` cli available. Should you set a database, username or password, remeber to
pass these options to the `mariadb` client.

## Tests

This container image is tested with [`bash_unit`][3] - a bash testing framework. You can find installation
instructions in [their repository][4] (using homebrew: `brew install bash_unit`). To test:

```console
$ sh/build-image.sh
<snip>
$ IMAGE_VERSION=a22c300 bash_unit test/*.sh
Running tests in test/basic.sh
  Running test_connect_and_version_output ... SUCCESS ✓
  Running test_verify_no_default_binlog ... SUCCESS ✓
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

## Benchmarks

The main goal of this project is to save disk space and startup time. At the moment, only disk space is tracked.
Check out the tool to generate this data [here][6].

| image name                     | size    | digest (version)                                                                                                                                                           |
| :----------------------------- | :------ | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| linuxserver/mariadb            | 83.6Mi  | [9e01d531](https://hub.docker.com/layers/linuxserver/mariadb/latest/images/sha256:9e01d531a25d272309f6eb80da1b13cce5f80c17cc5c834cebc16a926dc12b88?context=explore)        |
| **jbergstroem/mariadb-alpine** | 12.3Mi  | [b01ecfa7](https://hub.docker.com/layers/jbergstroem/mariadb-alpine/latest/images/sha256:b01ecfa73d8ec2374541065c37dc429f7ab3a5fb208196e7691c698c6a9d9037?context=explore) |
| clearlinux/mariadb             | 278.0Mi | [e7010077](https://hub.docker.com/layers/clearlinux/mariadb/latest/images/sha256:e7010077b93ec174b08d23bed943a746997f2a38263510361c7c94e9e0893462?context=explore)         |
| mariadb                        | 118.4Mi | [59ef1139](https://hub.docker.com/layers/library/mariadb/latest/images/sha256:59ef1139afa1ec26f98e316a8dbef657daf9f64f84e9378b190d1d7557ad2feb?context=explore)            |
| bitnami/mariadb                | 109.0Mi | [e10d22f3](https://hub.docker.com/layers/bitnami/mariadb/latest/images/sha256:e10d22f3f3348335a21da21bea92c6471be708c34e9ab244d1444740b06e2f5a?context=explore)            |
| mysql                          | 150.0Mi | [147572c9](https://hub.docker.com/layers/library/mysql/latest/images/sha256:147572c972192417add6f1cf65ea33edfd44086e461a3381601b53e1662f5d15?context=explore)              |

[1]: https://mariadb.org
[2]: https://alpinelinux.org
[3]: https://github.com/pgrange/bash_unit
[4]: https://github.com/pgrange/bash_unit#how-to-install-bash_unit
[5]: https://git.alpinelinux.org/aports/tree/main/mariadb/APKBUILD#n327
[6]: ./sh/generate-benchmark.sh
[7]: ./LICENSE
[8]: https://github.com/jbergstroem/mariadb-alpine/issues
