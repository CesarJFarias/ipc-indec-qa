<#
.SYNOPSIS
    Descarga las series del IPC (INDEC) desde la API de datos.gob.ar y genera
    los CSV versionados en /data.

.DESCRIPTION
    Genera dos archivos:
      data/ipc-regiones-mensual.csv            fecha,region,indice
      data/ipc-variacion-oficial-mensual.csv   fecha,region,variacion_pct
    y deja constancia de la descarga en data/registro-descargas.md.

    No modifica los valores que publica el INDEC: solo los ordena en formato
    largo. Los vacios se escriben como campo vacio, nunca como 0.

.EXAMPLE
    pwsh ./scripts/descargar-datos.ps1
    pwsh ./scripts/descargar-datos.ps1 -OutDir C:\temp\data
#>
[CmdletBinding()]
param(
    [string]$OutDir
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$inv = [System.Globalization.CultureInfo]::InvariantCulture
$ApiBase = 'https://apis.datos.gob.ar/series/api/series/'
$UrlSerie = $ApiBase + '?ids={0}&format=json&limit=1000&sort=asc'

if (-not $OutDir) { $OutDir = Join-Path $PSScriptRoot '..\data' }
$OutDir = [System.IO.Path]::GetFullPath($OutDir)
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

# Una sola familia de series (distribucion 145.3) para que las 7 regiones sean
# comparables entre si. Ver qa/bugs/BUG-001 para el caso de las series duplicadas.
$Regiones = [ordered]@{
    'Nacional'  = @{ Indice = '145.3_INGNACNAL_DICI_M_15'; Variacion = '145.3_INGNACUAL_DICI_M_38' }
    'GBA'       = @{ Indice = '145.3_INGGBAGBA_DICI_M_10'; Variacion = '145.3_INGGBAUAL_DICI_M_33' }
    'Cuyo'      = @{ Indice = '145.3_INGCUYUYO_DICI_M_11'; Variacion = '145.3_INGCUYUAL_DICI_M_34' }
    'Noreste'   = @{ Indice = '145.3_INGNEANEA_DICI_M_10'; Variacion = '145.3_INGNEAUAL_DICI_M_33' }
    'Noroeste'  = @{ Indice = '145.3_INGNOANOA_DICI_M_10'; Variacion = '145.3_INGNOAUAL_DICI_M_33' }
    'Pampeana'  = @{ Indice = '145.3_INGPAMANA_DICI_M_15'; Variacion = '145.3_INGPAMUAL_DICI_M_38' }
    'Patagonia' = @{ Indice = '145.3_INGPATNIA_DICI_M_16'; Variacion = '145.3_INGPATUAL_DICI_M_39' }
}

function Get-Serie {
    param([Parameter(Mandatory)][string]$Id)

    $resp = Invoke-RestMethod -Uri ($UrlSerie -f $Id) -Headers @{ Accept = 'application/json' }

    $filas = @()
    if ($null -ne $resp.data) {
        foreach ($fila in $resp.data) {
            $valor = $null
            if ($fila.Count -gt 1 -and $null -ne $fila[1]) { $valor = [double]$fila[1] }
            $filas += [pscustomobject]@{ Fecha = [string]$fila[0]; Valor = $valor }
        }
    }
    Write-Output -NoEnumerate $filas
}

function Format-Valor {
    param([AllowNull()]$Valor, [string]$Formato)
    if ($null -eq $Valor) { return '' }
    return ([double]$Valor).ToString($Formato, $inv)
}

$lineasIndice = [System.Collections.Generic.List[string]]::new()
$lineasIndice.Add('fecha,region,indice')

$lineasVariacion = [System.Collections.Generic.List[string]]::new()
$lineasVariacion.Add('fecha,region,variacion_pct')

$bitacora = [System.Collections.Generic.List[string]]::new()
$ultimoMes = $null
$primeraFecha = $null

foreach ($nombre in $Regiones.Keys) {
    $idIndice = $Regiones[$nombre].Indice
    $idVar = $Regiones[$nombre].Variacion

    $serie = Get-Serie -Id $idIndice
    foreach ($p in $serie) {
        $lineasIndice.Add(('{0},{1},{2}' -f $p.Fecha, $nombre, (Format-Valor $p.Valor '0.############')))
        if ($null -eq $primeraFecha -or $p.Fecha -lt $primeraFecha) { $primeraFecha = $p.Fecha }
        if ($null -eq $ultimoMes -or $p.Fecha -gt $ultimoMes) { $ultimoMes = $p.Fecha }
    }

    Start-Sleep -Milliseconds 200
    $serieVar = Get-Serie -Id $idVar
    foreach ($p in $serieVar) {
        $pct = $null
        if ($null -ne $p.Valor) { $pct = [double]$p.Valor * 100 }
        $lineasVariacion.Add(('{0},{1},{2}' -f $p.Fecha, $nombre, (Format-Valor $pct '0.######')))
    }

    $bitacora.Add(('| {0} | `{1}` | {2} | `{3}` | {4} |' -f $nombre, $idIndice, $serie.Count, $idVar, $serieVar.Count))

    Write-Host ('{0,-10} indice: {1,3} filas   variacion oficial: {2,3} filas' -f $nombre, $serie.Count, $serieVar.Count)
    Start-Sleep -Milliseconds 200
}

$txtIndice = $lineasIndice -join "`n"
$txtVariacion = $lineasVariacion -join "`n"

$utf8 = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText((Join-Path $OutDir 'ipc-regiones-mensual.csv'), $txtIndice + "`n", $utf8)
[System.IO.File]::WriteAllText((Join-Path $OutDir 'ipc-variacion-oficial-mensual.csv'), $txtVariacion + "`n", $utf8)

$ahora = (Get-Date).ToString('yyyy-MM-dd HH:mm', $inv)
$registro = @"
# Registro de descargas

Generado por ``scripts/descargar-datos.ps1``.

- Fecha de descarga: $ahora (hora local)
- Fuente: API de Series de Tiempo de datos.gob.ar
- Endpoint: ``$ApiBase``
- Rango cubierto: $primeraFecha a $ultimoMes
- Los vacios se escriben como campo vacio, nunca como 0.

## Series usadas

| Region | ID indice | Filas | ID variacion oficial | Filas |
|---|---|---|---|---|
$($bitacora -join "`n")

## Notas

- Las 7 regiones salen de la distribucion 145.3 del dataset 145, para que sean comparables entre si.
- La serie de variacion oficial de Noroeste devuelve 0 filas aunque su metadata declara datos (ver qa/bugs/BUG-002).
- La serie de variacion oficial de Cuyo arranca en 2019-07, no en 2017-01 como las demas (ver qa/bugs/BUG-003).
"@

$utf8 = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText((Join-Path $OutDir 'registro-descargas.md'), $registro + "`n", $utf8)

Write-Host ''
Write-Host "Listo. Archivos en $OutDir"
Write-Host "Rango: $primeraFecha a $ultimoMes"
