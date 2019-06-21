workflow "lint" {
  on = "push"
  resolves = ["hadolint", "shfmt", "shellcheck"]
}

action "hadolint" {
  uses = "docker://cdssnc/docker-lint"
}

action "shellcheck" {
  uses = "actions/bin/shellcheck@master"
  args = "*.sh"
}

action "shfmt" {
  uses = "bltavares/actions/shfmt@master"
}
