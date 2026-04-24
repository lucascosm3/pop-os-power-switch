#!/bin/bash
set -euo pipefail

backlight="/sys/class/backlight/intel_backlight/brightness"
brightness=$(cat "$backlight") 2>/dev/null || true

ac_online=0
for supply in /sys/class/power_supply/*/online; do
    if [ "$(cat "$supply")" = "1" ]; then
        ac_online=1
        break
    fi
done

if [ "$ac_online" = "1" ]; then
    system76-power profile performance > /dev/null 2>&1
else
    system76-power profile balanced > /dev/null 2>&1
fi

[ -n "$brightness" ] && echo "$brightness" > "$backlight" 2>/dev/null || true