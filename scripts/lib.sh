# Shared helpers for initialize.sh and uninitialize.sh.
# Callers must set CONFIG_DIR, HOME_DIR_LIST, IGNORED_LIST and FLAT_LIST before
# calling these; initialize.sh must also set DRY_RUN.

containsElement() { # containsElement <needle> <haystack...>
  local e match="$1"
  shift
  for e; do [ "$e" = "$match" ] && return 0; done
  return 1
}

# Print "<source><TAB><target>" for every link a config dir deploys.
config_links() { # config_links <config dir> <source path>
  local base="$1" src="$2" dest subitem
  if containsElement "$base" "${HOME_DIR_LIST[@]}"; then
    printf '%s\t%s\n' "$src" "$HOME/.$base"
    return
  fi
  if containsElement "$base" "${IGNORED_LIST[@]}"; then
    dest="$HOME" # contents, e.g. config/zsh/.zshrc -> ~/.zshrc
  elif containsElement "$base" "${FLAT_LIST[@]}"; then
    dest="$HOME/.config" # contents, e.g. config/dolphin/dolphinrc
  else
    printf '%s\t%s\n' "$src" "$HOME/.config/$base"
    return
  fi
  if [ ! -d "$src" ]; then
    printf '%s\t%s\n' "$src" "$dest/$(basename "$src")"
    return
  fi
  shopt -s dotglob
  for subitem in "$src"/*; do
    [ -e "$subitem" ] || continue
    printf '%s\t%s\n' "$subitem" "$dest/$(basename "$subitem")"
  done
  shopt -u dotglob # restore default behaviour
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
