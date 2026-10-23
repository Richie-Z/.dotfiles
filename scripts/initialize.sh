#!/usr/bin/env bash

IGNORED_LIST=('zsh' 'tmux' 'bash' 'gtk')
# Directories whose *contents* link into ~/.config/ individually, for apps that
# read plain files there (KDE: dolphinrc, kiorc, ...) instead of a dir.
FLAT_LIST=('dolphin')
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
CONFIG_DIR="$(cd "$SCRIPT_DIR/../config" && pwd)"

# shellcheck source=env-detect.sh
. "$SCRIPT_DIR/env-detect.sh"
OS="$(detect_os)"

if ! $DRY_RUN; then
  mkdir -p "$HOME/.config"
fi

link() { # link <source> <target>
  if $DRY_RUN; then
    echo "[dry-run] ln -sfn $1 $2"
  else
    # -n: replace a symlink that points at a directory instead of nesting a
    # link inside it (ln -sf src existing-dirlink creates dirlink/<base>).
    ln -sfn "$1" "$2"
    echo "Linked $1 -> $2"
  fi
}

# Link every entry of a directory into a destination dir (dotfiles included)
link_contents() { # link_contents <source dir> <dest dir>
  local src="$1" dest="$2" subitem target
  if [ ! -d "$src" ]; then
    link "$src" "$dest/$(basename "$src")"
    return
  fi
  shopt -s dotglob
  for subitem in "$src"/*; do
    [[ -e "$subitem" ]] || continue
    target="$dest/$(basename "$subitem")"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
      echo "Backup needed: $target (already exists and is not a symlink)"
    else
      link "$subitem" "$target"
    fi
  done
  shopt -u dotglob # restore default behaviour
}

# Remove the deployed symlink for a skipped config, only when it points into
# this repo. Real files and foreign symlinks are never touched.
unlink_if_ours() { # unlink_if_ours <target>
  local target="$1"
  [ -L "$target" ] || return 0
  case "$(readlink -f "$target")" in
    "$CONFIG_DIR"/*)
      if $DRY_RUN; then
        echo "[dry-run] rm -f $target"
      else
        rm -f "$target"
        echo "Removed $target"
      fi
      ;;
  esac
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
    unlink_if_ours "$HOME/.config/$base"
    continue
  fi

  if containsElement "$base" "${IGNORED_LIST[@]}"; then
    # Contents link into $HOME/ (e.g. config/zsh/.zshrc -> ~/.zshrc)
    link_contents "$item" "$HOME"
  elif containsElement "$base" "${FLAT_LIST[@]}"; then
    # Contents link into ~/.config/ (e.g. config/dolphin/dolphinrc)
    link_contents "$item" "$HOME/.config"
  else
    # Not ignored: link directly to ~/.config/
    target="$HOME/.config/$base"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
      echo "Backup needed: $target (already exists and is not a symlink)"
    else
      link "$item" "$target"
    fi
  fi
done

echo "Done."
