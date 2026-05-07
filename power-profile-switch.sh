#!/bin/bash
set -euo pipefail

backlight="/sys/class/backlight/intel_backlight/brightness"
max_brightness=$(cat /sys/class/backlight/intel_backlight/max_brightness)
persist_file="/var/lib/power-profile-switch/brightness"
min_brightness=$((max_brightness * 5 / 100))
tag="power-profile-switch"

prefer_saved=0
if [ "${1:-}" = "--prefer-saved" ]; then
    prefer_saved=1
fi

if [ -f "$backlight" ]; then
    current=$(cat "$backlight")
fi

if [ -f "$persist_file" ]; then
    saved=$(cat "$persist_file")
fi

if [ "$prefer_saved" = "1" ] && [ -n "$saved" ] && [ "$saved" -ge "$min_brightness" ] 2>/dev/null; then
    brightness="$saved"
elif [ -n "$current" ] && [ "$current" -ge "$min_brightness" ] 2>/dev/null; then
    brightness="$current"
elif [ -n "$saved" ] && [ "$saved" -ge "$min_brightness" ] 2>/dev/null; then
    brightness="$saved"
else
    brightness=$((max_brightness * 80 / 100))
fi

logger -t "$tag" "prefer_saved=$prefer_saved current=${current:-none} saved=${saved:-none} using=$brightness"

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

logger -t "$tag" "AC=$ac_online target_profile=$target"

system76-power profile "$target" > /dev/null 2>&1 || true

echo "$brightness" > "$backlight" 2>/dev/null || true

mkdir -p "$(dirname "$persist_file")"
echo "$brightness" > "$persist_file"

logger -t "$tag" "profile=$target brightness=$brightness set"