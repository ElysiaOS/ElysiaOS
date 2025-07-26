#!/bin/bash

WAYBAR_SCRIPT="$HOME/.config/hypr/Scripts/waybar-reload.sh"
SWAYNC_SCRIPT="$HOME/.config/swaync/swaync-reload.sh"
WAYBAR_DARK_STYLE="$HOME/.config/waybar/Dark/style.css"
SWAYNC_DARK_STYLE="$HOME/.config/swaync/Dark/style.css"
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
    sed -i -E 's|^\$launcher *=.*$|$launcher = rofi -show drun -theme ~/.config/rofi/themes/ely.rasi|' "$APPLICATIONS"
    kitty +kitten themes --reload-in=all "Elysia"
    hyprctl reload

    pkill eww && eww daemon

    # Set GTK theme
    gsettings set org.gnome.desktop.interface gtk-theme "ElysiaOS"
    gsettings set org.gnome.desktop.interface icon-theme "ElysiaOS"
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'

    # Set Light theme Wallpaper

    # Remove any previous theme state
    rm -f "$DARK_FILE"
    touch "$LIGHT_FILE"

    ~/.config/Elysia/wallpaper/Light/l-wallpaper.sh

    # Reload Waybar after saving state
    "$WAYBAR_SCRIPT"

    # Kill and restart swaync
    "$SWAYNC_SCRIPT"
    pkill visualizer && "$VISUALIZER_ELY"

    echo "Light theme applied."
}


# Detect and apply
if [[ -f "$LIGHT_FILE" ]]; then
    echo "bomb"
else
    apply_light_theme
fi