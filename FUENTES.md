# Fuentes y referencias · Norte Redes Lab

Todo el material de este repositorio (textos, scripts, presentación, resúmenes de órdenes, imágenes y código QR) es **de elaboración propia** para esta práctica. Las explicaciones técnicas se han contrastado con la documentación oficial que se enlaza abajo. **No se ha copiado** texto ni imágenes de esas fuentes: solo se enlazan para que puedas ampliar.

Fecha de la última comprobación de los enlaces: **10 de noviembre de 2026**.

## 1. Temario del centro (fuente principal)

- **UF2 01 · Administración de software base** (resumen y puntos clave).
- **UF2 01.1 · Administración de software base** (contenido completo).

Son materiales del centro: este repositorio **no los incluye ni los reproduce**, solo indica qué apartado repasar. La tabla completa está en el [README](README.md#relación-con-el-temario).

## 2. Linux (Ubuntu)

Páginas de manual oficiales de Ubuntu 24.04 (también las tienes en tu máquina con `man ORDEN`):

| Orden o fichero | Enlace | Apartado del tema |
|---|---|---|
| `useradd` | https://manpages.ubuntu.com/manpages/noble/man8/useradd.8.html | 1.2.1 |
| `passwd` (orden) | https://manpages.ubuntu.com/manpages/noble/man1/passwd.1.html | 1.2.2 |
| `chage` | https://manpages.ubuntu.com/manpages/noble/man1/chage.1.html | 1.2.2 · 1.1.4 |
| `usermod` | https://manpages.ubuntu.com/manpages/noble/man8/usermod.8.html | 1.2.4 · 1.2.6 |
| `groupadd` | https://manpages.ubuntu.com/manpages/noble/man8/groupadd.8.html | 1.2.5 |
| `/etc/passwd` | https://manpages.ubuntu.com/manpages/noble/man5/passwd.5.html | 1.1.3 |
| `/etc/shadow` | https://manpages.ubuntu.com/manpages/noble/man5/shadow.5.html | 1.1.4 |
| `/etc/group` | https://manpages.ubuntu.com/manpages/noble/man5/group.5.html | 1.1.5 |

- Guía oficial de Ubuntu Server sobre gestión de usuarios: https://documentation.ubuntu.com/server/how-to/security/user-management/

## 3. Windows

Documentación oficial de Microsoft (Microsoft Learn, en español):

| Tema | Enlace | Apartado del tema |
|---|---|---|
| `New-LocalUser` | https://learn.microsoft.com/es-es/powershell/module/microsoft.powershell.localaccounts/new-localuser | 3.1 |
| `Set-LocalUser` | https://learn.microsoft.com/es-es/powershell/module/microsoft.powershell.localaccounts/set-localuser | 3.2 |
| `New-LocalGroup` | https://learn.microsoft.com/es-es/powershell/module/microsoft.powershell.localaccounts/new-localgroup | 3.4 |
| `Add-LocalGroupMember` | https://learn.microsoft.com/es-es/powershell/module/microsoft.powershell.localaccounts/add-localgroupmember | 3.4 |
| `net user` | https://learn.microsoft.com/es-es/windows-server/administration/windows-commands/net-user | 3.2 |
| SID (identificadores de seguridad, -500, -501, S-1-5-32-544…) | https://learn.microsoft.com/es-es/windows-server/identity/ad-ds/manage/understand-security-identifiers | 3.4 |
| Control de cuentas de usuario (UAC) | https://learn.microsoft.com/es-es/windows/security/application-security/application-control/user-account-control/how-it-works | 3.5 |
| Active Directory (visión general) | https://learn.microsoft.com/es-es/windows-server/identity/ad-ds/get-started/virtual-dc/active-directory-domain-services-overview | 3.6.7 |
| `powercfg` (planes de energía) | https://learn.microsoft.com/es-es/windows-hardware/design/device-experiences/powercfg-command-line-options | 4.2 |

`net accounts` se explica con la propia ayuda de Windows: escribe `net help accounts` en una consola.

## 4. Seguridad de contraseñas

- NIST SP 800-63B (directrices de identidad digital del Gobierno de EE. UU.; base de la idea «lo que importa es la longitud»): https://csrc.nist.gov/pubs/sp/800/63/b/upd2/final — apartado del tema 3.2.1 y 3.2.2.

## 5. Ejemplo real citado en la presentación

- **Colonial Pipeline (2021)**: el ataque de ransomware empezó con la contraseña de una cuenta VPN antigua que ya no se usaba y no tenía doble factor, según declaró su director general ante el Senado de EE. UU.
  - Insurance Journal: https://www.insurancejournal.com/news/national/2021/06/09/617870.htm
  - Dark Reading: https://www.darkreading.com/attacks-breaches/colonial-pipeline-ceo-ransomware-attack-started-via-pilfered-legacy-vpn-account/d/d-id/1341237

## 6. Mercado laboral y estudios (diapositivas finales)

- Real Decreto 260/2020 (título de Especialista en Ciberseguridad en Entornos de las TI, curso de especialización de FP): https://www.boe.es/boe/dias/2020/05/13/pdfs/BOE-A-2020-4963.pdf
| Dato de la diapositiva 35 | Fuente original | Dónde se publicó |
|---|---|---|
| «La demanda de perfiles tecnológicos duplica la oferta» | Noticia de Qué! (junio de 2026) | https://www.que.es/2026/06/24/talento-tecnologia-espana-demanda-oferta/ |
| «1,06 millones de especialistas TIC, el 4,9 % del empleo» | Informe *Digital Talent Overview 2026 – España*, de Mobile World Capital Barcelona | https://www.corresponsables.com/actualidad/espana-talento-digital-empleo-especialistas-tic/ |
| «Suben ciberseguridad, cloud y datos; baja el soporte tradicional» | Informe *Tech Cities 2026*, de Experis (ManpowerGroup) | https://www.que.es/2026/06/20/empleo-tecnologico-espana-2026-crece-64/ |

Las cifras de mercado laboral son de esas noticias en la fecha indicada y pueden cambiar.

## 7. Para seguir practicando

- **OverTheWire · Bandit**: juego gratuito para aprender la terminal de Linux superando niveles. https://overthewire.org/wargames/bandit/

## 8. Herramientas usadas para preparar el material

- Presentación hecha con Microsoft PowerPoint (formato `.pptx`) y exportada a PDF.
- Código QR generado con la biblioteca libre `segno` (Python).
- Los iconos y emojis son caracteres Unicode estándar.
