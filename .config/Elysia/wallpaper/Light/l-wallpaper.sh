# Directory variables
wall_dir="${HOME}/.config/Elysia/wallpaper/Light/"
icon_dir="${HOME}/.config/Elysia/wallpaper/icon/"  # Directory containing matching icons

# Randomly select a wallpaper
selected_wallpaper="$(find "$wall_dir" -maxdepth 1 -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \) | shuf -n 1)"

# Ensure a wallpaper was found
if [ -z "$selected_wallpaper" ]; then
    notify-send "Elysia" "No wallpapers found in ${wall_dir}"
    exit 1
fi

# Set the wallpaper with swww
swww img --transition-duration 2 --transition-type grow --transition-step 45 --transition-fps 30 "$selected_wallpaper"

# Extract the wallpaper filename
wallpaper_name=$(basename "$selected_wallpaper")

# Set the icon path to match the wallpaper name
icon_path="${icon_dir}/${wallpaper_name}"

# Check for an existing matching icon (handling multiple extensions)
for ext in png jpg jpeg; do
    if [ -f "${icon_dir}/${wallpaper_name%.*}.$ext" ]; then
        icon_path="${icon_dir}/${wallpaper_name%.*}.$ext"
        break
    fi
done

# Send a notification with the wallpaper name and matching icon
if [ -f "$icon_path" ]; then
    notify-send -i "$icon_path" "Elysia" "Wallpaper was changed"
else
    notify-send "Elysia" "Wallpaper was changed"
fi