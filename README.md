# Norte Redes Lab

Prácticas de **1.º ASIR · Implantación de Sistemas Operativos · UF2, tema 01 (Administración de software base)**.

Hoy eres el administrador de sistemas de **Norte Redes S.L.**, una operadora pequeña (ficticia). Tienes que dar de alta a su plantilla en Ubuntu y en Windows, protegerla con una directiva de contraseñas y, al final, auditar la máquina de un compañero que la ha saboteado.

Este repositorio trae un **corrector automático**: lo ejecutas en tu máquina virtual y te dice qué has hecho bien, qué falta y una pista de por dónde seguir. Puedes ejecutarlo todas las veces que quieras. Solo lee la configuración, no cambia nada.

> Trabaja siempre en tu **máquina virtual**, y haz antes una instantánea llamada `antes-UF2`.

---

## ⚠️ Aviso importante: hasta dónde se llegó en clase

En la sesión del **9 de noviembre de 2026** se trabajó la teoría y se completó la parte de **Ubuntu**:

| Parte | ¿Se hizo en clase? |
|---|---|
| Práctica 1 · Ubuntu | ✅ Sí, hasta el final |
| Reto en parejas · Ubuntu | ✅ Sí |
| Práctica 2 · Windows | ❌ **No dio tiempo** |

**Habla con tu profesor o profesora de la asignatura** para que te diga cómo continuar con la parte de Windows (si se hará en otra clase, si es para casa o si cambia la entrega). El material de Windows se queda en este repositorio, con sus soluciones, para cuando os lo indique.

---

## Por dónde empezar

| Material | Para qué sirve |
|---|---|
| **[Guía del alumno paso a paso](GUIA_ALUMNO.md)** | Hacer la práctica tú solo. Empieza por aquí. |
| **[Soluciones explicadas](SOLUCIONES.md)** | Comprobar en casa lo que hiciste, orden por orden |
| [Fuentes y referencias](FUENTES.md) | De dónde sale cada dato y dónde ampliar |
| [Presentación completa (PowerPoint)](presentacion/Norte_Redes_UF2_Administracion_software_base.pptx) | Repasar la teoría de la clase, con las soluciones |
| [Presentación completa (PDF)](presentacion/Norte_Redes_UF2_Administracion_software_base.pdf) | Lo mismo, para verla en el móvil |
| [Resumen de órdenes · Ubuntu (PDF)](resumen-ordenes/Ordenes_Ubuntu.pdf) | Sintaxis de las órdenes de Linux |
| [Resumen de órdenes · Windows (PDF)](resumen-ordenes/Ordenes_Windows.pdf) | Sintaxis de las órdenes de Windows |

<img src="img/qr-norte-redes-lab.png" alt="Código QR de este repositorio" width="160">

Escanea el QR con el móvil para abrir este repositorio.

---

## Relación con el temario

Cada parte de la práctica se apoya en un apartado de vuestro tema **«UF2 01.1 · Administración de software base»**. Tenlo abierto al lado mientras repasas. (Entre paréntesis, la página del PDF del tema.)

| Lo que haces en la práctica | Apartado del tema UF2 01.1 |
|---|---|
| Usar la terminal y las órdenes básicas (`cd`, `ls`, `grep`…) | 1.1.1 El intérprete de órdenes (p. 9) · 1.1.2 Órdenes básicas (p. 10) |
| Entender `/etc/passwd` (usuarios, UID, shell) | 1.1.3 Fichero con información de usuarios (p. 12) |
| Entender `/etc/shadow` (contraseñas, caducidad, `!` de bloqueo) | 1.1.4 Fichero con información de contraseñas (p. 13) |
| Entender `/etc/group` (grupos y sus miembros) | 1.1.5 Ficheros con información de grupos (p. 15) |
| Crear usuarios con `useradd` | 1.2.1 Añadir usuarios al sistema (p. 16) |
| Poner contraseñas con `passwd` y caducidad con `chage` | 1.2.2 Asignar una contraseña (p. 17) |
| Borrar usuarios con `userdel` (reto) | 1.2.3 Eliminar usuarios (p. 17) |
| Bloquear cuentas y quitar la terminal (`nologin`) | 1.2.4 Deshabilitar usuarios temporalmente (p. 17) |
| Crear grupos con `groupadd` | 1.2.5 Creación, eliminación y asignación de usuarios a grupos |
| Añadir a ana al grupo `sudo` con `usermod -aG` | 1.2.6 Modificación del grupo de un usuario (p. 19) |
| Ver quién está conectado (`w`, `last`) | 1.2.7 Monitorización de usuarios (p. 19) |
| Kit de bienvenida en `/etc/skel` | 1.4 Perfiles de usuario locales (p. 22) |
| Usuarios locales de Windows (`New-LocalUser`) | 3.1 Usuarios de Windows (p. 30) |
| Directiva de contraseñas (`net accounts`, `net user`) | 3.2 Gestión de contraseñas (p. 32) |
| Perfiles de Windows (`C:\Users\Default`) | 3.3 Perfiles de usuarios locales (p. 35) |
| Grupos Usuarios y Administradores, SID | 3.4 Grupos de usuarios (p. 37) |
| Consola «como administrador», `whoami /groups` | 3.5 Control de cuentas de usuario (UAC) (p. 38) |
| Teoría de clase: dominios y Active Directory | 3.6 Dominios, grupos de trabajo y grupos (p. 40) |
| Teoría de clase: suspensión, hibernación, energía | 2.1 Gestión energética en GNU/Linux (p. 26) · 4.1–4.4 Ahorro energético en Windows (p. 51–54) |

En el resumen del tema (**UF2 01**), la práctica cubre los **puntos clave 1, 2 y 4** (usuarios y grupos en Linux, herramientas en modo texto, usuarios en Windows). Los puntos 3 y 5 (portátiles y energía) solo se vieron en la teoría.

---

## La plantilla de la empresa

| Usuario | Nombre | Departamento (grupo) |
|---|---|---|
| `ana` | Ana Ruiz | sistemas · administradora del equipo |
| `luis` | Luis Gomez | desarrollo |
| `marta` | Marta Sanz | comercial |
| `becario` | Becario | desarrollo (solo en los extra ★) |

Son personas inventadas para la práctica.

## Descargarlo en la máquina virtual

**Ubuntu** (en la terminal, una orden cada vez):

```bash
cd ~
wget -O lab.tar.gz https://github.com/keespootes-cloud/norte-redes-lab/archive/refs/heads/main.tar.gz
tar xzf lab.tar.gz
cd norte-redes-lab-main/linux
```

| Orden | Qué hace |
|---|---|
| `cd ~` | Va a tu carpeta personal (`~` significa «mi home») |
| `wget -O lab.tar.gz URL` | Descarga el repositorio comprimido y lo guarda (`-O`) con el nombre `lab.tar.gz` |
| `tar xzf lab.tar.gz` | Descomprime: `x` extraer, `z` el fichero está comprimido con gzip, `f` el fichero es este |
| `cd norte-redes-lab-main/linux` | Entra en la carpeta de los scripts de Linux |

**Windows**: abre https://github.com/keespootes-cloud/norte-redes-lab en el navegador → **Code** → **Download ZIP** → descomprime → abre PowerShell en la carpeta `windows`.

## Práctica 1 · Ubuntu (45 min) · tema 1.1, 1.2 y 1.4

**Básico**

1. Crea los grupos `sistemas` (GID 2001), `desarrollo` (GID 2002) y `comercial` (GID 2003).
2. Haz que todo usuario nuevo reciba en su home un `LEEME.txt` de bienvenida (pista: `/etc/skel`).
3. Crea a `ana`, `luis` y `marta` con su home, la shell `/bin/bash` y su grupo como grupo principal.
4. Ponles contraseña.
5. Haz administradora a `ana` (grupo `sudo`) sin quitarle su grupo principal.

**Extra ★**

6. Obliga a `luis` a cambiar su contraseña la primera vez que entre.
7. La contraseña de `marta` caduca cada 90 días, con un mínimo de 1 día y aviso 7 días antes.
8. Crea a `becario` (grupo `desarrollo`) sin acceso a la terminal y con la cuenta caducando el 31/12/2026.

Órdenes que necesitas: `groupadd`, `useradd`, `passwd`, `usermod`, `chage`. Cuando quieras ver cómo vas:

```bash
sudo bash comprobar.sh
```

(`sudo` = ejecutar como administrador; `bash comprobar.sh` = ejecutar el script con el intérprete bash.)

Ejemplo de salida:

```text
A · Grupos y usuarios
  ✔ Grupo sistemas con GID 2001
  ✘ Falta el grupo comercial
      Pista: Créalo con groupadd e indica su número (GID)
...
Básico: 20 / 20  [##############################] 100 %
Extra ★: 1 / 3
Práctica básica completa. Haz una captura de esta pantalla para la entrega.
```

## Reto en parejas · auditoría de cuentas (25 min, Ubuntu) · tema 1.1.3 a 1.1.5

1. **Saboteador**: en tu máquina virtual, con la instantánea hecha:
   ```bash
   sudo bash sabotaje.sh
   ```
   El script esconde 3 fallos de seguridad relacionados con las cuentas, las contraseñas y los permisos. Pásale el teclado a tu compañero.
2. **Auditor**: tienes 10 minutos para encontrar los 3 fallos **solo con la terminal**, sin el corrector y sin abrir los scripts.
3. Al acabar, el saboteador enseña la solución:
   ```bash
   sudo bash sabotaje.sh --solucion
   ```
4. Dejad la máquina como estaba: restaurad la instantánea `antes-UF2` o
   ```bash
   sudo bash reparar.sh
   ```
5. Cambiad los papeles.

## Práctica 2 · Windows (40 min) · tema 3.1 a 3.5

> **No se hizo en clase por falta de tiempo.** Consulta con tu profesor o profesora antes de hacerla (mira el aviso de arriba).

Abre PowerShell **como administrador**.

**Básico**

1. Crea los grupos locales `Sistemas`, `Desarrollo` y `Comercial`.
2. Crea a `ana`, `luis` y `marta` con contraseña, mételos en su grupo y en el grupo **Usuarios**.
3. Haz administradora a `ana`.
4. Directiva de contraseñas con `net accounts`: longitud mínima 12, caducidad 90 días y bloqueo tras 5 intentos fallidos durante 15 minutos (duración y ventana de observación).

**Extra ★**

5. La contraseña de `ana` nunca expira; `luis` debe cambiarla al entrar; `marta` no puede cambiarla.
6. Crea a `becario` con la cuenta caducando el 31/12/2026 y después deshabilítala.

Órdenes que necesitas: `New-LocalGroup`, `New-LocalUser`, `Add-LocalGroupMember`, `net accounts`, `net user`, `Set-LocalUser`, `Disable-LocalUser`. El corrector se ejecuta así:

```powershell
powershell -ExecutionPolicy Bypass -File .\Comprobar-NorteRedes.ps1
```

`-ExecutionPolicy Bypass` permite ejecutar este script solo esa vez; no cambia la configuración de Windows. `-File` indica qué script ejecutar.

## Qué hay en cada carpeta

| Carpeta / fichero | Contenido |
|---|---|
| `linux/comprobar.sh` | Corrector de la práctica 1 (solo lee) |
| `linux/sabotaje.sh` | Mete 3 fallos para el reto (solo funciona en una máquina virtual) |
| `linux/reparar.sh` | Deshace los fallos del reto |
| `windows/Comprobar-NorteRedes.ps1` | Corrector de la práctica 2 (solo lee) |
| `presentacion/` | La presentación de clase completa |
| `resumen-ordenes/` | Resúmenes de sintaxis de las órdenes |
| `img/` | Código QR del repositorio |

Todos los scripts están **comentados línea a línea en español**: ábrelos con un editor de texto y lee los comentarios (las líneas que empiezan por `#`) para entender qué hace cada parte.

## Avisos

- **Norte Redes S.L. y sus empleados son ficticios.** Cualquier parecido con empresas o personas reales es casual.
- **Uso educativo.** Ejecuta estos scripts solo en máquinas virtuales de prácticas que sean tuyas. `sabotaje.sh` crea cuentas inseguras a propósito y se niega a funcionar fuera de una máquina virtual.
- Los correctores solo leen la configuración del sistema; no envían nada a ningún sitio.
- Este repositorio **no incluye** el temario del centro: solo lo cita por apartados para que lo consultes en tu copia.

## Licencia

El código y los textos de este repositorio se publican con licencia **MIT** (ver [LICENSE](LICENSE)): puedes usarlos, copiarlos y adaptarlos libremente; se entregan tal cual, sin garantías. Las fuentes externas citadas en [FUENTES.md](FUENTES.md) pertenecen a sus autores y solo se enlazan.
