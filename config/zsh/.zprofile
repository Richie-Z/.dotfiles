# ~/.zprofile
# Login shells only. macOS: load the Homebrew environment (PATH, MANPATH, INFOPATH).
if [ "$(uname -s)" = "Darwin" ] && [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv zsh)"
fi
