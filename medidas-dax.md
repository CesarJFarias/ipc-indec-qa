# Medidas DAX

## Supuestos del modelo

- Tabla de hechos `IPC` con las columnas `Fecha` (primer día de cada mes), `Region` e `Indice`.
- Tabla `Calendario` con la columna `Fecha`, **marcada como tabla de fechas** y relacionada 1:* con `IPC[Fecha]`.
- Tabla `VariacionOficial` con `Fecha`, `Region` y `VariacionPct`, usada **solo para QA**.

Sin la tabla de calendario marcada, `PREVIOUSMONTH` y `SAMEPERIODLASTYEAR` no funcionan de forma confiable.

## Índice

```dax
Indice = AVERAGE ( IPC[Indice] )
```

> `AVERAGE` sobre un solo mes devuelve el índice de ese mes. Sobre un rango devuelve el promedio, que **no** es un índice válido de ningún período. Para los KPIs, usá las medidas de un solo mes de más abajo o filtrá el visual por mes.

## Variación mensual

```dax
Indice Mes Anterior =
CALCULATE ( [Indice], PREVIOUSMONTH ( Calendario[Fecha] ) )

Var Mensual % =
VAR Actual = [Indice]
VAR Previo = [Indice Mes Anterior]
RETURN
    DIVIDE ( Actual - Previo, Previo )
```

## Variación interanual

```dax
Var Interanual % =
VAR Actual = [Indice]
VAR HaceDoceMeses =
    CALCULATE ( [Indice], SAMEPERIODLASTYEAR ( Calendario[Fecha] ) )
RETURN
    DIVIDE ( Actual - HaceDoceMeses, HaceDoceMeses )
```

## Variación acumulada del año

```dax
Var Acumulada Anio % =
VAR MesActual = MAX ( Calendario[Fecha] )
VAR DicAnterior = DATE ( YEAR ( MesActual ) - 1, 12, 1 )
VAR Base = CALCULATE ( [Indice], Calendario[Fecha] = DicAnterior )
RETURN
    DIVIDE ( [Indice] - Base, Base )
```

En enero da la variación de enero; en diciembre, la acumulada del año completo. Conviene usarla en un visual con el mes en el eje: si el visual muestra varios meses a la vez, `[Indice]` promedia y el resultado deja de ser una acumulada real.

## Último mes disponible

```dax
Ultimo Mes = MAX ( IPC[Fecha] )

Indice Ultimo Mes =
CALCULATE ( [Indice], Calendario[Fecha] = [Ultimo Mes] )
```

`Indice Ultimo Mes` es el que conviene usar en un KPI: siempre muestra el último dato, aunque el visual no tenga filtro de fecha.

## Medidas para QA

```dax
-- Filas con el índice vacío (debe ser 0)
Filas Sin Indice = COUNTROWS ( FILTER ( IPC, ISBLANK ( IPC[Indice] ) ) )

-- Meses distintos cubiertos (debe ser 117 a agosto 2026)
Meses Con Indice = DISTINCTCOUNT ( IPC[Fecha] )

-- Variación que publica el INDEC para el mismo período
Variacion Oficial % = AVERAGE ( VariacionOficial[VariacionPct] ) / 100

-- Diferencia contra el INDEC, en puntos porcentuales
Dif vs Oficial pp = ABS ( [Var Mensual %] - [Variacion Oficial %] ) * 100
```

`Dif vs Oficial pp` es la medida que hace visible la validación dentro del propio tablero: se puede poner en una tabla por mes y ver los 666 meses comparados sin salir de Power BI. La tolerancia acordada es 0,1 pp (ver `qa/casos-de-prueba.md`).

## Formato

| Medida | Formato |
|---|---|
| `Indice`, `Indice Mes Anterior`, `Indice Ultimo Mes` | decimal, 2 decimales, sin separador de miles en el eje |
| `Var Mensual %`, `Var Interanual %`, `Var Acumulada Anio %` | porcentaje, 2 decimales |
| `Dif vs Oficial pp` | decimal, 4 decimales, sufijo " pp" |

## Notas

- `DIVIDE` devuelve vacío si el denominador es vacío: por eso el primer mes de la serie (2016-12) muestra variación en blanco y no un 0 % falso. Es el comportamiento que pide TC-10.
- Si en lugar de `PREVIOUSMONTH` se usa `DATEADD ( Calendario[Fecha], -1, MONTH )`, el resultado es equivalente con datos mensuales, pero `DATEADD` exige que la columna de fechas sea contigua: cualquier hueco en el calendario devuelve vacío.
- `[Indice]` es un promedio. Si una región se cargara dos veces para el mismo mes, el promedio taparía el duplicado en lugar de delatarlo. Por eso TC-01 se valida en los datos y no en el reporte.
