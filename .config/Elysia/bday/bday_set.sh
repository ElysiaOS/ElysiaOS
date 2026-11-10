#!/usr/bin/env bash

INI_FILE="$HOME/.config/Elysia/bday/birthday.ini"

PATTERN='^[0-9]{2}/[0-9]{2}'

while true; do
  read -rp "Enter birthday as MM/DD format: " birthday
  
  if [[ "$birthday" =~ $PATTERN ]]; then
    break
  else
    echo "Invalid format. Please enter exactly two digits, a slash, and two digits (e.g. 05/14)"
  fi
done

echo "birthday=$birthday" > "$INI_FILE"

echo "Successfully wrote to $INI_FILE"
