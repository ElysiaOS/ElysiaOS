#!/bin/bash

setsid bash -c '

while true; do
    # Check if Waybar is running
    if ! pgrep -x "battery-bar" > /dev/null; then
        echo "Waybar is not running. Waiting..."
        sleep 9
        continue
    fi

    # Get list of active players
    players=$(playerctl -l 2>/dev/null)
    index=1

    # Loop through all detected players
    for player in $players; do
        status=$(playerctl -p "$player" status 2>/dev/null)
        if [[ $status == "Playing" ]]; then
            # Determine output file name
            if [[ $index -eq 1 ]]; then
                output="/tmp/cover_music.png"
            else
                output="/tmp/cover_music${index}.png"
            fi

            # Try to get album art
            album_art=$(playerctl -p "$player" metadata mpris:artUrl 2>/dev/null)

            # Handle mpv fallback
            if [[ -z $album_art && "$player" == "mpv" ]]; then
                album_art="/path/to/default/video_icon.png"
                cp "$album_art" "$output"
                echo "$output"
                ((index++))
                continue
            fi

            # Skip if no album art at all
            if [[ -z $album_art ]]; then
                ((index++))
                continue
            fi

            # Copy or download cover image
            if [[ "$album_art" =~ ^file:// ]]; then
                cp "${album_art#file://}" /tmp/cover_tmp.jpeg
            else
                curl -s "${album_art}" --output "/tmp/cover_tmp.jpeg"
            fi

            # Convert to circular PNG with alpha using ImageMagick
            convert /tmp/cover_tmp.jpeg -resize 128x128^ -gravity center -extent 128x128 \
                \( +clone -threshold -1 -negate -fill white -draw "circle 64,64 64,0" \) \
                -alpha off -compose CopyOpacity -composite "$output"

            echo "$output"
            ((index++))
        fi
    done

    # Optional cleanup: remove old unused covers if fewer players now
    existing=$(ls /tmp/cover_music*.png 2>/dev/null | wc -l)
    if (( existing > index - 1 )); then
        for extra in $(seq $index $existing); do
            rm -f "/tmp/cover_music${extra}.png" 2>/dev/null
        done
    fi

    sleep 2
done
' >/dev/null 2>&1 &
