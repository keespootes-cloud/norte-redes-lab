#!/usr/bin/env bash
# =============================================================================
#  Norte Redes · Reto en parejas: el SABOTEADOR
#
#  Qué hace: mete 3 fallos de seguridad al azar (de 5 posibles) en ESTA máquina
#  virtual. Después, tu compañero tiene que encontrarlos solo con la terminal.
#
#  Cómo se usa:
#     sudo bash sabotaje.sh              mete los 3 fallos
#     sudo bash sabotaje.sh --solucion   enseña cuáles eran (al acabar el reto)
#  Para deshacerlo: restaura la instantánea "antes-UF2"  o  sudo bash reparar.sh
#
#  SOLO para máquinas virtuales de prácticas: se niega a funcionar fuera de una.
#  Temario relacionado: UF2 · Tema 01 · apartados 1.1.3 a 1.1.5 y 1.2.
# =============================================================================

# Detener el script si se usa una variable que no existe.
set -u

# Fichero donde se apuntan los fallos metidos. Está en la carpeta de root
# (/root), así que un usuario normal no puede leerlo.
REGISTRO=/root/.norte-redes-sabotaje

# "id -u" devuelve el número de usuario (UID). Si no es 0, no somos root.
if [ "$(id -u)" -ne 0 ]; then echo "Ejecútalo con sudo:  sudo bash sabotaje.sh"; exit 1; fi

# Con la opción --solucion solo enseñamos el registro y salimos.
# "sed 's/^/  - /'" añade "  - " al principio de cada línea para que se lea mejor.
if [ "${1:-}" = "--solucion" ]; then
  if [ -f "$REGISTRO" ]; then echo "Fallos que metió el saboteador:"; sed 's/^/  - /' "$REGISTRO"
  else echo "No hay ningún sabotaje registrado en esta máquina."; fi
  exit 0
fi

# Protección: "systemd-detect-virt -q" termina bien solo si estamos dentro de
# una máquina virtual. En un ordenador real, el script no hace nada.
if ! systemd-detect-virt -q 2>/dev/null; then
  echo "Esto no parece una máquina virtual. Por seguridad, no hago nada."; exit 1
fi

# Si ya existe el registro, la máquina ya está saboteada: no repetimos.
if [ -f "$REGISTRO" ]; then
  echo "Esta máquina ya está saboteada. Para repetir: sudo bash reparar.sh"; exit 1
fi

# Pedimos confirmación escrita. "read -p" muestra la pregunta y guarda la
# respuesta en la variable r. Solo seguimos si se escribe exactamente SI.
echo "Vas a meter 3 fallos de seguridad en esta máquina virtual."
read -r -p "¿Has hecho la instantánea 'antes-UF2'? Escribe SI para continuar: " r
[ "$r" = "SI" ] || { echo "Cancelado. Haz primero la instantánea."; exit 1; }

# primero_que_exista A B C: devuelve el primer usuario de la lista que exista.
# "id usuario" termina bien si el usuario existe; ">/dev/null 2>&1" oculta su salida.
primero_que_exista() { for u in "$@"; do id "$u" >/dev/null 2>&1 && { echo "$u"; return; }; done; }

# --- Los 5 fallos posibles --------------------------------------------------------

# Fallo 1: una cuenta "soporte" con UID 0, es decir, root con otro nombre.
#   -o  permite repetir un UID que ya existe     -u 0  le da el UID de root
#   -g 0  grupo root     -M  sin carpeta personal     -s /bin/bash  con terminal
fallo_uid0() {
  id soporte >/dev/null 2>&1 || useradd -o -u 0 -g 0 -M -d /nonexistent -s /bin/bash -c "Soporte" soporte
  echo "uid0: la cuenta 'soporte' tiene UID 0 (es root con otro nombre)" >> "$REGISTRO"
}

# Fallo 2: una cuenta "invitado" SIN contraseña.
#   passwd -d  borra la contraseña (deja vacío el campo 2 de /etc/shadow)
fallo_sinpass() {
  id invitado >/dev/null 2>&1 || useradd -m -s /bin/bash -c "Invitado" invitado
  passwd -d invitado >/dev/null
  echo "sinpass: la cuenta 'invitado' no tiene contraseña" >> "$REGISTRO"
}

# Fallo 3: alguien que no debería es administrador (lo mete en el grupo sudo).
fallo_sudo() {
  u=$(primero_que_exista marta luis becario)
  [ -n "$u" ] || { useradd -m -s /bin/bash temporal; u=temporal; }
  usermod -aG sudo "$u"
  echo "sudo:$u: '$u' está en el grupo sudo sin motivo" >> "$REGISTRO"
}

# Fallo 4: /etc/shadow legible por todos. 644 = rw-r--r-- (los "otros" pueden leer).
fallo_shadow() {
  chmod 644 /etc/shadow
  echo "shadow: /etc/shadow es legible por todos (644)" >> "$REGISTRO"
}

# Fallo 5: una cuenta que no debería tener terminal pasa a tener /bin/bash.
fallo_shell() {
  u=$(primero_que_exista becario games)
  usermod -s /bin/bash "$u"
  echo "shell:$u: '$u' tiene shell de login y no debería" >> "$REGISTRO"
}

# --- Ejecución ----------------------------------------------------------------------

# Crea el registro vacío con permisos 600 (solo root puede leerlo y escribirlo).
install -m 600 /dev/null "$REGISTRO"

# "printf … | shuf -n 3" baraja la lista de 5 fallos y se queda con 3 al azar.
# Para cada uno se llama a su función: fallo_uid0, fallo_sudo, etc.
for f in $(printf '%s\n' uid0 sinpass sudo shadow shell | shuf -n 3); do "fallo_$f"; done

# Limpiamos la pantalla para no dejar pistas al auditor.
clear
echo "Sabotaje terminado: hay 3 fallos escondidos en esta máquina."
echo "Pásale el teclado a tu compañero. Tiene 10 minutos."
