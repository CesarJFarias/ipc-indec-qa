# BUG-004 — Precisión inconsistente en la serie de variación oficial

| | |
|---|---|
| **Severidad** | Baja |
| **Ambiente** | API datos.gob.ar, consultada el 2026-10-31 |
| **Componente** | Series `145.3_ING*UAL_*` (variación mensual oficial) |
| **Estado** | Abierto (documentado, no bloquea) |

## Descripción

De los 666 valores de variación mensual oficial, **660 traen 6 decimales** (por ejemplo `4.176266`) y **6 traen 1 decimal o menos**: todos corresponden a **2024-05**, uno por región.

| Región | Valor oficial 2024-05 | Variación recalculada desde el índice | Diferencia |
|---|---|---|---|
| Nacional | 4,2 | 4,1763 % | 0,0237 pp |
| GBA | 4,3 | — | ≤ 0,03 pp |
| Cuyo | 4,3 | — | 0,0330 pp |
| Noreste | 3,7 | — | 0,0308 pp |
| Pampeana | 4,0 | — | 0,0159 pp |
| Patagonia | 4,5 | — | 0,0203 pp |

Es el mismo mes en que se registran las **diferencias máximas de TC-07** en 5 de las 6 regiones.

## Pasos para reproducir

1. Consultar `data/ipc-variacion-oficial-mensual.csv`.
2. Filtrar `fecha = 2024-05-01` y mirar `variacion_pct`.
3. Comparar con cualquier otro mes: el resto tiene 6 decimales.

## Resultado esperado

Precisión uniforme en toda la serie.

## Resultado actual

Un mes con el valor ya redondeado (el número que se publicó en el informe), el resto con precisión completa. La serie mezcla dos criterios de redondeo.

## Impacto

- Explica el error residual de TC-07 y justifica que la tolerancia sea de 0,1 pp en lugar de exigir coincidencia exacta.
- Un test que compare con igualdad exacta fallaría en 2024-05 sin que haya un error de cálculo real. Es el típico caso que hace que alguien desactive un test en lugar de entenderlo.

## Acción tomada

- La tolerancia de TC-07 se documenta como criterio (ver `qa/casos-de-prueba.md`), no como un número arbitrario.
- `qa/resultados-ejecucion.md` deja registrada la causa de las diferencias máximas.
- No se corrige el dato en el snapshot: se guarda tal como lo publica la fuente.
