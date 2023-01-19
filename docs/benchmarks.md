# Benchmarks

The main goal of this project is to save disk space and startup time.
At the moment, only disk space is tracked. Check out the tool to generate this data [here][1].

| image name                     | size    | digest (version)                                                                                                                                                           |
| :----------------------------- | :------ | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **jbergstroem/mariadb-alpine** | 14.2Mi  | [b7047653](https://hub.docker.com/layers/jbergstroem/mariadb-alpine/latest/images/sha256:b7047653c525d0d59f2bd6ee85ef61e0b04ae045e15cbc201c693c9df7020df6?context=explore) |
| linuxserver/mariadb            | 83.6Mi  | [1795674a](https://hub.docker.com/layers/linuxserver/mariadb/latest/images/sha256:1795674a017595743b822fc1603d4bbad4bc24b8c465d497caf5b911a938c2e3?context=explore)        |
| bitnami/mariadb                | 112.1Mi | [d13796a1](https://hub.docker.com/layers/bitnami/mariadb/latest/images/sha256:d13796a155183987011ce580617af39a0d876f33dc0738347d30057fdcfe7fe2?context=explore)            |
| mariadb                        | 119.9Mi | [8c15c3de](https://hub.docker.com/layers/library/mariadb/latest/images/sha256:8c15c3def7ae1bb408c96d322a3cc0346dba9921964d8f9897312fe17e127b90?context=explore)            |
| mysql                          | 145.0Mi | [6f54880f](https://hub.docker.com/layers/library/mysql/latest/images/sha256:6f54880f928070a036aa3874d4a3fa203adc28688eb89e9f926a0dcacbce3378?context=explore)              |
| clearlinux/mariadb             | 297.2Mi | [35a7f2e9](https://hub.docker.com/layers/clearlinux/mariadb/latest/images/sha256:35a7f2e9b817ce1f1fc12ec568f8b0e9d1941a8b57cf57b4053f68c3e1eaa010?context=explore)         |

[1]: ../sh/generate-benchmark.sh
