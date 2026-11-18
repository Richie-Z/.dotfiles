#!/usr/bin/env bash

IGNORED_LIST=('zsh' 'tmux' 'bash' 'gtk')
HOME_DIR_LIST=('agents')
# Directories whose *contents* link into ~/.config/ individually, for apps that
# read plain files there (KDE: dolphinrc, kiorc, ...) instead of a dir.
FLAT_LIST=('dolphin')
SKIP_LIST=('refind') # not linkable, ESP deploy via scripts/deploy-refind.sh

# "<config dir>:<required command>:<os>" — empty command = any, empty os = any.
# A command may list alternatives separated by | (binary or path).
# A config is skipped when its command is missing or the OS does not match.
# A config dir with no entry here is always linked.
REQUIREMENTS=(
  'Moonlight Game Streaming Project:moonlight|/Applications/Moonlight.app:'
  'btop:btop:'
  'dolphin:dolphin:linux'
  'fastfetch:fastfetch:'
  'gtk:gtk-launch|gtk4-launch:'
  'hypr:Hyprland:linux'
  'jamesdsp:jamesdsp:linux'
  'k9s:k9s:'
  'kitty:kitty|/Applications/kitty.app:'
  'lazydocker:lazydocker:'
  'lazygit:lazygit:'
  'mako:mako:linux'
  'mise:mise:'
  'nwg-displays:nwg-displays:linux'
  'nwg-look:nwg-look:linux'
  'opencode:opencode:'
  'rofi:rofi:linux'
  'waybar:waybar:linux'
  'wlogout:wlogout:linux'
  'xsettingsd:xsettingsd:linux'
  'yazi:yazi:'
)

DRY_RUN=false
FORCE=false
PRUNE=true
FAILED=false
ARGS=()
for arg in "$@"; do
  case "$arg" in
  --dry-run) DRY_RUN=true ;;
  --all) FORCE=true ;;
  --no-prune) PRUNE=false ;;
  --*)
    echo "Unknown flag: $arg" >&2
    exit 2
    ;;
  *) ARGS+=("$arg") ;;
  esac
done

EXCLUDE_LIST=("${ARGS[@]}") # config dir names to skip, e.g. ./initialize.sh hypr waybar

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(cd "$SCRIPT_DIR/../config" && pwd)"

# shellcheck source=env-detect.sh
. "$SCRIPT_DIR/env-detect.sh"
# shellcheck source=lib.sh
. "$SCRIPT_DIR/lib.sh"
OS="$(detect_os)"

if ! $DRY_RUN; then
  mkdir -p "$HOME/.config"
fi

link() { # link <source> <target>
  if [ -e "$2" ] && [ ! -L "$2" ]; then
    echo "Backup needed: $2 (already exists and is not a symlink)"
  elif $DRY_RUN; then
    echo "[dry-run] ln -sf $1 $2"
  elif rm -f "$2" && ln -s "$1" "$2"; then
    # rm first: `ln -sf src existing-dirlink` nests a link inside the dir
    # instead of replacing it, and -n/-h differ between GNU and BSD ln.
    echo "Linked $1 -> $2"
  else
    echo "Failed: $2" >&2
    FAILED=true
  fi
}

# Remove every deployed link for a config dir, at the targets config_links names.
prune() { # prune <config dir> <source path>
  local src target
  while IFS=$'\t' read -r src target; do
    unlink_if_ours "$target"
  done < <(config_links "$1" "$2")
}

# Print skip reason for a config dir, or return 1 when it can be linked
skip_reason() { # skip_reason <config dir>
  local req dir cmd os c
  for req in "${REQUIREMENTS[@]}"; do
    IFS=: read -r dir cmd os <<<"$req"
    [ "$dir" = "$1" ] || continue
    if [ -n "$os" ] && [ "$os" != "$OS" ]; then
      echo "needs $os, running $OS"
      return 0
    fi
    [ -z "$cmd" ] && return 1
    local IFS='|'
    for c in $cmd; do
      if command -v "$c" >/dev/null 2>&1 || [ -e "$c" ]; then
        return 1
      fi
    done
    echo "$cmd not installed"
    return 0
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
    $PRUNE && prune "$base" "$item"
    continue
  fi

  while IFS=$'\t' read -r src target; do
    link "$src" "$target"
  done < <(config_links "$base" "$item")
done

if $FAILED; then
  echo "Finished with errors." >&2
  exit 1
fi
echo "Done."
