#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="$SCRIPT_DIR/../packages"

mkdir -p "$OUTPUT_DIR"

DATE=$(date +%F)

OFFICIAL_FILE="$OUTPUT_DIR/pacman-official-${DATE}.txt"
FOREIGN_FILE="$OUTPUT_DIR/pacman-aur-${DATE}.txt"

echo "Saving explicitly installed official packages to $OFFICIAL_FILE"
pacman -Qen >"$OFFICIAL_FILE"

echo "Saving explicitly installed AUR packages to $FOREIGN_FILE"
pacman -Qem >"$FOREIGN_FILE"

echo "Done. Files are in $OUTPUT_DIR"
