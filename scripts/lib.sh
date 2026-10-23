# Shared helpers for initialize.sh and uninitialize.sh.
# Callers must set CONFIG_DIR and DRY_RUN before calling these.

containsElement() { # containsElement <needle> <haystack...>
  local e match="$1"
  shift
  for e; do [ "$e" = "$match" ] && return 0; done
  return 1
}

# Remove a deployed symlink, only when it points into this repo.
# readlink (not -f): links here are absolute, and BSD readlink has no -f.
unlink_if_ours() { # unlink_if_ours <target>
  local target="$1" link
  [ -L "$target" ] || return 0
  link="$(readlink "$target")"
  case "$link" in
  "$CONFIG_DIR"/*)
    if $DRY_RUN; then
      echo "[dry-run] rm -f $target"
    else
      rm -f "$target" && echo "Removed $target"
    fi
    ;;
  *)
    echo "Kept $target (points outside $CONFIG_DIR)"
    ;;
  esac
}
