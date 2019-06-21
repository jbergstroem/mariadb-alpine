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
