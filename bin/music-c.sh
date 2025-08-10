#!/bin/sh

# Path to your widget
WIDGET="$HOME/.config/Elysia/assets/music_widget"

# Check if the widget is running
if pgrep -f "$WIDGET" >/dev/null; then
    echo "Stopping music_widget..."
    pkill -f "$WIDGET"
else
    "$WIDGET" &
fi
