#!/bin/bash

# Directories
dark_wall_dir="${HOME}/.config/Elysia/wallpaper/Dark"
light_wall_dir="${HOME}/.config/Elysia/wallpaper/Light"
theme_script="${HOME}/.config/Elysia/Theme.sh"

# Theme state flags
dark_flag="${HOME}/.config/hypr/Dark.txt"
light_flag="${HOME}/.config/hypr/Light.txt"

# Collect wallpapers from BOTH Light and Dark
all_wallpapers=$(find "$dark_wall_dir" "$light_wall_dir" -maxdepth 1 -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \))

# Randomly select one wallpaper
selected_wallpaper=$(echo "$all_wallpapers" | shuf -n 1)

# Exit if nothing found
if [ -z "$selected_wallpaper" ]; then
    notify-send "Elysia" "No wallpapers found"
    exit 1
fi

# Determine theme type based on selected wallpaper path
if [[ "$selected_wallpaper" == "$light_wall_dir"* ]]; then
    theme_type="Light"
    icon_dir="${light_wall_dir}/icon"
elif [[ "$selected_wallpaper" == "$dark_wall_dir"* ]]; then
    theme_type="Dark"
    icon_dir="${dark_wall_dir}/icon"
else
    theme_type="Unknown"
    icon_dir=""
fi

# Set the wallpaper
swww img --transition-duration 2 --transition-type grow --transition-step 45 --transition-fps 30 "$selected_wallpaper"

# Extract filename
wallpaper_name=$(basename "$selected_wallpaper")

# Look for a matching icon
icon_path=""
for ext in png jpg jpeg; do
    try="${icon_dir}/${wallpaper_name%.*}.$ext"
    if [ -f "$try" ]; then
        icon_path="$try"
        break
    fi
done

# Notify user
if [ -n "$icon_path" ]; then
    notify-send -i "$icon_path" "Elysia" "Wallpaper changed"
else
    notify-send -i "$icon_path" "Elysia" "Wallpaper changed"
fi

# Conditionally run Theme.sh if the selected theme doesn't match current
if [[ "$theme_type" == "Light" && ! -f "$light_flag" ]]; then
    bash "$theme_script"
elif [[ "$theme_type" == "Dark" && ! -f "$dark_flag" ]]; then
    bash "$theme_script"
fi
