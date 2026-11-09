#!/usr/bin/env bash
# =============================================================================
#  Norte Redes · Corrector de la Práctica 1 (Ubuntu)
#  Solo LEE ficheros del sistema: no cambia nada.
#  Uso:   sudo bash comprobar.sh
# =============================================================================
set -u

ROOT="${NR_ROOT:-}"                 # solo para pruebas: carpeta con un /etc falso
PASSWD="$ROOT/etc/passwd"
GROUP="$ROOT/etc/group"
SHADOW="$ROOT/etc/shadow"
FECHA_BECARIO="2026-12-31"

if [ -t 1 ]; then
  V=$'\e[32m'; R=$'\e[31m'; A=$'\e[33m'; G=$'\e[90m'; N=$'\e[1m'; X=$'\e[0m'
else
  V=""; R=""; A=""; G=""; N=""; X=""
fi

if [ ! -r "$SHADOW" ]; then
  echo "${R}No puedo leer $SHADOW.${X} Ejecútalo con sudo:  ${N}sudo bash comprobar.sh${X}"
  exit 1
fi

# Nivel básico (obligatorio) y extra (★, para quien termine antes)
NIVEL=basico; PB=0; TB=0; PE=0; TE=0
marca() { [ "$NIVEL" = extra ] && printf '★ ' ; }
ok()   { if [ "$NIVEL" = extra ]; then PE=$((PE+1)); TE=$((TE+1)); else PB=$((PB+1)); TB=$((TB+1)); fi; echo "  ${V}✔${X} $(marca)$1"; }
ko()   { if [ "$NIVEL" = extra ]; then TE=$((TE+1)); else TB=$((TB+1)); fi; echo "  ${R}✘${X} $(marca)$1"; [ -n "${2:-}" ] && echo "      ${A}Pista:${X} $2"; }
info() { echo "  ${G}·${X} $1"; }
tramo(){ echo; echo "${N}$1${X}"; }

campo() { awk -F: -v k="$2" -v n="$3" '$1==k {print $n; exit}' "$1"; }   # fichero clave nºcampo
existe_usuario() { [ -n "$(campo "$PASSWD" "$1" 1)" ]; }
gid_de()  { campo "$GROUP" "$1" 3; }
miembros(){ campo "$GROUP" "$1" 4; }
en_grupo(){ case ",$(miembros "$2")," in *",$1,"*) return 0;; *) return 1;; esac; }

echo "${N}Norte Redes · Práctica 1${X}  ${G}equipo: $(hostname 2>/dev/null) · $(date '+%d/%m/%Y %H:%M')${X}"

# --- Tramo A ------------------------------------------------------------------
tramo "A · Grupos y usuarios"
for par in sistemas:2001 desarrollo:2002 comercial:2003; do
  g=${par%%:*}; id=${par##*:}; real=$(gid_de "$g")
  if [ "$real" = "$id" ]; then ok "Grupo $g con GID $id"
  elif [ -n "$real" ]; then ko "Grupo $g existe pero su GID es $real (debería ser $id)" "Revisa el número (GID) con el que lo creaste: groupmod permite cambiarlo"
  else ko "Falta el grupo $g" "Créalo con groupadd e indica su número (GID)"; fi
done

if [ -f "$ROOT/etc/skel/LEEME.txt" ]; then ok "Kit de bienvenida /etc/skel/LEEME.txt"
else ko "Falta /etc/skel/LEEME.txt" "Crea el fichero dentro de /etc/skel. Ojo: la redirección > no funciona con sudo"; fi

for par in ana:sistemas luis:desarrollo marta:comercial; do
  u=${par%%:*}; g=${par##*:}
  if ! existe_usuario "$u"; then
    ko "Falta el usuario $u" "Créalo con useradd: necesita home, shell y grupo principal"; continue
  fi
  gid=$(campo "$PASSWD" "$u" 4); home=$(campo "$PASSWD" "$u" 6); shell=$(campo "$PASSWD" "$u" 7)
  if [ "$gid" = "$(gid_de "$g")" ]; then ok "$u tiene como grupo principal $g"
  else ko "El grupo principal de $u no es $g" "usermod permite cambiar el grupo principal"; fi
  if [ "$shell" = "/bin/bash" ]; then ok "$u usa /bin/bash"
  else ko "$u tiene la shell $shell" "usermod permite cambiar la shell"; fi
  if [ -f "$ROOT$home/LEEME.txt" ]; then ok "$u tiene LEEME.txt en su home"
  elif [ -d "$ROOT$home" ]; then ko "$u no tiene LEEME.txt en $home" "Creaste el usuario antes que el fichero de /etc/skel"
  else ko "$u no tiene home ($home)" "Faltó la opción de useradd que crea el home: bórralo y créalo otra vez"; fi
done

# --- Tramo B ------------------------------------------------------------------
tramo "B · Contraseñas y permisos"
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

if existe_usuario ana; then
  if en_grupo ana sudo; then ok "ana es administradora (grupo sudo)"
  else ko "ana no está en el grupo sudo" "Tiene que estar en el grupo de administradores sin perder sus otros grupos"; fi
fi

# --- Extra ★ ------------------------------------------------------------------
tramo "★ Extra · para quien termine antes"
NIVEL=extra
if existe_usuario luis; then
  d=$(campo "$SHADOW" luis 3)
  if [ "$d" = "0" ]; then ok "luis deberá cambiar su contraseña al entrar"
  else info "luis ya ha cambiado su contraseña o no se forzó el cambio (compruébalo: sudo chage -l luis)"; fi
fi

if existe_usuario marta; then
  mn=$(campo "$SHADOW" marta 4); mx=$(campo "$SHADOW" marta 5); wn=$(campo "$SHADOW" marta 6)
  if [ "$mx" = "90" ] && [ "$mn" = "1" ] && [ "$wn" = "7" ]; then ok "marta: caduca a los 90 días, mínimo 1, aviso 7"
  else ko "marta: mínimo=$mn máximo=$mx aviso=$wn (se pide 1 / 90 / 7)" "Mira las opciones de chage (man chage)"; fi
fi

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

# --- Seguridad ----------------------------------------------------------------
tramo "Seguridad del sistema"
NIVEL=basico
uid0=$(awk -F: '$3==0 && $1!="root" {printf "%s ", $1}' "$PASSWD")
if [ -z "$uid0" ]; then ok "Solo root tiene UID 0"
else ko "Hay cuentas con UID 0 además de root" "Una cuenta con UID 0 es root con otro nombre"; fi

vacias=$(awk -F: '$2=="" {printf "%s ", $1}' "$SHADOW")
if [ -z "$vacias" ]; then ok "Ninguna cuenta entra sin contraseña"
else ko "Hay cuentas que entran sin contraseña"; fi

modo="${NR_SHADOW_MODE:-$(stat -c %a "$SHADOW" 2>/dev/null)}"
case "$modo" in *0) ok "/etc/shadow no es legible por otros usuarios ($modo)";;
  *) ko "/etc/shadow tiene permisos $modo: cualquiera puede leer los hashes" "Revisa sus permisos con ls -l";; esac

admins=$(miembros sudo)
for u in luis marta becario; do
  if en_grupo "$u" sudo; then ko "Hay en el grupo sudo alguien que no debería"; break; fi
done

# --- Resultado ----------------------------------------------------------------
echo
llenos=$(( PB * 30 / TB ))
barra="$(printf '%*s' "$llenos" '' | tr ' ' '#')$(printf '%*s' $((30-llenos)) '' | tr ' ' '.')"
echo "${N}Básico: $PB / $TB  [$barra] $(( PB * 100 / TB )) %${X}"
echo "${N}Extra ★: $PE / $TE${X}"
[ -n "${NR_SALIDA:-}" ] && echo "$PB $TB $PE $TE" > "$NR_SALIDA"   # solo para las pruebas automáticas
if [ "$PB" -eq "$TB" ]; then
  echo "${V}${N}Práctica básica completa. Haz una captura de esta pantalla para la entrega.${X}"
  if [ "$PE" -lt "$TE" ]; then echo "¿Te sobra tiempo? Ve a por los extra ★."; fi
else
  echo "Arregla lo que está en rojo y vuelve a ejecutar:  ${N}sudo bash comprobar.sh${X}"
fi
exit 0
