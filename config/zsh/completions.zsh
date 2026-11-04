# macOS Homebrew completions
if [[ "$(detect_os)" = "mac" ]]; then
  BREW_PREFIXES=(/opt/homebrew /usr/local)
  command -v brew >/dev/null 2>&1 && BREW_PREFIXES+=("$(brew --prefix)")
  for prefix in $BREW_PREFIXES; do
    [[ -d "$prefix/share/zsh/site-functions" ]] &&
      fpath=("$prefix/share/zsh/site-functions" $fpath)
  done
fi

# zsh-completions plugin
if [[ -d "$ZSH/custom/plugins/zsh-completions/src" ]]; then
  fpath=("$ZSH/custom/plugins/zsh-completions/src" $fpath)
fi

# Tool lazy-load wrappers
_mise_lazy_load() {
  unfunction mise
  unfunction _mise_lazy_load
  eval "$(mise activate zsh)"
  mise "$@"
}
mise() { _mise_lazy_load "$@"; }

_zoxide_lazy_load() {
  unfunction z
  unfunction zi
  unfunction _zoxide_lazy_load
  eval "$(zoxide init zsh)"
  z "$@"; }
z() { _zoxide_lazy_load "$@"; }
zi() { _zoxide_lazy_load "$@"; }

_fzf_lazy_load() {
  unfunction fzf
  unfunction _fzf_lazy_load
  source <(fzf --zsh)
  fzf "$@"
}
fzf() { _fzf_lazy_load "$@"; }

_crossplane_lazy_load() {
  unfunction crossplane
  unfunction _crossplane_lazy_load
  source <(crossplane completions)
  crossplane "$@"
}
crossplane() { _crossplane_lazy_load "$@"; }

_helm_lazy_load() {
  unfunction helm
  unfunction _helm_lazy_load
  helm "$@"
}
helm() { _helm_lazy_load "$@"; }

_herdr_lazy_load() {
  unfunction herdr
  unfunction _herdr_lazy_load
  herdr "$@"
}
herdr() { _herdr_lazy_load "$@"; }

_k3s_lazy_load() {
  unfunction k3s
  unfunction _k3s_lazy_load
  k3s "$@"
}
k3s() { _k3s_lazy_load "$@"; }

_terraform_lazy_load() {
  unfunction terraform
  unfunction _terraform_lazy_load
  autoload -U +X bashcompinit && bashcompinit
  complete -o nospace -C /usr/bin/terraform terraform
  terraform "$@"
}
terraform() { _terraform_lazy_load "$@"; }

# Completion cache and generation
ZSH_COMPLETIONS_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/completions"
mkdir -p "$ZSH_COMPLETIONS_DIR"

_zsh_completions_cache_file="$ZSH_COMPLETIONS_DIR/.last_regen"
_zsh_should_regen_completions() {
  [[ ! -f "$_zsh_completions_cache_file" ]] && return 0
  local last_regen="$(cat "$_zsh_completions_cache_file" 2>/dev/null)"
  local today="$(date +%s)"
  ((today - last_regen > 86400)) # 24h
}

_zsh_gen_completions() {
  local spec fname cmd bin bin_path out
  for spec in "$@"; do
    fname="${spec%% *}"
    cmd="${spec#* }"
    bin="${cmd%% *}"
    bin_path="$(whence -p "$bin" 2>/dev/null)"
    [[ -z "$bin_path" ]] && continue
    out="$ZSH_COMPLETIONS_DIR/_$fname"
    if [[ -f "$out" && "$out" -nt "$bin_path" ]]; then
      continue
    fi
    eval "command $cmd" >"$out.tmp" 2>/dev/null &&
      [[ "$(head -n1 "$out.tmp")" == '#compdef'* ]] &&
      mv -f "$out.tmp" "$out" &&
      _zsh_regened=true
    rm -f "$out.tmp"
  done
}

_zsh_completion_specs=(
  "podman podman completion zsh"
  "kubectl kubectl completion zsh"
  "gh gh completion -s zsh"
  "uv uv generate-shell-completion zsh"
  "bun bun completions"
  "rustup rustup completions zsh"
  "cargo rustup completions zsh cargo"
  "kubectl-neat kubectl-neat completion zsh"
  "mise mise completion zsh"
  "helm helm completion zsh"
  "herdr herdr completion zsh"
  "k3s k3s completion zsh"
  "gaal gaal completion zsh"
  "immich-go immich-go completion zsh"
  "opencode opencode --completions zsh"
)

if _zsh_should_regen_completions; then
  _zsh_regened=false
  _zsh_gen_completions "${_zsh_completion_specs[@]}"
  date +%s >"$_zsh_completions_cache_file"
  if [[ "$_zsh_regened" = true ]]; then
    rm -f "$ZSH_COMPLETIONS_DIR/.zcompdump"
  fi
fi

# Dedicated dump: OMZ builds its own $ZSH_COMPDUMP before this dir joins $fpath
fpath=("$ZSH_COMPLETIONS_DIR" $fpath)
autoload -Uz compinit && compinit -C -d "$ZSH_COMPLETIONS_DIR/.zcompdump"

# docker is podman-docker shim: reuse podman's completion for `docker`
if (($+functions[_podman])); then
  compdef _podman docker 2>/dev/null
fi

# Regenerate helper function
completion-regen() {
  local spec
  for spec in "${_zsh_completion_specs[@]}"; do
    rm -f "$ZSH_COMPLETIONS_DIR/_${spec%% *}"
  done
  rm -f "$_zsh_completions_cache_file" "$ZSH_COMPLETIONS_DIR/.zcompdump"
  exec zsh
}