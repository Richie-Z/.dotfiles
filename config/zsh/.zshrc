# =======================
# Zsh options
# =======================
setopt correct
# echo 'unset HISTFILE' >>|${ZDOTDIR:-~}/.zshrc

# =======================
# Oh My Zsh
# =======================
export ZSH="$HOME/.oh-my-zsh"
source $ZSH/custom/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh

ZSH_THEME="" # repo-local, sourced below from $DOTFILES_PATH/omz/themes
CATPPUCCIN_FLAVOR="mocha"
CATPPUCCIN_SHOW_TIME=true

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

if [[ -d "$ZSH" ]]; then
  source "$ZSH/oh-my-zsh.sh"
fi

if [[ -n "$DOTFILES_PATH" ]]; then
  source "$DOTFILES_PATH/omz/themes/catppuccin.zsh-theme"
else
  echo "[zshrc] DOTFILES_PATH unset, catppuccin theme not loaded" >&2
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

# Fzf
source <(fzf --zsh)

# Crossplane
if command -v crossplane >/dev/null 2>&1; then
  source <(crossplane completions)
fi

# Helm
if command -v helm >/dev/null 2>&1; then
  source <(helm completion zsh)
fi

# Terraform
autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/bin/terraform terraform

# =======================
# Shell completions
# =======================
# Static completions from /usr/share/zsh/site-functions (pacman, yay, yazi,
# zoxide, eza, fd, rg, bat, ...) are already autoloaded via $fpath.
#
# Tools whose completions are *generated* are handled below by writing the
# generated file into $ZSH_COMPLETIONS_DIR and adding that dir to $fpath, so
# compinit autoloads them as _<cmd>. Do NOT `source <(cmd completion zsh)`:
# these generated files use a `funcstack[1]`/`compdef` self-registration guard
# meant for autoloading, which misfires when sourced under oh-my-zsh +
# zsh-autocomplete (`_arguments: can only be called from completion function`).

ZSH_COMPLETIONS_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/completions"
if [[ ! -d "$ZSH_COMPLETIONS_DIR" ]]; then
  mkdir -p "$ZSH_COMPLETIONS_DIR"
fi

# Regenerate a completion file when missing or older than its generator binary
# (so completions follow tool upgrades). Each entry is: <file-name> <command>.
_zsh_gen_completions() {
  local spec fname cmd bin out
  for spec in "$@"; do
    fname="${spec%% *}"
    cmd="${spec#* }"
    bin="${cmd%% *}"
    command -v "$bin" >/dev/null 2>&1 || continue
    out="$ZSH_COMPLETIONS_DIR/_$fname"
    if [[ -f "$out" && "$out" -nt "$(command -v "$bin")" ]]; then
      continue
    fi
    eval "$cmd" >"$out" 2>/dev/null
  done
}

_zsh_gen_completions \
  "podman podman completion zsh" \
  "kubectl kubectl completion zsh" \
  "gh gh completion -s zsh" \
  "uv uv generate-shell-completion zsh" \
  "bun bun completions" \
  "rustup rustup completions zsh" \
  "cargo rustup completions zsh cargo" \
  "kubectl-neat kubectl-neat completion zsh" \
  "opencode opencode completion zsh"

if [[ -d "$ZSH_COMPLETIONS_DIR" ]]; then
  fpath=("$ZSH_COMPLETIONS_DIR" $fpath)
  # Use a dedicated dump file: OMZ's own $ZSH_COMPDUMP is built before this dir
  # is added to $fpath, so reusing it with `compinit -C` would keep the new
  # completions unresolved.
  autoload -Uz compinit && compinit -C -d "$ZSH_COMPLETIONS_DIR/.zcompdump"
fi

# docker is the podman-docker shim: reuse podman's completion for `docker`.
if (( $+functions[_podman] )); then
  compdef _podman docker 2>/dev/null
fi

# Private Shell
unset HISTFILE
# export HISTSIZE=0
# export SAVEHIST=0
