#!/usr/bin/env bash
# =============================================================================
#  Norte Redes · Corrector de la Práctica 1 (Ubuntu)
#
#  Qué hace: revisa si has creado bien los grupos, usuarios y contraseñas de la
#  práctica y te dice qué está bien (✔), qué falta (✘) y una pista.
#  IMPORTANTE: solo LEE ficheros del sistema. No cambia nada.
#
#  Cómo se usa:   sudo bash comprobar.sh
#  (sudo hace falta porque el fichero /etc/shadow solo lo puede leer root)
#
#  Temario relacionado: UF2 · Tema 01 · apartados 1.1 (ficheros passwd, shadow y
#  group), 1.2 (useradd, passwd, usermod…) y 1.4 (perfiles: /etc/skel).
# =============================================================================

# "set -u" hace que el script se detenga si usamos una variable que no existe.
# Así un error de escritura no pasa desapercibido.
set -u

# -----------------------------------------------------------------------------
# 1. DÓNDE ESTÁN LOS FICHEROS QUE VAMOS A LEER
# -----------------------------------------------------------------------------
# NR_ROOT solo se usa en las pruebas del profesor (un /etc falso). En vuestra
# máquina está vacío, así que las rutas son las normales: /etc/passwd, etc.
ROOT="${NR_ROOT:-}"
PASSWD="$ROOT/etc/passwd"     # lista de usuarios (la lee cualquiera)
GROUP="$ROOT/etc/group"       # lista de grupos y sus miembros
SHADOW="$ROOT/etc/shadow"     # hashes de contraseñas y caducidad (solo root)
FECHA_BECARIO="2026-12-31"    # fecha en la que debe caducar la cuenta del becario

# -----------------------------------------------------------------------------
# 2. COLORES PARA LA PANTALLA
# -----------------------------------------------------------------------------
# "[ -t 1 ]" pregunta: ¿la salida va a una pantalla (terminal)?
# Si es así, usamos códigos de color (verde, rojo, amarillo, gris, negrita).
# Si la salida va a un fichero, no ponemos colores para no ensuciarlo.
if [ -t 1 ]; then
  V=$'\e[32m'; R=$'\e[31m'; A=$'\e[33m'; G=$'\e[90m'; N=$'\e[1m'; X=$'\e[0m'
else
  V=""; R=""; A=""; G=""; N=""; X=""
fi

# -----------------------------------------------------------------------------
# 3. ¿PODEMOS LEER /etc/shadow?
# -----------------------------------------------------------------------------
# "[ ! -r fichero ]" significa "el fichero NO se puede leer".
# Pasa si se ejecuta sin sudo. En ese caso avisamos y salimos.
if [ ! -r "$SHADOW" ]; then
  echo "${R}No puedo leer $SHADOW.${X} Ejecútalo con sudo:  ${N}sudo bash comprobar.sh${X}"
  exit 1
fi

# -----------------------------------------------------------------------------
# 4. CONTADORES Y FUNCIONES DE AYUDA
# -----------------------------------------------------------------------------
# Llevamos la cuenta por separado del nivel básico (PB de TB) y de los extra
# (PE de TE). NIVEL indica en qué parte estamos ahora.
NIVEL=basico; PB=0; TB=0; PE=0; TE=0

# marca: escribe una estrella delante de las comprobaciones extra.
marca() { [ "$NIVEL" = extra ] && printf '★ ' ; }

# ok "texto": suma un acierto y escribe una línea con ✔ en verde.
ok()   { if [ "$NIVEL" = extra ]; then PE=$((PE+1)); TE=$((TE+1)); else PB=$((PB+1)); TB=$((TB+1)); fi; echo "  ${V}✔${X} $(marca)$1"; }

# ko "texto" "pista": suma un fallo, escribe ✘ en rojo y, si la hay, la pista.
ko()   { if [ "$NIVEL" = extra ]; then TE=$((TE+1)); else TB=$((TB+1)); fi; echo "  ${R}✘${X} $(marca)$1"; [ -n "${2:-}" ] && echo "      ${A}Pista:${X} $2"; }

# info "texto": una nota en gris que no suma ni resta.
info() { echo "  ${G}·${X} $1"; }

# tramo "título": deja una línea en blanco y escribe el título en negrita.
tramo(){ echo; echo "${N}$1${X}"; }

# campo FICHERO CLAVE N: busca la línea que empieza por CLAVE y devuelve su
# campo número N. Los ficheros de /etc separan los campos con dos puntos (:).
#   awk -F:        → usa los dos puntos como separador de columnas
#   $1==k          → quédate con la línea cuyo primer campo sea la clave
#   {print $n}     → escribe el campo número n
# Ejemplo: campo /etc/passwd ana 7  → la shell de ana (/bin/bash)
campo() { awk -F: -v k="$2" -v n="$3" '$1==k {print $n; exit}' "$1"; }

# existe_usuario U: verdadero si U aparece en /etc/passwd.
existe_usuario() { [ -n "$(campo "$PASSWD" "$1" 1)" ]; }

# gid_de G: número (GID) del grupo G.     miembros G: lista de miembros de G.
gid_de()  { campo "$GROUP" "$1" 3; }
miembros(){ campo "$GROUP" "$1" 4; }

# en_grupo U G: verdadero si U está en la lista de miembros de G.
# Ponemos comas alrededor (",ana,luis,") para no confundir "ana" con "mariana".
en_grupo(){ case ",$(miembros "$2")," in *",$1,"*) return 0;; *) return 1;; esac; }

# Cabecera: nombre del equipo y fecha, útil para la captura de la entrega.
echo "${N}Norte Redes · Práctica 1${X}  ${G}equipo: $(hostname 2>/dev/null) · $(date '+%d/%m/%Y %H:%M')${X}"

# -----------------------------------------------------------------------------
# 5. TRAMO A · GRUPOS Y USUARIOS                       (temario 1.1.5, 1.2.1, 1.2.5)
# -----------------------------------------------------------------------------
tramo "A · Grupos y usuarios"

# Cada "par" es grupo:GID. ${par%%:*} se queda con lo de antes de los dos puntos
# (el nombre) y ${par##*:} con lo de después (el número).
for par in sistemas:2001 desarrollo:2002 comercial:2003; do
  g=${par%%:*}; id=${par##*:}; real=$(gid_de "$g")
  if [ "$real" = "$id" ]; then ok "Grupo $g con GID $id"
  elif [ -n "$real" ]; then ko "Grupo $g existe pero su GID es $real (debería ser $id)" "Revisa el número (GID) con el que lo creaste: groupmod permite cambiarlo"
  else ko "Falta el grupo $g" "Créalo con groupadd e indica su número (GID)"; fi
done

# El kit de bienvenida tiene que estar en /etc/skel (temario 1.4).
# "[ -f fichero ]" significa "existe y es un fichero normal".
if [ -f "$ROOT/etc/skel/LEEME.txt" ]; then ok "Kit de bienvenida /etc/skel/LEEME.txt"
else ko "Falta /etc/skel/LEEME.txt" "Crea el fichero dentro de /etc/skel. Ojo: la redirección > no funciona con sudo"; fi

# Para cada usuario: ¿existe?, ¿su grupo principal es el correcto?, ¿usa bash?,
# ¿tiene el LEEME.txt en su carpeta personal?
for par in ana:sistemas luis:desarrollo marta:comercial; do
  u=${par%%:*}; g=${par##*:}
  if ! existe_usuario "$u"; then
    ko "Falta el usuario $u" "Créalo con useradd: necesita home, shell y grupo principal"; continue
  fi
  # Campos de /etc/passwd: 4 = GID principal, 6 = carpeta personal, 7 = shell
  gid=$(campo "$PASSWD" "$u" 4); home=$(campo "$PASSWD" "$u" 6); shell=$(campo "$PASSWD" "$u" 7)
  if [ "$gid" = "$(gid_de "$g")" ]; then ok "$u tiene como grupo principal $g"
  else ko "El grupo principal de $u no es $g" "usermod permite cambiar el grupo principal"; fi
  if [ "$shell" = "/bin/bash" ]; then ok "$u usa /bin/bash"
  else ko "$u tiene la shell $shell" "usermod permite cambiar la shell"; fi
  # "[ -d carpeta ]" significa "existe y es una carpeta".
  if [ -f "$ROOT$home/LEEME.txt" ]; then ok "$u tiene LEEME.txt en su home"
  elif [ -d "$ROOT$home" ]; then ko "$u no tiene LEEME.txt en $home" "Creaste el usuario antes que el fichero de /etc/skel"
  else ko "$u no tiene home ($home)" "Faltó la opción de useradd que crea el home: bórralo y créalo otra vez"; fi
done

# -----------------------------------------------------------------------------
# 6. TRAMO B · CONTRASEÑAS Y PERMISOS                  (temario 1.1.4, 1.2.2, 1.2.6)
# -----------------------------------------------------------------------------
tramo "B · Contraseñas y permisos"

# El campo 2 de /etc/shadow es el hash de la contraseña:
#   vacío       → la cuenta entra SIN contraseña (peligroso)
#   "!" o "*"   → todavía no se ha puesto contraseña
#   "!" + hash  → la cuenta está bloqueada (usermod -L)
#   otro        → tiene contraseña
for u in ana luis marta; do
  existe_usuario "$u" || continue
  h=$(campo "$SHADOW" "$u" 2)
  case "$h" in
    "")    ko "$u NO tiene contraseña (entra sin ella)" "Ponle una contraseña" ;;
    "!"|"*"|"!*") ko "$u aún no tiene contraseña" "Ponle una contraseña" ;;
    "!"*)  ko "$u está bloqueada" "usermod tiene una opción para desbloquear" ;;
    *)     ok "$u tiene contraseña" ;;
  esac
done

# En Ubuntu, los administradores son los miembros del grupo "sudo".
if existe_usuario ana; then
  if en_grupo ana sudo; then ok "ana es administradora (grupo sudo)"
  else ko "ana no está en el grupo sudo" "Tiene que estar en el grupo de administradores sin perder sus otros grupos"; fi
fi

# -----------------------------------------------------------------------------
# 7. EXTRA ★ (solo para quien termine antes)                     (temario 1.1.4)
# -----------------------------------------------------------------------------
tramo "★ Extra · para quien termine antes"
NIVEL=extra

# Campo 3 de /etc/shadow: día del último cambio de contraseña, contado desde el
# 1/1/1970. Si vale 0, el sistema obliga a cambiarla al entrar (chage -d 0).
if existe_usuario luis; then
  d=$(campo "$SHADOW" luis 3)
  if [ "$d" = "0" ]; then ok "luis deberá cambiar su contraseña al entrar"
  else info "luis ya ha cambiado su contraseña o no se forzó el cambio (compruébalo: sudo chage -l luis)"; fi
fi

# Campos 4, 5 y 6 de /etc/shadow: días mínimos, máximos y de aviso.
if existe_usuario marta; then
  mn=$(campo "$SHADOW" marta 4); mx=$(campo "$SHADOW" marta 5); wn=$(campo "$SHADOW" marta 6)
  if [ "$mx" = "90" ] && [ "$mn" = "1" ] && [ "$wn" = "7" ]; then ok "marta: caduca a los 90 días, mínimo 1, aviso 7"
  else ko "marta: mínimo=$mn máximo=$mx aviso=$wn (se pide 1 / 90 / 7)" "Mira las opciones de chage (man chage)"; fi
fi

# El becario: shell que no deja entrar (nologin o false) y cuenta con caducidad.
# Campo 8 de /etc/shadow: día (desde 1970) en que caduca la cuenta. Calculamos
# qué número corresponde al 31/12/2026 dividiendo sus segundos entre 86400
# (los segundos que tiene un día).
if existe_usuario becario; then
  ok "Existe el usuario becario"
  s=$(campo "$PASSWD" becario 7)
  case "$s" in */nologin|*/false) ok "becario no puede usar la terminal ($s)";;
    *) ko "becario tiene la shell $s" "Su shell debe impedir el acceso a la terminal";; esac
  esperado=$(( $(date -u -d "$FECHA_BECARIO" +%s) / 86400 ))
  e=$(campo "$SHADOW" becario 8)
  if [ "$e" = "$esperado" ]; then ok "La cuenta caduca el 31/12/2026"
  elif [ -z "$e" ]; then ko "La cuenta de becario no caduca" "Revisa la fecha de caducidad de la cuenta"
  else ko "La cuenta de becario caduca otro día (día $e desde 1970, se esperaba $esperado)" "Revisa la fecha de caducidad de la cuenta"; fi
else
  ko "Falta el usuario becario" "Créalo con useradd: sin terminal y con fecha de caducidad"
fi

# -----------------------------------------------------------------------------
# 8. SEGURIDAD DEL SISTEMA                                 (temario 1.1.3 a 1.1.5)
# -----------------------------------------------------------------------------
# Estas comprobaciones salen bien en un sistema normal. Fallan si alguien ha
# metido fallos de seguridad (por ejemplo, con el reto en parejas).
tramo "Seguridad del sistema"
NIVEL=basico

# ¿Hay alguna cuenta, aparte de root, con UID 0? Sería root con otro nombre.
uid0=$(awk -F: '$3==0 && $1!="root" {printf "%s ", $1}' "$PASSWD")
if [ -z "$uid0" ]; then ok "Solo root tiene UID 0"
else ko "Hay cuentas con UID 0 además de root" "Una cuenta con UID 0 es root con otro nombre"; fi

# ¿Hay alguna cuenta con el campo de contraseña vacío?
vacias=$(awk -F: '$2=="" {printf "%s ", $1}' "$SHADOW")
if [ -z "$vacias" ]; then ok "Ninguna cuenta entra sin contraseña"
else ko "Hay cuentas que entran sin contraseña"; fi

# Permisos de /etc/shadow en octal (por ejemplo 640). "stat -c %a" los muestra.
# El último dígito son los permisos de "otros": debe ser 0 (sin acceso).
modo="${NR_SHADOW_MODE:-$(stat -c %a "$SHADOW" 2>/dev/null)}"
case "$modo" in *0) ok "/etc/shadow no es legible por otros usuarios ($modo)";;
  *) ko "/etc/shadow tiene permisos $modo: cualquiera puede leer los hashes" "Revisa sus permisos con ls -l";; esac

# ¿Hay en el grupo sudo alguien de la plantilla que no debería ser administrador?
for u in luis marta becario; do
  if en_grupo "$u" sudo; then ko "Hay en el grupo sudo alguien que no debería"; break; fi
done

# -----------------------------------------------------------------------------
# 9. RESULTADO FINAL
# -----------------------------------------------------------------------------
echo
# Barra de progreso de 30 casillas: '#' para lo hecho y '.' para lo que falta.
llenos=$(( PB * 30 / TB ))
barra="$(printf '%*s' "$llenos" '' | tr ' ' '#')$(printf '%*s' $((30-llenos)) '' | tr ' ' '.')"
echo "${N}Básico: $PB / $TB  [$barra] $(( PB * 100 / TB )) %${X}"
echo "${N}Extra ★: $PE / $TE${X}"
# NR_SALIDA solo lo usan las pruebas del profesor: guarda los números en un fichero.
[ -n "${NR_SALIDA:-}" ] && echo "$PB $TB $PE $TE" > "$NR_SALIDA"
if [ "$PB" -eq "$TB" ]; then
  echo "${V}${N}Práctica básica completa. Haz una captura de esta pantalla para la entrega.${X}"
  if [ "$PE" -lt "$TE" ]; then echo "¿Te sobra tiempo? Ve a por los extra ★."; fi
else
  echo "Arregla lo que está en rojo y vuelve a ejecutar:  ${N}sudo bash comprobar.sh${X}"
fi
exit 0
