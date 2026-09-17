#!/usr/bin/env bash
#
# Mirror the ESPHome configs from Home Assistant into this repo.
#
# Mount the Samba share first (Finder: smb://homeassistant.local/config).
#
# Usage: ./sync.sh [--dry-run] [source]
#   source defaults to $ESPHOME_SRC or /Volumes/config/esphome

set -euo pipefail

cd "$(dirname "$0")"

args=()
if [[ "${1:-}" == "--dry-run" || "${1:-}" == "-n" ]]; then
  args+=(--dry-run)
  shift
fi

src="${1:-${ESPHOME_SRC:-/Volumes/config/esphome}}"

if [[ ! -d "$src" ]]; then
  echo "error: $src not found, is the Home Assistant config share mounted?" >&2
  exit 1
fi

# Files deleted on Home Assistant are deleted here too; git keeps the history.
rsync -a --delete --itemize-changes "${args[@]+"${args[@]}"}" \
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
  "$src/" ./

git status --short
