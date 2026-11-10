#!/usr/bin/env bash
# =============================================================================
#  Norte Redes · Deshace los fallos que metió sabotaje.sh en esta máquina.
#
#  Cómo se usa:  sudo bash reparar.sh
#  (Restaurar la instantánea "antes-UF2" también vale y es lo más seguro.)
#
#  Temario relacionado: UF2 · Tema 01 · apartados 1.2.3 (userdel) y 1.2.6 (usermod, grupos).
# =============================================================================

# Detener el script si se usa una variable que no existe.
set -u

# El mismo registro que escribió sabotaje.sh con los fallos que metió.
REGISTRO=/root/.norte-redes-sabotaje

# Hace falta ser root. Si no hay registro, no hay nada que reparar.
if [ "$(id -u)" -ne 0 ]; then echo "Ejecútalo con sudo:  sudo bash reparar.sh"; exit 1; fi
if [ ! -f "$REGISTRO" ]; then echo "No hay ningún sabotaje registrado. Nada que reparar."; exit 0; fi

# Leemos el registro línea a línea. Cada línea empieza por el tipo de fallo,
# por ejemplo "sudo:marta: …". Separamos:
#   tipo    = lo de antes del primer ":"            (sudo)
#   usuario = lo que hay entre el primer y el segundo ":"  (marta)
while IFS= read -r linea; do
  tipo=${linea%%:*}; resto=${linea#*:}; usuario=${resto%%:*}
  case "$tipo" in
    # Borra la cuenta con UID 0. "-f" (forzar) hace falta porque, al tener el
    # mismo UID que root, userdel creería que la cuenta está en uso.
    uid0)    userdel -f soporte 2>/dev/null && echo "Borrada la cuenta soporte (UID 0)";;
    # Borra la cuenta sin contraseña y su carpeta personal (-r).
    sinpass) userdel -r invitado 2>/dev/null; echo "Borrada la cuenta invitado";;
    # Saca al usuario del grupo sudo sin tocar sus otros grupos.
    sudo)    gpasswd -d "$usuario" sudo >/dev/null && echo "Quitado $usuario del grupo sudo";;
    # Devuelve a /etc/shadow su dueño (root), su grupo (shadow) y sus permisos (640).
    shadow)  chown root:shadow /etc/shadow; chmod 640 /etc/shadow; echo "Permisos de /etc/shadow: 640";;
    # Vuelve a quitarle la terminal a la cuenta.
    shell)   usermod -s /usr/sbin/nologin "$usuario" && echo "Shell de $usuario: /usr/sbin/nologin";;
  esac
done < "$REGISTRO"

# Borramos el registro: la máquina vuelve a estar como antes del sabotaje.
rm -f "$REGISTRO"
echo "Máquina reparada. Comprueba con:  sudo bash comprobar.sh"
