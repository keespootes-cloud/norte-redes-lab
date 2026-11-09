#!/usr/bin/env bash
# =============================================================================
#  Norte Redes · Reto en parejas: el SABOTEADOR
#  Mete 3 fallos de seguridad al azar (de 5 posibles) en ESTA máquina virtual.
#  Después, tu compañero tiene que encontrarlos solo con la terminal.
#
#  Uso:     sudo bash sabotaje.sh              mete los 3 fallos
#           sudo bash sabotaje.sh --solucion   enseña cuáles eran (al final)
#  Deshacer: restaura la instantánea "antes-UF2"  o  sudo bash reparar.sh
#
#  SOLO para máquinas virtuales de prácticas. Se niega a funcionar fuera de una VM.
# =============================================================================
set -u
REGISTRO=/root/.norte-redes-sabotaje

if [ "$(id -u)" -ne 0 ]; then echo "Ejecútalo con sudo:  sudo bash sabotaje.sh"; exit 1; fi

if [ "${1:-}" = "--solucion" ]; then
  if [ -f "$REGISTRO" ]; then echo "Fallos que metió el saboteador:"; sed 's/^/  - /' "$REGISTRO"
  else echo "No hay ningún sabotaje registrado en esta máquina."; fi
  exit 0
fi

if ! systemd-detect-virt -q 2>/dev/null; then
  echo "Esto no parece una máquina virtual. Por seguridad, no hago nada."; exit 1
fi
if [ -f "$REGISTRO" ]; then
  echo "Esta máquina ya está saboteada. Para repetir: sudo bash reparar.sh"; exit 1
fi

echo "Vas a meter 3 fallos de seguridad en esta máquina virtual."
read -r -p "¿Has hecho la instantánea 'antes-UF2'? Escribe SI para continuar: " r
[ "$r" = "SI" ] || { echo "Cancelado. Haz primero la instantánea."; exit 1; }

primero_que_exista() { for u in "$@"; do id "$u" >/dev/null 2>&1 && { echo "$u"; return; }; done; }

fallo_uid0() {
  id soporte >/dev/null 2>&1 || useradd -o -u 0 -g 0 -M -d /nonexistent -s /bin/bash -c "Soporte" soporte
  echo "uid0: la cuenta 'soporte' tiene UID 0 (es root con otro nombre)" >> "$REGISTRO"
}
fallo_sinpass() {
  id invitado >/dev/null 2>&1 || useradd -m -s /bin/bash -c "Invitado" invitado
  passwd -d invitado >/dev/null
  echo "sinpass: la cuenta 'invitado' no tiene contraseña" >> "$REGISTRO"
}
fallo_sudo() {
  u=$(primero_que_exista marta luis becario)
  [ -n "$u" ] || { useradd -m -s /bin/bash temporal; u=temporal; }
  usermod -aG sudo "$u"
  echo "sudo:$u: '$u' está en el grupo sudo sin motivo" >> "$REGISTRO"
}
fallo_shadow() {
  chmod 644 /etc/shadow
  echo "shadow: /etc/shadow es legible por todos (644)" >> "$REGISTRO"
}
fallo_shell() {
  u=$(primero_que_exista becario games)
  usermod -s /bin/bash "$u"
  echo "shell:$u: '$u' tiene shell de login y no debería" >> "$REGISTRO"
}

install -m 600 /dev/null "$REGISTRO"
for f in $(printf '%s\n' uid0 sinpass sudo shadow shell | shuf -n 3); do "fallo_$f"; done

clear
echo "Sabotaje terminado: hay 3 fallos escondidos en esta máquina."
echo "Pásale el teclado a tu compañero. Tiene 10 minutos."
