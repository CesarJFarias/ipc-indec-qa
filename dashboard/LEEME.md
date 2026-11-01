# Proyecto Power BI

Acá va el archivo `.pbip` con el modelo y el reporte. Se guarda como **proyecto** (no como `.pbix`) para que Git pueda versionar el contenido como texto.

## Cómo guardarlo

1. En Power BI Desktop: **Archivo → Guardar como**.
2. Elegir **Proyecto de Power BI (\*.pbip)**.
3. Guardar en esta carpeta con el nombre `IPC-Indec.pbip`.

Power BI crea tres cosas:

```
dashboard/
├── IPC-Indec.pbip
├── IPC-Indec.Report/
└── IPC-Indec.SemanticModel/
```

Las medidas DAX quedan en texto dentro de `IPC-Indec.SemanticModel/definition/`, y el reporte en `IPC-Indec.Report/definition/`. Eso es lo que hace que un cambio se pueda revisar en un Pull Request.

## Tablas a cargar

| Tabla | Origen | Uso |
|---|---|---|
| `IPC` | `../data/ipc-regiones-mensual.csv` | hechos |
| `VariacionOficial` | `../data/ipc-variacion-oficial-mensual.csv` | solo QA |
| `Calendario` | calculada en DAX o Power Query | tabla de fechas |

## Al cargar los CSV

Los archivos usan **coma como separador de campos y punto como separador decimal** (formato invariante, `12276.766`). En Power Query, al importar, elegir:

- Delimitador: coma
- Cultura del archivo: **Inglés (Estados Unidos)** o *Invariant*

Si se deja Español (Argentina), Power BI interpreta el punto como separador de miles y los índices se cargan como texto o con el valor equivocado. Es el error de carga más común con CSV en este proyecto.

## Antes de guardar

- Desactivar **Auto date/time** en Opciones para no generar calendarios ocultos.
- Marcar `Calendario` como tabla de fechas y relacionarla con `IPC[Fecha]`.
- Verificar que la ruta de la carpeta sea corta: PBIP tiene un límite de 260 caracteres y los nombres de tabla largos lo alcanzan.
