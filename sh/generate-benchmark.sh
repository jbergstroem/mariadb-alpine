#!/usr/bin/env bash
# shellcheck shell=bash
set -euo pipefail

# Fetches latest version and compressed size from dockerhub
# TODO Benchmark should be run as part of release engineering/automation
# TODO Sort benchmark by container size
# TODO Fetch latest tag instead of digest for containers in benchmark
# TODO Add size factor compared to smallest container in benchmark

declare -A images=(
  ["mysql"]="library/mysql"
  ["mariadb"]="library/mariadb"
  ["bitnami/mariadb"]="bitnami/mariadb"
  ["linuxserver/mariadb"]="linuxserver/mariadb"
  ["clearlinux/mariadb"]="clearlinux/mariadb"
  ["**jbergstroem/mariadb-alpine**"]="jbergstroem/mariadb-alpine"
)

output=("| image name | size | digest (version) |")
output+=("|:--|:--|:--|")
for image in "${!images[@]}"; do
  result=$(curl -L -s "https://hub.docker.com/v2/repositories/${images[${image}]}/tags?page_size=100" | jq '.results[] | select(.name =="latest")')
  size=$(echo "${result}" | jq '.full_size' | numfmt --from=iec --to=iec-i --format "%.1f")
  digest=$(echo "${result}" | jq -r '.digest')
  short_digest=$(echo "${result}" | jq -r '.digest | sub("sha256:";"") | .[0:8]')
  output+=("| ${image} | ${size} | [${short_digest}](https://hub.docker.com/layers/${images[${image}]}/latest/images/${digest}?context=explore) |")
done

printf "%s\n" "${output[@]}"
