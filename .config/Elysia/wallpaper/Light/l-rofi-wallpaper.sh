# Set some variables
wall_dir="${HOME}/.config/Elysia/wallpaper/Light/"
icon_dir="${HOME}/.config/Elysia/wallpaper/Light/icon/"  # Directory containing matching icons
cacheDir="${HOME}/.config/Elysia/wallpaper/Light/1366x768/${theme}"
cacheDir2="${HOME}/.config/Elysia/wallpaper/Light/icon/${theme}"
rofi_command="${HOME}/bin/rofi -x11 -dmenu -theme ${HOME}/.config/rofi/themes/wallpaper.rasi -theme-str ${rofi_override}"

# Create cache dir if not exists
if [ ! -d "${cacheDir}" ] ; then
    mkdir -p "${cacheDir}"
fi

if [ ! -d "${cacheDir2}" ] ; then
    mkdir -p "${cacheDir2}"
fi

physical_monitor_size=24
monitor_res=$(hyprctl monitors | grep -A2 Monitor | head -n 2 | awk '{print $1}' | grep -oE '^[0-9]+')
dotsperinch=$(echo "scale=2; $monitor_res / $physical_monitor_size" | bc | xargs printf "%.0f")
monitor_res=$(( $monitor_res * $physical_monitor_size / $dotsperinch ))

rofi_override="element-icon{size:${monitor_res}px;border-radius:0px;}"

# Convert images in directory and save to cache dir
for imagen in "$wall_dir"/*.{jpg,jpeg,png}; do
    if [ -f "$imagen" ]; then
        nombre_archivo=$(basename "$imagen")
        if [ ! -f "${cacheDir}/${nombre_archivo}" ] ; then
            convert -strip "$imagen" -thumbnail 1366x768^ -gravity north -extent 1366x768 "${cacheDir}/${nombre_archivo}"
        fi
    fi
done

for imagen in "$wall_dir"/*.{jpg,jpeg,png}; do
    if [ -f "$imagen" ]; then
        nombre_archivo=$(basename "$imagen")
        if [ ! -f "${cacheDir2}/${nombre_archivo}" ] ; then
            convert -strip "$imagen" -thumbnail 250x250^ -gravity north -extent 250x250 "${cacheDir2}/${nombre_archivo}"
        fi
    fi
done

# Select a picture with rofi
wall_selection=$(find "${wall_dir}" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -exec basename {} \; | sort | while read -r A ; do echo -en "$A\x00icon\x1f""${cacheDir}"/"$A\n" ; done | $rofi_command)

# Set the wallpaper
[[ -n "$wall_selection" ]] || exit 1
swww img --transition-duration 2 --transition-type grow --transition-step 45 --transition-fps 30 "${wall_dir}/${wall_selection}"

# Send a notification with the wallpaper name and matching icon
icon_path="${icon_dir}/${wall_selection}"  # Assuming icons match wallpaper names
if [ -f "$icon_path" ]; then
    notify-send -i "$icon_path" "Elysia" "Wallpaper was changed"
else
    notify-send "Elysia" "Wallpaper was changed"
fi

exit 0
