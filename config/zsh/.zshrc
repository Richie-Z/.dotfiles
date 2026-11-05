# Zsh options
setopt correct
# echo 'unset HISTFILE' >>|${ZDOTDIR:-~}/.zshrc

# Oh My Zsh (lazy-loaded)
export ZSH="$HOME/.oh-my-zsh"

# Lazy-load OMZ and plugins on first prompt
_zsh_lazy_load_omz() {
  unfunction _zsh_lazy_load_omz
  ZSH_THEME="" # repo-local, sourced below from $DOTFILES_PATH/omz/themes
  CATPPUCCIN_FLAVOR="mocha"
  CATPPUCCIN_SHOW_TIME=true
  CATPPUCCIN_SHOW_HOSTNAME="always" # never | ssh | always

  plugins=(
    git
    flutter
    laravel
    tmux
    vi-mode
    gcloud
    kubectl
    podman
    docker-compose
    zsh-autocomplete
    zsh-autosuggestions
    zsh-syntax-highlighting
  )

  export ZSH_TMUX_AUTONAME_SESSION=true

  # zsh-completions: add to fpath before compinit
  if [[ -d "$ZSH/custom/plugins/zsh-completions/src" ]]; then
    fpath=("$ZSH/custom/plugins/zsh-completions/src" $fpath)
  fi

  if [[ -d "$ZSH" ]]; then
    source "$ZSH/oh-my-zsh.sh"
  fi

  if [[ -n "$DOTFILES_PATH" ]]; then
    source "$DOTFILES_PATH/omz/themes/catppuccin.zsh-theme"
  else
    echo "[zshrc] DOTFILES_PATH unset, catppuccin theme not loaded" >&2
  fi

  . "$ZSH_CUSTOM/plugins/catppuccin-zsh-syntax-highlighting/themes/catppuccin_mocha-zsh-syntax-highlighting.zsh"

  # Load zsh-autocomplete AFTER OMZ (was loading before, causing slowdown)
  source "$ZSH/custom/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh"
}

# Trigger lazy load on first prompt
autoload -Uz add-zsh-hook
add-zsh-hook precmd _zsh_lazy_load_omz

# Load completions
if [[ -n "$DOTFILES_PATH" && -f "$DOTFILES_PATH/config/zsh/completions.zsh" ]]; then
  source "$DOTFILES_PATH/config/zsh/completions.zsh"
else
  echo "[zshrc] DOTFILES_PATH unset, completions not loaded" >&2
fi

# Load aliases
if [[ -n "$DOTFILES_PATH" && -f "$DOTFILES_PATH/config/.aliases" ]]; then
  source "$DOTFILES_PATH/config/.aliases"
fi

# yazi (cwd integration)
y() {
  local tmp cwd
  tmp="$(mktemp -t yazi-cwd.XXXXXX)" || return

  yazi "$@" --cwd-file="$tmp"

  if cwd="$(<"$tmp")" && [[ -n "$cwd" && "$cwd" != "$PWD" ]]; then
    builtin cd "$cwd"
  fi

  rm -f "$tmp"
}

# Completion access via .zshrc-completion wrapper (allow completion-regen invocation without sourcing completions.zsh if file moves)
.zshrc-completion() { completion-regen "$@"; }
alias completion='.zshrc-completion'

# Private Shell
# unset HISTFILE
# export HISTSIZE=0
# export SAVEHIST=0
