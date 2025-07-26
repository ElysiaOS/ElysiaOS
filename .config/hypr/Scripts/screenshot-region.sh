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

# Define the screenshot path with a timestamp and the window class
screenshot="$HOME/Pictures/Screenshots/$window$(date '+%y%m%d_%H-%M-%S').png"

# Take a screenshot of the selected region
if grim -g "$(slurp)" "$screenshot"; then
    # Copy the screenshot to the clipboard
    wl-copy < "$screenshot"
    # Send a notification with the screenshot name, a "Copy" button, and the screenshot as an icon
    notify-send "Elysia" "$screenshot" --icon="$screenshot" 
    # Wait for the "Copy" action to be triggered
    gdbus call --session --dest org.freedesktop.Notifications --object-path /org/freedesktop/Notifications --method org.freedesktop.Notifications.GetCapabilities | grep -q "actions" && wl-copy < "$screenshot"
else
    # Notify user of failure
    notify-send "Screenshot failed"
fi