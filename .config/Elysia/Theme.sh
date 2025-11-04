#!/bin/bash

THEME_STATE_DIR="$HOME/.config/hypr"
LIGHT_FILE="$THEME_STATE_DIR/Light.txt"
DARK_FILE="$THEME_STATE_DIR/Dark.txt"
HYPER_CONF="$HOME/.config/hypr/variables.conf"
VISUALIZER_ELY="$HOME/.config/Elysia/widgets/visualizer/light/visualizer"
VISUALIZER_HOC="$HOME/.config/Elysia/widgets/visualizer/dark/visualizer"
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
if [[ -f "$LIGHT_FILE" ]]; then
    apply_dark_theme
else
    apply_light_theme
fi
