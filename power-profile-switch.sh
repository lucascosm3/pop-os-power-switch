#!/bin/bash
set -euo pipefail

backlight="/sys/class/backlight/intel_backlight/brightness"
max_brightness=$(cat /sys/class/backlight/intel_backlight/max_brightness)
saved_brightness="/var/lib/systemd/backlight/pci-0000:00:02.0:backlight:intel_backlight"
persist_file="/var/lib/power-profile-switch/brightness"

min_brightness=$((max_brightness * 10 / 100))

if [ -f "$persist_file" ]; then
    brightness=$(cat "$persist_file")
elif [ -f "$saved_brightness" ] && [ "$(cat "$saved_brightness")" -ge "$min_brightness" ]; then
    brightness=$(cat "$saved_brightness")
elif [ -f "$backlight" ] && [ "$(cat "$backlight")" -ge "$min_brightness" ]; then
    brightness=$(cat "$backlight")
fi

[ -z "$brightness" ] || [ "$brightness" -lt "$min_brightness" ] && brightness=$((max_brightness * 80 / 100))

ac_online=0
for supply in /sys/class/power_supply/*/online; do
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

for i in 1 2 3; do
    system76-power profile "$target" > /dev/null 2>&1 || true
    [ "$i" -lt 3 ] && sleep 2
done

echo "$brightness" > "$backlight" 2>/dev/null || true

mkdir -p "$(dirname "$persist_file")"
echo "$brightness" > "$persist_file"