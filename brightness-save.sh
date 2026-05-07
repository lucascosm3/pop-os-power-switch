#!/bin/bash
set -euo pipefail

backlight="/sys/class/backlight/intel_backlight/brightness"
persist_file="/var/lib/power-profile-switch/brightness"
max_brightness=$(cat /sys/class/backlight/intel_backlight/max_brightness)
min_brightness=$((max_brightness * 5 / 100))

current=$(cat "$backlight")

if [ "$current" -ge "$min_brightness" ] 2>/dev/null; then
    mkdir -p "$(dirname "$persist_file")"
    echo "$current" > "$persist_file"
fi