#!/bin/bash

setsid bash -c '

while true; do
    # Check if Waybar is running
    if ! pgrep -x "waybar" > /dev/null; then
        echo "Waybar is not running. Waiting..."
        sleep 9
        continue
    fi

    # Check for album art from prioritized players (now includes mpv)
    album_art=$(playerctl -p kew metadata mpris:artUrl 2>/dev/null || \
                playerctl -p chromium metadata mpris:artUrl 2>/dev/null || \
                playerctl -p spotify metadata mpris:artUrl 2>/dev/null || \
                playerctl -p firefox metadata mpris:artUrl 2>/dev/null || \
                playerctl -p mpv metadata mpris:artUrl 2>/dev/null)

    # If mpv is playing but no art URL is provided, use a default icon
    if [[ -z $album_art && $(playerctl -p mpv status 2>/dev/null) == "Playing" ]]; then
        album_art="/path/to/default/video_icon.png"
        cp "$album_art" /tmp/cover_waybar.png
        echo "/tmp/cover_waybar.png"
        sleep 2
        continue
    fi

    if [[ -n $album_art ]]; then
        # If the album art is a local file, copy it; otherwise download it
        if [[ "$album_art" =~ ^file:// ]]; then
            cp "${album_art#file://}" /tmp/cover.jpeg
        else
            curl -s "${album_art}" --output "/tmp/cover.jpeg"
        fi

        # Convert to circular PNG with alpha using ImageMagick
        convert /tmp/cover.jpeg -resize 128x128^ -gravity center -extent 128x128 \
            \( +clone -threshold -1 -negate -fill white -draw "circle 64,64 64,0" \) \
            -alpha off -compose CopyOpacity -composite /tmp/cover_waybar.png

        echo "/tmp/cover_waybar.png"
    else
        echo "No active players found."
    fi

    sleep 2
done
' >/dev/null 2>&1 &
