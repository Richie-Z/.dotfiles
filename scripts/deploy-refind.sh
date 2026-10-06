#!/usr/bin/env bash

# Deploys config/refind/ (rice only) to the ESP.
# Not a symlink: ESP is vfat. refind_x64.efi + BOOT.CSV stay pacman-owned, vars/ is machine state.
# ponytail: no --delete; stale files linger. Add `--delete --exclude refind_x64.efi --exclude BOOT.CSV` only if that starts to matter.

set -euo pipefail

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
# --no-owner --no-group: ESP is vfat, chown always fails there and aborts the transfer.
if $DRY_RUN; then
  rsync -ain --no-owner --no-group --exclude 'refind_linux.conf' "$SRC" "$DST"
  rsync -ain --no-owner --no-group "$SRC/refind_linux.conf" /boot/
else
  sudo rsync -a --no-owner --no-group --exclude 'refind_linux.conf' "$SRC" "$DST"
  sudo rsync -a --no-owner --no-group "$SRC/refind_linux.conf" /boot/
  echo "Deployed $SRC -> $DST and /boot/refind_linux.conf"
fi

# Arch logo for auto-detected kernels: rEFInd checks for <kernel>.png next to the vmlinuz first.
# No os-release on the ESP, so auto-detect never picks Arch on its own.
ARCH_ICON="$DST/themes/catppuccin/assets/mocha/icons/os_arch.png"
for k in /boot/vmlinuz-*; do
  [ -f "$k" ] || continue
  case "$k" in *.png) continue ;; esac # skip icons from previous runs
  if $DRY_RUN; then
    echo "would install Arch icon: $k.png"
  else
    sudo cp "$ARCH_ICON" "$k.png"
  fi
done

# Banner: blur the current wallpaper (matches hyprlock) and write it to the ESP.
# ESP-only on purpose: wallpaper is machine-local, not in the repo. Runs after rsync so rsync's flat background.png copy gets overwritten.
# No wallpaper -> keep the flat mocha base from rsync.
BANNER="$DST/themes/catppuccin/assets/mocha/background.png"
if $DRY_RUN; then
  echo "would regenerate banner: $BANNER from $HOME/.current_wallpaper"
elif [ -f "$HOME/.current_wallpaper" ]; then
  # Generate as user into /tmp (ESP not writable without root), then sudo cp.
  TMP_BANNER="$(mktemp --suffix=.png)"
  trap 'rm -f "$TMP_BANNER"' EXIT
  uv run --no-project --with pillow python - "$HOME/.current_wallpaper" "$TMP_BANNER" <<'PYEOF'
import sys
from PIL import Image, ImageEnhance, ImageFilter

src, dst = sys.argv[1], sys.argv[2]
im = Image.open(src).convert("RGB")
scale = max(1920 / im.width, 1080 / im.height)
im = im.resize((round(im.width * scale), round(im.height * scale)), Image.LANCZOS)
left, top = (im.width - 1920) // 2, (im.height - 1080) // 2
im = im.crop((left, top, left + 1920, top + 1080))
im = im.filter(ImageFilter.GaussianBlur(9))
im = ImageEnhance.Contrast(im).enhance(1.3)
im = ImageEnhance.Brightness(im).enhance(0.55)
im = Image.blend(im, Image.new("RGB", im.size, (0x1E, 0x1E, 0x2E)), 0.5)
im.save(dst)
print(f"Banner generated: {dst}")
PYEOF
  sudo cp "$TMP_BANNER" "$BANNER"
  echo "Banner installed: $BANNER"
else
  echo "No wallpaper at $HOME/.current_wallpaper, keeping flat mocha banner"
fi
