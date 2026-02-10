#!/usr/bin/env sh

. "$DOTFILES_PATH/scripts/env-detect.sh"

clipboard_copy() {
  os="$(detect_os)"
  display="$(detect_display)"

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
