# Usage

### "Default" startup

```console
$ docker run -it --rm -p 3306:3306 --name=mariadb \
    jbergstroem/mariadb-alpine
```

### Disable InnoDB (faster startup)

```console
$ docker run -it --rm --name=mariadb \
    -e SKIP_INNODB=yes \
    jbergstroem/mariadb-alpine
```

### Create a database with a user/password to access it

```console
$ docker run -it --rm --name=mariadb \
    -e MYSQL_USER=foo \
    -e MYSQL_DATABASE=bar \
    -e MYSQL_PASSWORD=baz \
    jbergstroem/mariadb-alpine
```

### Set a root password

```console
$ docker run -it --rm --name=mariadb \
    -e MYSQL_ROOT_PASSWORD=secret \
    jbergstroem/mariadb-alpine
```

### Use a volume to persist your storage across restarts

```console
$ docker volume create db
db
$ docker run -it --rm --name=mariadb \
    -v db:/var/lib/mysql \
    jbergstroem/mariadb-alpine
```

### UUse a volume and a different port (3307) to access the container

```console
$ docker volume create db
db
$ docker run -it --rm --name=mariadb \
    -v db:/var/lib/mysql \
    -p 3307:3306 \
    jbergstroem/mariadb-alpine
```

Full options can be found in [configuration][1].

[1]: ./configuration.md