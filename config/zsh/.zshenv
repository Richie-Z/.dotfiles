# =======================
# Core environment
# =======================
export XDG_CONFIG_HOME="$HOME/.config"
export EDITOR="nvim"

# Base paths
export PROGRAMMING_PATH="$HOME/Documents/Programming"
export DOTFILES_PATH="$PROGRAMMING_PATH/Projects/dotfiles"

# =======================
# Environment detection
# =======================
if [ -f "$DOTFILES_PATH/scripts/env-detect.sh" ]; then
  . "$DOTFILES_PATH/scripts/env-detect.sh"
fi

OS="$(detect_os 2>/dev/null)"
DISPLAY_SERVER="$(detect_display 2>/dev/null)"

if [ "$OS" = "linux" ]; then
  case "$DISPLAY_SERVER" in
  wayland) LINUX_DISTRO="arch" ;;
  xorg) LINUX_DISTRO="debian" ;;
  *) LINUX_DISTRO="unknown" ;;
  esac
fi

# =======================
# PATH bootstrap
# =======================
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# =======================
# macOS
# =======================
if [ "$OS" = "mac" ]; then
  # Homebrew
  export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

  # Android SDK (macOS layout)
  export ANDROID_HOME="$HOME/Library/Android/Sdk"
  export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"

  # Flutter
  export PATH="$HOME/Development/flutter/bin:$PATH"

  # PostgreSQL (Homebrew)
  export LDFLAGS="-L/opt/homebrew/opt/postgresql@16/lib"
  export CPPFLAGS="-I/opt/homebrew/opt/postgresql@16/include"
  export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"

  # VS Code
  export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"
fi

# =======================
# Linux
# =======================
if [ "$OS" = "linux" ]; then
  # Podman
  export DOCKER_HOST="unix:///run/user/1000/podman/podman.sock"

  case "$LINUX_DISTRO" in
  arch)
    # Wayland / Arch specific hooks live here
    :
    ;;
  debian)
    # Xorg / Debian specific hooks live here
    :
    ;;
  esac
fi

# =======================
# Tooling (cross-platform)
# =======================

# Bun
[ -d "$HOME/.bun/bin" ] && export PATH="$HOME/.bun/bin:$PATH"

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
*":$PNPM_HOME:"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac

# uv / local bins
[ -d "$HOME/.local/bin" ] && export PATH="$HOME/.local/bin:$PATH"

# Mason (Neovim)
export MASON_PACKAGES_PATH="$HOME/.local/share/nvim/mason/packages"
[ -d "$MASON_PACKAGES_PATH/phpactor" ] &&
  export PATH="$MASON_PACKAGES_PATH/phpactor:$PATH"

# rust
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# Java (guarded)
if command -v mise >/dev/null 2>&1; then
  JAVA_HOME="$(mise which java 2>/dev/null | xargs dirname | xargs dirname)"
  [ -n "$JAVA_HOME" ] && export JAVA_HOME PATH="$JAVA_HOME/bin:$PATH"
fi
