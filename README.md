[![mariadb-alpine](site/img/mariadb-alpine.png)](https://github.com/jbergstroem/mariadb-alpine)

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
- No bin-logging: Not your default-case deployment
- Reduce default settings for InnoDB: production deployments should have their on `my.cnf`
- Conveniently skip InnoDB: Gain a few seconds on startup
- Ultra-fast startup: all init scripts are re-rewritten or skipped for a faster startup
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

The `root` user is intentionally left passwordless. Should you insist setting one, pass `MYSQL_ROOT_PASSWORD` at initialization stage:

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
         -v db:/var/lib/mysql
         jbergstroem/mariadb-alpine
```

### Customization

You can override default behavior by passing environment variables. All flags
are unset unless provided.

-  **MYSQL_DATABASE**: creates a database as provided by input
-  **MYSQL_USER**: creates a user with owner permissions over said database
-  **MYSQL_PASSWORD**: changes password of the provided user (not root)
-  **MYSQL_ROOT_PASSWORD**: sets a root password
-  **SKIP_INNODB**: skip using InnoDB which shaves off both time and
   disk allocation size. If you mount a persistent volume
   this setting will be remembered.

### Adding custom sql on init

When a database is empty, the `mysql_install_db` script will be invoked. As part of this, you can pass custom input via the commonly used `/docker-entrypoint-initdb.d` convention. This will not be run when an existing database is found.

```console
$ mkdir init && echo "create database mydatabase;" > init/mydatabase.sql
$ echo "#\!/bin/sh\necho Hello from script" > init/custom.sh
$ docker volume create db
db
$ docker run -it --rm -e SKIP_INNODB=1 -v db:/var/lib/mysql -v $(PWD)/init:/docker-entrypoint-initdb.d jbergstroem/mariadb-alpine:latest
init: installing mysql client
init: updating system tables
init: adding /docker-entrypoint-initdb.d/mydatabase.sql
init: executing /docker-entrypoint-initdb.d/custom.sh
Hello from script
init: removing mysql client
2019-06-17 18:41:14 0 [Note] /usr/bin/mysqld (mysqld 10.3.15-MariaDB) starting as process 55 ...
2019-06-17 18:41:14 0 [Note] Plugin 'InnoDB' is disabled.
2019-06-17 18:41:14 0 [Note] Plugin 'FEEDBACK' is disabled.
2019-06-17 18:41:14 0 [Note] Server socket created on IP: '::'.
2019-06-17 18:41:14 0 [Note] Reading of all Master_info entries succeded
2019-06-17 18:41:14 0 [Note] Added new Master_info '' to hash table
2019-06-17 18:41:14 0 [Note] /usr/bin/mysqld: ready for connections.
Version: '10.3.15-MariaDB'  socket: '/run/mysqld/mysqld.sock'  port: 3306  MariaDB Server
```

The procedure is similar to how other containers implements it; shell scripts are executed (`.sh`), optionally compressed sql (`.sql` or `.sql.gz`) is piped to mysqld as part of it starting up. Any script or sql will use the scope of `MYSQL_DATABASE` if provided.

## Testing

This container image is tested with [`bats`][3] - a bash testing framework. You can find installation
instructions in [their repository][4]. To test:

```console
$ bin/build-image.sh
<snip>
$ bats test
 ✓ should output mysqld version
 ✓ start a default server with InnoDB and no password
 ✓ start a server without a dedicated volume (issue #1)
 ✓ start a server without InnoDB
 ✓ start a server with a custom root password
 ✓ start a server with a custom database
 ✓ start a server with a custom database, user and password
 ✓ verfiy that binary logging is turned off
 ✓ should import a .sql file and execute it
 ✓ should import a compressed file and execute it
 ✓ should execute an imported shell script

11 tests, 0 failures
```

## Benchmarks

The main goal of this project is to save disk space and startup time. At the moment,
we only track disk space:

 | Name | Version | Size |
 | ---- | ------- | ---- |
 | mysql  | <img src="https://img.shields.io/docker/v/_/mysql/5.7?color=666&label=%22%22"> | <img src="https://img.shields.io/docker/image-size/_/mysql/5.7?color=666&label=%22%22"> |
 | mariadb | <img src="https://img.shields.io/docker/v/_/mariadb/10.4?color=666&label=%22%22"> | <img src="https://img.shields.io/docker/image-size/_/mariadb/10.4?color=666&label=%22%22"> |
 | bitnami/mariadb | <img src="https://img.shields.io/docker/v/bitnami/mariadb/10.4?color=666&label=%22%22"> | <img src="https://img.shields.io/docker/image-size/bitnami/mariadb/10.4?color=666&label=%22%22"> |
 | yobasystems/alpine-mariadb | <img src="https://img.shields.io/docker/v/yobasystems/alpine-mariadb?color=666&label=%22%22"> | <img src="https://img.shields.io/docker/image-size/yobasystems/alpine-mariadb?color=666&label=%22%22"> |
 | jbergstroem/mariadb-alpine | <img src="https://img.shields.io/docker/v/jbergstroem/mariadb-alpine?color=666&&sort=semver&label="> | <img src="https://img.shields.io/docker/image-size/jbergstroem/mariadb-alpine?color=666&sort=semver&label="> |

[1]: https://mariadb.org
[2]: https://alpinelinux.org
[3]: https://github.com/bats-core/bats-core
[4]: https://github.com/bats-core/bats-core#installation
