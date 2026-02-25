# =======================
# Zsh options
# =======================
setopt correct

# =======================
# Oh My Zsh
# =======================
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="catppuccin"
CATPPUCCIN_FLAVOR="mocha"
CATPPUCCIN_SHOW_TIME=true

plugins=(
  git
  flutter
  laravel
  tmux
  vi-mode
  zsh-autosuggestions
  zsh-autocomplete
  zsh-syntax-highlighting
)

export ZSH_TMUX_AUTONAME_SESSION=true

if [[ -d "$ZSH" ]]; then
  source "$ZSH/oh-my-zsh.sh"
fi

. "$ZSH_CUSTOM/plugins/catppuccin-zsh-syntax-highlighting/themes/catppuccin_mocha-zsh-syntax-highlighting.zsh"

# =======================
# Load aliases
# =======================
if [[ -n "$DOTFILES_PATH" && -f "$DOTFILES_PATH/config/.aliases" ]]; then
  source "$DOTFILES_PATH/config/.aliases"
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
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# rust
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# Fzf
source <(fzf --zsh)
