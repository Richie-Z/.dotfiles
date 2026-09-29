#!/usr/bin/env bash

set -euo pipefail

ZSH="${ZSH:-$HOME/.oh-my-zsh}"
ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH/custom}"

if [ ! -d "$ZSH/.git" ]; then
  echo "Cloning oh-my-zsh -> $ZSH"
  git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$ZSH"
fi

# Plugins oh-my-zsh does not ship. Everything else in .zshrc plugins=() is bundled.
EXTERNAL_PLUGINS=(
  "zsh-autocomplete https://github.com/marlonrichert/zsh-autocomplete.git"
  "catppuccin-zsh-syntax-highlighting https://github.com/catppuccin/zsh-syntax-highlighting.git"
)

mkdir -p "$ZSH_CUSTOM/plugins"

for entry in "${EXTERNAL_PLUGINS[@]}"; do
  name="${entry%% *}"
  url="${entry#* }"
  dest="$ZSH_CUSTOM/plugins/$name"

  if [ -d "$dest/.git" ]; then
    echo "Present: $name"
  else
    echo "Cloning $name -> $dest"
    git clone --depth=1 "$url" "$dest"
  fi
done

echo "Done."
