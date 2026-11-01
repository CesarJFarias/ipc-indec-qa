# Registro de descargas

Generado por `scripts/descargar-datos.ps1`.

- Fecha de descarga: 2026-10-31 22:52 (hora local)
- Fuente: API de Series de Tiempo de datos.gob.ar
- Endpoint: `https://apis.datos.gob.ar/series/api/series/`
- Rango cubierto: 2016-12-01 a 2026-08-01
- Los vacios se escriben como campo vacio, nunca como 0.

## Series usadas

| Region | ID indice | Filas | ID variacion oficial | Filas |
|---|---|---|---|---|
| Nacional | `145.3_INGNACNAL_DICI_M_15` | 117 | `145.3_INGNACUAL_DICI_M_38` | 116 |
| GBA | `145.3_INGGBAGBA_DICI_M_10` | 117 | `145.3_INGGBAUAL_DICI_M_33` | 116 |
| Cuyo | `145.3_INGCUYUYO_DICI_M_11` | 117 | `145.3_INGCUYUAL_DICI_M_34` | 86 |
| Noreste | `145.3_INGNEANEA_DICI_M_10` | 117 | `145.3_INGNEAUAL_DICI_M_33` | 116 |
| Noroeste | `145.3_INGNOANOA_DICI_M_10` | 117 | `145.3_INGNOAUAL_DICI_M_33` | 0 |
| Pampeana | `145.3_INGPAMANA_DICI_M_15` | 117 | `145.3_INGPAMUAL_DICI_M_38` | 116 |
| Patagonia | `145.3_INGPATNIA_DICI_M_16` | 117 | `145.3_INGPATUAL_DICI_M_39` | 116 |

## Notas

- Las 7 regiones salen de la distribucion 145.3 del dataset 145, para que sean comparables entre si.
- La serie de variacion oficial de Noroeste devuelve 0 filas aunque su metadata declara datos (ver qa/bugs/BUG-002).
- La serie de variacion oficial de Cuyo arranca en 2019-07, no en 2017-01 como las demas (ver qa/bugs/BUG-003).
