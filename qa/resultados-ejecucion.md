# Resultados de ejecución — QA de datos

## Ambiente

| | |
|---|---|
| Fecha de ejecución | 2026-10-31 |
| Sistema | Windows 11 |
| Motor | PowerShell 5.1 |
| Script | `scripts/validar-datos.ps1` |
| Snapshot | `data/ipc-regiones-mensual.csv` — 819 filas, 2016-12 a 2026-08 |
| Datos oficiales | `data/ipc-variacion-oficial-mensual.csv` — 666 filas |
| Tolerancia | 0,1 punto porcentual |

## Comando

```powershell
./scripts/validar-datos.ps1
```

## Salida

| ID | Caso | Detalle | Estado |
|---|---|---|---|
| TC-01 | Sin duplicados | 0 pares (fecha, region) repetidos de 819 | PASA |
| TC-02 | Sin indices vacios | 0 vacios en 819 filas | PASA |
| TC-05 | Tipos de dato | todas las fechas son ISO y los indices son decimales positivos | PASA |
| TC-03 | Meses continuos | 7 regiones sin huecos mensuales | PASA |
| TC-07 | Variacion mensual vs INDEC | Nacional: 116 meses, dif. max 0,0237 pp; GBA: 116 meses, dif. max 0,0044 pp; Cuyo: 86 meses, dif. max 0,0330 pp; Noreste: 116 meses, dif. max 0,0308 pp; Noroeste: sin serie oficial para comparar; Pampeana: 116 meses, dif. max 0,0159 pp; Patagonia: 116 meses, dif. max 0,0203 pp | PASA |
| TC-17 | Cobertura de la serie oficial | sin variacion oficial: Noroeste | ADVERTENCIA |
| TC-04 | Trazabilidad del snapshot | registro de descarga presente; 11 anios cubiertos (2016-2026) | PASA |

**Resumen: 0 fallas, 1 advertencia.** Código de salida: `0`.

## Interpretación

- **TC-07** es el caso central: compara la variación calculada a partir del índice contra la tasa de variación que publica el INDEC. Se compararon 666 meses-región y la diferencia máxima fue de 0,033 pp, muy por debajo de la tolerancia. La fórmula de cálculo es correcta.
- Las diferencias máximas se concentran en **2024-05** en 5 de las 6 regiones. La causa está identificada: en ese mes las series de variación oficial devuelven el valor redondeado (por ejemplo `4.2` para Nacional) mientras que los otros 660 valores traen 6 decimales. La variación recalculada con el índice da 4,1763 % y la publicada 4,2 %, de ahí los 0,0237 pp. Ver [BUG-004](bugs/BUG-004-precision-inconsistente-variacion.md).
- **TC-17** es la advertencia: Noroeste tiene índice pero no variación oficial. No es un fallo de este proyecto, es un hueco de la fuente (BUG-002).

## Casos manuales pendientes

| ID | Caso | Por qué queda pendiente |
|---|---|---|
| TC-06 | Último mes | Necesita el visual `Ultimo Mes` en el dashboard |
| TC-08 | Variación interanual | Validación manual contra 3 meses publicados |
| TC-09 | Acumulada del año | Validación manual del cálculo |
| TC-10 | Primer mes | Comportamiento visual del vacío en el KPI |
| TC-11 a TC-16 | Interfaz y filtros | Requieren el reporte publicado |

Al publicarse el dashboard, esta sección se completa con la evidencia de cada caso.
