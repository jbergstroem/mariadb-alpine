#!/usr/bin/env bash
# shellcheck shell=bash
set -euo pipefail

# Fetches images, extracts daemon version and container size
# TODO Benchmark should be run as part of release engineering/automation

declare -A images=(
  ["mysql"]="library/mysql"
  ["mariadb"]="library/mariadb"
  ["bitnami/mariadb"]="bitnami/mariadb"
  ["linuxserver/mariadb"]="linuxserver/mariadb"
  ["clearlinux/mariadb"]="clearlinux/mariadb"
  ["**jbergstroem/mariadb-alpine**"]="jbergstroem/mariadb-alpine"
)

for image in "${!images[@]}"; do
  entrypoint=mariadbd
  [[ "${image}" == "mysql" ]] && entrypoint="mysqld"
  docker pull -q "${images[$image]}:latest" >/dev/null 2>&1
  version=$(docker run -it --rm --entrypoint "${entrypoint}" "${images[$image]}:latest" --version)
  [[ "${version}" =~ Ver[[:space:]]([0-9]+.[0-9]+.[0-9]+) ]]
  parsed_version="${BASH_REMATCH[1]}"
  compressed_size=$(curl -L -s "https://hub.docker.com/v2/repositories/${images[${image}]}/tags?page_size=100" | jq '.results[] | select(.name =="latest") | .full_size' | numfmt --from=iec --to=iec-i --format "%.1f")
  size=$(docker image inspect -f "{{.Size}}" "${images[$image]}" | numfmt --from=iec --to=iec-i --format "%.1f")
  output+=("| ${image} | ${compressed_size} (${size}) | [${parsed_version}](https://hub.docker.com/layers/${images[$image]}/latest/images/latest?context=explore) |")
  # some images may already exist on disk and be in use, we don't care if pruning fails
  docker rmi "${images[$image]}" >/dev/null 2>&1 || true
done

echo "| Image name | Compressed size (Original) | Version |"
echo "|:--|:--|:--|"
printf "%s\n" "${output[@]}" | sort -t '|' -k 3 -h
