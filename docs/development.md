# Developer documentation

## Local testing and development

In order to assist with developing `mariadb-alpine`, the following software is strongly recommended:

- a [containerd][containerd] runtime such as [docker for desktop][docker] or [lima][lima-vm]
- a docker-cli compatible client (@TODO more testing with [nerdctl][], [podman][podman])
- [bash][bash] 4.0 or newer
- [bash_unit][bash_unit] - a bash testing framework
- [shellcheck][shellcheck] to validate shell script
- [hadolint][hadolint] to validate `Dockerfile`
- [shfmt][shfmt] to verify shell script style
- [actionlint][actionlint] to validate github workflows
- [prettier][prettier] (and [Node.js][node-js]) for checking code/documentation style
- [jq][jq], [curl][curl] and [coreutils][coreutils] for generating the benchmark
  Check [the CI lint workflow][ci-lint] to see which versions are tested against, but stick to $latest as a general rule.

From here you can build an image (`sh/build-image.sh`) or run tests with `bash_unit`.

## Cutting a release

To cut a release, you need to be a maintainer of the github repository. The repository contains
secrets with enough privileges to push containers to [Docker Hub][docker-hub].

Instead of tagging and building images locally, the release workflow is fully automated through [github actions][github-actions].

There are sanity checks in place to help you from making mistakes:
1. The workflow will only be run if there is no existing github or docker tag corresponding to
   the mariadbd version in `Dockerfile.
2. The workflow will fail if there are issues building or testing the container.
3. Only by changing

### To create a release (browser):

1. Visit the overview for [the Release workflow][release-workflow]
2. Click the button "Run workflow".
   You should be greeted by three inputs:
   - Branch: stick with the `main` branch unless you know what you're doing.
   - Replace existing tag: This will override any existing git tags as well as releases on docker hub. Useful if you broke a release. Can also be used with choosing branch/tag to build in order to rebuild older versions
   - update `:latest` tag on Docker Hub: only do this when cutting new (read: latest available) stable release
3. Hit "Run workflow" and wait a few minutes. Should tests or building containers fail, no tags or containers will be published to Github or Docker.
4. Should you run into issues, file a new issue in the repository and assign @jbergstroem.

<!-- @TODO Create a release with gh-cli -->

[containerd]: https://containerd.io
[docker]: https://docker.com
[nerdctl]: https://github.com/containerd/nerdctl
[podman]: https://podman.io
[lima-vm]: https://github.com/lima-vm/lima
[bash]: https://www.gnu.org/software/bash/
[bash_unit]: https://github.com/pgrange/bash_unit
[shellcheck]: https://github.com/koalaman/shellcheck
[hadolint]: https://github.com/hadolint/hadolint
[shfmt]: https://github.com/mvdan/sh
[actionlint]: https://github.com/rhysd/actionlint
[prettier]: https://prettier.io
[node-js]: https://nodejs.org/en/
[ci-lint]: ../.github/workflows/lint.yml
[curl]: https://curl.se
[jq]: https://stedolan.github.io/jq/
[coreutils]: https://www.gnu.org/software/coreutils/
[docker-hub]: https://hub.docker.com/r/jbergstroem/mariadb-alpine
[github-actions]: https://github.com/features/actions
[release-workflow]: https://github.com/jbergstroem/mariadb-alpine/actions/workflows/release.yml
