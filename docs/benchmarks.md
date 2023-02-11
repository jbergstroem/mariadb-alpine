# Benchmarks

The main goal of this project is to save disk space and startup time.
Only disk space and daemon version is tracked for now. Check out the tool to generate this data [here][1].

| Image name                     | Compressed size (Original) | Version                                                                                                  |
| :----------------------------- | :------------------------- | :------------------------------------------------------------------------------------------------------- |
| **jbergstroem/mariadb-alpine** | 14.2Mi (40.3Mi)            | [10.6.12](https://hub.docker.com/layers/jbergstroem/mariadb-alpine/latest/images/latest?context=explore) |
| linuxserver/mariadb            | 84.8Mi (277.1Mi)           | [10.6.12](https://hub.docker.com/layers/linuxserver/mariadb/latest/images/latest?context=explore)        |
| bitnami/mariadb                | 111.7Mi (355.2Mi)          | [10.10.3](https://hub.docker.com/layers/bitnami/mariadb/latest/images/latest?context=explore)            |
| mariadb                        | 117.4Mi (382.0Mi)          | [10.10.3](https://hub.docker.com/layers/library/mariadb/latest/images/latest?context=explore)            |
| mysql                          | 145.7Mi (493.5Mi)          | [8.0.32](https://hub.docker.com/layers/library/mysql/latest/images/latest?context=explore)               |
| clearlinux/mariadb             | 296.3Mi (927.5Mi)          | [10.9.2](https://hub.docker.com/layers/clearlinux/mariadb/latest/images/latest?context=explore)          |

[1]: ../sh/generate-benchmark.sh
