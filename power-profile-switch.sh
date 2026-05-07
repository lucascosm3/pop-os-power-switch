#!/bin/bash
set -euo pipefail

backlight="/sys/class/backlight/intel_backlight/brightness"
max_brightness=$(cat /sys/class/backlight/intel_backlight/max_brightness)
persist_file="/var/lib/power-profile-switch/brightness"
min_brightness=$((max_brightness * 5 / 100))

if [ -f "$backlight" ]; then
    current=$(cat "$backlight")
fi

if [ -f "$persist_file" ]; then
    saved=$(cat "$persist_file")
fi

if [ -n "$current" ] && [ "$current" -ge "$min_brightness" ] 2>/dev/null; then
    brightness="$current"
elif [ -n "$saved" ] && [ "$saved" -ge "$min_brightness" ] 2>/dev/null; then
    brightness="$saved"
else
    brightness=$((max_brightness * 80 / 100))
fi

ac_online=0
for supply in /sys/class/power_supply/*/online; do
    [ -f "$supply" ] || continue
    if [ "$(cat "$supply")" = "1" ]; then
        ac_online=1
        break
    fi
done

if [ "$ac_online" = "1" ]; then
    target="performance"
else
    target="balanced"
fi

for i in 1 2 3 4 5; do
    system76-power profile "$target" > /dev/null 2>&1 || true
    [ "$i" -lt 5 ] && sleep 3
done

echo "$brightness" > "$backlight" 2>/dev/null || true

mkdir -p "$(dirname "$persist_file")"
echo "$brightness" > "$persist_file"