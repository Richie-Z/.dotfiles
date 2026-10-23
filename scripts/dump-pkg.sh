#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="$SCRIPT_DIR/../packages"

if ! command -v pacman >/dev/null 2>&1; then
  echo "pacman not found, nothing to dump" >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

DATE=$(date +%F)

OFFICIAL_FILE="$OUTPUT_DIR/pacman-official-${DATE}.txt"
FOREIGN_FILE="$OUTPUT_DIR/pacman-aur-${DATE}.txt"

# Write to a temp file and move only on success: a failed pacman must not leave
# an empty dated dump in packages/.
dump() { # dump <output file> <pacman args...>
  local out="$1"
  shift
  if ! pacman "$@" >"$out.tmp"; then
    rm -f "$out.tmp"
    echo "pacman $* failed, $out not written" >&2
    return 1
  fi
  mv "$out.tmp" "$out"
  echo "Saved $out"
}

dump "$OFFICIAL_FILE" -Qen
dump "$FOREIGN_FILE" -Qem

echo "Done. Files are in $OUTPUT_DIR"
