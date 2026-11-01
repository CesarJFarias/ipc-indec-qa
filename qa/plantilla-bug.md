# Plantilla de reporte de bug

```
ID: BUG-00X
Título: <resumen corto y específico>
Severidad: Alta / Media / Baja
Ambiente: <herramienta y versión>, datos del <fecha>
Componente: <serie, tabla o visual afectado>
Estado: Abierto / Corregido / Documentado

Descripción:
  <qué pasa, en una o dos frases>

Pasos para reproducir:
  1.
  2.
  3.

Resultado esperado:
Resultado actual:

Impacto:
  <a quién afecta y cómo se nota en el reporte>

Acción tomada:
  <qué se hizo en el proyecto para que el bug no afecte el resultado>

Evidencia: <captura en /docs o URL de la API>
```

## Criterio de severidad

| Severidad | Cuándo |
|---|---|
| **Alta** | El número mostrado es incorrecto, o el visual queda vacío sin explicación |
| **Media** | El número es correcto pero la fuente es inconsistente, o falta cobertura en parte del período |
| **Baja** | Inconsistencia de formato o precisión que no cambia la conclusión |

## Convención de nombres

`BUG-00X-titulo-corto-en-minusculas.md` dentro de `qa/bugs/`.
