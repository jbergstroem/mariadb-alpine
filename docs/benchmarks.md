# Benchmarks

The main goal of this project is to save disk space and startup time.
Only disk space and daemon version is tracked for now. Check out the tool to generate this data [here][1].

| Image name                     | Compressed size (Original) | Version                                                                                                  |
| :----------------------------- | :------------------------- | :------------------------------------------------------------------------------------------------------- |
| **jbergstroem/mariadb-alpine** | 14.2Mi (40.2Mi)            | [10.6.11](https://hub.docker.com/layers/jbergstroem/mariadb-alpine/latest/images/latest?context=explore) |
| linuxserver/mariadb            | 83.6Mi (274.2Mi)           | [10.6.10](https://hub.docker.com/layers/linuxserver/mariadb/latest/images/latest?context=explore)        |
| bitnami/mariadb                | 112.1Mi (357.0Mi)          | [10.10.2](https://hub.docker.com/layers/bitnami/mariadb/latest/images/latest?context=explore)            |
| mariadb                        | 119.9Mi (390.7Mi)          | [10.10.2](https://hub.docker.com/layers/library/mariadb/latest/images/latest?context=explore)            |
| mysql                          | 145.0Mi (490.4Mi)          | [8.0.32](https://hub.docker.com/layers/library/mysql/latest/images/latest?context=explore)               |
| clearlinux/mariadb             | 297.2Mi (928.9Mi)          | [10.9.2](https://hub.docker.com/layers/clearlinux/mariadb/latest/images/latest?context=explore)          |

[1]: ../sh/generate-benchmark.sh
