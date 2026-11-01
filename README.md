# Dashboard de Inflación en Argentina (IPC INDEC) — Power BI + QA

Dashboard en Power BI sobre el Índice de Precios al Consumidor (IPC) del INDEC, con una capa de **validación de datos y pruebas** documentada en este repositorio.

> El objetivo del proyecto no es solo mostrar un dashboard, sino demostrar que sé **verificar que los números sean correctos** y reportar los problemas que encuentro en la fuente.

## Estado del proyecto

| Etapa | Estado |
|---|---|
| Extracción y limpieza de datos (7 regiones, 117 meses) | ✅ Listo |
| Validación automatizada de datos y cálculos | ✅ Listo — `scripts/validar-datos.ps1` |
| Documentación de QA y bugs encontrados | ✅ Listo — `/qa` |
| Medidas DAX documentadas | ✅ Listo — `medidas-dax.md` |
| Modelo y dashboard en Power BI Desktop | 🚧 En construcción |
| Capturas del dashboard | ⏳ Pendiente |

Los resultados documentados más abajo son de la **capa de datos**, no del dashboard, que todavía no está publicado.

## Fuente de datos

- API de Series de Tiempo de datos.gob.ar (publica series del INDEC, sin clave de acceso): `https://apis.datos.gob.ar/series/api/series/`
- Dataset 145 — *Índice de Precios al Consumidor Nacional (IPC). Base diciembre 2016.*
- Se usan las 7 regiones de la distribución 145.3 para que sean comparables entre sí:

| Región | Serie del índice | Serie de variación mensual oficial |
|---|---|---|
| Nacional | `145.3_INGNACNAL_DICI_M_15` | `145.3_INGNACUAL_DICI_M_38` |
| GBA | `145.3_INGGBAGBA_DICI_M_10` | `145.3_INGGBAUAL_DICI_M_33` |
| Cuyo | `145.3_INGCUYUYO_DICI_M_11` | `145.3_INGCUYUAL_DICI_M_34` |
| Noreste | `145.3_INGNEANEA_DICI_M_10` | `145.3_INGNEAUAL_DICI_M_33` |
| Noroeste | `145.3_INGNOANOA_DICI_M_10` | `145.3_INGNOAUAL_DICI_M_33` ⚠️ vacía |
| Pampeana | `145.3_INGPAMANA_DICI_M_15` | `145.3_INGPAMUAL_DICI_M_38` |
| Patagonia | `145.3_INGPATNIA_DICI_M_16` | `145.3_INGPATUAL_DICI_M_39` |

- Rango cubierto: **2016-12 a 2026-08** (117 meses por región).
- Último dato disponible al momento de la descarga: **agosto 2026**.
- Fecha de descarga y detalle de series: [`data/registro-descargas.md`](data/registro-descargas.md).

> Nota: la serie `148.3_INIVELNAL_DICI_M_26` que suele citarse para el nivel general nacional es un **duplicado** de `145.3_INGNACNAL_DICI_M_15` y no coincide en 2 de 117 meses. Ver [`qa/bugs/BUG-001`](qa/bugs/BUG-001-series-duplicadas-divergentes.md).

## Qué muestra el dashboard

- KPIs: inflación mensual, interanual y acumulada del año.
- Evolución del índice en el tiempo.
- Comparación entre las 7 regiones.
- Filtros por rango de fechas y región.

## Estructura del repositorio

```
/data          snapshots CSV generados por el script de descarga
/docs          capturas del dashboard
/qa            casos de prueba, resultados de ejecución y reportes de bugs
/scripts       descarga y validación reproducibles (PowerShell)
/dashboard     proyecto Power BI (PBIP: modelo y reporte como texto)
/.github       workflow que valida los datos en cada push
medidas-dax.md medidas DAX documentadas
```

## Proceso

1. **Extracción:** `scripts/descargar-datos.ps1` consulta la API (`format=json`) y escribe dos CSV en formato largo. Power Query usa los mismos endpoints para refrescar.
2. **Transformación:** tipos de dato, fechas al primer día del mes, formato largo (`fecha / región / índice`), sin inventar valores en los huecos.
3. **Modelo:** tabla de calendario + tabla de hechos `IPC`.
4. **Medidas DAX:** ver [`medidas-dax.md`](medidas-dax.md).
5. **Validación:** comparación de la variación mensual calculada contra la **variación mensual oficial que publica el INDEC**, con tolerancia de 0,1 punto porcentual. Ver [`qa/casos-de-prueba.md`](qa/casos-de-prueba.md).

## Resultados de la validación

Última ejecución: 2026-10-31 · `scripts/validar-datos.ps1` · **0 fallas, 1 advertencia**

| Qué | Resultado |
|---|---|
| Duplicados `(fecha, región)` | 0 de 819 filas |
| Índices vacíos | 0 de 819 filas |
| Meses faltantes por región | 0 en las 7 regiones |
| Variación mensual calculada vs. oficial | coincide en **666 de 666 meses comparables**; diferencia máxima **0,033 pp** (Cuyo, 2024-05) |
| Cobertura de la serie oficial | ⚠️ Noroeste no tiene serie de variación (ver BUG-002) |
| Bugs encontrados | 4 documentados en [`/qa/bugs`](qa/bugs) |

Detalle completo en [`qa/resultados-ejecucion.md`](qa/resultados-ejecucion.md).

Lo más relevante del resultado: en las 6 regiones con serie oficial comparable, la diferencia máxima fue de 0,033 pp contra el número publicado por el INDEC, muy por debajo de la tolerancia de 0,1 pp. La lógica de cálculo (índice actual / índice del mes anterior − 1) es correcta; los problemas están en la **fuente**, no en la fórmula.

## Bugs encontrados en la fuente

| ID | Problema | Severidad |
|---|---|---|
| [BUG-001](qa/bugs/BUG-001-series-duplicadas-divergentes.md) | Dos series "Nivel General Nacional" con valores distintos en 2 meses | Media |
| [BUG-002](qa/bugs/BUG-002-noroeste-variacion-vacia.md) | La serie de variación mensual de Noroeste devuelve 0 filas aunque su metadata declara datos | Alta |
| [BUG-003](qa/bugs/BUG-003-cuyo-variacion-incompleta.md) | La serie de variación de Cuyo arranca en 2019-07 y no en 2017-01: faltan 30 meses | Media |
| [BUG-004](qa/bugs/BUG-004-precision-inconsistente-variacion.md) | 6 valores de variación oficial vienen redondeados a 1 decimal y el resto a 6 | Baja |

## Cómo reproducir

Requiere PowerShell 5.1 o superior (viene con Windows).

```powershell
# Descargar los datos actuales de la API
./scripts/descargar-datos.ps1

# Ejecutar los casos de prueba sobre el snapshot
./scripts/validar-datos.ps1
```

El validador devuelve código de salida 1 si algún caso falla, así que se puede usar en CI. El workflow [`.github/workflows/qa-datos.yml`](.github/workflows/qa-datos.yml) lo ejecuta en cada push.

## Conclusiones

Con datos a agosto 2026:

- La inflación mensual nacional fue **1,66%**, la interanual **33,54%** y la acumulada de 2026 **21,30%** (contra 31,55% acumulado en todo 2025).
- La región con mayor inflación interanual es **Noreste (36,99%)** y la menor **Patagonia (31,60%)**: 5,4 puntos de diferencia entre extremos.
- La acumulada del año muestra la misma brecha: Noreste 24,44% contra Patagonia 19,56%.
- Las 7 regiones comparten base diciembre 2016 = 100, así que el nivel del índice es comparable directo: todas están entre 12.224 y 12.405 puntos.

## Limitaciones

- Los datos dependen de lo que publica el INDEC y pueden ser revisados hacia atrás sin aviso; el snapshot queda fechado para poder auditarlo.
- El diseño del dashboard y las capturas están pendientes: por ahora el repositorio documenta la capa de datos y su validación.
- La comparación automática cubre la variación mensual. Interanual y acumulada se validan a mano en `qa/resultados-ejecucion.md`.
- Proyecto con fines de portfolio, no es un análisis económico oficial.

## Licencia y atribución

- Código y documentación: [MIT](LICENSE).
- Datos: elaborados por el **INDEC** y publicados por datos.gob.ar bajo licencia [Creative Commons Atribución 4.0](https://creativecommons.org/licenses/by/4.0/deed.es). Este repositorio no modifica los valores: solo los reorganiza y los cita.

## Autor

Cesar Farias — QA en formación · Mendoza, Argentina
