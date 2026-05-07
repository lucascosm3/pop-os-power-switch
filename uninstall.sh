#!/bin/bash
set -euo pipefail

echo "Removendo power-profile-switch..."

systemctl stop power-profile-switch.service 2>/dev/null || true
systemctl stop power-profile-switch-resume.service 2>/dev/null || true
systemctl stop brightness-watcher.service 2>/dev/null || true

systemctl disable power-profile-switch.service 2>/dev/null || true
systemctl disable power-profile-switch-resume.service 2>/dev/null || true
systemctl disable brightness-watcher.service 2>/dev/null || true

rm -f /etc/systemd/system/power-profile-switch.service
rm -f /etc/systemd/system/power-profile-switch-resume.service
rm -f /etc/systemd/system/brightness-watcher.service
systemctl daemon-reload

rm -f /etc/udev/rules.d/99-power-profile.rules
udevadm control --reload-rules

rm -f /usr/local/bin/power-profile-switch.sh
rm -f /usr/local/bin/brightness-watcher.sh

rm -rf /var/lib/power-profile-switch

echo "Removido. Perfil de energia voltou ao comportamento padrao do sistema."