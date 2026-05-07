#!/bin/bash
set -euo pipefail

backlight="/sys/class/backlight/intel_backlight/brightness"
persist_dir="/var/lib/power-profile-switch"
persist_file="$persist_dir/brightness"

mkdir -p "$persist_dir"

current=$(cat "$backlight")
echo "$current" > "$persist_file"

while inotifywait -qq -e modify,attrib "$backlight"; do
    current=$(cat "$backlight")
    echo "$current" > "$persist_file"
done