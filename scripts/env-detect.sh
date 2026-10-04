#!/usr/bin/env sh

detect_os() {
  case "$(uname -s)" in
  Darwin) echo "mac" ;;
  Linux) echo "linux" ;;
  *) echo "unknown" ;;
  esac
}

detect_display() {
  if [ -n "$WAYLAND_DISPLAY" ]; then
    echo "wayland"
  elif [ -n "$DISPLAY" ]; then
    echo "xorg"
  else
    echo "none"
  fi
}

detect_ssh() {
  if [ -n "$SSH_CONNECTION" ] || [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    echo "ssh"
  else
    echo "local"
  fi
}
