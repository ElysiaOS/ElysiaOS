#!/usr/bin/env bash

SCRIPTS_DIR="$HOME/.config/Elysia"

LIGHT_SCRIPT="$SCRIPTS_DIR/ElysiaTheme.sh"
DARK_SCRIPT="$SCRIPTS_DIR/DarkTheme.sh"
CYRENE_SCRIPT="$SCRIPTS_DIR/CyreneTheme.sh"

clear
echo "==============================="
echo "        SELECT THEME           "
echo "==============================="
echo "   [1] Light Theme"
echo "   [2] Dark Theme"
echo "   [3] Cyrene Theme"
echo "   [q] Cancel / Exit"
echo "==============================="

read -r -p "Enter selection (1-3): " KEY

echo "Captured input: [${KEY}]"

if [[ -z "${KEY}" ]]; then
  echo "Error: No input detected. Aborting"
  sleep 1.5
  exit 1
fi

case "${KEY}" in
    1)
        [[ -f "$LIGHT_SCRIPT" ]] && bash "$LIGHT_SCRIPT"
        ;;
    2)
        [[ -f "$DARK_SCRIPT" ]] && bash "$DARK_SCRIPT"
        ;;
    3)
        [[ -f "$CYRENE_SCRIPT" ]] && bash "$CYRENE_SCRIPT"
        ;;
    q|Q)
        echo "Exiting."
        exit 0
        ;;
    *)
        echo "Invalid key: '${KEY}'"
        sleep 0.4
        exit 1
        ;;
esac
