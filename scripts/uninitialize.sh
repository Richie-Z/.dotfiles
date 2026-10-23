#!/usr/bin/env bash

IGNORED_LIST=('zsh' 'tmux' 'bash' 'gtk')
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

  if ! containsElement "$base" "${IGNORED_LIST[@]}" && ! containsElement "$base" "${FLAT_LIST[@]}"; then
    unlink_if_ours "$HOME/.config/$base"
  elif [ -d "$item" ]; then
    dest="$HOME"
    containsElement "$base" "${FLAT_LIST[@]}" && dest="$HOME/.config"
    shopt -s dotglob
    for subitem in "$item"/*; do
      [[ -e "$subitem" ]] || continue
      unlink_if_ours "$dest/$(basename "$subitem")"
    done
    shopt -u dotglob
  else
    unlink_if_ours "$HOME/.config/$base"
  fi
done

echo "Done."
