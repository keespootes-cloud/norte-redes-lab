# =============================================================================
#  Norte Redes · Corrector de la Práctica 2 (Windows 10/11, cualquier edición)
#
#  Qué hace: revisa si has creado bien los grupos, usuarios y la directiva de
#  contraseñas de la práctica, y te dice qué está bien ([OK]), qué falta
#  ([FALTA]) y una pista.
#  IMPORTANTE: solo LEE la configuración. No cambia nada.
#
#  Cómo se usa (en PowerShell, dentro de la carpeta "windows"):
#     powershell -ExecutionPolicy Bypass -File .\Comprobar-NorteRedes.ps1
#  "-ExecutionPolicy Bypass" permite ejecutar este script descargado solo esta
#  vez, sin cambiar la configuración de Windows.
#
#  Temario relacionado: UF2 · Tema 01 · apartados 3.1 a 3.5 (usuarios, contraseñas,
#  perfiles, grupos y UAC en Windows).
# =============================================================================

# Si una orden falla de forma inesperada, el script se detiene en vez de seguir.
$ErrorActionPreference = 'Stop'

# -----------------------------------------------------------------------------
# 1. CONTADORES Y FUNCIONES DE AYUDA
# -----------------------------------------------------------------------------
# Llevamos la cuenta del nivel básico (PB de TB) y de los extra (PE de TE).
# "$script:" hace que la variable se pueda cambiar desde dentro de las funciones.
$script:Nivel = 'basico'; $script:PB = 0; $script:TB = 0; $script:PE = 0; $script:TE = 0

# Marca: pone una estrella delante de las comprobaciones extra.
function Marca { if ($script:Nivel -eq 'extra') { '★ ' } else { '' } }

# Ok "texto": suma un acierto y escribe [OK] en verde.
function Ok([string]$t)              { if ($script:Nivel -eq 'extra') { $script:PE++; $script:TE++ } else { $script:PB++; $script:TB++ }; Write-Host '  [OK]    ' -ForegroundColor Green -NoNewline; Write-Host ((Marca) + $t) }

# Ko "texto" "pista": suma un fallo, escribe [FALTA] en rojo y la pista en amarillo.
function Ko([string]$t, [string]$p)  { if ($script:Nivel -eq 'extra') { $script:TE++ } else { $script:TB++ }; Write-Host '  [FALTA] ' -ForegroundColor Red -NoNewline; Write-Host ((Marca) + $t); if ($p) { Write-Host "          Pista: $p" -ForegroundColor Yellow } }

# Nombre de este ordenador (por ejemplo, ASIR-WIN).
$Equipo = $env:COMPUTERNAME

# Info "texto": una nota en gris que no suma ni resta.
function Info([string]$t)            { Write-Host "  [i]     $t" -ForegroundColor DarkGray }

# Tramo "título": deja una línea en blanco y escribe el título en color.
function Tramo([string]$t)           { Write-Host ''; Write-Host $t -ForegroundColor Cyan }

# Usuario "nombre": devuelve el usuario local si existe; si no, nada.
function Usuario([string]$n) { Get-LocalUser -Name $n -ErrorAction SilentlyContinue }

# NombreDeSid: traduce un SID (identificador de seguridad) al nombre del grupo en
# el idioma de este Windows. Ejemplo: S-1-5-32-544 → "Administradores" (o
# "Administrators" en inglés). Así el script funciona en cualquier idioma.
function NombreDeSid([string]$sid) {
    (New-Object Security.Principal.SecurityIdentifier $sid).Translate([Security.Principal.NTAccount]).Value.Split('\')[-1]
}

# Miembros "grupo": lista los nombres de los miembros de un grupo local.
# Usa ADSI (una forma antigua de consultar cuentas) porque Get-LocalGroupMember
# falla cuando el grupo contiene cuentas que ya no existen.
function Miembros([string]$grupo) {
    try {
        $g = [ADSI]"WinNT://$Equipo/$grupo,group"
        @($g.Invoke('Members') | ForEach-Object { $_.GetType().InvokeMember('Name', 'GetProperty', $null, $_, $null) })
    } catch { @() }
}

# EnGrupo "usuario" "grupo": verdadero si el usuario es miembro del grupo.
function EnGrupo([string]$u, [string]$grupo) { (Miembros $grupo) -contains $u }

# Cabecera: nombre del equipo y fecha, útil para la captura de la entrega.
Write-Host "Norte Redes · Práctica 2   equipo: $Equipo · $(Get-Date -Format 'dd/MM/yyyy HH:mm')" -ForegroundColor White

# Nombres de los grupos Administradores y Usuarios en el idioma de este equipo.
$Admins   = NombreDeSid 'S-1-5-32-544'
$Usuarios = NombreDeSid 'S-1-5-32-545'

# -----------------------------------------------------------------------------
# 2. TRAMO A · GRUPOS Y USUARIOS                        (temario 3.1 y 3.4)
# -----------------------------------------------------------------------------
Tramo 'A · Grupos y usuarios'

# ¿Existen los tres grupos de departamento?
foreach ($g in 'Sistemas', 'Desarrollo', 'Comercial') {
    if (Get-LocalGroup -Name $g -ErrorAction SilentlyContinue) { Ok "Grupo $g" }
    else { Ko "Falta el grupo $g" "Créalo con New-LocalGroup" }
}

# Tabla usuario → grupo de su departamento.
$dept = [ordered]@{ ana = 'Sistemas'; luis = 'Desarrollo'; marta = 'Comercial' }

# Para cada usuario: ¿existe?, ¿está en su grupo?, ¿está en el grupo Usuarios?
foreach ($u in $dept.Keys) {
    if (-not (Usuario $u)) { Ko "Falta el usuario $u" "Créalo con New-LocalUser"; continue }
    Ok "Existe el usuario $u"
    if (EnGrupo $u $dept[$u]) { Ok "$u está en $($dept[$u])" }
    else { Ko "$u no está en $($dept[$u])" "Mételo en su grupo con Add-LocalGroupMember" }
    if (EnGrupo $u $Usuarios) { Ok "$u está en $Usuarios (puede iniciar sesión)" }
    else { Ko "$u no está en $($Usuarios), no podrá iniciar sesión" "Sin el grupo Usuarios no puede iniciar sesión" }
}

# ana tiene que estar en el grupo Administradores.
if (Usuario ana) {
    if (EnGrupo ana $Admins) { Ok "ana es administradora ($Admins)" }
    else { Ko 'ana no es administradora' 'Tiene que estar en el grupo Administradores' }
}

# -----------------------------------------------------------------------------
# 3. TRAMO B · DIRECTIVAS DE CUENTA                               (temario 3.2)
# -----------------------------------------------------------------------------
Tramo 'B · Directivas de cuenta (net accounts)'

# "net accounts" muestra la directiva de contraseñas. Escribe siempre las líneas
# en el mismo orden (en cualquier idioma):
#   1 cierre forzado, 2 duración mínima, 3 duración máxima, 4 longitud mínima,
#   5 historial, 6 umbral de bloqueo, 7 duración del bloqueo, 8 ventana, 9 rol
# Nos quedamos con lo que hay después de los dos puntos de cada línea.
$v = @(net accounts | Where-Object { $_ -match ':' } | ForEach-Object { ($_ -split ':')[-1].Trim() })

# Num "texto": convierte el texto en número; si no es un número (por ejemplo
# "Nunca"), devuelve 0.
function Num([string]$s) { $n = 0; if ([int]::TryParse($s, [ref]$n)) { $n } else { 0 } }

# Las listas empiezan a contar en 0: $v[3] es la línea 4 (longitud mínima), etc.
$min    = Num $v[3]
$max    = Num $v[2]
$fallos = Num $v[5]
$durac  = Num $v[6]
$vent   = Num $v[7]
if ($min -ge 12) { Ok "Longitud mínima: $min" } else { Ko "Longitud mínima: $min (se pide 12)" 'Mira las opciones de net accounts' }
if ($max -eq 90) { Ok 'Caducidad: 90 días' } else { Ko "Caducidad: $max días (se pide 90)" 'Mira las opciones de net accounts' }
if ($fallos -eq 5) { Ok 'Bloqueo tras 5 intentos' } else { Ko "Bloqueo tras $fallos intentos (se pide 5)" 'Mira las opciones de net accounts' }
if ($durac -eq 15) { Ok 'Duración del bloqueo: 15 min' } else { Ko "Duración del bloqueo: $durac min (se pide 15)" 'Mira las opciones de net accounts' }
if ($vent -eq 15) { Ok 'Ventana de observación: 15 min' } else { Ko "Ventana de observación: $vent min (se pide 15)" 'Mira las opciones de net accounts' }

# -----------------------------------------------------------------------------
# 4. EXTRA ★ (solo para quien termine antes)                      (temario 3.2)
# -----------------------------------------------------------------------------
Tramo '★ Extra · para quien termine antes'
$script:Nivel = 'extra'

# Si PasswordExpires está vacío ($null), la contraseña no caduca nunca.
if (Usuario ana) {
    if ($null -eq (Usuario ana).PasswordExpires) { Ok 'La contraseña de ana nunca expira' }
    else { Ko 'La contraseña de ana expira' 'Mira las opciones de Set-LocalUser' }
}

# PasswordExpired = 1 significa "debe cambiar la contraseña al iniciar sesión".
if (Usuario luis) {
    $exp = ([ADSI]"WinNT://$Equipo/luis,user").PasswordExpired.Value
    if ($exp -eq 1) { Ok 'luis deberá cambiar su contraseña al iniciar sesión' }
    else { Info 'luis ya cambió su contraseña o no se forzó el cambio (net user luis)' }
}

# UserMayChangePassword = falso significa "no puede cambiar su contraseña".
if (Usuario marta) {
    if (-not (Usuario marta).UserMayChangePassword) { Ok 'marta no puede cambiar su contraseña' }
    else { Ko 'marta puede cambiar su contraseña' 'Mira las opciones de net user' }
}

# El becario: debe existir, estar deshabilitado (Enabled = falso) y caducar el
# 31/12/2026. Se acepta un día de diferencia por cómo Windows guarda la hora.
$b = Usuario becario
if ($b) {
    Ok 'Existe el usuario becario'
    if (-not $b.Enabled) { Ok 'La cuenta de becario está deshabilitada' }
    else { Ko 'La cuenta de becario está habilitada' 'Hay una orden para deshabilitar cuentas' }
    $fin = Get-Date '2026-12-31'
    if ($b.AccountExpires -and [math]::Abs(($b.AccountExpires.Date - $fin.Date).TotalDays) -le 1) { Ok 'La cuenta caduca el 31/12/2026' }
    else { Ko "La cuenta de becario caduca: $($b.AccountExpires)" 'Revisa la fecha de caducidad de la cuenta' }
} else { Ko 'Falta el usuario becario' 'Créalo con New-LocalUser e indica cuándo caduca la cuenta' }

# -----------------------------------------------------------------------------
# 5. SEGURIDAD DEL SISTEMA                                   (temario 3.1 y 3.4)
# -----------------------------------------------------------------------------
Tramo 'Seguridad del sistema'
$script:Nivel = 'basico'

# El Administrador integrado es la cuenta cuyo SID acaba en -500. Lo normal es
# que esté deshabilitada; aquí solo informamos, no cuenta como fallo.
$adm = Get-LocalUser | Where-Object { $_.SID.Value -like '*-500' }
if (-not $adm.Enabled) { Ok "El Administrador integrado ($($adm.Name)) está deshabilitado" }
else { Info "El Administrador integrado ($($adm.Name)) está habilitado: en un equipo real conviene deshabilitarlo" }

# La cuenta Invitado (SID acabado en -501) debe estar deshabilitada.
$inv = Get-LocalUser | Where-Object { $_.SID.Value -like '*-501' }
if (-not $inv.Enabled) { Ok "La cuenta Invitado ($($inv.Name)) está deshabilitada" }
else { Ko "La cuenta Invitado ($($inv.Name)) está habilitada" "Esa cuenta debe estar deshabilitada" }

# Nadie de la plantilla, salvo ana, debe ser administrador.
foreach ($u in 'luis', 'marta', 'becario') {
    if ((Usuario $u) -and (EnGrupo $u $Admins)) { Ko "$u es administrador y no debería" "Solo ana debe ser administradora" }
}

# -----------------------------------------------------------------------------
# 6. RESULTADO FINAL
# -----------------------------------------------------------------------------
Write-Host ''
# Barra de progreso de 30 casillas: '#' para lo hecho y '.' para lo que falta.
$llenos = [int]($script:PB * 30 / [math]::Max(1, $script:TB))
$barra = ('#' * $llenos) + ('.' * (30 - $llenos))
Write-Host "Básico: $($script:PB) / $($script:TB)  [$barra] $([int]($script:PB * 100 / [math]::Max(1, $script:TB))) %" -ForegroundColor White
Write-Host "Extra ★: $($script:PE) / $($script:TE)" -ForegroundColor White
# NR_SALIDA solo lo usan las pruebas del profesor: guarda los números en un fichero.
if ($env:NR_SALIDA) { "$($script:PB) $($script:TB) $($script:PE) $($script:TE)" | Set-Content -Path $env:NR_SALIDA -Encoding ascii }
if ($script:PB -eq $script:TB) {
    Write-Host 'Práctica básica completa. Haz una captura para la entrega.' -ForegroundColor Green
    if ($script:PE -lt $script:TE) { Write-Host '¿Te sobra tiempo? Ve a por los extra ★.' }
} else { Write-Host 'Arregla lo que está en rojo y vuelve a ejecutar el corrector.' }
