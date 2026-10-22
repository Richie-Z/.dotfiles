# ~/.zprofile
# Login shells only. .zshenv has already sourced env-detect.sh.
# macOS: load the Homebrew environment (PATH, MANPATH, INFOPATH).
if [ "$(detect_os)" = "mac" ] && [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv zsh)"
fi
