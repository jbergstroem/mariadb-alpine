# A (small) MariaDB container

[![](https://images.microbadger.com/badges/version/jbergstroem/mariadb-alpine.svg)](https://microbadger.com/images/jbergstroem/mariadb-alpine "Get your own version badge on microbadger.com") [![](https://images.microbadger.com/badges/image/jbergstroem/mariadb-alpine.svg)](https://microbadger.com/images/jbergstroem/mariadb-alpine "Get your own image badge on microbadger.com") 

Here's another MariaDB container based on [Alpine Linux][1]. It's opinionated and trades tools and functionality for disk size/startup speed. See it as a small, quick-to-get-going development edition.

I intend to keep this up to date, building a new container on each new MariaDB release, meaning `:latest` actually mean latest as well as having the comfort of staying with `10.1.26` should you prefer.

In addition to this, the versioning will also try to stay close to $current Alpine Linux version, meaning should `3.7` be released; this versioning will additionally be updated.

[1]: https://alpinelinux.org


## But why?

Since you're new, lets start with Alpine. Alpine Linux is (in their own words) a security-oriented, lightweight Linux distribution based on musl libc and busybox.

Being based on musl gives the additional benefit of size concerns. Each kilobyte matters.

### Another MariaDB container though?

1.  The ones I found were out of date. Either based on the 5.x series or just not kept up to date
2.  They were obviously too large
3.  Didn't trap CTRL+C -- not being able to quickly signal out is annoying.
4.  Startup needs to be lighting fast


## Changed behavior

### No more bin-logging

Replication from your docker image? Seriously.

### Shrink default settings for InnoDB

Pretty sure you don't need 50mb (x2) pre-allocated files.

### Removed tooling

Here's what's gone (so far):
-   mysql_* !mysql_install_db 
-   aria*
-   myisam*
-   innochecksum
-   mariabackup
-   mbstream
-   mysqlslap
-   mysqltest
-   mysql_test_embedded
-   my_print_defaults
-   resolve_stack_dump
-   resolveip
-   replace

### Faster initialization

Replaced both init and seeding scripts with as little boilerplate as possible.

### Laxed ACL

`root` Just Works without having to take hosts into consideration. You can set a root password on initialization should you need the extra security. You can
always increase it further with custom sql past creation.

### Your feature here

Need something else gone? Added? File a PR.


## Usage

Typical usage would look something like this:
```console
$ docker run -it --rm --name=db \
         -v $(PWD)/mariadb/:/var/lib/mysql \
         jbergstroem/mariadb-alpine
```

Or, creating your own database with a user/password assigned to it:
```console
$ docker run -it --rm --name=db \
         -v $(PWD)/mariadb/:/var/lib/mysql \
         -e MYSQL_USER=foo \
         -e MYSQL_DATABASE=bar \
         -e MYSQL_PASSWORD=baz \
         jbergstroem/mariadb-alpine
```

The `root` user is intentionally left passwordless. Should you need the extra security layer, pass `MYSQL_ROOT_PASSWORD` at initialization stage.

### Customization

You can override default behavior by passing environment variables:

-   MYSQL_DATABASE (defaults to unset): setting this executes a
    `create database if not exists` query
-   MYSQL_USER (defaults to `root`): setting this will create a user and assign
    ownership over the database you _may_ provide
-   MYSQL_PASSWORD (defaults to unset): setting this will change the password
    of the user you provide.
-   MYSQL_ROOT_PASSWORD (defaults to unset): setting this will set a
    root password.
-   SKIP_INNODB (defaults to unset): this can be used to skip using InnoDB
    which will shave off both time and size. Note: If you do this at
    initialization, you will have to subsequently pass it. This is a good thing.


## License

[APL-2](./LICENSE).
