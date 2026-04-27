#!/bin/bash
set -euo pipefail

backlight="/sys/class/backlight/intel_backlight/brightness"
saved_brightness="/var/lib/systemd/backlight/pci-0000:00:02.0:backlight:intel_backlight"

if [ -f "$saved_brightness" ]; then
    brightness=$(cat "$saved_brightness")
elif [ -f "$backlight" ]; then
    brightness=$(cat "$backlight")
fi

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

[ -n "$brightness" ] && echo "$brightness" > "$backlight" 2>/dev/null || true