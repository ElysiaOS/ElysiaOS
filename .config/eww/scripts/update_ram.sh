#!/usr/bin/env bash
#!/bin/bash

# Get memory stats in a locale-independent way
read -r label total used free shared buff_cache available <<< \
  "$(LC_ALL=C free -m | awk 'NR==2 {print $1, $2, $3, $4, $5, $6, $7}')"

# Calculate percentage used
printf "%.0f\n" "$(( used * 100 / total ))"
