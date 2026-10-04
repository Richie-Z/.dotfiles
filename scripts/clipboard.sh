#!/usr/bin/env sh

. "$DOTFILES_PATH/scripts/env-detect.sh"

# OSC 52: ask the *local* terminal to set its clipboard. This is how a copy
# inside an SSH session lands on the machine you are sitting at, since the
# remote box has no access to your local clipboard manager.
osc52_copy() {
  if command -v base64 >/dev/null 2>&1; then
    payload="$(base64 | tr -d '\n')"
  else
    echo "clipboard_copy: base64 not found" >&2
    return 1
  fi

  printf '\033]52;c;%s\a' "$payload" >"${TTY:-/dev/tty}" 2>/dev/null ||
    printf '\033]52;c;%s\a' "$payload"
}

clipboard_copy() {
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
    pbcopy
    ;;
  linux:wayland)
    wl-copy
    ;;
  linux:xorg)
    xclip -selection clipboard
    ;;
  *)
    echo "clipboard_copy: unsupported environment" >&2
    return 1
    ;;
  esac
}
