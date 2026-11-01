# Datos

Snapshots generados por `../scripts/descargar-datos.ps1`. No se editan a mano.

| Archivo | Columnas | Filas | Descripción |
|---|---|---|---|
| `ipc-regiones-mensual.csv` | `fecha,region,indice` | 819 | IPC nivel general por región, base dic 2016 = 100 |
| `ipc-variacion-oficial-mensual.csv` | `fecha,region,variacion_pct` | 666 | Variación mensual **publicada por el INDEC**, en porcentaje |
| `registro-descargas.md` | — | — | Fecha de descarga, IDs de serie y cantidad de filas |

## Convenciones

- `fecha`: primer día del mes, formato ISO `AAAA-MM-DD`.
- `indice`: número decimal con punto como separador decimal (formato invariante).
- `variacion_pct`: ya viene multiplicado por 100 (`4.176266` = 4,176266 %).
- Los valores faltantes se escriben como **campo vacío**, nunca como `0`. Un 0 en un índice de precios es un dato imposible y ocultaría el hueco.
- Codificación UTF-8 sin BOM, fin de línea LF.

## Por qué hay dos archivos

El primero es la tabla de hechos del modelo. El segundo es el **oráculo de validación**: la tasa que el INDEC publica para cada mes y región. Comparar el cálculo propio contra el número oficial es lo que convierte "el dashboard se ve bien" en "el dashboard es correcto".

Por eso `VariacionOficial` no se usa en los visuales del reporte: si se usara, se estaría mostrando el resultado en lugar de comprobarlo.
