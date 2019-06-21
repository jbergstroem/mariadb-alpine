workflow "lint" {
  on = "push"
  resolves = ["lint: hadolint", "lint: shfmt", "lint: shellcheck"]
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


workflow "docker" {
  on = "push"
  resolves = ["docker: build"]
}

action "docker: build" {
  needs = "lint: shfmt"
  uses = "actions/docker/cli@master"
  args = "build -t  jbergstroem/mariadb-alpine ."
}
