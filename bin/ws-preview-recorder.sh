#!/usr/bin/env zsh
set -euo pipefail

DIR="/tmp/workspace_previews"
mkdir -p "$DIR"

echo "[ws-preview] Saving previews to $DIR"
echo "[ws-preview] Watching current workspace..."

last_id=""
last_capture_time=0

# Temporary location for new capture
TMP_IMG="/tmp/ws_temp.png"
THUMB_WIDTH=1366
THUMB_HEIGHT=768

# Store last image hash per workspace
declare -A last_hashes

while true; do
    id=$(hyprctl -j activeworkspace | jq -r '.id' 2>/dev/null || echo "")
    now=$(date +%s)

    if [[ "$id" != "$last_id" ]]; then
        last_id="$id"
        last_capture_time=$now
    fi

    elapsed=$(( now - last_capture_time ))

    if (( elapsed >= 2 )); then
        out="$DIR/workspace_${id}.png"

        # Capture to temporary location first
        if grim "$TMP_IMG" >/dev/null 2>&1; then
            new_hash=$(sha256sum "$TMP_IMG" | cut -d' ' -f1)
            if [[ "${last_hashes[$id]:-}" != "$new_hash" ]]; then
                mv "$TMP_IMG" "$out"
                last_hashes[$id]="$new_hash"
                echo "[ws-preview] Captured workspace $id -> $out (changed)"
            else
                echo "[ws-preview] Skipped workspace $id (unchanged)"
            fi
        else
            echo "[ws-preview] grim failed for workspace $id" >&2
        fi

        last_capture_time=$now
    fi

    sleep 0.2
done
