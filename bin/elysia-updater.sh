#!/bin/bash

# Fix DISPLAY and DBUS for .desktop launches
SESSION_PID=$(pgrep -u "$USER" -x waybar || pgrep -u "$USER" -x hyprland || pgrep -u "$USER" -x gnome-session | head -n1)

if [[ -n "$SESSION_PID" ]]; then
    ENVFILE="/proc/$SESSION_PID/environ"
    export DISPLAY=$(tr '\0' '\n' < "$ENVFILE" | grep ^DISPLAY= | cut -d= -f2-)
    export DBUS_SESSION_BUS_ADDRESS=$(tr '\0' '\n' < "$ENVFILE" | grep ^DBUS_SESSION_BUS_ADDRESS= | cut -d= -f2-)
    export XAUTHORITY=$(tr '\0' '\n' < "$ENVFILE" | grep ^XAUTHORITY= | cut -d= -f2-)
fi

# Run the real launcher
exec ~/.config/Elysia/assets/elyupdate
