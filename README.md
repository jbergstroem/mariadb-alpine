# A MariaDB container suitable for development

[![](https://images.microbadger.com/badges/version/jbergstroem/mariadb-alpine.svg)](https://microbadger.com/images/jbergstroem/mariadb-alpine) [![](https://images.microbadger.com/badges/image/jbergstroem/mariadb-alpine.svg)](https://microbadger.com/images/jbergstroem/mariadb-alpine)

Here's another MariaDB container based on [Alpine Linux][1]. It's opinionated: trade tools and functionality for startup speed/disk size. See it as a small, quick-to-get-going development edition.

I intend to keep this up to date, building a new container on each new MariaDB release, meaning `:latest` actually mean latest as well as having the comfort of staying with `10.3.13` should you prefer.

Container size and assumptions about default featureset. It's considerably faster to get up and running.

1. The ones I found were out of date. Either based on the 5.x series or just not kept up to date
2. They were obviously too large
3. Didn't trap CTRL+C -- not being able to quickly signal out is annoying.
4. Startup needs to be lighting fast

Here's a quick comparison:

| Name                       | Version | Compressed size |
| -------------------------- | ------- | --------------- |
| mysql                      | 5.7.25  | 124mb           |
| mariadb                    | 10.2.21 | 114mb           |
| bitnami/mariadb            | 10.2.21 | 93mb            |
| webhippie/mariadb          | 10.1.26 | 72mb            |
| yobasystems/alpine-mariadb | amd64   | 46mb            |
| jbergstroem/mariadb-alpine | 10.1.26 | **12mb**        |
| jbergstroem/mariadb-alpine | 10.2.19 | **12mb**        |
| jbergstroem/mariadb-alpine | 10.3.13 |                 |

## Changes from other containers

### No more bin-logging

Replication from your docker image? Seriously.

### Shrink default settings for InnoDB

Pretty sure you don't need 50mb (x2) pre-allocated files.

### Optional InnoDB

I rarely use InnoDB in testing/development. Provide the option to skip it.

### Removed tooling

Remove a lot of "quality of life: userland-tools, startup scripts, test stuff and replication-related tools.

### Faster initialization

Replaced both init and seeding scripts with as little boilerplate as possible.

### Permissive ACL

`root` Just Works™️ without having to take connecting hostname into consideration. You can set a root password on initialization should you prefer the extra security. You can always improve your state further with custom sql past creation.

### Your feature here

Need something else gone? Added (less likely)? File a PR.

## Usage

Note! Because of a [bug with innodb allocation][2] you will have to create a docker volume first. Below examples will make the assumption you created one:

```console
$ docker volume create db
db
```

"Default" startup:

```console
$ docker run -it --rm --name=db \
         -v db:/var/lib/mysql \
         jbergstroem/mariadb-alpine
```

If you prefer skipping InnoDB (read: faster), this is for you:

```console
$ docker run -it --rm --name=db \
         -v db:/var/lib/mysql \
         -e SKIP_INNODB=yes \
         jbergstroem/mariadb-alpine
```

Creating your own database with a user/password assigned to it:

```console
$ docker run -it --rm --name=db \
         -v db:/var/lib/mysql \
         -e MYSQL_USER=foo \
         -e MYSQL_DATABASE=bar \
         -e MYSQL_PASSWORD=baz \
         jbergstroem/mariadb-alpine
```

The `root` user is intentionally left passwordless. Should you insist setting one, pass `MYSQL_ROOT_PASSWORD` at initialization stage:

```console
$ docker run -it --rm --name=db \
         -v db:/var/lib/mysql \
         -e MYSQL_ROOT_PASSWORD=secretsauce \
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

## License

[APL-2](./LICENSE).

[1]: https://alpinelinux.org
[2]: https://github.com/jbergstroem/mariadb-alpine/issues/1
