#!/bin/bash

# Configuration
TMP_DIR="$HOME/.cache/eww"
IMAGE_DIR="$HOME/.config/Elysia/Art"
CACHE_FILE="$TMP_DIR/.dashboard_cache"  # Cache file where we store the current image path

# Ensure TMP_DIR exists
if [[ ! -d $TMP_DIR ]]; then
  mkdir -p $TMP_DIR
fi

# Function to get a list of all "elysia" images (jpg or png) in IMAGE_DIR
get_image_list() {
  find "$IMAGE_DIR" -type f \( -iname "elysia*.jpg" -o -iname "elysia*.png" \) | sort
}

# Function to get the next image in the sequence
get_next_image() {
  IMAGE_LIST=($(get_image_list))  # Get the sorted list of images
  
  # If no image is currently selected (no cache), default to the first image
  if [[ ! -f $CACHE_FILE ]]; then
    echo "${IMAGE_LIST[0]}"
  else
    CURRENT_IMAGE=$(cat "$CACHE_FILE")  # Read the current image path from the cache
    
    # Find the next image in the list
    for i in "${!IMAGE_LIST[@]}"; do
      if [[ "${IMAGE_LIST[$i]}" == "$CURRENT_IMAGE" ]]; then
        NEXT_INDEX=$(( (i + 1) % ${#IMAGE_LIST[@]} ))  # Wrap around if necessary
        echo "${IMAGE_LIST[$NEXT_INDEX]}"
        return
      fi
    done
    # If not found (somehow), default to the first image
    echo "${IMAGE_LIST[0]}"
  fi
}

# Change image only when 'eww close dashboard' is detected
if [[ $1 == "close" ]]; then
  NEXT_IMAGE=$(get_next_image)
  # Update the cache file with the new image path
  echo "$NEXT_IMAGE" > "$CACHE_FILE"
  # Optionally, copy the next image to the cache directory
  cp "$NEXT_IMAGE" "$TMP_DIR/$(basename $NEXT_IMAGE)"
  echo "Updated image: $NEXT_IMAGE"
fi

# Echo the path of the current image
echo_image_url() {
  if [[ -f $CACHE_FILE ]]; then
    CURRENT_IMAGE=$(cat "$CACHE_FILE")
    echo "$CURRENT_IMAGE"
  else
    echo "No image found in cache"
  fi
}

# Handle the 'echo' and 'get' commands
if [[ $1 == "echo" ]]; then
  echo_image_url
fi

if [[ $1 == "get" ]]; then
  echo "Updated image path: $(echo_image_url)"
fi
