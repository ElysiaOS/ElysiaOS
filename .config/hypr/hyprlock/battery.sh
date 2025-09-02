#!/bin/bash
# Script for Battery Stats
if [ "$1" == "-bat" ]; then
	# Find the first available battery (BAT0, BAT1, BAT2, etc.)
	battery_path=""
	for bat in /sys/class/power_supply/BAT*; do
		if [ -d "$bat" ] && [ -f "$bat/capacity" ] && [ -f "$bat/status" ]; then
			battery_path="$bat"
			break
		fi
	done
	
	# Check if we found a battery
	if [ -z "$battery_path" ]; then
		echo "No battery found"
		exit 1
	fi
	
	# Get the current battery percentage
	battery_percentage=$(cat "$battery_path/capacity")
	# Get the battery status (Charging or Discharging)
	battery_status=$(cat "$battery_path/status")
	
	# Define the battery icons for each 10% segment
	battery_icons=("󱉝" "󱊡" "󱊡" "󱊡" "󱊢" "󱊢" "󱊢" "󱊢" "󱊢" "󱊣")
	# Define the charging icon
	charging_icon="󰂄"
	
	# Calculate the index for the icon array
	icon_index=$((battery_percentage / 10))
	# Ensure index doesn't exceed array bounds
	if [ $icon_index -gt 9 ]; then
		icon_index=9
	fi
	
	# Get the corresponding icon
	battery_icon=${battery_icons[icon_index]}
	
	# Check if the battery is charging
	if [ "$battery_status" = "Charging" ]; then
		battery_icon="$charging_icon"
	fi
	
	# Output the battery percentage and icon
	echo "$battery_percentage%$battery_icon"
else
	echo "Invalid option: $1"
	echo "Usage: $0 -bat"
	exit 1
fi