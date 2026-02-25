#!/usr/bin/env bash

IGNORED_LIST=('zsh' 'tmux' 'bash' 'gtk')

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/../config"

mkdir -p "$HOME/.config"

# Helper function to check if an element is in an array
containsElement() {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

# Process each item in the config directory
for item in "$CONFIG_DIR"/*; do
  [ -e "$item" ] || continue # skip if no files
  base="$(basename "$item")"

  if ! containsElement "$base" "${IGNORED_LIST[@]}"; then
    # Not ignored: link directly to ~/.config/
    target="$HOME/.config/$base"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
      echo "Backup needed: $target (already exists and is not a symlink)"
    else
      ln -sf "$item" "$target"
      echo "Linked $item -> $target"
    fi
  else
    # Ignored directory: link its contents (including hidden files) to $HOME/
    if [ -d "$item" ]; then
      # Enable matching of dotfiles
      shopt -s dotglob
      for subitem in "$item"/*; do
        # After enabling dotglob, we need to skip . and .. explicitly
        [[ -e "$subitem" ]] || continue
        subbase="$(basename "$subitem")"
        target="$HOME/$subbase"

        if [ -e "$target" ] && [ ! -L "$target" ]; then
          echo "Backup needed: $target (already exists and is not a symlink)"
        else
          ln -sf "$subitem" "$target"
          echo "Linked $subitem -> $target"
        fi
      done
      shopt -u dotglob # restore default behaviour
    else
      # If the ignored item itself is a file (unexpected), fall back to normal linking
      target="$HOME/.config/$base"
      if [ -e "$target" ] && [ ! -L "$target" ]; then
        echo "Backup needed: $target (already exists and is not a symlink)"
      else
        ln -sf "$item" "$target"
        echo "Linked $item -> $target"
      fi
    fi
  fi
done

echo "Done."
