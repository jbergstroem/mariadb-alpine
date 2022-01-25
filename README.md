<p align="center">
  <a href="https://github.com/jbergstroem/mariadb-alpine#gh-light-mode-only"><img width="450" src="mariadb-alpine.svg"></a>
  <a href="https://github.com/jbergstroem/mariadb-alpine#gh-dark-mode-only"><img width="450" src="mariadb-alpine-light.svg"></a>
</p>
<p align="center">
  <img src="https://img.shields.io/docker/v/jbergstroem/mariadb-alpine?color=999&sort=semver">
  <img src="https://img.shields.io/docker/image-size/jbergstroem/mariadb-alpine?color=999&sort=semver">
  <img src="https://img.shields.io/docker/pulls/jbergstroem/mariadb-alpine?color=999&sort=semver">
</p>
<p align="center">
  <a href="#a-tiny-mariadb-image">About</a> |
  <a href="#features">Features</a> |
  <a href="#usage">Usage</a> |
  <a href="#testing">Testing</a> |
  <a href="#benchmarks">Benchmarks</a>
</p>

---

# A tiny MariaDB image

The goal of this project is to achieve a high quality, bite-sized, fast startup docker image for [MariaDB][1].
It is built on the excellent, container-friendly Linux distribution [Alpine Linux][2].

Licensed under [MIT](./LICENSE).

## Features

- Test suite: Each PR is tested to make sure that things stay working
- Ultra-fast startup: all init scripts are re-rewritten or skipped for a faster startup
- No bin-logging: Not your default-case deployment
- Conveniently skip InnoDB: Gain a few seconds on startup
- Reduce default settings for InnoDB: production deployments should have their on `my.cnf`
- Simple and fast shutdowns: Both `CTRL+C` in interactive mode and `docker stop` does the job
- Permissive ACL: A minimal no-flags startup "just works"; convenient for development
- Your feature here: File an issue or PR

## Usage

"Default" startup:

```console
$ docker run -it --rm --name=db \
         jbergstroem/mariadb-alpine
```

If you prefer skipping InnoDB (read: faster), this is for you:

```console
$ docker run -it --rm --name=db \
         -e SKIP_INNODB=yes \
         jbergstroem/mariadb-alpine
```

Creating your own database with a user/password assigned to it:

```console
$ docker run -it --rm --name=db \
         -e MYSQL_USER=foo \
         -e MYSQL_DATABASE=bar \
         -e MYSQL_PASSWORD=baz \
         jbergstroem/mariadb-alpine
```

The `root` user is intentionally left password-less. Should you insist setting one, pass `MYSQL_ROOT_PASSWORD` at initialization stage:

```console
$ docker run -it --rm --name=db \
         -e MYSQL_ROOT_PASSWORD=secretsauce \
         jbergstroem/mariadb-alpine
```

Using a volume to persist your storage across restarts:

```console
$ docker volume create db
db
$ docker run -it --rm --name=db \
         -v db:/var/lib/mysql \
         jbergstroem/mariadb-alpine
```

Using a volume and a port to allow the host to access the container:

```console
$ docker volume create db
db
$ docker run -it --rm --name=db \
         -v db:/var/lib/mysql \
         -p 3306:3306
         jbergstroem/mariadb-alpine
```

### Customization

You can override default behavior by passing environment variables. All flags
are unset unless provided.

- **MYSQL_DATABASE**: create a database as provided by input
- **MYSQL_CHARSET**: set charset for said database
- **MYSQL_COLLATION**: set default collation for said database
- **MYSQL_USER**: create a user with owner permissions over said database
- **MYSQL_PASSWORD**: change password of the provided user (not root)
- **MYSQL_ROOT_PASSWORD**: set a root password
- **SKIP_INNODB**: skip using InnoDB which shaves off both time and
  disk allocation size. If you mount a persistent volume
  this setting will be remembered.

### Adding your custom config

You can add your custom `my.cnf` with various settings (be it for production or tuning InnoDB).
You can also add other `.cnf` files in `/etc/my.cnf.d/` they will be loaded.
Note: this will bypass `SKIP_INNODB` since it is injected into the default config on launch.

```console
$ docker run -it --rm --name=db \
         -v $(pwd)/config/my.cnf:/etc/my.cnf.d/my.cnf:ro \
         jbergstroem/mariadb-alpine
```

### Adding custom sql on init

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
2020-06-21  5:28:02 0 [Note] /usr/bin/mysqld (mysqld 10.4.13-MariaDB) starting as process 1 ...
2020-06-21  5:28:03 0 [Note] Plugin 'InnoDB' is disabled.
2020-06-21  5:28:03 0 [Note] Plugin 'FEEDBACK' is disabled.
2020-06-21  5:28:03 0 [Note] Server socket created on IP: '::'.
2020-06-21  5:28:03 0 [Note] Reading of all Master_info entries succeeded
2020-06-21  5:28:03 0 [Note] Added new Master_info '' to hash table
2020-06-21  5:28:03 0 [Note] /usr/bin/mysqld: ready for connections.
Version: '10.4.13-MariaDB'  socket: '/run/mysqld/mysqld.sock'  port: 3306  MariaDB Server
```

The procedure is similar to how other images implements it; shell scripts are executed (`.sh`), optionally compressed sql (`.sql` or `.sql.gz`) is piped to mysqld as part of it starting up. Any script or sql will use the scope of `MYSQL_DATABASE` if provided.

## Testing

This container image is tested with [`bats`][3] - a bash testing framework. You can find installation
instructions in [their repository][4]. To test:

```console
$ sh/build-image.sh
<snip>
$ VERSION=c363434 sh/run-tests.bash
 ✓ should output mysqld version
 ✓ start a default server with InnoDB and no password
 ✓ start a server without a dedicated volume (issue #1)
 ✓ start a server without InnoDB
 ✓ start a server with a custom root password
 ✓ start a server with a custom database
 ✓ start a server with a custom database, user and password
 ✓ verify that binary logging is turned off
 ✓ should allow a user to pass a custom config
 ✓ should import a .sql file and execute it
 ✓ should import a compressed file and execute it
 ✓ should execute an imported shell script

12 tests, 0 failures
```

## Benchmarks

The main goal of this project is to save disk space and startup time. At the moment,
we only track disk space:

| Name                       | Version                                                                                              | Size                                                                                                         |
| -------------------------- | ---------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| mysql                      | <img src="https://img.shields.io/docker/v/_/mysql/5.7?color=666&label=%22%22">                       | <img src="https://img.shields.io/docker/image-size/_/mysql/5.7?color=666&label=%22%22">                      |
| mariadb                    | <img src="https://img.shields.io/docker/v/_/mariadb/10.4?color=666&label=%22%22">                    | <img src="https://img.shields.io/docker/image-size/_/mariadb/10.4?color=666&label=%22%22">                   |
| bitnami/mariadb            | <img src="https://img.shields.io/docker/v/bitnami/mariadb/10.4?color=666&label=%22%22">              | <img src="https://img.shields.io/docker/image-size/bitnami/mariadb/10.4?color=666&label=%22%22">             |
| yobasystems/alpine-mariadb | <img src="https://img.shields.io/docker/v/yobasystems/alpine-mariadb?color=666&label=%22%22">        | <img src="https://img.shields.io/docker/image-size/yobasystems/alpine-mariadb?color=666&label=%22%22">       |
| jbergstroem/mariadb-alpine | <img src="https://img.shields.io/docker/v/jbergstroem/mariadb-alpine?color=666&&sort=semver&label="> | <img src="https://img.shields.io/docker/image-size/jbergstroem/mariadb-alpine?color=666&sort=semver&label="> |
| tobi312/rpi-mariadb        | <img src="https://img.shields.io/docker/v/tobi312/rpi-mariadb?color=666&&sort=semver&label=">        | <img src="https://img.shields.io/docker/image-size/tobi312/rpi-mariadb?color=666&sort=semver&label=">        |
| linuxserver/mariadb:alpine | <img src="https://img.shields.io/docker/v/linuxserver/mariadb/alpine?color=666&&sort=semver&label="> | <img src="https://img.shields.io/docker/image-size/linuxserver/mariadb/alpine?color=666&sort=semver&label="> |

[1]: https://mariadb.org
[2]: https://alpinelinux.org
[3]: https://github.com/bats-core/bats-core
[4]: https://github.com/bats-core/bats-core#installation
