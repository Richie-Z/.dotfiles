#!/usr/bin/env bash
# This script for selecting wallpapers (SUPER W)

# Wallpapers Path
wallpaperDir="$HOME/Pictures/Wallpapers"
rofiDir="$HOME/.config/rofi"

# Transition config
FPS=60
TYPE="any"
DURATION=3
BEZIER="0.4,0.2,0.4,1.0"
AWWW_PARAMS="--transition-fps ${FPS} --transition-type ${TYPE} --transition-duration ${DURATION} --transition-bezier ${BEZIER}"
PICS=($(find -L "${wallpaperDir}" -type f \( -iname \*.jpg -o -iname \*.jpeg -o -iname \*.png -o -iname \*.gif \) | sort))

# Use date variable to increase randomness
randomNumber=$((($(date +%s) + RANDOM) + $$))
randomPicture="${PICS[$((randomNumber % ${#PICS[@]}))]}"
randomChoice="[${#PICS[@]}] Random"

# Rofi command
rofiCommand="rofi -show -dmenu -theme ${rofiDir}/config-wallpaper.rasi"

# Execute command according the wallpaper manager
executeCommand() {
  if command -v awww &>/dev/null; then
    awww img "$1" ${AWWW_PARAMS}

  else
    echo "No "
    exit 1
  fi

  ln -sf "$1" "$HOME/.current_wallpaper"
}

menu() {
  printf "$randomChoice\n"
  for file in "${PICS[@]}"; do
    name="$(basename "$file")"
    printf "%s\x00icon\x1f%s\x00info\x1f%s\n" \
      "$name" "$file" "$file"
  done
}

# If awww exists, start it
if command -v awww &>/dev/null; then
  awww-daemon
fi

main() {
  choice=$(menu | ${rofiCommand})

  if [[ -z $choice ]]; then
    exit 0
  fi

  if [ "$choice" = "$randomChoice" ]; then
    executeCommand "${randomPicture}"
    return 0
  fi

  for file in "${PICS[@]}"; do
    if [[ "$(basename "$file")" = "$choice" ]]; then
      selectedFile="$file"
      break
    fi
  done

  if [[ -n "$selectedFile" ]]; then
    executeCommand "${selectedFile}"
    return 0
  else
    echo "Image not found."
    exit 1
  fi

}

# Check if rofi is already running
if pidof rofi >/dev/null; then
  pkill rofi
  exit 0
fi

main
