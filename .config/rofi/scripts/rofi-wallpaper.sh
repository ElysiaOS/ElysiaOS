#!/usr/bin/env bash

DIR_LIGHT="$HOME/.config/Elysia/wallpaper/Light"
DIR_DARK="$HOME/.config/Elysia/wallpaper/Dark"

COLOR_SCHEME=$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null | tr -d "'")

if [[ "$COLOR_SCHEME" == "prefer-light" ]]; then
  TARGET_DIR="$DIR_LIGHT"
else
  TARGET_DIR="$DIR_DARK"
fi

if [[ ! -d "$TARGET_DIR" ]]; then
  notify-send "Wallpaper Selector" "Directory not found: $TARGET_DIR"
  exit 1
fi

if [[ "$TARGET_DIR" == "$DIR_LIGHT" ]]; then
  TARGET_SCRIPT="$TARGET_DIR/l-rofi-wallpaper.sh"
  SCRIPT_NAME="l-rofi-wallpaper.sh"
else
  TARGET_SCRIPT="$TARGET_DIR/d-rofi-wallpaper.sh"
  SCRIPT_NAME="d-rofi-wallpaper.sh"
fi

if [[ -f "$TARGET_SCRIPT" ]]; then
  cd "$TARGET_DIR" || exit 1
  chmod +X "$TARGET_SCRIPT" 2>/dev/null
  exec "./$SCRIPT_NAME" "$@"
else
  notify-send "Wallpaper Selector" "Could not find $SCRIPT_NAME in $TARGET_DIR"
  exit 1
fi
