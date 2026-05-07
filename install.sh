#!/bin/bash
set -euo pipefail

echo "Instalando power-profile-switch..."

if ! command -v inotifywait &>/dev/null; then
    echo "Instalando inotify-tools..."
    apt install -y inotify-tools
fi

cp power-profile-switch.sh /usr/local/bin/
chmod +x /usr/local/bin/power-profile-switch.sh

cp brightness-watcher.sh /usr/local/bin/
chmod +x /usr/local/bin/brightness-watcher.sh

cp 99-power-profile.rules /etc/udev/rules.d/
udevadm control --reload-rules

cp power-profile-switch.service /etc/systemd/system/
cp power-profile-switch-resume.service /etc/systemd/system/
cp brightness-watcher.service /etc/systemd/system/
systemctl daemon-reload

systemctl enable power-profile-switch.service
systemctl enable power-profile-switch-resume.service
systemctl enable brightness-watcher.service

systemctl start power-profile-switch.service
systemctl start brightness-watcher.service

mkdir -p /var/lib/power-profile-switch

echo "Pronto! O perfil de energia agora troca automaticamente."
echo "AC conectada  -> performance"
echo "Na bateria    -> balanced"
echo ""
echo "O servico brightness-watcher monitora alteracoes manuais"
echo "de brilho e salva a preferencia do usuario."