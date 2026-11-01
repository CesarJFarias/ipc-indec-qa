<#
.SYNOPSIS
    Ejecuta los casos de prueba de datos sobre el snapshot versionado en /data.

.DESCRIPTION
    Valida el CSV de indices contra el CSV de variaciones oficiales del INDEC.
    No usa red: sirve para correr en cada push o pull request.

    Codigos de salida:
      0 = todos los casos pasaron (puede haber advertencias)
      1 = al menos un caso fallo
      2 = no se encontraron los archivos de datos

.EXAMPLE
    pwsh ./scripts/validar-datos.ps1
    pwsh ./scripts/validar-datos.ps1 -ToleranciaPP 0.1
#>
[CmdletBinding()]
param(
    [double]$ToleranciaPP = 0.1,
    [string]$DataDir
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$inv = [System.Globalization.CultureInfo]::InvariantCulture

if (-not $DataDir) { $DataDir = Join-Path $PSScriptRoot '..\data' }
$rutaIndice = Join-Path $DataDir 'ipc-regiones-mensual.csv'
$rutaVar = Join-Path $DataDir 'ipc-variacion-oficial-mensual.csv'

foreach ($r in @($rutaIndice, $rutaVar)) {
    if (-not (Test-Path $r)) {
        Write-Error "Falta el archivo de datos: $r"
        exit 2
    }
}

function To-Double {
    param([string]$Texto)
    if ([string]::IsNullOrWhiteSpace($Texto)) { return $null }
    return [double]::Parse($Texto, [System.Globalization.NumberStyles]::Float, $inv)
}

$indices = Import-Csv -Path $rutaIndice -Encoding UTF8
$variaciones = Import-Csv -Path $rutaVar -Encoding UTF8

$fallos = 0
$advertencias = 0
$resultados = [System.Collections.Generic.List[string]]::new()

function Agregar-Resultado {
    param([string]$Id, [string]$Caso, [string]$Detalle, [string]$Estado)
    $script:resultados.Add(('| {0} | {1} | {2} | {3} |' -f $Id, $Caso, $Detalle, $Estado))
    if ($Estado -eq 'FALLA') { $script:fallos++ }
    if ($Estado -eq 'ADVERTENCIA') { $script:advertencias++ }
}

# ---------------------------------------------------------------- TC-01
$claves = $indices | ForEach-Object { "$($_.fecha)|$($_.region)" }
$duplicados = $claves.Count - ($claves | Select-Object -Unique).Count
if ($duplicados -eq 0) {
    Agregar-Resultado 'TC-01' 'Sin duplicados' "0 pares (fecha, region) repetidos de $($claves.Count)" 'PASA'
} else {
    Agregar-Resultado 'TC-01' 'Sin duplicados' "$duplicados pares repetidos" 'FALLA'
}

# ---------------------------------------------------------------- TC-02
$vacios = @($indices | Where-Object { [string]::IsNullOrWhiteSpace($_.indice) })
if ($vacios.Count -eq 0) {
    Agregar-Resultado 'TC-02' 'Sin indices vacios' "0 vacios en $($indices.Count) filas" 'PASA'
} else {
    Agregar-Resultado 'TC-02' 'Sin indices vacios' "$($vacios.Count) filas sin indice" 'FALLA'
}

# ---------------------------------------------------------------- TC-05
$invalidos = 0
foreach ($fila in $indices) {
    $fecha = [datetime]::MinValue
    $fechaOk = [datetime]::TryParseExact($fila.fecha, 'yyyy-MM-dd', $inv, [System.Globalization.DateTimeStyles]::None, [ref]$fecha)
    if (-not $fechaOk) { $invalidos++; continue }
    $valor = To-Double $fila.indice
    if ($null -eq $valor -or $valor -le 0) { $invalidos++ }
}
if ($invalidos -eq 0) {
    Agregar-Resultado 'TC-05' 'Tipos de dato' 'todas las fechas son ISO y los indices son decimales positivos' 'PASA'
} else {
    Agregar-Resultado 'TC-05' 'Tipos de dato' "$invalidos filas con fecha o indice invalido" 'FALLA'
}

# ---------------------------------------------------------------- TC-03
$porRegion = $indices | Group-Object region
$regionesConHuecos = @()
foreach ($grupo in $porRegion) {
    $fechas = $grupo.Group | ForEach-Object { [datetime]::ParseExact($_.fecha, 'yyyy-MM-dd', $inv) } | Sort-Object
    $esperados = @()
    $cursor = $fechas[0]
    while ($cursor -le $fechas[-1]) { $esperados += $cursor; $cursor = $cursor.AddMonths(1) }
    if ($esperados.Count -ne $fechas.Count) {
        $regionesConHuecos += "$($grupo.Name) ($($fechas.Count) de $($esperados.Count) meses)"
    }
}
if ($regionesConHuecos.Count -eq 0) {
    Agregar-Resultado 'TC-03' 'Meses continuos' "$($porRegion.Count) regiones sin huecos mensuales" 'PASA'
} else {
    Agregar-Resultado 'TC-03' 'Meses continuos' ($regionesConHuecos -join '; ') 'FALLA'
}

# ---------------------------------------------------------------- TC-07
$varPorRegion = $variaciones | Group-Object region
$detalleVar = [System.Collections.Generic.List[string]]::new()
$peorDif = 0.0
$peorRegion = ''
$peorMes = ''

foreach ($grupo in $porRegion) {
    $region = $grupo.Name
    $filas = $grupo.Group | Sort-Object fecha
    $oficial = @{}
    $filasVar = @($varPorRegion | Where-Object { $_.Name -eq $region } | ForEach-Object { $_.Group })
    foreach ($v in $filasVar) {
        $pct = To-Double $v.variacion_pct
        if ($null -ne $pct) { $oficial[$v.fecha] = $pct }
    }

    $comparados = 0
    $fueraTolerancia = 0
    $maxDif = 0.0
    $mesMax = ''
    for ($i = 1; $i -lt $filas.Count; $i++) {
        $anterior = To-Double $filas[$i - 1].indice
        $actual = To-Double $filas[$i].indice
        if ($null -eq $anterior -or $null -eq $actual -or $anterior -eq 0) { continue }
        if (-not $oficial.ContainsKey($filas[$i].fecha)) { continue }
        $calculado = ($actual - $anterior) / $anterior * 100
        $dif = [math]::Abs($calculado - $oficial[$filas[$i].fecha])
        $comparados++
        if ($dif -gt $maxDif) { $maxDif = $dif; $mesMax = $filas[$i].fecha }
        if ($dif -gt $ToleranciaPP) { $fueraTolerancia++ }
    }

    if ($comparados -eq 0) {
        $detalleVar.Add("$region`: sin serie oficial para comparar")
        continue
    }

    if ($maxDif -gt $peorDif) { $peorDif = $maxDif; $peorRegion = $region; $peorMes = $mesMax }

    if ($fueraTolerancia -eq 0) {
        $detalleVar.Add(('{0}: {1} meses, dif. max {2:N4} pp' -f $region, $comparados, $maxDif))
    } else {
        $detalleVar.Add(('{0}: {1} de {2} meses fuera de tolerancia (max {3:N4} pp en {4})' -f $region, $fueraTolerancia, $comparados, $maxDif, $mesMax))
    }
}

$detalleTexto = $detalleVar -join '; '
if ($peorDif -le $ToleranciaPP) {
    Agregar-Resultado 'TC-07' 'Variacion mensual vs INDEC' ('{0} | peor caso: {1} en {2} ({3:N4} pp)' -f $detalleTexto, $peorRegion, $peorMes, $peorDif) 'PASA'
} else {
    Agregar-Resultado 'TC-07' 'Variacion mensual vs INDEC' ('{0} | peor caso: {1} en {2} ({3:N4} pp)' -f $detalleTexto, $peorRegion, $peorMes, $peorDif) 'FALLA'
}

# Regiones del indice sin ninguna fila de variacion oficial
$regionesIndice = $porRegion | ForEach-Object { $_.Name }
$regionesVar = @($varPorRegion | ForEach-Object { $_.Name })
$faltantes = @($regionesIndice | Where-Object { $regionesVar -notcontains $_ })
if ($faltantes.Count -gt 0) {
    Agregar-Resultado 'TC-17' 'Cobertura de la serie oficial' ("sin variacion oficial: " + ($faltantes -join ', ')) 'ADVERTENCIA'
} else {
    Agregar-Resultado 'TC-17' 'Cobertura de la serie oficial' 'las 7 regiones tienen variacion oficial' 'PASA'
}

# ---------------------------------------------------------------- TC-04 (integridad del snapshot)
$anios = ($indices | ForEach-Object { ([datetime]::ParseExact($_.fecha, 'yyyy-MM-dd', $inv)).Year } | Sort-Object -Unique)
$lineasRegistro = Get-Content -Path (Join-Path $DataDir 'registro-descargas.md') -ErrorAction SilentlyContinue
$tieneRegistro = ($null -ne $lineasRegistro) -and @($lineasRegistro -match 'Fecha de descarga').Count -gt 0
if ($tieneRegistro) {
    Agregar-Resultado 'TC-04' 'Trazabilidad del snapshot' "registro de descarga presente; $($anios.Count) anios cubiertos ($($anios[0])-$($anios[-1]))" 'PASA'
} else {
    Agregar-Resultado 'TC-04' 'Trazabilidad del snapshot' 'falta data/registro-descargas.md' 'ADVERTENCIA'
}

# ---------------------------------------------------------------- Salida
$tabla = @"
| ID | Caso | Detalle | Estado |
|---|---|---|---|
$($resultados -join "`n")
"@

Write-Host ''
Write-Host $tabla
Write-Host ''
Write-Host ("Resumen: {0} fallas, {1} advertencias" -f $fallos, $advertencias)

if ($fallos -gt 0) { exit 1 }
exit 0
