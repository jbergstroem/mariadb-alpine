# Configuring your deployment

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

## Adding a custom config

You can add your custom `my.cnf` with various settings (be it for production or tuning InnoDB).
You can also add other `.cnf` files in `/etc/my.cnf.d/`, which will be [included by MariaDB on start][1].
Note: If you mount your own configs, defaults and custom logic like `SKIP_INNODB` will be ignored.

```console
$ docker run -it --rm --name=mariadb \
    -v $(pwd)/config/my.cnf:/etc/my.cnf.d/my.cnf:ro \
    jbergstroem/mariadb-alpine
```

## Executing custom sql on startup

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

Shell scripts will have the `mariadb` cli available. Should you set a database, username or password,
remember to pass these options to the `mariadb` client.

## Using Docker Secrets

[Docker secrets][2] is a way for you to manage sensitive information and avoid passing
said info through environment variables. Secrets are only available when using Docker compose
(with our without a Swarm context).

By defining `MYSQL_PASSWORD` or `MYSQL_ROOT_PASSWORD` as a secret, the container will use
(and prefer) these over any environment variables passed.

You can find [an example in usage][3].

[1]: https://git.alpinelinux.org/aports/tree/main/mariadb/APKBUILD#n327
[2]: https://docs.docker.com/engine/swarm/secrets/#about-secrets
[3]: ./usage.md
