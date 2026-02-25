#!/usr/bin/env bash
# Better waybar reload script

# Check if waybar is running
if pgrep -x "waybar" >/dev/null; then
  pkill -9 waybar
else
  waybar
  echo "Waybar started"
fi
