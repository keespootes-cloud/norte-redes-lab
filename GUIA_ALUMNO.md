# Guía del alumno · Norte Redes Lab

Esta guía te acompaña paso a paso por la práctica. Tienes **1 h 50 min** en total:

| Parte | Tiempo |
|---|---|
| Paso 0 · Preparar la máquina y descargar el laboratorio | 5 min |
| Práctica 1 · Ubuntu | 45 min |
| Reto en parejas · Ubuntu | 25 min |
| Práctica 2 · Windows (después del descanso) | 40 min |

Las tareas marcadas con **★** son **extra**: hazlas solo si terminas el resto. Lo que se entrega es el **nivel básico al 100 %**.

En cada paso tienes la **sintaxis** de la orden: tú decides qué poner en lo que está en MAYÚSCULAS. Para consultar opciones, usa el **resumen de órdenes** ([Ubuntu](resumen-ordenes/Ordenes_Ubuntu.pdf) · [Windows](resumen-ordenes/Ordenes_Windows.pdf)), `man ORDEN` o `Get-Help ORDEN -Examples`.

**Después de la clase:** comprueba tu práctica en casa con el corrector y compárala con las [soluciones](SOLUCIONES.md).

> **⚠️ Hasta dónde se llegó en clase (9/11/2026):** se hicieron la **Práctica 1 (Ubuntu)** y el **reto en parejas**. La **Práctica 2 (Windows) no dio tiempo**: habla con tu profesor o profesora para saber cómo continuar.

**📖 Tema:** en cada paso verás el apartado del PDF **«UF2 01.1 · Administración de software base»** que lo explica. Léelo antes o después de hacer el paso.

**Cómo pedir ayuda:** pon el pósit **rosa** en la pantalla. Cuando termines una parte, pon el **amarillo**.

---

## Paso 0 · Antes de empezar

### 0.1 Haz una instantánea de tu máquina virtual

Así, si algo se rompe, vuelves atrás en 10 segundos.

1. En VirtualBox, selecciona tu máquina de **Ubuntu**.
2. Menú **Máquina** → **Tomar instantánea**.
3. Nombre: `antes-UF2` → **Aceptar**.

Repite lo mismo con tu máquina de **Windows** antes de la práctica 2.

### 0.2 Abre una terminal en Ubuntu

📖 Tema: 1.1.1 El intérprete de órdenes · 1.1.2 Órdenes básicas.

Pulsa `Ctrl + Alt + T`.

Trucos del teclado español en la máquina virtual:

| Quiero escribir | Pulsa |
|---|---|
| `\|` (barra vertical) | `AltGr + 1` |
| `~` | `AltGr + 4` |
| `#` | `AltGr + 3` |

Al escribir una contraseña **no se ve nada en pantalla**. Es normal: escríbela y pulsa Intro.

**Escribe las órdenes de una en una**, sobre todo las que piden contraseñas.

### 0.3 Descarga el laboratorio

Escribe estas órdenes una a una en la terminal de Ubuntu:

```bash
cd ~
wget -O lab.tar.gz https://github.com/keespootes-cloud/norte-redes-lab/archive/refs/heads/main.tar.gz
tar xzf lab.tar.gz
cd norte-redes-lab-main/linux
ls
```

Debes ver tres ficheros: `comprobar.sh`, `reparar.sh` y `sabotaje.sh`.

**Si da error:** abre Firefox **dentro** de la máquina virtual, ve a `github.com/keespootes-cloud/norte-redes-lab` → botón verde **Code** → **Download ZIP**, y descomprímelo.

### 0.4 Prueba el corrector

```bash
sudo bash comprobar.sh
```

Te pedirá **tu** contraseña (la de tu usuario de Ubuntu). Saldrá casi todo en rojo: es normal, aún no has hecho nada. Ejecútalo todas las veces que quieras: solo mira, no cambia nada, y te da una pista de por dónde ir en cada fallo.

---

## Práctica 1 · Ubuntu (45 min)

Eres el administrador de sistemas de **Norte Redes S.L.** Tienes que dar de alta a su plantilla.

| Usuario | Nombre | Grupo principal |
|---|---|---|
| `ana` | Ana Ruiz | sistemas (GID 2001) |
| `luis` | Luis Gomez | desarrollo (GID 2002) |
| `marta` | Marta Sanz | comercial (GID 2003) |

> En Linux, **si una orden no dice nada, ha ido bien**.

### Paso 1 · Crear los tres grupos, cada uno con su GID

📖 Tema: 1.2.5 Creación de grupos · 1.1.5 `/etc/group`.

```bash
sudo groupadd -g GID GRUPO
```

**Comprueba** con `getent group GRUPO`. Debe salir una línea con el formato `grupo:x:GID:`.

### Paso 2 · El kit de bienvenida

📖 Tema: 1.4 Perfiles de usuario locales.

Todo lo que hay en `/etc/skel` se copia al home de cada usuario **nuevo**. Crea ahí un fichero `LEEME.txt` con un texto de bienvenida, **antes** de crear los usuarios.

```bash
echo "TEXTO" | sudo tee RUTA_DEL_FICHERO
```

`tee` escribe en un fichero lo que le llega por la tubería `|`. Se usa en lugar de `>` porque la redirección `>` no funciona con `sudo`.

### Paso 3 · Crear los tres usuarios

📖 Tema: 1.2.1 `useradd` · 1.1.3 `/etc/passwd`.

```bash
sudo useradd OPCIONES USUARIO
```

Cada usuario necesita: **carpeta personal** (home), la shell **`/bin/bash`**, su **nombre completo** como comentario y su **grupo principal**. Busca qué opción hace cada cosa en el resumen de órdenes o en `man useradd`.

**Comprueba** con `getent passwd USUARIO` y mira su home con `sudo ls -la /home/USUARIO`: tiene que estar `LEEME.txt`.

### Paso 4 · Ponerles contraseña

📖 Tema: 1.2.2 `passwd` · 1.1.4 `/etc/shadow`.

```bash
sudo passwd USUARIO
```

Te pide la contraseña nueva dos veces.

### Paso 5 · Ana es la administradora

📖 Tema: 1.2.6 `usermod`.

En Ubuntu, los administradores son los miembros del grupo `sudo`. Añade a ana a ese grupo **sin quitarle sus otros grupos**: mira las opciones de `usermod`.

**Cuidado:** hay una opción que **sustituye** todos los grupos secundarios y otra que **añade**. Equivocarse borra los grupos que ya tenía.

**Comprueba** con `id ana`: debe aparecer su grupo principal y, entre sus grupos, `sudo`.

### ✔ Comprueba el nivel básico

```bash
sudo bash comprobar.sh
```

Cuando veas **«Básico: 20 / 20 … 100 %»** y **«Práctica básica completa»**, haz una **captura de pantalla**: es tu entrega de la práctica 1.

### Extra ★ (solo si te sobra tiempo)

📖 Tema: 1.1.4 `/etc/shadow` (caducidad) · 1.2.4 Deshabilitar usuarios.

- **★ 6 · luis** debe **cambiar su contraseña** la primera vez que entre. Pista: `chage`. Para comprobarlo, entra como él con `su - luis` (escríbelo solo): te pedirá su contraseña actual y después una **nueva y distinta**. Para volver a tu usuario: `exit`.
- **★ 7 · La contraseña de marta** caduca cada **90 días**, con un **mínimo de 1 día** entre cambios y **aviso 7 días** antes. Pista: `chage`; compruébalo con `sudo chage -l marta`.
- **★ 8 · El becario** (grupo `desarrollo`): **sin acceso a la terminal** y con la **cuenta caducando el 31/12/2026**. Ponle contraseña. Pista: hay una shell que no deja entrar. Comprueba con `su - becario` que no puede usar la terminal.

---

## Reto en parejas · auditoría (25 min, Ubuntu)

Se hace **justo después de la práctica 1**, antes del descanso.

📖 Tema: 1.1.3 a 1.1.5 (los tres ficheros) · 1.2.3 `userdel` · 1.2.7 Monitorización.

1. **Saboteador** (en su máquina, con la instantánea hecha):
   ```bash
   cd ~/norte-redes-lab-main/linux
   sudo bash sabotaje.sh
   ```
   Escribe `SI` cuando lo pida. El script esconde **3 fallos de seguridad** relacionados con las **cuentas, las contraseñas y los permisos**. Pásale el teclado a tu compañero.
2. **Auditor:** tienes **10 minutos** para encontrar los 3 fallos usando **solo la terminal**: ni el corrector ni abrir los scripts. Piensa qué haría peligroso a un sistema y revisa `/etc/passwd`, `/etc/shadow` y `/etc/group`. Herramientas útiles: `getent`, `grep`, `awk`, `ls -l`.
3. **Al acabar los 10 minutos**, el saboteador enseña la solución:
   ```bash
   sudo bash sabotaje.sh --solucion
   ```
4. **Dejadlo como estaba:**
   ```bash
   sudo bash reparar.sh
   ```
   o restaurad la instantánea `antes-UF2`.
5. **Cambiad los papeles.**

---

## Práctica 2 · Windows (40 min)

> **No se hizo en clase por falta de tiempo.** Pregunta a tu profesor o profesora antes de hacerla.

📖 Tema: 3.1 Usuarios de Windows · 3.2 Contraseñas · 3.4 Grupos · 3.5 UAC.

1. Haz la instantánea `antes-UF2` de tu máquina de Windows (paso 0.1).
2. Dentro de la máquina virtual, descarga el ZIP del laboratorio y descomprímelo.
3. Botón derecho en **Inicio** → **Terminal (administrador)** o **Windows PowerShell (administrador)** → **Sí**.
4. Comprueba que la ruta empieza por `PS C:\Windows\system32>`: así sabes que eres administrador.

La plantilla es la misma que en Ubuntu: **Sistemas**, **Desarrollo** y **Comercial**, con `ana`, `luis` y `marta`.

### Paso 1 · Crear los tres grupos locales

```powershell
New-LocalGroup -Name GRUPO
```

### Paso 2 · Crear los usuarios

Primero guarda una contraseña inicial sin que se vea en pantalla (mínimo 12 caracteres, con mayúsculas y números):

```powershell
$pw = Read-Host -AsSecureString "Contraseña inicial"
```

Después crea a cada usuario con su nombre completo:

```powershell
New-LocalUser -Name USUARIO -FullName "NOMBRE COMPLETO" -Password $pw
```

### Paso 3 · Meterlos en sus grupos

```powershell
Add-LocalGroupMember -Group GRUPO -Member USUARIO
```

Además, los tres tienen que estar en el grupo **Usuarios**, o no podrán iniciar sesión. Como el nombre del grupo cambia con el idioma de Windows, es mejor indicarlo por su **SID** (búscalo en el resumen de órdenes):

```powershell
Add-LocalGroupMember -SID SID -Member USUARIO
```

### Paso 4 · Ana es la administradora

Igual que el paso anterior, pero con el grupo **Administradores**.

### Paso 5 · Directiva de contraseñas

📖 Tema: 3.2 Gestión de contraseñas.

Configura el equipo para que las contraseñas tengan **12 caracteres como mínimo**, **caduquen a los 90 días** y la cuenta se **bloquee 15 minutos tras 5 intentos fallidos** (ventana de observación de 15 minutos). Todo se hace con una sola orden: `net accounts` y sus opciones. Comprueba el resultado con `net accounts`.

### ✔ Comprueba el nivel básico

En la carpeta `windows` del laboratorio:

```powershell
cd RUTA\DONDE\DESCOMPRIMISTE\norte-redes-lab-main\windows
powershell -ExecutionPolicy Bypass -File .\Comprobar-NorteRedes.ps1
```

Cuando veas **«Práctica básica completa»**, haz la **captura**.

### Extra ★

- **★** La contraseña de **ana** no caduca nunca.
- **★** **luis** debe cambiar su contraseña al iniciar sesión, y **marta** no puede cambiar la suya.
- **★** Crea al **becario** con la cuenta caducando el 31/12/2026 y después **deshabilítala**.

Pistas: `Set-LocalUser`, `net user` y `Disable-LocalUser`. **Pruébalo de verdad:** cierra sesión y entra como `luis`.

---

## Errores frecuentes

| Mensaje | Qué pasa | Qué hacer |
|---|---|---|
| `Permission denied` | No eres administrador | Pon `sudo` delante |
| `command not found` | Orden mal escrita | Revisa letra a letra |
| `group '…' does not exist` | No has creado el grupo o lo has escrito distinto | `getent group NOMBRE` |
| `user '…' already exists` | Ya lo creaste | Sigue. Si lo creaste mal, bórralo con `userdel -r` y repite |
| No hay `LEEME.txt` en el home | Creaste el usuario antes que el fichero de `/etc/skel` | Borra el usuario y créalo otra vez |
| `Authentication failure` | Contraseña incorrecta | ¿Teclado en inglés? Prueba despacio |
| `sudo` no funciona tras añadir a sudo | Los grupos se leen al iniciar sesión | `exit` y vuelve a entrar |
| `BAD PASSWORD: … shorter than 8 characters` o `fails the dictionary check` | Ubuntu avisa de que la contraseña es débil | Es un aviso: puedes seguir, pero mejor usa una más larga |
| `Sorry, passwords do not match.` | Las dos contraseñas no coinciden | Escríbela otra vez despacio |
| `The password is the same as the old one` | En `su - luis`, la nueva es igual que la vieja | Pon una **distinta** |
| `Have exhausted maximum number of retries` | 3 intentos fallidos seguidos | Vuelve a escribir la orden y empieza de nuevo |
| Aparece `^[[200~` delante de la orden | Se pegó texto cuando la terminal no estaba lista | `Ctrl + C` y vuelve a escribirla |
| Windows: `Acceso denegado` | PowerShell no está como administrador | Ábrelo con «Ejecutar como administrador» |
| Windows: la contraseña no cumple los requisitos | Es demasiado corta o simple | Mínimo 12 caracteres, con mayúsculas y números |

---

## Para seguir en casa

- Este repositorio es público: puedes repetir la práctica cuando quieras.
- Todas las fuentes y enlaces para ampliar están en [FUENTES.md](FUENTES.md).
- **OverTheWire Bandit** (https://overthewire.org/wargames/bandit/): un juego gratuito para aprender la terminal de Linux superando niveles.

*Norte Redes S.L. y sus empleados son ficticios. Usa estos scripts solo en tus máquinas virtuales de prácticas.*
