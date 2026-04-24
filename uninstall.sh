#!/bin/bash
set -euo pipefail

echo "Removendo power-profile-switch..."

systemctl stop power-profile-switch.service 2>/dev/null || true
systemctl disable power-profile-switch.service 2>/dev/null || true

rm -f /etc/systemd/system/power-profile-switch.service
systemctl daemon-reload

rm -f /etc/udev/rules.d/99-power-profile.rules
udevadm control --reload-rules

rm -f /usr/local/bin/power-profile-switch.sh

echo "Removido. Perfil de energia voltou ao comportamento padrão do sistema."