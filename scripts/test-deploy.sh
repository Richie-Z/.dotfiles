#!/usr/bin/env bash

# Smoke test for initialize.sh / uninitialize.sh against a throwaway HOME.
# Run: bash scripts/test-deploy.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

fail=0
check() { # check <description> <command...>
  local desc="$1"
  shift
  if "$@"; then
    echo "ok: $desc"
  else
    echo "FAIL: $desc" >&2
    fail=1
  fi
}

HOME="$TMP/home"
export HOME

# --dry-run must not create anything
bash "$SCRIPT_DIR/initialize.sh" --dry-run >/dev/null
check "dry-run leaves .config empty" test ! -e "$HOME/.config/btop"
check "dry-run leaves opencode config empty" test ! -e "$HOME/.config/opencode"
check "dry-run leaves home dotdir empty" test ! -e "$HOME/.agents"

# --all: link every config regardless of which apps this machine has
bash "$SCRIPT_DIR/initialize.sh" --all >/dev/null
check "dir config linked" test -L "$HOME/.config/btop"
check "HOME-level dotfile linked" test -L "$HOME/.zshrc"
check "flat config linked into .config" test -L "$HOME/.config/dolphinrc"
check "no dolphin dir link" test ! -e "$HOME/.config/dolphin"
check "whole-dir config linked" test -L "$HOME/.config/opencode"
check "home dotdir linked" test -L "$HOME/.agents"
check "home dotdir not under .config" test ! -e "$HOME/.config/agents"

mkdir -p "$TMP/home-real/.agents"
HOME="$TMP/home-real" bash "$SCRIPT_DIR/initialize.sh" --all >"$TMP/real-agents.out" 2>&1
check "real home dotdir kept" test -d "$TMP/home-real/.agents"
check "real home dotdir reported" grep -Fq "Backup needed: $TMP/home-real/.agents" "$TMP/real-agents.out"

# Foreign symlink and real file must survive uninitialize
mkdir -p "$TMP/elsewhere"
ln -s "$TMP/elsewhere" "$HOME/.config/foreign"
printf 'keep\n' >"$HOME/.config/real-file"

bash "$SCRIPT_DIR/uninitialize.sh" >/dev/null
check "our link removed" test ! -e "$HOME/.zshrc"
check "whole-dir config link removed" test ! -e "$HOME/.config/opencode"
check "home dotdir link removed" test ! -e "$HOME/.agents"
check "foreign symlink kept" test -L "$HOME/.config/foreign"
check "real file kept" test -f "$HOME/.config/real-file"

mkdir -p "$TMP/elsewhere-agents"
ln -s "$TMP/elsewhere-agents" "$HOME/.agents"
bash "$SCRIPT_DIR/uninitialize.sh" >/dev/null
check "foreign home dotdir kept" test -L "$HOME/.agents"

exit $fail
