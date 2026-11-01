# Casos de prueba — Dashboard IPC

Ambiente: Windows · PowerShell 5.1 · datos descargados el 2026-10-31
Snapshot validado: `data/ipc-regiones-mensual.csv` (819 filas), `data/ipc-variacion-oficial-mensual.csv`

Los casos marcados como **automático** los ejecuta `scripts/validar-datos.ps1`.
Los marcados como **manual** requieren el dashboard en Power BI Desktop y quedan pendientes hasta que esté publicado.

## Datos (fuente y transformación)

| ID | Caso | Pasos | Resultado esperado | Tipo | Estado |
|---|---|---|---|---|---|
| TC-01 | Sin duplicados | Contar filas por `(fecha, region)` en `IPC` | Ningún par repetido | Automático | ✅ Pasa — 0 de 819 |
| TC-02 | Sin nulos en el índice | Contar filas con `indice` vacío | 0 | Automático | ✅ Pasa — 0 de 819 |
| TC-03 | Fechas continuas | Verificar que no falten meses entre la primera y la última fecha, por región | Un registro por mes | Automático | ✅ Pasa — 7 regiones sin huecos |
| TC-04 | Datos crudos intactos | Comparar `/data` con la respuesta actual de la API | Mismos valores, o diferencias explicadas por revisiones del INDEC | Automático (parcial) | ✅ Pasa — registro de descarga presente |
| TC-05 | Tipos de dato | Verificar que la fecha es fecha e `indice` es decimal | Tipos correctos | Automático | ✅ Pasa — 819 filas válidas |

## Cálculos

| ID | Caso | Pasos | Resultado esperado | Tipo | Estado |
|---|---|---|---|---|---|
| TC-06 | Último mes | Comparar `Ultimo Mes` con el último informe del INDEC | Mismo mes (2026-08) | Manual | ⏳ Pendiente |
| TC-07 | Variación mensual | Comparar `Var Mensual %` contra la serie oficial de variación mensual del INDEC | Diferencia menor a 0,1 pp | Automático | ✅ Pasa — 666 meses, máximo 0,033 pp |
| TC-08 | Variación interanual | Elegir 3 meses y comparar contra el valor publicado | Diferencia menor a 0,1 pp | Manual | ⏳ Pendiente |
| TC-09 | Acumulada del año | Calcular a mano `(índice actual / índice de dic anterior) − 1` | Coincide con la medida | Manual | ⏳ Pendiente |
| TC-10 | Primer mes de la serie | Ver la variación mensual de 2016-12 | Vacío, sin error ni 0 % falso | Manual | ⏳ Pendiente |
| TC-17 | Cobertura de la serie oficial | Verificar que cada región tenga serie de variación oficial | Las 7 regiones con datos | Automático | ⚠️ Advertencia — Noroeste sin datos (BUG-002) |

## Interfaz y filtros

| ID | Caso | Pasos | Resultado esperado | Tipo | Estado |
|---|---|---|---|---|---|
| TC-11 | Filtro por región | Seleccionar cada región | Todos los visuales se actualizan | Manual | ⏳ Pendiente |
| TC-12 | Filtro por fechas | Acotar a un solo año | KPIs y gráficos coinciden con ese rango | Manual | ⏳ Pendiente |
| TC-13 | Combinación de filtros | Región + rango de fechas | No aparece un gráfico vacío sin explicación | Manual | ⏳ Pendiente |
| TC-14 | Formato numérico | Revisar decimales y símbolo % | Consistente en todo el reporte | Manual | ⏳ Pendiente |
| TC-15 | Actualización | Actualizar los datos desde la API | Sin errores, valores consistentes | Manual | ⏳ Pendiente |
| TC-16 | Diseño en celular | Ver la vista móvil | Legible y sin elementos cortados | Manual | ⏳ Pendiente |

## Criterio de tolerancia

La tolerancia de **0,1 punto porcentual** no es arbitraria: el INDEC publica la variación redondeada a 1 decimal, así que el valor recalculado desde el índice siempre difiere un poco. Una diferencia mayor a 0,1 pp sí indicaría un error de cálculo, de período o de serie equivocada.
