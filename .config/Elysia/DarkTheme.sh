#!/bin/bash

WAYBAR_SCRIPT="$HOME/.config/hypr/Scripts/waybar-reload.sh"
SWAYNC_SCRIPT="$HOME/.config/swaync/swaync-reload.sh"
WAYBAR_DARK_STYLE="$HOME/.config/waybar/Dark/style.css"
SWAYNC_DARK_STYLE="$HOME/.config/swaync/Dark/style.css"
THEME_STATE_DIR="$HOME/.config/hypr"
LIGHT_FILE="$THEME_STATE_DIR/Light.txt"
DARK_FILE="$THEME_STATE_DIR/Dark.txt"
HYPER_CONF="$HOME/.config/hypr/variables.conf"
VISUALIZER_HOC="$HOME/.config/Elysia/widgets/visualizer/dark/visualizer"
APPLICATIONS="$HOME/.config/hypr/applications.conf"

apply_dark_theme() {
    echo "Applying Dark Theme..."

    # Update Hyprland colors for Dark theme
    sed -i -E 's/^( *col\.active_border *= *rgb\()[^)]+(\))$/\1'"7077bd"'\2/' "$HYPER_CONF"
    kitty +kitten themes --reload-in=all "HoC Elysia"
    hyprctl reload

    pkill elysia-widget-daemon
    elysia-widget-daemon

    # Set GTK theme
    gsettings set org.gnome.desktop.interface gtk-theme "ElysiaOS-HoC"
    gsettings set org.gnome.desktop.interface icon-theme "ElysiaOS-HoC"
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

    # Set Dark theme Wallpaper

    # Remove any previous theme state
    rm -f "$LIGHT_FILE"
    touch "$DARK_FILE"

    ~/.config/Elysia/wallpaper/Dark/d-wallpaper.sh

    pkill visualizer && "$VISUALIZER_HOC"

    echo "Dark theme applied."
}

# Detect and apply
if [[ -f "$DARK_FILE" ]]; then
    echo "bomb"
else
    apply_dark_theme
fi