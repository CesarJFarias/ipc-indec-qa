# BUG-002 — La serie de variación mensual de Noroeste devuelve 0 filas

| | |
|---|---|
| **Severidad** | Alta |
| **Ambiente** | API datos.gob.ar, consultada el 2026-10-31 |
| **Componente** | Serie `145.3_INGNOAUAL_DICI_M_33` |
| **Estado** | Abierto |

## Descripción

La serie "IPC. Tasa de variación mensual. Nivel General. región Noroeste. Base dic 2016." aparece en el catálogo y en el buscador de la API con rango declarado **2017-01 a 2026-08**, pero al consultarla devuelve **0 registros**.

Las otras 6 regiones devuelven 116 filas cada una para el mismo período.

## Pasos para reproducir

1. Buscar "variación mensual nivel general noroeste" en `https://apis.datos.gob.ar/series/api/search/?q=...` → aparece la serie con `time_index_start: 2017-01-01` y `time_index_end: 2026-08-01`.
2. Consultar `https://apis.datos.gob.ar/series/api/series/?ids=145.3_INGNOAUAL_DICI_M_33&format=json&limit=1000&sort=asc`
3. Observar la respuesta: `{"data": [], "count": 0, "meta": [{"frequency": "month"}]}`.

## Resultado esperado

116 filas entre 2017-01 y 2026-08, como las demás regiones.

## Resultado actual

`data` vacío y `meta` sin `start_date` ni `end_date`, contradiciendo el rango declarado en el catálogo.

## Impacto

Un tablero que use esta serie para un visual de variación por región muestra **Noroeste vacío sin ningún mensaje de error**: el usuario no puede distinguir "no hay datos" de "el filtro está mal". Es el peor escenario para un reporte: el silencio.

## Acción tomada

- La variación de Noroeste se **calcula a partir del índice** (`145.3_INGNOANOA_DICI_M_10`, que sí tiene las 117 filas), no se toma de la serie oficial.
- El caso de prueba **TC-17** verifica la cobertura de las series oficiales y marca esta región como advertencia, para que el hueco no pase inadvertido.
- El caso **TC-13** (combinación de filtros) exige que ningún gráfico quede vacío sin explicación: si el modelo usara la serie oficial, Noroeste fallaría ese caso.
