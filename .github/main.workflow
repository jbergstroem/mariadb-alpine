workflow "lint" {
  on = "push"
  resolves = ["hadolint", "shfmt", "shellcheck"]
}

action "hadolint" {
  uses = "docker://cdssnc/docker-lint"
}

action "shellcheck" {
  uses = "bltavares/actions/shellcheck@master"
  args = "*.sh"
}

action "shfmt" {
  uses = "bltavares/actions/shfmt@master"
}
