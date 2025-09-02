#!/bin/bash

TEMP_CPU=$(sensors | grep -m 1 '^CPU:' | awk '{print $2}')
TEMP_GPU=$(sensors | grep -m 1 '^GPU:' | awk '{print $2}')
FAN=$(sensors | grep -m 1 'Processor Fan:' | awk '{print $3}')

# Use C locale to avoid localization issues and parse by column
read -r _ total used free shared buff_cache available <<< "$(LC_ALL=C free -h | awk 'NR==2 {print $1, $2, $3, $4, $5, $6, $7}')"

RAM_USED=$used
RAM_FREE=$available

[ -z "$TEMP_CPU" ] && TEMP_CPU="N/A"
[ -z "$TEMP_GPU" ] && TEMP_GPU="N/A"
[ -z "$FAN" ] && FAN="N/A"
[ -z "$RAM_FREE" ] && RAM_FREE="N/A"
[ -z "$RAM_USED" ] && RAM_USED="N/A"

echo "{\"text\": \"🌡 $TEMP_CPU\", \"tooltip\": \"CPU: $TEMP_CPU\nCPU Fan Speed: ${FAN} RPM\nUsed RAM: ${RAM_USED}\nFree RAM: ${RAM_FREE}\"}"
