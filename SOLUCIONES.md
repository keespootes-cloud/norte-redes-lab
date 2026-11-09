# Soluciones · Norte Redes Lab

Publicadas **después de la clase** (9 de noviembre de 2026) para que podáis repasar en casa.

> **Antes de mirar:** intenta primero hacerlo por tu cuenta con la [guía](GUIA_ALUMNO.md) y el corrector. Las soluciones se entienden mucho mejor cuando ya te has peleado con el problema.

## Índice

1. [Cómo comprobar tu práctica en casa](#1--cómo-comprobar-tu-práctica-en-casa)
2. [Práctica 1 · Ubuntu](#2--práctica-1--ubuntu)
3. [Reto en parejas: los fallos y cómo encontrarlos](#3--reto-en-parejas-los-fallos-y-cómo-encontrarlos)
4. [Práctica 2 · Windows](#4--práctica-2--windows)
5. [Soluciones del quiz](#5--soluciones-del-quiz)

---

## 1 · Cómo comprobar tu práctica en casa

1. Arranca tu **máquina virtual de Ubuntu** (la misma de clase, si la tienes).
2. Si no tienes el laboratorio descargado, en una terminal:
   ```bash
   cd ~
   wget -O lab.tar.gz https://github.com/keespootes-cloud/norte-redes-lab/archive/refs/heads/main.tar.gz
   tar xzf lab.tar.gz
   cd norte-redes-lab-main/linux
   ```
3. Ejecuta el corrector:
   ```bash
   sudo bash comprobar.sh
   ```
4. Compara lo que te sale en rojo con las soluciones de abajo.
5. Si quieres **empezar de cero**, restaura la instantánea `antes-UF2` en VirtualBox (Máquina → Herramientas → Instantáneas → Restaurar) y repite la práctica entera.

En Windows es igual: descarga el ZIP, abre PowerShell **como administrador** en la carpeta `windows` y ejecuta:
```powershell
powershell -ExecutionPolicy Bypass -File .\Comprobar-NorteRedes.ps1
```

**Resultado esperado:** `Básico: 20 / 20` en Ubuntu y «Práctica básica completa» en los dos sistemas. Si has hecho los extras: `Extra ★: 5 / 5` en Ubuntu.

> En Linux, **si una orden no dice nada, ha ido bien**.

---

## 2 · Práctica 1 · Ubuntu

### Grupos

```bash
sudo groupadd -g 2001 sistemas
sudo groupadd -g 2002 desarrollo
sudo groupadd -g 2003 comercial
getent group sistemas desarrollo comercial
```
- `groupadd -g 2001` crea el grupo con ese número (GID).
- ✅ Debe salir `sistemas:x:2001:`, `desarrollo:x:2002:` y `comercial:x:2003:`. La última columna está vacía porque todavía nadie tiene esos grupos como **secundarios**.

### Kit de bienvenida

```bash
echo "Bienvenido a Norte Redes" | sudo tee /etc/skel/LEEME.txt
```
- Todo lo que hay en `/etc/skel` se copia al home de cada usuario **nuevo**. Por eso va **antes** de crear los usuarios.
- Se usa `sudo tee` y no `sudo echo … > fichero` porque la redirección `>` la hace tu shell, que no es root: daría `Permission denied`.

### Usuarios

```bash
sudo useradd -m -s /bin/bash -c "Ana Ruiz"   -g sistemas   ana
sudo useradd -m -s /bin/bash -c "Luis Gomez" -g desarrollo luis
sudo useradd -m -s /bin/bash -c "Marta Sanz" -g comercial  marta
sudo ls -la /home/ana
```
| Opción | Qué hace |
|---|---|
| `-m` | crea el home copiando `/etc/skel` (en Ubuntu, sin `-m` no se crea) |
| `-s /bin/bash` | le da una terminal para trabajar |
| `-c "…"` | nombre completo (campo 5 de `/etc/passwd`) |
| `-g grupo` | grupo **principal** |

✅ En `/home/ana` tiene que aparecer `LEEME.txt`, con dueño `ana` y grupo `sistemas`.

### Contraseñas

```bash
sudo passwd ana
sudo passwd luis
sudo passwd marta
```
Si sale `BAD PASSWORD: …` es un aviso de que la contraseña es débil; como root puedes seguir, pero lo correcto es usar una más larga.

### Ana, administradora

```bash
sudo usermod -aG sudo ana
id ana
```
- `-G sudo` = grupos secundarios; **`-a`** = **añadir** sin quitar los que ya tenía. Sin `-a`, `-G` **sustituye** todos sus grupos secundarios.
- ✅ `id ana` → `uid=1001(ana) gid=2001(sistemas) groups=2001(sistemas),27(sudo)` (el número de uid puede variar).

### Extras ★

```bash
# ★ 6 · luis debe cambiar la contraseña al entrar
sudo chage -d 0 luis
su - luis          # escríbelo solo: contraseña actual, otra vez la actual y una NUEVA distinta dos veces; sal con exit

# ★ 7 · caducidad de la contraseña de marta
sudo chage -M 90 -m 1 -W 7 marta
sudo chage -l marta

# ★ 8 · el becario
sudo useradd -m -s /usr/sbin/nologin -e 2026-12-31 -c "Becario" -g desarrollo becario
sudo passwd becario
su - becario       # ✅ "This account is currently not available."
```
- `chage -d 0`: pone la fecha del último cambio en el «día 0» (1/1/1970), así que el sistema obliga a cambiarla.
- `-M 90` máximo 90 días · `-m 1` mínimo 1 día entre cambios · `-W 7` aviso 7 días antes.
- `-s /usr/sbin/nologin`: sin terminal (puede usar otros servicios). `-e 2026-12-31`: la **cuenta** caduca ese día.

### Bloquear y desbloquear (vacaciones de marta)

```bash
sudo usermod -L marta          # bloquea: pone un ! delante del hash en /etc/shadow
sudo grep marta /etc/shadow    # se ve marta:!$y$…
sudo usermod -U marta          # desbloquea
```

---

## 3 · Reto en parejas: los fallos y cómo encontrarlos

`sabotaje.sh` elige **3 fallos al azar de estos 5**:

| Fallo | Qué hace el sabotaje | Cómo se detecta | Por qué es grave | Cómo se arregla |
|---|---|---|---|---|
| **Cuenta con UID 0** | crea `soporte` con UID 0 | `awk -F: '$3==0 {print $1}' /etc/passwd` → sale `root` **y** `soporte` | Es root con otro nombre: una puerta trasera | `sudo userdel -f soporte` |
| **Cuenta sin contraseña** | crea `invitado` y le borra la contraseña | `sudo awk -F: '$2=="" {print $1}' /etc/shadow` → `invitado` | Cualquiera entra sin contraseña | `sudo userdel -r invitado` |
| **Alguien de más en sudo** | mete a `marta` (o luis o becario) en `sudo` | `getent group sudo` → aparece alguien que no es `alumno` ni `ana` | Se salta el mínimo privilegio | `sudo gpasswd -d marta sudo` |
| **shadow legible** | `chmod 644 /etc/shadow` | `ls -l /etc/shadow` → `-rw-r--r--` en vez de `-rw-r-----` | Cualquiera puede leer los hashes y atacarlos | `sudo chmod 640 /etc/shadow` |
| **Shell de más** | le da `/bin/bash` al becario (o a `games`) | `grep 'bash$' /etc/passwd` → aparece alguien que no debería | Una cuenta sin terminal ahora la tiene | `sudo usermod -s /usr/sbin/nologin becario` |

**Cómo leer `awk -F: '$3==0 {print $1}' /etc/passwd`:** `-F:` separa las columnas por los dos puntos; `$3==0` se queda con las líneas cuyo campo 3 (el UID) es 0; `{print $1}` muestra el campo 1 (el nombre).

**Cómo leer los permisos:** `-rw-r-----` = dueño `rw-` (6) · grupo `r--` (4) · otros `---` (0) → **640**. Cada trío es un número en binario: `rw-` = 110 = 6.

**Para practicar solo en casa:** ejecuta `sudo bash sabotaje.sh`, búscalos sin mirar, comprueba con `sudo bash sabotaje.sh --solucion` y deja la máquina bien con `sudo bash reparar.sh`.

---

## 4 · Práctica 2 · Windows

PowerShell **como administrador** (el prompt debe ser `PS C:\Windows\system32>`).

```powershell
# Grupos (una línea: la lista pasa por ForEach-Object y $_ es cada nombre)
"Sistemas","Desarrollo","Comercial" | ForEach-Object { New-LocalGroup -Name $_ }

# Usuarios (la contraseña se guarda en $pw sin que se vea)
$pw = Read-Host -AsSecureString "Contraseña inicial"
New-LocalUser -Name ana   -FullName "Ana Ruiz"   -Password $pw
New-LocalUser -Name luis  -FullName "Luis Gomez" -Password $pw
New-LocalUser -Name marta -FullName "Marta Sanz" -Password $pw

# Cada uno a su grupo
Add-LocalGroupMember -Group Sistemas   -Member ana
Add-LocalGroupMember -Group Desarrollo -Member luis
Add-LocalGroupMember -Group Comercial  -Member marta

# Grupo Usuarios (S-1-5-32-545): sin él no pueden iniciar sesión
Add-LocalGroupMember -SID S-1-5-32-545 -Member ana,luis,marta

# ana administradora (Administradores = S-1-5-32-544, igual en cualquier idioma)
Add-LocalGroupMember -SID S-1-5-32-544 -Member ana

# Directiva: longitud 12, caducidad 90 días, bloqueo de 15 min tras 5 fallos
net accounts /minpwlen:12 /maxpwage:90 /lockoutthreshold:5 /lockoutwindow:15 /lockoutduration:15
net accounts
```

**Extras ★**
```powershell
Set-LocalUser -Name ana -PasswordNeverExpires $true      # la de ana no caduca
net user luis /logonpasswordchg:yes                      # luis la cambia al iniciar sesión
net user marta /passwordchg:no                           # marta no puede cambiarla
New-LocalUser -Name becario -FullName "Becario" -Password $pw -AccountExpires (Get-Date "2026-12-31")
Disable-LocalUser -Name becario                          # deshabilitada
```

**UAC en una línea:** compara `whoami /groups` en una consola normal (Administradores = «Grupo usado solo para denegar», nivel **medio**) y en otra «como administrador» (grupo habilitado, nivel **alto**). Son los dos tokens de UAC.

---

## 5 · Soluciones del quiz

| # | Pregunta | Respuesta | Por qué |
|---|---|---|---|
| 1 | ¿Dónde está el hash de las contraseñas en Linux? | `/etc/shadow` | Solo lo lee root; `/etc/passwd` lo lee cualquiera |
| 2 | ¿Qué UID tiene root? | 0 | Lo que da el poder es el número, no el nombre |
| 3 | ¿Qué pierde ana con `usermod -G sudo ana` sin `-a`? | Todos sus otros grupos secundarios | `-G` sustituye; `-a` añade |
| 4 | ¿Qué significa `!` delante del hash? | Cuenta bloqueada | Ninguna contraseña coincide con un hash que empieza por `!` |
| 5 | ¿Equivalente de `/etc/skel` en Windows? | `C:\Users\Default` | Plantilla de los perfiles nuevos |
| 6 | ¿En qué número acaba el SID del Administrador integrado? | 500 | Invitado es 501; tus cuentas, de 1000 en adelante |
| 7 | ¿Por qué un administrador con UAC tiene dos tokens? | Para trabajar sin privilegios y elevarse solo al aceptar UAC | La misma idea que `sudo` |
| 8 | Perfil móvil frente a obligatorio | El obligatorio (`NTUSER.MAN`) descarta los cambios al cerrar sesión | El móvil los guarda (`NTUSER.DAT`) |
| 9 | ¿Por qué `P@ssw0rd` es mala contraseña? | Está en todos los diccionarios de ataque | Lo que importa es la longitud |
| 10 | Suspensión o hibernación: ¿cuál consume cero? | Hibernación | Guarda la sesión en disco y apaga |

---

La **presentación completa**, con las diapositivas de solución, está en [`presentacion/`](presentacion/). Para seguir practicando: **OverTheWire Bandit** (overthewire.org/wargames/bandit).

*Norte Redes S.L. y sus empleados son ficticios. Usa estos scripts solo en tus máquinas virtuales de prácticas.*
