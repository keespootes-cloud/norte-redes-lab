#!/usr/bin/env bash
# =============================================================================
#  Norte Redes · Deshace los fallos que metió sabotaje.sh en esta máquina.
#  Uso:  sudo bash reparar.sh
#  (Restaurar la instantánea "antes-UF2" también vale y es lo más seguro.)
# =============================================================================
set -u
REGISTRO=/root/.norte-redes-sabotaje

if [ "$(id -u)" -ne 0 ]; then echo "Ejecútalo con sudo:  sudo bash reparar.sh"; exit 1; fi
if [ ! -f "$REGISTRO" ]; then echo "No hay ningún sabotaje registrado. Nada que reparar."; exit 0; fi

while IFS= read -r linea; do
  tipo=${linea%%:*}; resto=${linea#*:}; usuario=${resto%%:*}
  case "$tipo" in
    uid0)    userdel -f soporte 2>/dev/null && echo "Borrada la cuenta soporte (UID 0)";;
    sinpass) userdel -r invitado 2>/dev/null; echo "Borrada la cuenta invitado";;
    sudo)    gpasswd -d "$usuario" sudo >/dev/null && echo "Quitado $usuario del grupo sudo";;
    shadow)  chown root:shadow /etc/shadow; chmod 640 /etc/shadow; echo "Permisos de /etc/shadow: 640";;
    shell)   usermod -s /usr/sbin/nologin "$usuario" && echo "Shell de $usuario: /usr/sbin/nologin";;
  esac
done < "$REGISTRO"

rm -f "$REGISTRO"
echo "Máquina reparada. Comprueba con:  sudo bash comprobar.sh"
