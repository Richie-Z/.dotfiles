#!/usr/bin/env bash

set -euo pipefail

TPM_DIR="${TPM_DIR:-$HOME/.tmux/plugins/tpm}"
PLUGIN_DIR="$(dirname "$TPM_DIR")"

# tpm requirements: tmux, git, bash (see https://github.com/tmux-plugins/tpm#installation)
for cmd in tmux git; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "$cmd not installed, skipping tpm" >&2
    exit 0
  fi
done

if [ -d "$TPM_DIR/.git" ]; then
  echo "Present: tpm"
else
  echo "Cloning tpm -> $TPM_DIR"
  git clone --depth=1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

# tpm reads TMUX_PLUGIN_MANAGER_PATH, which the tpm script normally sets when a
# tmux server starts. Do it here so the CLI installer works on a fresh machine.
# tmux is not required to be running for this; stop our own server on exit.
if ! tmux list-sessions >/dev/null 2>&1; then
  tmux start-server
  trap 'tmux kill-server >/dev/null 2>&1 || true' EXIT
fi

tmux set-environment -g TMUX_PLUGIN_MANAGER_PATH "$PLUGIN_DIR/"

# Plugins come from @plugin lines in ~/.tmux.conf; install them all.
"$TPM_DIR/bin/install_plugins"

echo "Done."
