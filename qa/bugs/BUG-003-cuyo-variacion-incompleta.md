# BUG-003 — La variación mensual de Cuyo arranca 30 meses más tarde que las demás regiones

| | |
|---|---|
| **Severidad** | Media |
| **Ambiente** | API datos.gob.ar, consultada el 2026-10-31 |
| **Componente** | Serie `145.3_INGCUYUAL_DICI_M_34` |
| **Estado** | Abierto |

## Descripción

La serie de variación mensual oficial de Cuyo empieza en **2019-07**, mientras que las de las otras regiones empiezan en **2017-01**. Faltan **30 meses**.

## Pasos para reproducir

1. Consultar `https://apis.datos.gob.ar/series/api/series/?ids=145.3_INGCUYUAL_DICI_M_34&format=json&limit=1000&sort=asc`
2. Comparar la primera fecha con la de otra región, por ejemplo `145.3_INGNACUAL_DICI_M_38`.

## Resultado esperado

116 filas desde 2017-01, igual que las demás regiones.

## Resultado actual

86 filas desde 2019-07. La metadata declara `start_date: 2017-01-01` pero la primera fila real es de 2019-07.

## Impacto

- La comparación automática de Cuyo cubre **86 meses en vez de 116**: 26 % menos de cobertura que el resto.
- Cualquier análisis que compare Cuyo contra otra región en 2017-2018 queda incompleto, y el vacío no se ve en el gráfico.
- El índice de Cuyo (`145.3_INGCUYUYO_DICI_M_11`) sí tiene los 117 meses, así que la variación de ese tramo **se puede calcular**; lo que falta es la tasa publicada.

## Acción tomada

- La variación se calcula desde el índice para todas las regiones, así que el reporte no depende de la serie oficial.
- La serie oficial se usa solo como **oráculo de validación**, y TC-07 reporta cuántos meses comparó por región (ver `qa/resultados-ejecucion.md`), de modo que la menor cobertura de Cuyo queda a la vista en vez de promediarse con las demás.
