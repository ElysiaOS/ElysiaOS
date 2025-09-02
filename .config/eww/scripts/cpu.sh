#!/usr/bin/env bash
# ~/.config/eww/scripts/cpu_usage.sh

LC_ALL=C top -bn1 | grep "Cpu(s)" | \
  sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | \
  awk '{printf "%d\n", 100 - $1}'
