#!/usr/bin/env bash

# Deploys config/refind/ (rice only) to the ESP.
# Not a symlink: ESP is vfat. refind_x64.efi + BOOT.CSV stay pacman-owned, vars/ is machine state.
# ponytail: no --delete; stale files linger. Add `--delete --exclude refind_x64.efi --exclude BOOT.CSV` only if that starts to matter.

DRY_RUN=false
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$SCRIPT_DIR/../config/refind/"
DST="/boot/EFI/refind/"

if [ ! -d "$DST" ]; then
  echo "No rEFInd install at $DST" >&2
  exit 1
fi

# refind_linux.conf lives next to the kernel (/boot), rEFInd reads it from kernel dir, not the refind dir.
if $DRY_RUN; then
  rsync -ain --exclude 'refind_linux.conf' "$SRC" "$DST"
  rsync -ain "$SRC/refind_linux.conf" /boot/
else
  sudo rsync -a --exclude 'refind_linux.conf' "$SRC" "$DST"
  sudo rsync -a "$SRC/refind_linux.conf" /boot/
  echo "Deployed $SRC -> $DST and /boot/refind_linux.conf"
fi
