# Benchmarks

The main goal of this project is to save disk space and startup time.
At the moment, only disk space is tracked. Check out the tool to generate this data [here][1].

| image name                     | size    | digest (version)                                                                                                                                                           |
| :----------------------------- | :------ | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| linuxserver/mariadb            | 83.6Mi  | [9e01d531](https://hub.docker.com/layers/linuxserver/mariadb/latest/images/sha256:9e01d531a25d272309f6eb80da1b13cce5f80c17cc5c834cebc16a926dc12b88?context=explore)        |
| **jbergstroem/mariadb-alpine** | 12.3Mi  | [b01ecfa7](https://hub.docker.com/layers/jbergstroem/mariadb-alpine/latest/images/sha256:b01ecfa73d8ec2374541065c37dc429f7ab3a5fb208196e7691c698c6a9d9037?context=explore) |
| clearlinux/mariadb             | 278.0Mi | [e7010077](https://hub.docker.com/layers/clearlinux/mariadb/latest/images/sha256:e7010077b93ec174b08d23bed943a746997f2a38263510361c7c94e9e0893462?context=explore)         |
| mariadb                        | 118.4Mi | [59ef1139](https://hub.docker.com/layers/library/mariadb/latest/images/sha256:59ef1139afa1ec26f98e316a8dbef657daf9f64f84e9378b190d1d7557ad2feb?context=explore)            |
| bitnami/mariadb                | 109.0Mi | [e10d22f3](https://hub.docker.com/layers/bitnami/mariadb/latest/images/sha256:e10d22f3f3348335a21da21bea92c6471be708c34e9ab244d1444740b06e2f5a?context=explore)            |
| mysql                          | 150.0Mi | [147572c9](https://hub.docker.com/layers/library/mysql/latest/images/sha256:147572c972192417add6f1cf65ea33edfd44086e461a3381601b53e1662f5d15?context=explore)              |

[1]: ../sh/generate-benchmark.sh
