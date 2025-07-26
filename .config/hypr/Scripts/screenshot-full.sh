#!/bin/bash

# Create Pictures directory if it doesn't exist
mkdir -p "$HOME/Pictures"

# Create Screenshots directory if it doesn't exist
mkdir -p "$HOME/Pictures/Screenshots"

# Get the class of the currently active window
window=$(hyprctl activewindow | awk -F': ' '/initialClass:/ {print $2}' | xargs)

# Fallback for unknown window class
if [ -z "$window" ]; then
    window="Unknown"
fi

# Take a screenshot of the selected region and save it with a timestamp
screenshot="$HOME/Pictures/Screenshots/$window$(date '+%y%m%d_%H-%M-%S').png"
grim "$screenshot" && wl-copy < "$screenshot"

# Send a notification with the screenshot name and a "Copy" button
notify-send "Elysia" "$screenshot" --icon="$screenshot"