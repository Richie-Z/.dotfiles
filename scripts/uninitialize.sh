#!/usr/bin/env bash

IGNORED_LIST=('zsh' 'tmux' 'bash' 'gtk')
HOME_DIR_LIST=('agents')
FLAT_LIST=('dolphin') # contents link into ~/.config/, not the directory itself

DRY_RUN=false
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(cd "$SCRIPT_DIR/../config" && pwd)"

# shellcheck source=lib.sh
. "$SCRIPT_DIR/lib.sh"

for item in "$CONFIG_DIR"/*; do
  [ -e "$item" ] || continue
  base="$(basename "$item")"
  while IFS=$'\t' read -r src target; do
    unlink_if_ours "$target"
  done < <(config_links "$base" "$item")
done

echo "Done."
