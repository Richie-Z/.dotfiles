#!/usr/bin/env bash
# Screenshot capture with a mako preview notification.
#
# Usage:
#   screenshot.sh full     - capture the whole screen, save file
#   screenshot.sh region   - select a region, save file + copy to clipboard
#
# Saves to ~/Pictures/Screenshots and shows a notification whose preview
# thumbnail opens the image (xdg-open) when the notification is clicked.

set -euo pipefail

MODE="${1:-full}"
DIR="${HOME}/Pictures/Screenshots"
FILE="${DIR}/Screenshot_$(date +%Y-%m-%d_%H-%M-%S).png"

mkdir -p "$DIR"

case "$MODE" in
full)
    grim "$FILE"
    ;;
region)
    # slurp prints nothing when cancelled (Esc); bail without a file or toast.
    GEOM="$(slurp)" || exit 0
    [ -n "$GEOM" ] || exit 0
    grim -g "$GEOM" - | tee "$FILE" | wl-copy
    ;;
*)
    echo "usage: $(basename "$0") [full|region]" >&2
    exit 2
    ;;
esac

# Preview toast. -A implies --wait, so run it in the background to keep the
# keybind non-blocking; run in a subshell so the notification's stdout is
# captured and a click ("default") opens the image.
(
    chosen="$(notify-send \
        -a Screenshot \
        -t 6000 \
        -i "$FILE" \
        -h string:image-path:"$FILE" \
        -A default=Open \
        "Screenshot saved" "$(basename "$FILE")")"
    [ "$chosen" = "default" ] && xdg-open "$FILE"
) &

disown
