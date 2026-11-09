# Norte Redes Lab

Prácticas de **1.º ASIR · Implantación de Sistemas Operativos · UF2, tema 01 (Administración de software base)**.

Hoy eres el administrador de sistemas de **Norte Redes S.L.**, una operadora pequeña. Tienes que dar de alta a su plantilla en Ubuntu y en Windows, protegerla con una directiva de contraseñas y, al final, auditar la máquina de un compañero que la ha saboteado.

Este repositorio trae un **corrector automático**: lo ejecutas en tu máquina virtual y te dice qué has hecho bien, qué falta y una pista de por dónde seguir. Puedes ejecutarlo todas las veces que quieras. Solo lee la configuración, no cambia nada.

> Trabaja siempre en tu **máquina virtual**, y haz antes una instantánea llamada `antes-UF2`.

**👉 [Guía del alumno paso a paso](GUIA_ALUMNO.md)**: empieza por aquí.

| Material | Enlace |
|---|---|
| Guía paso a paso | [GUIA_ALUMNO.md](GUIA_ALUMNO.md) |
| Presentación de la clase (PowerPoint) | [presentacion/Norte_Redes_UF2_Administracion_software_base.pptx](presentacion/Norte_Redes_UF2_Administracion_software_base.pptx) |
| Presentación de la clase (PDF) | [presentacion/Norte_Redes_UF2_Administracion_software_base.pdf](presentacion/Norte_Redes_UF2_Administracion_software_base.pdf) |
| Resumen de órdenes más importantes · Ubuntu (PDF) | [resumen-ordenes/Ordenes_Ubuntu.pdf](resumen-ordenes/Ordenes_Ubuntu.pdf) |
| Resumen de órdenes más importantes · Windows (PDF) | [resumen-ordenes/Ordenes_Windows.pdf](resumen-ordenes/Ordenes_Windows.pdf) |

<img src="img/qr-norte-redes-lab.png" alt="Código QR de este repositorio" width="160">

Escanea el QR con el móvil para abrir este repositorio.

## Tiempo: 1 h 50 min en total

| Parte | Tiempo | Qué entregas |
|---|---|---|
| Práctica 1 · Ubuntu | 45 min | Captura del corrector con el **básico** al 100 % |
| Reto en parejas · Ubuntu | 25 min | Los 3 fallos que encontraste |
| Práctica 2 · Windows | 40 min | Captura del corrector con el **básico** al 100 % |

Cada práctica tiene un **nivel básico**, que es lo que hay que entregar, y unas tareas **extra ★** para quien termine antes. Las extra no son obligatorias.

## La plantilla

| Usuario | Nombre | Departamento (grupo) |
|---|---|---|
| `ana` | Ana Ruiz | sistemas · administradora del equipo |
| `luis` | Luis Gomez | desarrollo |
| `marta` | Marta Sanz | comercial |
| `becario` | Becario | desarrollo (solo en los extra ★) |

## Descargarlo en la máquina virtual

**Ubuntu** (en la terminal):

```bash
cd ~
wget -O lab.tar.gz https://github.com/keespootes-cloud/norte-redes-lab/archive/refs/heads/main.tar.gz
tar xzf lab.tar.gz
cd norte-redes-lab-main/linux
```

**Windows**: abre https://github.com/keespootes-cloud/norte-redes-lab en el navegador → **Code** → **Download ZIP** → descomprime → abre PowerShell en la carpeta `windows`.

## Práctica 1 · Ubuntu (45 min)

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

## Práctica 2 · Windows (40 min)

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

`-ExecutionPolicy Bypass` solo afecta a esa ejecución; no cambia la configuración de Windows.

## Reto en parejas · auditoría de cuentas (25 min, Ubuntu)

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

## Avisos

- **Norte Redes S.L. y sus empleados son ficticios.** Cualquier parecido con empresas o personas reales es casual.
- **Uso educativo.** Ejecuta estos scripts solo en máquinas virtuales de prácticas que sean tuyas. `sabotaje.sh` crea cuentas inseguras a propósito y se niega a funcionar fuera de una máquina virtual.
- Los correctores solo leen la configuración del sistema; no envían nada a ningún sitio.

## Licencia

MIT. Puedes usar, copiar y adaptar este material libremente; se entrega tal cual, sin garantías.
