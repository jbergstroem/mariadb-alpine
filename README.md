<p align="center">
  <br>
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/jbergstroem/mariadb-alpine/main/mariadb-alpine-light.svg">
    <img width="480" alt="mariadb-alpine" src="https://raw.githubusercontent.com/jbergstroem/mariadb-alpine/main/mariadb-alpine.svg">
  </picture>
</p>
<p align="center">
  <img src="https://img.shields.io/docker/v/jbergstroem/mariadb-alpine?style=flat&color=999&sort=semver">
  <img src="https://img.shields.io/docker/image-size/jbergstroem/mariadb-alpine?style=flat&color=999&sort=semver">
  <img src="https://img.shields.io/docker/pulls/jbergstroem/mariadb-alpine?style=flat&color=999&sort=semver">
</p>
<p align="center">
  <a href="#a-tiny-mariadb-container">About</a> |
  <a href="#features">Features</a> |
  <a href="docs/usage.md">Usage</a> |
  <a href="docs/configuration.md">Configuration</a> |
  <a href="docs/testing.md">Testing</a> |
  <a href="docs/benchmarks.md">Benchmarks</a>
</p>

---

# A tiny MariaDB container

The goal of this project is to provide a tiny, high quality and fast starting container for [MariaDB][1].
It is built on the excellent, container-friendly Linux distribution [Alpine Linux][2].

The project intentionally trims edges to achieve arguably the smallest and fastest starting MariaDB. Should you run into problems, feel free to [open an issue][3].

Licensed under [MIT][4].

## Features

- Lightning fast startup; everything is built with performance in mind.
- Multi-arch: currently supports `amd64`, `arm/v6`, `arm/v7`, `arm64`, `386`, `s390x` and `ppc64le`
- Test suite: Each PR is tested to make sure that things stay working
- No bin-logging: Most deployments don't use this by default
- Supports Docker secrets
- Conveniently skip InnoDB: Gain a few seconds on startup
- Reduce default settings for InnoDB: production deployments should have their on `my.cnf`
- `CTRL+C` shuts down a running container in interactive mode
- Bundles a MariaDB client: `docker run -it --entrypoint mariadb jbergstoem/mariadb-alpine`

## Quickstart

```console
$ docker run -it --rm -p 3306:3306 \
    --name=mariadb \
    -e SKIP_INNODB=1 \
    jbergstroem/mariadb-alpine
```

## Next steps

- [Usage](docs/usage.md)
- [Configuration](docs/configuration.md)
- [Tests](docs/tests.md)
- [Benchmarks](docs/benchmarks.md)
- [Developer documentation](docs/development.md)

[1]: https://mariadb.org
[2]: https://alpinelinux.org
[3]: https://github.com/jbergstroem/mariadb-alpine/issues
[4]: ./LICENSE
