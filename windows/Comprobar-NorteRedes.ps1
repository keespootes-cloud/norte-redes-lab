# =============================================================================
#  Norte Redes · Corrector de la Práctica 2 (Windows 10/11, cualquier edición)
#  Solo LEE la configuración: no cambia nada.
#  Uso (PowerShell):
#     powershell -ExecutionPolicy Bypass -File .\Comprobar-NorteRedes.ps1
# =============================================================================
$ErrorActionPreference = 'Stop'
# Nivel básico (obligatorio) y extra (★, para quien termine antes)
$script:Nivel = 'basico'; $script:PB = 0; $script:TB = 0; $script:PE = 0; $script:TE = 0
function Marca { if ($script:Nivel -eq 'extra') { '★ ' } else { '' } }
function Ok([string]$t)              { if ($script:Nivel -eq 'extra') { $script:PE++; $script:TE++ } else { $script:PB++; $script:TB++ }; Write-Host '  [OK]    ' -ForegroundColor Green -NoNewline; Write-Host ((Marca) + $t) }
function Ko([string]$t, [string]$p)  { if ($script:Nivel -eq 'extra') { $script:TE++ } else { $script:TB++ }; Write-Host '  [FALTA] ' -ForegroundColor Red -NoNewline; Write-Host ((Marca) + $t); if ($p) { Write-Host "          Pista: $p" -ForegroundColor Yellow } }
$Equipo = $env:COMPUTERNAME

function Info([string]$t)            { Write-Host "  [i]     $t" -ForegroundColor DarkGray }
function Tramo([string]$t)           { Write-Host ''; Write-Host $t -ForegroundColor Cyan }

function Usuario([string]$n) { Get-LocalUser -Name $n -ErrorAction SilentlyContinue }
function NombreDeSid([string]$sid) {
    (New-Object Security.Principal.SecurityIdentifier $sid).Translate([Security.Principal.NTAccount]).Value.Split('\')[-1]
}
function Miembros([string]$grupo) {
    # ADSI en vez de Get-LocalGroupMember: este falla si el grupo tiene SID huérfanos
    try {
        $g = [ADSI]"WinNT://$Equipo/$grupo,group"
        @($g.Invoke('Members') | ForEach-Object { $_.GetType().InvokeMember('Name', 'GetProperty', $null, $_, $null) })
    } catch { @() }
}
function EnGrupo([string]$u, [string]$grupo) { (Miembros $grupo) -contains $u }

Write-Host "Norte Redes · Práctica 2   equipo: $Equipo · $(Get-Date -Format 'dd/MM/yyyy HH:mm')" -ForegroundColor White

$Admins   = NombreDeSid 'S-1-5-32-544'
$Usuarios = NombreDeSid 'S-1-5-32-545'


# --- Grupos y usuarios -------------------------------------------------------
Tramo 'A · Grupos y usuarios'
foreach ($g in 'Sistemas', 'Desarrollo', 'Comercial') {
    if (Get-LocalGroup -Name $g -ErrorAction SilentlyContinue) { Ok "Grupo $g" }
    else { Ko "Falta el grupo $g" "Créalo con New-LocalGroup" }
}
$dept = [ordered]@{ ana = 'Sistemas'; luis = 'Desarrollo'; marta = 'Comercial' }
foreach ($u in $dept.Keys) {
    if (-not (Usuario $u)) { Ko "Falta el usuario $u" "Créalo con New-LocalUser"; continue }
    Ok "Existe el usuario $u"
    if (EnGrupo $u $dept[$u]) { Ok "$u está en $($dept[$u])" }
    else { Ko "$u no está en $($dept[$u])" "Mételo en su grupo con Add-LocalGroupMember" }
    if (EnGrupo $u $Usuarios) { Ok "$u está en $Usuarios (puede iniciar sesión)" }
    else { Ko "$u no está en $($Usuarios), no podrá iniciar sesión" "Sin el grupo Usuarios no puede iniciar sesión" }
}

# --- Administradora ----------------------------------------------------------
if (Usuario ana) {
    if (EnGrupo ana $Admins) { Ok "ana es administradora ($Admins)" }
    else { Ko 'ana no es administradora' 'Tiene que estar en el grupo Administradores' }
}

# --- Directivas de cuenta ------------------------------------------------------
Tramo 'B · Directivas de cuenta (net accounts)'
# net accounts escribe siempre las líneas en el mismo orden, en cualquier idioma:
# 1 cierre forzado, 2 duración mín., 3 duración máx., 4 longitud mín., 5 historial,
# 6 umbral de bloqueo, 7 duración del bloqueo, 8 ventana de observación, 9 rol
$v = @(net accounts | Where-Object { $_ -match ':' } | ForEach-Object { ($_ -split ':')[-1].Trim() })
function Num([string]$s) { $n = 0; if ([int]::TryParse($s, [ref]$n)) { $n } else { 0 } }
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

# --- Extra ★ ---------------------------------------------------------------------
Tramo '★ Extra · para quien termine antes'
$script:Nivel = 'extra'
if (Usuario ana) {
    if ($null -eq (Usuario ana).PasswordExpires) { Ok 'La contraseña de ana nunca expira' }
    else { Ko 'La contraseña de ana expira' 'Mira las opciones de Set-LocalUser' }
}
if (Usuario luis) {
    $exp = ([ADSI]"WinNT://$Equipo/luis,user").PasswordExpired.Value
    if ($exp -eq 1) { Ok 'luis deberá cambiar su contraseña al iniciar sesión' }
    else { Info 'luis ya cambió su contraseña o no se forzó el cambio (net user luis)' }
}
if (Usuario marta) {
    if (-not (Usuario marta).UserMayChangePassword) { Ok 'marta no puede cambiar su contraseña' }
    else { Ko 'marta puede cambiar su contraseña' 'Mira las opciones de net user' }
}
$b = Usuario becario
if ($b) {
    Ok 'Existe el usuario becario'
    if (-not $b.Enabled) { Ok 'La cuenta de becario está deshabilitada' }
    else { Ko 'La cuenta de becario está habilitada' 'Hay una orden para deshabilitar cuentas' }
    $fin = Get-Date '2026-12-31'
    if ($b.AccountExpires -and [math]::Abs(($b.AccountExpires.Date - $fin.Date).TotalDays) -le 1) { Ok 'La cuenta caduca el 31/12/2026' }
    else { Ko "La cuenta de becario caduca: $($b.AccountExpires)" 'Revisa la fecha de caducidad de la cuenta' }
} else { Ko 'Falta el usuario becario' 'Créalo con New-LocalUser e indica cuándo caduca la cuenta' }

# --- Seguridad -------------------------------------------------------------------
Tramo 'Seguridad del sistema'
$script:Nivel = 'basico'
$adm = Get-LocalUser | Where-Object { $_.SID.Value -like '*-500' }
if (-not $adm.Enabled) { Ok "El Administrador integrado ($($adm.Name)) está deshabilitado" }
else { Info "El Administrador integrado ($($adm.Name)) está habilitado: en un equipo real conviene deshabilitarlo" }
$inv = Get-LocalUser | Where-Object { $_.SID.Value -like '*-501' }
if (-not $inv.Enabled) { Ok "La cuenta Invitado ($($inv.Name)) está deshabilitada" }
else { Ko "La cuenta Invitado ($($inv.Name)) está habilitada" "Esa cuenta debe estar deshabilitada" }
foreach ($u in 'luis', 'marta', 'becario') {
    if ((Usuario $u) -and (EnGrupo $u $Admins)) { Ko "$u es administrador y no debería" "Solo ana debe ser administradora" }
}

# --- Resultado -----------------------------------------------------------------
Write-Host ''
$llenos = [int]($script:PB * 30 / [math]::Max(1, $script:TB))
$barra = ('#' * $llenos) + ('.' * (30 - $llenos))
Write-Host "Básico: $($script:PB) / $($script:TB)  [$barra] $([int]($script:PB * 100 / [math]::Max(1, $script:TB))) %" -ForegroundColor White
Write-Host "Extra ★: $($script:PE) / $($script:TE)" -ForegroundColor White
if ($env:NR_SALIDA) { "$($script:PB) $($script:TB) $($script:PE) $($script:TE)" | Set-Content -Path $env:NR_SALIDA -Encoding ascii }  # solo para las pruebas automáticas
if ($script:PB -eq $script:TB) {
    Write-Host 'Práctica básica completa. Haz una captura para la entrega.' -ForegroundColor Green
    if ($script:PE -lt $script:TE) { Write-Host '¿Te sobra tiempo? Ve a por los extra ★.' }
} else { Write-Host 'Arregla lo que está en rojo y vuelve a ejecutar el corrector.' }
