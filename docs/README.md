# Capturas del dashboard

Esta carpeta guarda la evidencia visual de los casos de prueba manuales (TC-06, TC-10 a TC-16).

## Nombres de archivo

| Archivo | Qué debe mostrar | Caso que evidencia |
|---|---|---|
| `01-vista-general.png` | Página principal con los 4 KPIs y los filtros visibles | — |
| `02-evolucion-indice.png` | Línea del índice nacional 2016-2026 | TC-12 |
| `03-comparacion-regiones.png` | Comparación de las 7 regiones | TC-11 |
| `04-filtro-region.png` | Misma página con una región seleccionada | TC-11 |
| `05-tabla-validacion.png` | Tabla con `Var Mensual %`, `Variacion Oficial %` y `Dif vs Oficial pp` | TC-07 |
| `06-primer-mes.png` | KPI en 2016-12: variación vacía, no 0 % | TC-10 |
| `07-vista-movil.png` | Vista móvil del reporte | TC-16 |
| `08-error-noroeste.png` | Lo que pasa si se usa la serie oficial de Noroeste (visual vacío) | BUG-002 |

## Criterios

- Ancho mínimo 1200 px para las de escritorio.
- Que se lean los números: no comprimir de más.
- Las capturas de bugs van también referenciadas en el archivo del bug correspondiente en `/qa/bugs`.
