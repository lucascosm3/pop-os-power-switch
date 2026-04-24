#!/bin/bash
set -euo pipefail

echo "Instalando power-profile-switch..."

cp power-profile-switch.sh /usr/local/bin/
chmod +x /usr/local/bin/power-profile-switch.sh

cp 99-power-profile.rules /etc/udev/rules.d/
udevadm control --reload-rules

cp power-profile-switch.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable power-profile-switch.service
systemctl start power-profile-switch.service

echo "Pronto! O perfil de energia agora troca automaticamente."
echo "AC conectada  -> performance"
echo "Na bateria    -> balanced"