#!/usr/bin/env bash

IGNORED_LIST=('zsh' 'tmux' 'bash' 'gtk')
SKIP_LIST=('refind') # not linkable, ESP deploy via scripts/deploy-refind.sh

# "<config dir>:<required command>:<os>" — empty command = any, empty os = any.
# A config is skipped when its command is missing or the OS does not match.
# A config dir with no entry here is always linked.
REQUIREMENTS=(
  'btop:btop:'
  'fastfetch:fastfetch:'
  'hypr:Hyprland:linux'
  'jamesdsp:jamesdsp:linux'
  'k9s:k9s:'
  'kitty:kitty:'
  'lazydocker:lazydocker:'
  'lazygit:lazygit:'
  'mako:mako:linux'
  'mise:mise:'
  'nwg-displays:nwg-displays:linux'
  'nwg-look:nwg-look:linux'
  'rofi:rofi:linux'
  'waybar:waybar:linux'
  'wlogout:wlogout:linux'
  'xsettingsd:xsettingsd:linux'
  'yazi:yazi:'
)

DRY_RUN=false
FORCE=false
ARGS=()
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --all) FORCE=true ;;
    *) ARGS+=("$arg") ;;
  esac
done

EXCLUDE_LIST=("${ARGS[@]}") # config dir names to skip, e.g. ./initialize.sh hypr waybar

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/../config"

# shellcheck source=env-detect.sh
. "$SCRIPT_DIR/env-detect.sh"
OS="$(detect_os)"

if ! $DRY_RUN; then
  mkdir -p "$HOME/.config"
fi

link() { # link <source> <target>
  if $DRY_RUN; then
    echo "[dry-run] ln -sf $1 $2"
  else
    ln -sf "$1" "$2"
    echo "Linked $1 -> $2"
  fi
}

# Helper function to check if an element is in an array
containsElement() {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

# Print skip reason for a config dir, or return 1 when it can be linked
skip_reason() { # skip_reason <config dir>
  local req dir cmd os
  for req in "${REQUIREMENTS[@]}"; do
    IFS=: read -r dir cmd os <<<"$req"
    [ "$dir" = "$1" ] || continue
    if [ -n "$os" ] && [ "$os" != "$OS" ]; then
      echo "needs $os, running $OS"
      return 0
    fi
    if [ -n "$cmd" ] && ! command -v "$cmd" >/dev/null 2>&1; then
      echo "$cmd not installed"
      return 0
    fi
  done
  return 1
}

# Process each item in the config directory
for item in "$CONFIG_DIR"/*; do
  [ -e "$item" ] || continue # skip if no files
  base="$(basename "$item")"

  if containsElement "$base" "${EXCLUDE_LIST[@]}"; then
    echo "Skipped $base (excluded)"
    continue
  fi

  if containsElement "$base" "${SKIP_LIST[@]}"; then
    echo "Skipped $base (use scripts/deploy-refind.sh)"
    continue
  fi

  if ! $FORCE && reason="$(skip_reason "$base")"; then
    echo "Skipped $base ($reason)"
    continue
  fi

  if ! containsElement "$base" "${IGNORED_LIST[@]}"; then
    # Not ignored: link directly to ~/.config/
    target="$HOME/.config/$base"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
      echo "Backup needed: $target (already exists and is not a symlink)"
    else
      link "$item" "$target"
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
          link "$subitem" "$target"
        fi
      done
      shopt -u dotglob # restore default behaviour
    else
      # If the ignored item itself is a file (unexpected), fall back to normal linking
      target="$HOME/.config/$base"
      if [ -e "$target" ] && [ ! -L "$target" ]; then
        echo "Backup needed: $target (already exists and is not a symlink)"
      else
        link "$item" "$target"
      fi
    fi
  fi
done

echo "Done."
