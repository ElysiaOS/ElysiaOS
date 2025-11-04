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

    # Set Light theme Wallpaper

    # Remove any previous theme state
    rm -f "$DARK_FILE"

    # Create the Light file with a random name
    choice=$(shuf -e "ely" "cyrene" -n 1)
    echo "$choice" > "$LIGHT_FILE"

    ~/.config/Elysia/wallpaper/Light/l-wallpaper.sh

    pkill visualizer && "$VISUALIZER_ELY"

    echo "Light theme applied. ($choice)"
}


# Detect and apply
if [[ -f "$LIGHT_FILE" ]]; then
    echo "bomb"
else
    apply_light_theme
fi