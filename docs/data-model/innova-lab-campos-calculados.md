# Innova Lab — Campos calculados para Looker Studio
Basado en `innovalab_eventos_v3.csv` (event log, 1 fila = 1 evento) y el mockup validado del dashboard.

Columnas del dataset usadas abajo: `event_date`, `event_timestamp`, `event_name`, `user_id`, `user_name`, `user_segment`, `city`, `province`, `latitude`, `longitude`, `course_name`, `session_id`, `session_duration_seconds`, `feature`, `feature_value`, `mode`, `preset`, `activity_id`, `action`, `status`.

---

## Scorecards superiores

| KPI | Cálculo | Notas |
|---|---|---|
| Usuarios activos | `COUNT_DISTINCT(user_id)` | Métrica directa, sin campo calculado |
| Sesiones | `COUNT_DISTINCT(session_id)` | Métrica directa |
| Eventos totales | `COUNT(event_name)` (record count) | Métrica directa |
| Tareas completadas | `COUNT` filtrando `event_name = "task_completed"` | Métrica directa + filtro de gráfico |

**Duración promedio** (requiere campo calculado, ver detalle):
```
Duración sesión (seg) — solo session_start
CASE
  WHEN event_name = "session_start" THEN session_duration_seconds
  ELSE NULL
END
```
En el editor de campos, tipo de dato = **Duración (segundos)**, no Número — así Looker Studio renderiza `HH:MM:SS` solo. Agregación del scorecard = Promedio.

**Comparación vs. período anterior** (las flechas ↑% que se ven en todos los scorecards): se activa en el control de rango de fechas del dashboard ("Comparar período anterior"), no es un campo calculado.

---

## Sesiones por día (línea)
- Dimensión: `event_date`
- Métrica: `COUNT_DISTINCT(session_id)`
- Filtro de gráfico: `event_name = "session_start"`

## Usuarios nuevos vs recurrentes (dona)
- Dimensión: `user_segment` (campo crudo, ya viene con "Nuevo"/"Recurrente")
- Métrica: `COUNT_DISTINCT(user_id)`

## Eventos por tipo (barras)
- Dimensión: `event_name`
- Métrica: `COUNT` (record count)

---

## Panel Accesibilidad

**Ajustes más utilizados** (barras)
- Filtro: `event_name = "accessibility_changed"`
- Dimensión: `feature` (font_size, contrast_mode, spacing, font_family, color_palette)
- Métrica: `COUNT`

**Contraste preferido** (dona)
```
Contraste preferido
CASE
  WHEN event_name = "accessibility_changed" AND feature = "contrast_mode"
  THEN feature_value
  ELSE NULL
END
```
⚠️ No confirmé todavía los valores exactos de `feature_value` para `contrast_mode` (asumo "Alto contraste"/"Normal" por el mockup). Antes de publicar, verificalo igual que hicimos con "Modo concentración".

---

## Panel IA Cognitiva

**Solicitudes por tipo** (barras) y **Evolución diaria** (línea)
- Filtro: `event_name = "ai_cognitive_request"`
- Dimensión: `mode` (summary / simplify / key_concepts) — para la evolución diaria, agregar `event_date` como segunda dimensión
- Métrica: `COUNT`

---

## Panel Texto a voz

**Acciones en texto a voz** (dona) y **Evolución diaria** (línea)
- Filtro: `event_name = "tts_interaction"`
- Dimensión: `action` (Play / Pause / Stop) — para evolución diaria, agregar `event_date`
- Métrica: `COUNT`

---

## Panel Uso por curso (mapa)

- Dimensión geo: `city` (usar `latitude`/`longitude` ya presentes en el dataset para el mapa de burbujas)
- Métrica: `COUNT_DISTINCT(user_id)` (o `COUNT_DISTINCT(session_id)` si preferís medir actividad en vez de alcance — definir cuál corresponde al mockup)
- ⚠️ Pendiente de la conversación anterior: el mockup titula este panel "Uso por curso" pero grafica por ciudad — vale la pena confirmar si falta un gráfico real por `course_name` que no está en el mockup.

---

## Panel Perfiles rápidos (Presets)

**Presets más utilizados** (dona) y **Evolución diaria** (línea)
- Filtro: `event_name = "preset_selected"`
- Dimensión: `preset` (Lectura asistida, Concentración (TDAH), Contraste visual, Daltonismo, Personalizado) — para evolución diaria, agregar `event_date`
- Métrica: `COUNT`

---

## Panel Navegación y Progreso

**Funciones más utilizadas** (barras) — excluye "Modo concentración" y "Progreso curso", que tienen sus propios paneles:
```
Función de navegación
CASE
  WHEN event_name = "navigation_event"
   AND feature IN ("Mi progreso", "Próximos pasos", "Navegación clara")
  THEN feature
  ELSE NULL
END
```
Dimensión = este campo, Métrica = `COUNT`.

**Uso de modo concentración** (dona)
```
Modo concentración
CASE
  WHEN event_name = "navigation_event" AND feature = "Modo concentración"
  THEN feature_value
  ELSE NULL
END
```
Dimensión = este campo (valores confirmados: "Activado" / "No activado"), Métrica = `COUNT`.

**Progreso promedio por curso** (barras)
```
Progreso extraído (%)
CASE
  WHEN event_name = "navigation_event" AND feature = "Progreso curso"
  THEN CAST(REGEXP_EXTRACT(feature_value, "([0-9]+)") AS NUMBER)
  ELSE NULL
END
```
Dimensión = `course_name`, Métrica = este campo con agregación **Promedio**.

---

## Eventos en tiempo real (tabla)

Sin campos calculados — tabla directa con: `event_timestamp`, `event_name`, `user_name` (o `user_id`), `course_name`, `detail`, `status`. Ordenar descendente por `event_timestamp`, límite de filas (ej. 10-20) para que funcione como "feed en vivo".

---

## Insights destacados

No son campos calculados de Looker Studio — son texto estático (o texto que armás vos revisando los números del período, para el MVP con dataset sintético). La versión completa a futuro se resuelve en la capa Gold de BigQuery con lógica de comparación de períodos, no acá.

---

## Pendientes de verificar antes de publicar
1. Valores exactos de `feature_value` para `contrast_mode` (Accesibilidad → Contraste preferido).
2. Si "Uso por curso" necesita un gráfico adicional real por curso, separado del de ciudad.
3. Que `preset` y `feature` no tengan variantes de mayúscula/tilde distintas a las que usamos en los CASE (mismo cuidado que tuvimos con "Modo concentración").
