#!/bin/bash

THEME_STATE_DIR="$HOME/.config/hypr"
LIGHT_FILE="$THEME_STATE_DIR/Light.txt"
DARK_FILE="$THEME_STATE_DIR/Dark.txt"
VISUALIZER_ELY="$HOME/.config/Elysia/widgets/visualizer/light/visualizer"
HYPER_CONF="$HOME/.config/hypr/variables.conf"
APPLICATIONS="$HOME/.config/hypr/applications.conf"

apply_light_theme() {
    echo "Applying Light Theme..."

    # Update Hyprland colors for Light theme
    sed -i -E 's/^( *col\.active_border *= *rgb\()[^)]+(\))$/\1'"eb71dc"'\2/' "$HYPER_CONF"
    kitty +kitten themes --reload-in=all "Elysia"
    hyprctl reload

    pkill elysia-widget-daemon
    elysia-widget-daemon

    # Set GTK theme
    gsettings set org.gnome.desktop.interface gtk-theme "ElysiaOS"
    gsettings set org.gnome.desktop.interface icon-theme "ElysiaOS"
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'

    # Remove Dark theme state
    rm -f "$DARK_FILE"

    # ALWAYS write "cyrene" to Light.txt
    echo "cyrene" > "$LIGHT_FILE"

    # Set Light wallpaper
    ~/.config/Elysia/wallpaper/Light/l-wallpaper.sh

    pkill visualizer && "$VISUALIZER_ELY"

    echo "Light theme applied. (cyrene)"
}

apply_light_theme
