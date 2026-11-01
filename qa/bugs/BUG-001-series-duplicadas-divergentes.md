# BUG-001 — Dos series "IPC Nivel General Nacional" con valores distintos

| | |
|---|---|
| **Severidad** | Media |
| **Ambiente** | API datos.gob.ar, consultada el 2026-10-31 |
| **Componente** | Dataset 145, distribución 145.3 vs 145.9 |
| **Estado** | Abierto |

## Descripción

La API publica dos series con la **misma descripción** ("IPC. Nivel General Nacional. Base dic 2016. Mensual.") pero con **IDs distintos** y valores que no coinciden:

- `145.3_INGNACNAL_DICI_M_15`
- `148.3_INIVELNAL_DICI_M_26`

De 117 meses comparados, **2 difieren**:

| Fecha | `145.3_INGNACNAL` | `148.3_INIVELNAL` | Diferencia relativa |
|---|---|---|---|
| 2019-04 | 213,0517 | 212,9596414 | 0,043 % |
| 2024-05 | 6073,7165 | 6073,7000 | 0,0003 % |

## Pasos para reproducir

1. Consultar `https://apis.datos.gob.ar/series/api/series/?ids=145.3_INGNACNAL_DICI_M_15&format=json&limit=1000&sort=asc`
2. Consultar `https://apis.datos.gob.ar/series/api/series/?ids=148.3_INIVELNAL_DICI_M_26&format=json&limit=1000&sort=asc`
3. Comparar fila por fila.

O en el repo:

```powershell
./scripts/validar-datos.ps1   # usa solo la familia 145.3
```

## Resultado esperado

Series con la misma descripción y el mismo período devuelven los mismos valores.

## Resultado actual

Divergen en 2019-04 y 2024-05. La metadata tampoco permite distinguirlas: ambas declaran la misma fuente (INDEC) y la misma unidad (índice base dic 2016).

## Impacto

Un usuario que arme un tablero mezclando series de ambas distribuciones obtiene **dos variaciones mensuales distintas para 2019-04**:

- calculada con `145.3`: **3,4447 %**
- calculada con `148.3`: **3,4000 %**

La diferencia es de 0,0447 pp: menor que la tolerancia de 0,1 pp, así que no rompe la validación, pero es una inconsistencia real de la fuente.

## Acción tomada

- El modelo usa **una sola familia** (`145.3_*`) para las 7 regiones, de modo que todas las comparaciones sean sobre la misma base.
- La serie `148.3_INIVELNAL_DICI_M_26` queda documentada pero fuera del modelo.
- Se agrega al README una nota para quien llegue desde otros tutoriales que citan `148.3`.
