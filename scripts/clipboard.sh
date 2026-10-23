#!/usr/bin/env sh

. "$DOTFILES_PATH/scripts/env-detect.sh"

# OSC 52: ask the *local* terminal to set its clipboard. This is how a copy
# inside an SSH session lands on the machine you are sitting at, since the
# remote box has no access to your local clipboard manager.
osc52_copy() {
  local payload
  if command -v base64 >/dev/null 2>&1; then
    payload="$(base64 | tr -d '\n')"
  else
    echo "clipboard_copy: base64 not found" >&2
    return 1
  fi

  printf '\033]52;c;%s\a' "$payload" >"${TTY:-/dev/tty}" 2>/dev/null ||
    printf '\033]52;c;%s\a' "$payload"
}

need() { # need <command>
  command -v "$1" >/dev/null 2>&1 && return 0
  echo "clipboard_copy: $1 not installed" >&2
  return 1
}

clipboard_copy() {
  local os display ssh
  os="$(detect_os)"
  display="$(detect_display)"
  ssh="$(detect_ssh)"

  # Over SSH the remote display is irrelevant: the clipboard we want to
  # populate is the one on the local machine, reachable only via OSC 52.
  if [ "$ssh" = "ssh" ]; then
    osc52_copy
    return $?
  fi

  case "$os:$display" in
  mac:*)
    need pbcopy && pbcopy
    ;;
  linux:wayland)
    need wl-copy && wl-copy
    ;;
  linux:xorg)
    need xclip && xclip -selection clipboard
    ;;
  *)
    echo "clipboard_copy: unsupported environment" >&2
    return 1
    ;;
  esac
}
