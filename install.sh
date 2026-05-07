#!/bin/bash
set -euo pipefail

echo "Instalando power-profile-switch..."

cp power-profile-switch.sh /usr/local/bin/
chmod +x /usr/local/bin/power-profile-switch.sh

cp brightness-save.sh /usr/local/bin/
chmod +x /usr/local/bin/brightness-save.sh

cp 99-power-profile.rules /etc/udev/rules.d/
udevadm control --reload-rules

cp power-profile-switch.service /etc/systemd/system/
cp power-profile-switch-resume.service /etc/systemd/system/
cp power-profile-switch-late.service /etc/systemd/system/
cp power-profile-switch-late.timer /etc/systemd/system/
cp brightness-save.service /etc/systemd/system/
cp brightness-save.timer /etc/systemd/system/
systemctl daemon-reload

systemctl enable power-profile-switch.service
systemctl enable power-profile-switch-resume.service
systemctl enable power-profile-switch-late.timer
systemctl enable brightness-save.timer

systemctl start power-profile-switch.service

mkdir -p /var/lib/power-profile-switch

echo "Pronto! O perfil de energia agora troca automaticamente."
echo "AC conectada  -> performance"
echo "Na bateria    -> balanced"
echo ""
echo "O.timer brightness-save salva a preferencia de brilho"
echo "a cada 5 minutos para restaurar no proximo boot."