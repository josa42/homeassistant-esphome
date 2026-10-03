#!/usr/bin/env bash
#
# Mirror the ESPHome configs from Home Assistant into this repo, or push the
# repo's configs back with --push.
#
# Mount the Samba share first (Finder: smb://homeassistant.local/config).
#
# Usage: ./sync.sh [--dry-run] [--push] [source]
#   source defaults to $ESPHOME_SRC or /Volumes/config/esphome

set -euo pipefail

cd "$(dirname "$0")"

args=()
push=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run | -n) args+=(--dry-run) ;;
    --push | -p) push=true ;;
    *) break ;;
  esac
  shift
done

src="${1:-${ESPHOME_SRC:-/Volumes/config/esphome}}"

if [[ ! -d "$src" ]]; then
  echo "error: $src not found, is the Home Assistant config share mounted?" >&2
  exit 1
fi

if $push; then
  # No --delete: files that only exist on Home Assistant are left alone.
  from=./
  to="$src/"
else
  # Files deleted on Home Assistant are deleted here too; git keeps the history.
  args+=(--delete)
  from="$src/"
  to=./
fi

rsync -a --itemize-changes "${args[@]+"${args[@]}"}" \
  --exclude='/.git/' \
  --exclude='.esphome/' \
  --exclude='.pioenvs/' \
  --exclude='.piolibdeps/' \
  --exclude='/.device-builder*' \
  --exclude='/secrets.yaml' \
  --exclude='.DS_Store' \
  --exclude='/sync.sh' \
  --exclude='/.gitignore' \
  --exclude='/secrets.yaml.example' \
  --exclude='/README.md' \
  "$from" "$to"

if ! $push; then
  git status --short
fi
