workflow "lint" {
  on = "push"
  resolves = ["lint: hadolint", "lint: shfmt", "lint: shellcheck", "docker: build"]
}

action "lint: hadolint" {
  uses = "docker://cdssnc/docker-lint"
}

action "lint: shellcheck" {
  uses = "bltavares/actions/shellcheck@master"
  args = "*.sh"
}

action "lint: shfmt" {
  uses = "bltavares/actions/shfmt@master"
}

action "docker: build" {
  needs = ["lint: shfmt", "lint: shellcheck", "lint: hadolint"]
  uses = "actions/docker/cli@master"
  args = "build -t  jbergstroem/mariadb-alpine ."
}
