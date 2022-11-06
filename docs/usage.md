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

### Use a volume and a different port (3307) to access the container

```console
$ docker volume create db
db
$ docker run -it --rm --name=mariadb \
    -v db:/var/lib/mysql \
    -p 3307:3306 \
    jbergstroem/mariadb-alpine
```

### Use it as part of a docker-compose orchestration

```yaml
version: "3.9"

services:
  db:
    image: jbergstroem/mariadb-alpine:latest
    restart: always
    environment:
      MYSQL_DATABASE: "db"
      MYSQL_USER: "user"
      MYSQL_PASSWORD: "password"
      MYSQL_ROOT_PASSWORD: "password"
      SKIP_INNODB: "yes"
    ports:
      - "3306:3306"
    volumes:
      - my-db:/var/lib/mysql

volumes:
  my-db:
```

### Mount secrets as part of docker compose

This is taken from the [mariadb-alpine test suite][1], which intentionally overrides
`MYSQL_USER_PASSWORD` to showcase that secrets takes precedence over environment variables.

The files `root.txt` and `user.txt` contains the passwords in plaintext. Instead of using
files, you can manage secrets through `docker secrets`. Make sure that your secrets are named
appropriately and assign them in the secrets section.

```yaml
version: "3.9"

services:
  db:
    image: jbergstroem/mariadb-alpine:latest
    environment:
      MYSQL_DATABASE: "db"
      MYSQL_USER: "foo"
      MYSQL_PASSWORD: "password"
    ports:
      - "3306:3306"
    secrets:
      - MYSQL_ROOT_PASSWORD
      - MYSQL_PASSWORD

secrets:
  MYSQL_ROOT_PASSWORD:
    file: ./root.txt
  MYSQL_PASSWORD:
    file: ./user.txt
```

All ways to configure the container can be found in [configuration][2].

[1]: ../test/compose.sh
[2]: ./configuration.md
