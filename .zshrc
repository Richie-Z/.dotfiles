# =======================
# Zsh options
# =======================
setopt correct

# =======================
# Load aliases
# =======================
if [[ -n "$DOTFILES_PATH" && -f "$DOTFILES_PATH/.aliases" ]]; then
  source "$DOTFILES_PATH/.aliases"
fi

# =======================
# Oh My Zsh
# =======================
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="catppuccin"
CATPPUCCIN_FLAVOR="mocha"
CATPPUCCIN_SHOW_TIME=true

plugins=(
  git
  zsh-autosuggestions
  flutter
  laravel
  tmux
  vi-mode
)

export ZSH_TMUX_AUTONAME_SESSION=true

if [[ -d "$ZSH" ]]; then
  source "$ZSH/oh-my-zsh.sh"
fi

# =======================
# yazi (cwd integration)
# =======================
y() {
  local tmp cwd
  tmp="$(mktemp -t yazi-cwd.XXXXXX)" || return

  yazi "$@" --cwd-file="$tmp"

  if cwd="$(<"$tmp")" && [[ -n "$cwd" && "$cwd" != "$PWD" ]]; then
    builtin cd "$cwd"
  fi

  rm -f "$tmp"
}

# =======================
# Tool integrations
# =======================

# Mise
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

# Jump
if command -v jump >/dev/null 2>&1; then
  eval "$(jump shell)"
fi
