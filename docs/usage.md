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

### Import tzdata

Certain functions in mariadb such as `convert_tz()` relies on tzdata being
available in the database which isn't loaded by default.

This snippet starts a mariadb container and loads data through another container.
The import only needs to be run once since the data persists in the mysql database.

```console
$ docker network create db
33a220c8af110295accde1df7157de7e665e7852d25ac2e9d80a7ca12625619b
$ docker run --network db --name db -d -e SKIP_INNODB=1 -p 3306:3306 jbergstroem/mariadb-alpine
733de227b9a7b54039e13be922e8c7f13e509665377e402db9d56fd2f86415b3
$ docker run -it alpine
/ # apk add --no-cache -q mariadb mariadb-client tzdata
/ # mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -u root -h db mysql
```

As you can imagine, this is easy to script or incorporate as part of a container orchestration.

[1]: ../test/compose.sh
[2]: ./configuration.md
