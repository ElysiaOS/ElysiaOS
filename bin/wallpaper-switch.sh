#!/bin/bash


if [[ -f ~/.config/hypr/Dark.txt ]]; then
	swww img --transition-type grow --transition-step 10 --transition-fps 60 "$(find ~/.config/Elysia/wallpaper/Dark -maxdepth 1 -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \) | shuf -n 1)"

elif [[ -f ~/.config/hypr/Light.txt ]]; then
	swww img --transition-type grow --transition-step 10 --transition-fps 60 "$(find ~/.config/Elysia/wallpaper/Light -maxdepth 1 -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \) | shuf -n 1)"

else
	swww img --transition-type grow --transition-step 10 --transition-fps 60 "$(find ~/.config/Elysia/wallpaper/Light -maxdepth 1 -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \) | shuf -n 1)"
	
fi