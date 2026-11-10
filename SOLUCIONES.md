# Soluciones · Norte Redes Lab

Publicadas **después de la clase** (9 de noviembre de 2026) para que podáis repasar en casa.

> **Antes de mirar:** intenta primero hacerlo por tu cuenta con la [guía](GUIA_ALUMNO.md) y el corrector. Las soluciones se entienden mucho mejor cuando ya te has peleado con el problema.

> **⚠️ Hasta dónde se llegó en clase:** se completaron la **Práctica 1 (Ubuntu)** y el **reto en parejas**. La **Práctica 2 (Windows) no se hizo por falta de tiempo**. Habla con tu profesor o profesora de la asignatura para saber cómo continuar con ella. Su solución está en el apartado 4 por si os la piden.

En cada apartado verás **📖 Tema:** con el apartado del PDF **«UF2 01.1 · Administración de software base»** que explica esa parte. Ábrelo y léelo junto a la solución.

## Índice

1. [Cómo comprobar tu práctica en casa](#1--cómo-comprobar-tu-práctica-en-casa)
2. [Práctica 1 · Ubuntu](#2--práctica-1--ubuntu)
3. [Reto en parejas: los fallos y cómo encontrarlos](#3--reto-en-parejas-los-fallos-y-cómo-encontrarlos)
4. [Práctica 2 · Windows (pendiente)](#4--práctica-2--windows-pendiente)
5. [Soluciones del quiz](#5--soluciones-del-quiz)
6. [Fuentes](#6--fuentes)

---

## Antes de empezar: cómo leer una orden

Casi todas las órdenes tienen tres partes. Por ejemplo, en `sudo groupadd -g 2001 sistemas`:

| Parte | En el ejemplo | Qué es |
|---|---|---|
| `sudo` | `sudo` | «Hazlo como administrador (root)». Pide **tu** contraseña. |
| Orden | `groupadd` | El programa que se ejecuta (aquí, «añadir grupo») |
| Opciones | `-g 2001` | Modifican lo que hace la orden. Empiezan por `-`. Algunas llevan un valor detrás (aquí, el número 2001). |
| Parámetro | `sistemas` | Sobre qué actúa la orden (aquí, el nombre del grupo) |

📖 **Tema:** 1.1.1 El intérprete de órdenes · 1.1.2 Órdenes básicas.

---

## 1 · Cómo comprobar tu práctica en casa

1. Arranca tu **máquina virtual de Ubuntu** (la misma de clase, si la tienes).
2. Si no tienes el laboratorio descargado, en una terminal (`Ctrl + Alt + T`), escribe una orden cada vez:
   ```bash
   cd ~
   wget -O lab.tar.gz https://github.com/keespootes-cloud/norte-redes-lab/archive/refs/heads/main.tar.gz
   tar xzf lab.tar.gz
   cd norte-redes-lab-main/linux
   ```
   - `cd ~` → vas a tu carpeta personal.
   - `wget -O lab.tar.gz …` → descarga el repositorio y lo guarda como `lab.tar.gz`.
   - `tar xzf lab.tar.gz` → lo descomprime (`x` extraer, `z` gzip, `f` este fichero).
   - `cd norte-redes-lab-main/linux` → entras en la carpeta de los scripts.
3. Ejecuta el corrector:
   ```bash
   sudo bash comprobar.sh
   ```
   `sudo` porque necesita leer `/etc/shadow`, que solo lee root; `bash comprobar.sh` ejecuta el script.
4. Compara lo que te sale en rojo con las soluciones de abajo.
5. Si quieres **empezar de cero**, restaura la instantánea `antes-UF2` en VirtualBox (Máquina → Herramientas → Instantáneas → Restaurar) y repite la práctica entera.

**Resultado esperado en Ubuntu:** `Básico: 20 / 20` y «Práctica básica completa». Si has hecho los extras: `Extra ★: 5 / 5`.

> En Linux, **si una orden no dice nada, ha ido bien**.

---

## 2 · Práctica 1 · Ubuntu

### Paso 1 · Grupos

📖 **Tema:** 1.2.5 Creación, eliminación y asignación de usuarios a grupos · 1.1.5 `/etc/group`.

```bash
sudo groupadd -g 2001 sistemas
sudo groupadd -g 2002 desarrollo
sudo groupadd -g 2003 comercial
getent group sistemas desarrollo comercial
```

Línea a línea:

- `sudo groupadd -g 2001 sistemas` → crea el grupo `sistemas`. `-g 2001` le pone ese número de grupo (**GID**). Igual con los otros dos.
- `getent group sistemas desarrollo comercial` → **comprueba**: busca esos grupos en `/etc/group` y los muestra.

✅ Debe salir:

```text
sistemas:x:2001:
desarrollo:x:2002:
comercial:x:2003:
```

Cada línea tiene 4 campos separados por `:` → nombre : `x` (la contraseña de grupo, que casi no se usa) : GID : miembros secundarios. La última columna está vacía porque todavía nadie tiene esos grupos como **secundarios**.

### Paso 2 · Kit de bienvenida

📖 **Tema:** 1.4 Perfiles de usuario locales (`/etc/skel`).

```bash
echo "Bienvenido a Norte Redes" | sudo tee /etc/skel/LEEME.txt
```

- `echo "Bienvenido a Norte Redes"` → escribe ese texto.
- `|` (tubería) → en vez de mostrarlo en pantalla, se lo pasa a la orden siguiente.
- `sudo tee /etc/skel/LEEME.txt` → `tee` guarda lo que le llega en el fichero `LEEME.txt`, dentro de `/etc/skel`. Lleva `sudo` porque esa carpeta es de root.

¿Por qué? Todo lo que hay en `/etc/skel` se copia al home de cada usuario **nuevo**. Por eso va **antes** de crear los usuarios: a los que ya existían no se les copia.

¿Por qué no `sudo echo "…" > /etc/skel/LEEME.txt`? Porque el `>` lo hace **tu** terminal, que no es root, aunque `echo` lleve `sudo`: daría `Permission denied`.

### Paso 3 · Usuarios

📖 **Tema:** 1.2.1 Añadir usuarios al sistema: `useradd` · 1.1.3 `/etc/passwd`.

```bash
sudo useradd -m -s /bin/bash -c "Ana Ruiz"   -g sistemas   ana
sudo useradd -m -s /bin/bash -c "Luis Gomez" -g desarrollo luis
sudo useradd -m -s /bin/bash -c "Marta Sanz" -g comercial  marta
sudo ls -la /home/ana
```

| Opción | Qué hace |
|---|---|
| `-m` | crea la carpeta personal (`/home/ana`) copiando `/etc/skel`. En Ubuntu, sin `-m` no se crea. |
| `-s /bin/bash` | le da la terminal bash para trabajar (campo 7 de `/etc/passwd`) |
| `-c "Ana Ruiz"` | nombre completo, como comentario (campo 5 de `/etc/passwd`) |
| `-g sistemas` | su grupo **principal** (campo 4 de `/etc/passwd`) |
| `ana` | el nombre de usuario (el login) |

- `sudo ls -la /home/ana` → **comprueba**: lista (`ls`) en formato largo (`-l`) y con ficheros ocultos (`-a`) el home de ana.

✅ Tiene que aparecer `LEEME.txt`, con dueño `ana` y grupo `sistemas`. Puedes ver la línea de ana con `getent passwd ana`:

```text
ana:x:1001:2001:Ana Ruiz:/home/ana:/bin/bash
```

Campos: usuario : `x` (la contraseña está en shadow) : UID : GID : comentario : home : shell. (Tu UID puede ser otro número.)

### Paso 4 · Contraseñas

📖 **Tema:** 1.2.2 Asignar una contraseña a un usuario: `passwd` · 1.1.4 `/etc/shadow`.

```bash
sudo passwd ana
sudo passwd luis
sudo passwd marta
```

- `sudo passwd ana` → pide la contraseña nueva de ana **dos veces**. Al escribirla no se ve nada: es normal.
- La contraseña no se guarda tal cual: se guarda su **hash** (una «huella» que no se puede descifrar) en `/etc/shadow`.

Si sale `BAD PASSWORD: …` es un aviso de que la contraseña es débil; como root puedes seguir, pero lo correcto es usar una más larga.

### Paso 5 · Ana, administradora

📖 **Tema:** 1.2.6 Modificación del grupo de un usuario: `usermod`.

```bash
sudo usermod -aG sudo ana
id ana
```

- `usermod` → modifica un usuario que ya existe.
- `-G sudo` → le pone el grupo **secundario** `sudo`. En Ubuntu, quien está en el grupo `sudo` es administrador.
- **`-a`** → **añade** el grupo a los que ya tenía. **Sin `-a`, `-G` sustituye** todos sus grupos secundarios por los que pongas: es un error muy común.
- `id ana` → **comprueba**: muestra el UID, el grupo principal y todos los grupos de ana.

✅ Debe salir algo así: `uid=1001(ana) gid=2001(sistemas) groups=2001(sistemas),27(sudo)`.

### Extras ★

📖 **Tema:** 1.1.4 `/etc/shadow` (campos de caducidad) · 1.2.4 Deshabilitar usuarios temporalmente.

```bash
# ★ 6 · luis debe cambiar la contraseña al entrar
sudo chage -d 0 luis
su - luis
```
- `chage` → cambia los datos de **caducidad** de la contraseña (los campos 3 a 8 de `/etc/shadow`).
- `-d 0` → pone la fecha del último cambio en el «día 0» (1 de enero de 1970). El sistema cree que la contraseña es antiquísima y obliga a cambiarla.
- `su - luis` → entras como luis para probarlo. Te pide la contraseña actual y después una **nueva distinta** dos veces. Para volver a tu usuario: `exit`.

```bash
# ★ 7 · caducidad de la contraseña de marta
sudo chage -M 90 -m 1 -W 7 marta
sudo chage -l marta
```
- `-M 90` → la contraseña caduca a los **90 días** (máximo).
- `-m 1` → hay que esperar **1 día** como mínimo entre cambios.
- `-W 7` → avisa (**W**arning) **7 días** antes de caducar.
- `chage -l marta` → **comprueba**: lista (`-l`) los datos de caducidad de marta.

```bash
# ★ 8 · el becario
sudo useradd -m -s /usr/sbin/nologin -e 2026-12-31 -c "Becario" -g desarrollo becario
sudo passwd becario
su - becario
```
- `-s /usr/sbin/nologin` → en vez de bash le damos `nologin`, una «shell» que no deja entrar en la terminal.
- `-e 2026-12-31` → la **cuenta** caduca (**e**xpire) ese día. Ojo: no es lo mismo que caduque la contraseña.
- El resto de opciones son como en el paso 3.
- `su - becario` → ✅ debe responder `This account is currently not available.` (la cuenta no puede usar la terminal).

### Bloquear y desbloquear (vacaciones de marta)

📖 **Tema:** 1.2.4 Deshabilitar usuarios temporalmente · 1.1.4 `/etc/shadow`.

```bash
sudo usermod -L marta
sudo grep marta /etc/shadow
sudo usermod -U marta
```
- `usermod -L marta` → bloquea (**L**ock) la cuenta: pone un `!` delante del hash en `/etc/shadow`. Ninguna contraseña coincide ya con ese hash.
- `grep marta /etc/shadow` → busca la línea de marta en shadow. Se ve `marta:!$y$…`.
- `usermod -U marta` → desbloquea (**U**nlock): quita el `!`.

---

## 3 · Reto en parejas: los fallos y cómo encontrarlos

📖 **Tema:** 1.1.3 `/etc/passwd` · 1.1.4 `/etc/shadow` · 1.1.5 `/etc/group` · 1.2.3 Eliminar usuarios · 1.2.7 Monitorización.

`sabotaje.sh` elige **3 fallos al azar de estos 5**:

| Fallo | Qué hace el sabotaje | Cómo se detecta | Por qué es grave | Cómo se arregla |
|---|---|---|---|---|
| **Cuenta con UID 0** | crea `soporte` con UID 0 | `awk -F: '$3==0 {print $1}' /etc/passwd` → sale `root` **y** `soporte` | Es root con otro nombre: una puerta trasera | `sudo userdel -f soporte` |
| **Cuenta sin contraseña** | crea `invitado` y le borra la contraseña | `sudo awk -F: '$2=="" {print $1}' /etc/shadow` → `invitado` | Cualquiera entra sin contraseña | `sudo userdel -r invitado` |
| **Alguien de más en sudo** | mete a `marta` (o luis o becario) en `sudo` | `getent group sudo` → aparece alguien que no es tu usuario ni `ana` | Se salta el mínimo privilegio | `sudo gpasswd -d marta sudo` |
| **shadow legible** | `chmod 644 /etc/shadow` | `ls -l /etc/shadow` → `-rw-r--r--` en vez de `-rw-r-----` | Cualquiera puede leer los hashes y atacarlos | `sudo chmod 640 /etc/shadow` |
| **Shell de más** | le da `/bin/bash` al becario (o a `games`) | `grep 'bash$' /etc/passwd` → aparece alguien que no debería | Una cuenta sin terminal ahora la tiene | `sudo usermod -s /usr/sbin/nologin becario` |

### Cómo leer cada orden de detección

- **`awk -F: '$3==0 {print $1}' /etc/passwd`**
  - `awk` → programa que trabaja con columnas.
  - `-F:` → las columnas se separan por `:`.
  - `$3==0` → quédate solo con las líneas cuyo campo 3 (el UID) vale 0.
  - `{print $1}` → de esas líneas, muestra el campo 1 (el nombre).
  - Solo debería salir `root`.
- **`sudo awk -F: '$2=="" {print $1}' /etc/shadow`** → igual, pero en shadow: muestra las cuentas cuyo campo 2 (el hash) está **vacío** (`""`), es decir, sin contraseña. Lleva `sudo` porque shadow solo lo lee root.
- **`getent group sudo`** → muestra la línea del grupo `sudo`; al final están sus miembros.
- **`ls -l /etc/shadow`** → muestra los permisos del fichero.
- **`grep 'bash$' /etc/passwd`** → muestra las líneas que **terminan** (`$`) en `bash`, es decir, las cuentas con terminal.

### Cómo leer los permisos

`-rw-r-----` se lee en tríos: dueño `rw-` · grupo `r--` · otros `---`.
Cada trío es un número: `r` = 4, `w` = 2, `x` = 1, y se suman → `rw-` = 6, `r--` = 4, `---` = 0 → **640**.
Con `644` los «otros» tienen `r--`: **cualquiera** puede leer el fichero.

### Cómo leer las órdenes de arreglo

- `userdel -f soporte` → borra la cuenta. `-f` (forzar) hace falta porque, al tener UID 0 como root, el sistema cree que está en uso.
- `userdel -r invitado` → borra la cuenta y su carpeta personal (`-r`).
- `gpasswd -d marta sudo` → quita (`-d`, delete) a marta del grupo sudo sin tocar sus otros grupos.
- `chmod 640 /etc/shadow` → vuelve a poner los permisos correctos.
- `usermod -s /usr/sbin/nologin becario` → le vuelve a quitar la terminal.

**Para practicar solo en casa:** ejecuta `sudo bash sabotaje.sh`, búscalos sin mirar, comprueba con `sudo bash sabotaje.sh --solucion` y deja la máquina bien con `sudo bash reparar.sh`.

---

## 4 · Práctica 2 · Windows (pendiente)

> **No se hizo en clase por falta de tiempo.** Pregunta a tu profesor o profesora cómo vais a hacerla antes de seguir.

📖 **Tema:** 3.1 Usuarios de Windows · 3.2 Gestión de contraseñas · 3.4 Grupos de usuarios · 3.5 UAC.

Abre PowerShell **como administrador** (botón derecho en Inicio → Terminal (administrador)). El prompt debe ser `PS C:\Windows\system32>`.

### Grupos

```powershell
"Sistemas","Desarrollo","Comercial" | ForEach-Object { New-LocalGroup -Name $_ }
```
- `"Sistemas","Desarrollo","Comercial"` → una lista con tres nombres.
- `|` → pasa la lista a la orden siguiente.
- `ForEach-Object { … }` → repite lo de dentro de las llaves **una vez por cada nombre**.
- `New-LocalGroup -Name $_` → crea un grupo local. `$_` es «el nombre que toca en esta vuelta».
- Es lo mismo que escribir tres veces `New-LocalGroup -Name Sistemas`, etc.

### Usuarios

```powershell
$pw = Read-Host -AsSecureString "Contraseña inicial"
New-LocalUser -Name ana   -FullName "Ana Ruiz"   -Password $pw
New-LocalUser -Name luis  -FullName "Luis Gomez" -Password $pw
New-LocalUser -Name marta -FullName "Marta Sanz" -Password $pw
```
- `Read-Host` → pide un texto por teclado. `-AsSecureString` → lo guarda de forma protegida y no se ve en pantalla.
- `$pw = …` → guarda esa contraseña en la variable `$pw` para usarla tres veces.
- `New-LocalUser` → crea un usuario local. `-Name` el login, `-FullName` el nombre completo, `-Password` la contraseña.

### Cada uno a su grupo

```powershell
Add-LocalGroupMember -Group Sistemas   -Member ana
Add-LocalGroupMember -Group Desarrollo -Member luis
Add-LocalGroupMember -Group Comercial  -Member marta
```
- `Add-LocalGroupMember` → mete a un usuario (`-Member`) en un grupo (`-Group`).

### Grupo Usuarios y administradora

```powershell
Add-LocalGroupMember -SID S-1-5-32-545 -Member ana,luis,marta
Add-LocalGroupMember -SID S-1-5-32-544 -Member ana
```
- El **SID** es el número de identidad de una cuenta o grupo en Windows. Los grupos de sistema tienen el mismo SID en cualquier idioma:
  - `S-1-5-32-545` = **Usuarios** (sin este grupo no pueden iniciar sesión).
  - `S-1-5-32-544` = **Administradores**.
- Se usa `-SID` en vez de `-Group` porque el nombre cambia con el idioma («Usuarios» / «Users»).
- `-Member ana,luis,marta` → la coma permite poner varios a la vez.

### Directiva de contraseñas

```powershell
net accounts /minpwlen:12 /maxpwage:90 /lockoutthreshold:5 /lockoutwindow:15 /lockoutduration:15
net accounts
```

| Opción | Qué hace |
|---|---|
| `/minpwlen:12` | longitud mínima de la contraseña: 12 caracteres |
| `/maxpwage:90` | la contraseña caduca a los 90 días |
| `/lockoutthreshold:5` | se bloquea la cuenta tras 5 intentos fallidos |
| `/lockoutwindow:15` | los intentos se cuentan dentro de una ventana de 15 minutos |
| `/lockoutduration:15` | la cuenta queda bloqueada 15 minutos |

- El segundo `net accounts`, sin opciones, **muestra** la directiva para comprobarla.

### Extras ★

```powershell
Set-LocalUser -Name ana -PasswordNeverExpires $true
net user luis /logonpasswordchg:yes
net user marta /passwordchg:no
New-LocalUser -Name becario -FullName "Becario" -Password $pw -AccountExpires (Get-Date "2026-12-31")
Disable-LocalUser -Name becario
```
- `Set-LocalUser … -PasswordNeverExpires $true` → la contraseña de ana no caduca nunca (`$true` = sí).
- `net user luis /logonpasswordchg:yes` → luis tendrá que cambiar la contraseña al iniciar sesión.
- `net user marta /passwordchg:no` → marta no puede cambiar su contraseña.
- `-AccountExpires (Get-Date "2026-12-31")` → la cuenta caduca ese día. `Get-Date` convierte el texto en una fecha.
- `Disable-LocalUser -Name becario` → deshabilita la cuenta (no puede entrar).

### Comprobar

En la carpeta `windows` del laboratorio:

```powershell
powershell -ExecutionPolicy Bypass -File .\Comprobar-NorteRedes.ps1
```
✅ Debe terminar con «Práctica básica completa».

**UAC en una línea** (📖 3.5): compara `whoami /groups` en una consola normal (Administradores = «Grupo usado solo para denegar», nivel **medio**) y en otra «como administrador» (grupo habilitado, nivel **alto**). Son los dos «pases» (tokens) que UAC da a un administrador.

---

## 5 · Soluciones del quiz

| # | Pregunta | Respuesta | Por qué | 📖 Tema |
|---|---|---|---|---|
| 1 | ¿Dónde está el hash de las contraseñas en Linux? | `/etc/shadow` | Solo lo lee root; `/etc/passwd` lo lee cualquiera | 1.1.4 |
| 2 | ¿Qué UID tiene root? | 0 | Lo que da el poder es el número, no el nombre | 1.1.3 |
| 3 | ¿Qué pierde ana con `usermod -G sudo ana` sin `-a`? | Todos sus otros grupos secundarios | `-G` sustituye; `-a` añade | 1.2.6 |
| 4 | ¿Qué significa `!` delante del hash? | Cuenta bloqueada | Ninguna contraseña coincide con un hash que empieza por `!` | 1.2.4 |
| 5 | ¿Equivalente de `/etc/skel` en Windows? | `C:\Users\Default` | Plantilla de los perfiles nuevos | 1.4 · 3.3 |
| 6 | ¿En qué número acaba el SID del Administrador integrado? | 500 | Invitado es 501; tus cuentas, de 1000 en adelante | 3.1 · 3.4 |
| 7 | ¿Por qué un administrador con UAC tiene dos tokens? | Para trabajar sin privilegios y elevarse solo al aceptar UAC | La misma idea que `sudo` | 3.5 |
| 8 | Perfil móvil frente a obligatorio | El obligatorio (`NTUSER.MAN`) descarta los cambios al cerrar sesión | El móvil los guarda (`NTUSER.DAT`) | 3.3 |
| 9 | ¿Por qué `P@ssw0rd` es mala contraseña? | Está en todos los diccionarios de ataque | Lo que importa es la longitud | 3.2.1 · 3.2.2 |
| 10 | Suspensión o hibernación: ¿cuál consume cero? | Hibernación | Guarda la sesión en disco y apaga | 2.1.1 · 4.4 |

---

## 6 · Fuentes

Las explicaciones se han contrastado con las páginas de manual de Ubuntu (`man useradd`, `man chage`, `man shadow`…) y con la documentación de Microsoft Learn (`New-LocalUser`, `Add-LocalGroupMember`, `net user`, SID, UAC). Todos los enlaces están en **[FUENTES.md](FUENTES.md)**.

La **presentación completa**, con las diapositivas de solución, está en [`presentacion/`](presentacion/). Para seguir practicando: **OverTheWire Bandit** (https://overthewire.org/wargames/bandit/).

*Norte Redes S.L. y sus empleados son ficticios. Usa estos scripts solo en tus máquinas virtuales de prácticas.*
