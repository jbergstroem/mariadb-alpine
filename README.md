# A (small) MariaDB container

[![](https://images.microbadger.com/badges/version/jbergstroem/mariadb-alpine.svg)](https://microbadger.com/images/jbergstroem/mariadb-alpine) [![](https://images.microbadger.com/badges/image/jbergstroem/mariadb-alpine.svg)](https://microbadger.com/images/jbergstroem/mariadb-alpine) 

Here's another MariaDB container based on [Alpine Linux][1]. It's opinionated: trade tools and functionality for startup speed/disk size. See it as a small, quick-to-get-going development edition.

I intend to keep this up to date, building a new container on each new MariaDB release, meaning `:latest` actually mean latest as well as having the comfort of staying with `10.1.26` should you prefer.

[1]: https://alpinelinux.org


## But why?

Since you're new, lets start with Alpine. Alpine Linux is (in their own words) a security-oriented, lightweight Linux distribution based on musl libc and busybox.

Being based on musl gives the additional benefit of size concerns. Each kilobyte matters.

### Another MariaDB container though?

1.  The ones I found were out of date. Either based on the 5.x series or just not kept up to date
2.  They were obviously too large
3.  Didn't trap CTRL+C -- not being able to quickly signal out is annoying.
4.  Startup needs to be lighting fast

Here's a quick comparison:

| Name                       | Version | Compressed size |
| -------------------------- | ------- | --------------- |
| mysql                      | 5.7.19  | 144mb           |
| mariadb                    | 10.1.26 | 135mb           |
| bitnami/mariadb            | 10.1.26 | 131mb           |
| yobasystems/alpine-mariadb | 10.1.22 | 59mb            |
| webhippie/mariadb          | 10.1.26 | 72mb            |
| jbergstroem/mariadb-alpine | 10.1.26 | **12mb**        |


## Changed behavior

### No more bin-logging

Replication from your docker image? Seriously.

### Shrink default settings for InnoDB

Pretty sure you don't need 50mb (x2) pre-allocated files.

### Optional InnoDB

I rarely use InnoDB in testing/development. Provide the option to skip it.

### Removed tooling

Here's what's gone (so far):
-   aria_chk
-   aria_dump_log
-   aria_ftdump
-   aria_pack
-   aria_read_log
-   myisamchk
-   myisamlog
-   myisampack
-   mysqld_multi
-   mysqld_safe
-   mysqld_safe_helper
-   mysqltest_embedded
-   innochecksum
-   mysqlslap
-   mysqltest
-   replace
-   resolveip
-   perror
-   wsrep_sst_common
-   wsrep_sst_mariabackup
-   wsrep_sst_mysqldump
-   wsrep_sst_rsync
-   wsrep_sst_xtrabackup
-   wsrep_sst_xtrabackup-v2
-   mytop
-   resolve_stack_dump
-   mariabackup
-   mbstream
-   mysqlbinlog
-   mysql_client_test_embedded
-   mysql_convert_table_format
-   mysql_embedded
-   mysql_plugin
-   mysql_secure_installation
-   mysql_setpermission
-   mysql_tzinfo_to_sql
-   mysql_upgrade
-   mysql_zap

### Faster initialization

Replaced both init and seeding scripts with as little boilerplate as possible.

### Permissive ACL

`root` Just Works™️ without having to take connecting hostname into consideration. You can set a root password on initialization should you prefer the extra security. You can always improve your state further with custom sql past creation.

### Your feature here

Need something else gone? Added (less likely)? File a PR.


## Usage

Typical usage:
```console
$ docker run -it --rm --name=db \
         -v $(PWD)/mariadb/:/var/lib/mysql \
         jbergstroem/mariadb-alpine
```

If you prefer skipping InnoDB (read: faster), this is for you:
```console
$ docker run -it --rm --name=db \
         -v $(PWD)/mariadb/:/var/lib/mysql \
         -e SKIP_INNODB=yes \
         jbergstroem/mariadb-alpine
```

Creating your own database with a user/password assigned to it:
```console
$ docker run -it --rm --name=db \
         -v $(PWD)/mariadb/:/var/lib/mysql \
         -e MYSQL_USER=foo \
         -e MYSQL_DATABASE=bar \
         -e MYSQL_PASSWORD=baz \
         jbergstroem/mariadb-alpine
```

The `root` user is intentionally left passwordless. If you insist on one, pass `MYSQL_ROOT_PASSWORD` at initialization stage:
```console
$ docker run -it --rm --name=db \
         -v $(PWD)/mariadb/:/var/lib/mysql \
         -e MYSQL_ROOT_PASSWORD=secretsauce \
         jbergstroem/mariadb-alpine
```

### Customization

You can override default behavior by passing environment variables. All flags
are unset unless provided.

-   **MYSQL_DATABASE**: creates a database as provided by input
-   **MYSQL_USER**: creates a user with owner permissions over said database
-   **MYSQL_PASSWORD**: changes password of the provided user (not root)
-   **MYSQL_ROOT_PASSWORD**: sets a root password
-   **SKIP_INNODB**: skip using InnoDB which shaves off both time and
                     disk allocation size. If you mount a persistent volume 
                     this setting will be remembered.


## License

[APL-2](./LICENSE).
