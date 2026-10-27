# =======================
# Zsh options
# =======================
setopt correct
# echo 'unset HISTFILE' >>|${ZDOTDIR:-~}/.zshrc

# Homebrew zsh completions (macOS): formulae install `_<cmd>` files into
# <prefix>/share/zsh/site-functions (e.g. `zsh-completions`). Added before any
# compinit run so the dump picks them up. .zprofile only loads brew in login
# shells, so use the known prefixes plus `brew --prefix` when available.
if [[ "$(detect_os)" = "mac" ]]; then
  BREW_PREFIXES=(/opt/homebrew /usr/local)
  command -v brew >/dev/null 2>&1 && BREW_PREFIXES+=("$(brew --prefix)")
  for prefix in $BREW_PREFIXES; do
    [[ -d "$prefix/share/zsh/site-functions" ]] &&
      fpath=("$prefix/share/zsh/site-functions" $fpath)
  done
fi

# =======================
# Oh My Zsh (lazy-loaded)
# =======================
export ZSH="$HOME/.oh-my-zsh"

# Lazy-load OMZ and plugins on first prompt
_zsh_lazy_load_omz() {
  unfunction _zsh_lazy_load_omz
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
# Tool integrations (lazy-loaded)
# =======================

# Mise - lazy load on first command
_mise_lazy_load() {
  unfunction mise
  unfunction _mise_lazy_load
  eval "$(mise activate zsh)"
  mise "$@"
}
mise() { _mise_lazy_load "$@"; }

# Zoxide - lazy load on first command
_zoxide_lazy_load() {
  unfunction z
  unfunction zi
  unfunction _zoxide_lazy_load
  eval "$(zoxide init zsh)"
  z "$@"
}
z() { _zoxide_lazy_load "$@"; }
zi() { _zoxide_lazy_load "$@"; }

# Fzf - lazy load on first use
_fzf_lazy_load() {
  unfunction fzf
  unfunction _fzf_lazy_load
  source <(fzf --zsh)
  fzf "$@"
}
fzf() { _fzf_lazy_load "$@"; }

# Crossplane - lazy load
_crossplane_lazy_load() {
  unfunction crossplane
  unfunction _crossplane_lazy_load
  source <(crossplane completions)
  crossplane "$@"
}
crossplane() { _crossplane_lazy_load "$@"; }

# Helm - lazy load
_helm_lazy_load() {
  unfunction helm
  unfunction _helm_lazy_load
  helm "$@"
}
helm() { _helm_lazy_load "$@"; }

# Herdr - lazy load
_herdr_lazy_load() {
  unfunction herdr
  unfunction _herdr_lazy_load
  herdr "$@"
}
herdr() { _herdr_lazy_load "$@"; }

# k3s - lazy load
_k3s_lazy_load() {
  unfunction k3s
  unfunction _k3s_lazy_load
  k3s "$@"
}
k3s() { _k3s_lazy_load "$@"; }

# Terraform - static completion (fast, keep eager) - load after compinit
_terraform_lazy_load() {
  unfunction terraform
  unfunction _terraform_lazy_load
  autoload -U +X bashcompinit && bashcompinit
  complete -o nospace -C /usr/bin/terraform terraform
  terraform "$@"
}
terraform() { _terraform_lazy_load "$@"; }

# =======================
# Shell completions (cached daily)
# =======================
# Generated completions are written as _<cmd> files below and autoloaded via
# $fpath. Never `source <(cmd completion zsh)` instead: those files self-register
# and misfire under zsh-autocomplete.

ZSH_COMPLETIONS_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/completions"
mkdir -p "$ZSH_COMPLETIONS_DIR"

# Regenerate at most once per day (timestamp file)
_zsh_completions_cache_file="$ZSH_COMPLETIONS_DIR/.last_regen"
_zsh_should_regen_completions() {
  [[ ! -f "$_zsh_completions_cache_file" ]] && return 0
  local last_regen="$(cat "$_zsh_completions_cache_file" 2>/dev/null)"
  local today="$(date +%s)"
  (( today - last_regen > 86400 )) # 24h
}

# Each entry: <file-name> <command>. Regenerate when missing or older than its
# binary, so completions follow tool upgrades.
_zsh_gen_completions() {
  local spec fname cmd bin bin_path out
  for spec in "$@"; do
    fname="${spec%% *}"
    cmd="${spec#* }"
    bin="${cmd%% *}"
    # whence -p: lazy-load functions defined above shadow the binaries
    bin_path="$(whence -p "$bin" 2>/dev/null)"
    [[ -z "$bin_path" ]] && continue
    out="$ZSH_COMPLETIONS_DIR/_$fname"
    if [[ -f "$out" && "$out" -nt "$bin_path" ]]; then
      continue
    fi
    # tmp+mv: a Ctrl-C mid-write must not leave a truncated file that is newer
    # than the binary and so skips every future regen. #compdef guard: reject a
    # broken generator printing help text (opencode v2.1.4).
    eval "command $cmd" >"$out.tmp" 2>/dev/null &&
      [[ "$(head -n1 "$out.tmp")" == '#compdef'* ]] &&
      mv -f "$out.tmp" "$out" &&
      _zsh_regened=true
    rm -f "$out.tmp"
  done
}

if _zsh_should_regen_completions; then
  _zsh_regened=false
  # opencode v2.1.4: `completion zsh` prints help text; re-add when fixed
  _zsh_gen_completions \
    "podman podman completion zsh" \
    "kubectl kubectl completion zsh" \
    "gh completion -s zsh" \
    "uv uv generate-shell-completion zsh" \
    "bun bun completions" \
    "rustup rustup completions zsh" \
    "cargo rustup completions zsh cargo" \
    "kubectl-neat kubectl-neat completion zsh" \
    "mise mise completion zsh" \
    "helm helm completion zsh" \
    "herdr herdr completion zsh" \
    "k3s k3s completion zsh"
  date +%s >"$_zsh_completions_cache_file"
  # compinit -C trusts an existing dump; drop it when files changed
  if [[ "$_zsh_regened" = true ]]; then
    rm -f "$ZSH_COMPLETIONS_DIR/.zcompdump"
  fi
fi

# Dedicated dump: OMZ builds its own $ZSH_COMPDUMP before this dir joins $fpath
fpath=("$ZSH_COMPLETIONS_DIR" $fpath)
autoload -Uz compinit && compinit -C -d "$ZSH_COMPLETIONS_DIR/.zcompdump"

# docker is the podman-docker shim: reuse podman's completion for `docker`.
if (($+functions[_podman])); then
  compdef _podman docker 2>/dev/null
fi

# Private Shell
# unset HISTFILE
# export HISTSIZE=0
# export SAVEHIST=0

# agentmemory plugin (OpenCode auto-capture)
export AGENTMEMORY_URL="https://agentmemory.dreadwrym.my.id"
export AGENTMEMORY_SECRET="$(cat "$HOME/.agentmemory/secret")"
