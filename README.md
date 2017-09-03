# Just another MariaDB in Alpine Linux container

[![](https://images.microbadger.com/badges/version/jbergstroem/mariadb-alpine.svg)](https://microbadger.com/images/jbergstroem/mariadb-alpine "Get your own version badge on microbadger.com") [![](https://images.microbadger.com/badges/image/jbergstroem/mariadb-alpine.svg)](https://microbadger.com/images/jbergstroem/mariadb-alpine "Get your own image badge on microbadger.com") 

Here's another MariaDB container based on [Alpine Linux][1]. It's opinionated and trades tools and functionality for disk size/startup speed. See it as a small, quick-to-get-going development edition.

I intend to keep this up to date, building a new container on each new MariaDB release, meaning `:latest` actually mean latest as well as having the comfort of staying with `10.1.26` should you prefer.

In addition to this, the versioning will also try to stay close to $current Alpine Linux version, meaning should `3.7` be released; this versioning will additionally be updated.

[1]: https://alpinelinux.org


## But why?

Since you're new, lets start with Alpine. Alpine Linux is (with their own words) security-oriented, lightweight Linux distribution based on musl libc and busybox.

Being based on musl gives the additional benefit of size concerns. Each megabyte matters.

### Another MariaDB container though?

1.  The ones I found were out of date. Either based on the 5.x series or just not kept up to date
2.  It was obviously too large
3.  Not trapping CTRL+C. Not being able to quickly signal out is annoying.


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

Need something else gone? Added? File a PR.


## Usage

Todo. Mount storage folder to `/var/lib/mysql`.

### Customization

You can override default behavior by passing environment variables:

-   MYSQL_DATABASE (defaults to unset): setting this executes a
    `create database if not exists` query
-   MYSQL_USER (defaults to `root`): setting this will create a user and assign
    ownership over the database you _may_ provide
-   MYSQL_PASSWORD (defaults to unset): setting this will change the password
    of either the user you provide or default (`root`).

## License

[APL-2](./LICENSE).
