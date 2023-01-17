# Benchmarks

The main goal of this project is to save disk space and startup time.
At the moment, only disk space is tracked. Check out the tool to generate this data [here][1].

| image name                     | size    | digest (version)                                                                                                                                                           |
| :----------------------------- | :------ | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| linuxserver/mariadb            | 83.6Mi  | [60bd7088](https://hub.docker.com/layers/linuxserver/mariadb/latest/images/sha256:60bd7088278c0932cfece3f4826270a9eadacce9937833c92160f783a273b5fc?context=explore)        |
| **jbergstroem/mariadb-alpine** | 14.2Mi  | [b7047653](https://hub.docker.com/layers/jbergstroem/mariadb-alpine/latest/images/sha256:b7047653c525d0d59f2bd6ee85ef61e0b04ae045e15cbc201c693c9df7020df6?context=explore) |
| clearlinux/mariadb             | 296.8Mi | [18b7731b](https://hub.docker.com/layers/clearlinux/mariadb/latest/images/sha256:18b7731b27e8611dce0aee633039d6c3e770d0f32d2c652d3d446a0b61efd401?context=explore)         |
| mariadb                        | 119.9Mi | [8c15c3de](https://hub.docker.com/layers/library/mariadb/latest/images/sha256:8c15c3def7ae1bb408c96d322a3cc0346dba9921964d8f9897312fe17e127b90?context=explore)            |
| bitnami/mariadb                | 112.1Mi | [d28caf04](https://hub.docker.com/layers/bitnami/mariadb/latest/images/sha256:d28caf04ae49091c0ee360d2390ae2bee3a9f89897838e79477f5077b458a5ab?context=explore)            |
| mysql                          | 153.2Mi | [3d7ae561](https://hub.docker.com/layers/library/mysql/latest/images/sha256:3d7ae561cf6095f6aca8eb7830e1d14734227b1fb4748092f2be2cfbccf7d614?context=explore)              |

[1]: ../sh/generate-benchmark.sh
