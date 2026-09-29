#!/usr/bin/env bash

set -euo pipefail

ZSH="${ZSH:-$HOME/.oh-my-zsh}"
ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH/custom}"

if [ ! -d "$ZSH/.git" ]; then
  echo "Cloning oh-my-zsh -> $ZSH"
  git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$ZSH"
fi

# Plugins oh-my-zsh does not ship. Everything else in .zshrc plugins=() is bundled.
# The two zsh-users ones are vendored by oh-my-zsh but pinned to an older copy;
# cloning them into $ZSH_CUSTOM/plugins shadows that copy.
# See https://github.com/zsh-users/zsh-autosuggestions/blob/master/INSTALL.md
EXTERNAL_PLUGINS=(
  "zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions.git"
  "zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting.git"
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
  elif [ -e "$dest" ]; then
    echo "Replacing $name: $dest is not a git clone, moved to $dest.bak-$(date +%Y%m%d%H%M%S)"
    mv "$dest" "$dest.bak-$(date +%Y%m%d%H%M%S)"
    git clone --depth=1 "$url" "$dest"
  else
    echo "Cloning $name -> $dest"
    git clone --depth=1 "$url" "$dest"
  fi
done

echo "Done."
