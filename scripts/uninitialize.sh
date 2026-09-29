#!/usr/bin/env bash

IGNORED_LIST=('zsh' 'tmux' 'bash' 'gtk')

DRY_RUN=false
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(cd "$SCRIPT_DIR/../config" && pwd)"

# Remove target only if it is a symlink pointing into our config dir.
# Real files are never touched.
unlink_if_ours() {
  local target="$1"
  if [ ! -e "$target" ] && [ ! -L "$target" ]; then
    return 0
  fi
  if [ ! -L "$target" ]; then
    echo "Kept $target (not a symlink)"
    return 0
  fi
  case "$(readlink -f "$target")" in
    "$CONFIG_DIR"/*)
      if $DRY_RUN; then
        echo "[dry-run] rm -f $target"
      else
        rm -f "$target"
        echo "Removed $target"
      fi
      ;;
  *)
    echo "Kept $target (points outside $CONFIG_DIR)"
    ;;
  esac
}

containsElement() {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

for item in "$CONFIG_DIR"/*; do
  [ -e "$item" ] || continue
  base="$(basename "$item")"

  if ! containsElement "$base" "${IGNORED_LIST[@]}"; then
    unlink_if_ours "$HOME/.config/$base"
  elif [ -d "$item" ]; then
    shopt -s dotglob
    for subitem in "$item"/*; do
      [[ -e "$subitem" ]] || continue
      unlink_if_ours "$HOME/$(basename "$subitem")"
    done
    shopt -u dotglob
  else
    unlink_if_ours "$HOME/.config/$base"
  fi
done

echo "Done."
