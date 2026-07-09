# Innova Lab — Mapeo: Modelo transaccional → Esquema en estrella

Este documento conecta las dos capas de modelado del proyecto:

1. **Modelo transaccional (OLTP)** — `innova-lab-ddl-corregido.sql`: las 8 tablas reales/sintéticas tal como viven en el backend (Moodle + app) y en la capa de Data Analytics.
2. **Esquema en estrella (BI)** — el diagrama de FigJam `Innova Lab - Modelo estrella para dashboard`: fact + dimensiones, pensado para alimentar Looker Studio.

La idea: cuando migres del dataset sintético a datos reales, este mapeo te dice de dónde sale cada campo del esquema en estrella.

---

## DIM_USUARIO ← Users + user_enrichment

| Campo en DIM_USUARIO | Tabla origen | Campo origen | Transformación |
|---|---|---|---|
| `user_id` | Users | `moodle_user_sub` | directo (renombrado) |
| `user_name` | — | — | ⚠️ no existe en el DDL actual; si el dashboard necesita nombre visible, falta traerlo de Moodle |
| `user_segment` | user_enrichment | `is_new_user` | `CASE WHEN is_new_user THEN 'Nuevo' ELSE 'Recurrente' END` |
| `city` | user_enrichment | `city` | directo |
| `province` | — | — | ⚠️ no existe en el DDL; `user_enrichment` solo tiene `city` |
| `latitude` / `longitude` | — | — | ⚠️ no existen; hay que geocodificar `city` (tabla de referencia ciudad→lat/long) o pedir que Moodle las provea |
| `age_range` | — | — | ⚠️ no existe en el DDL; si el mockup lo filtra, falta agregarlo a `user_enrichment` o `Users` |
| `user_type` | user_enrichment | `user_type` | directo |
| `accessibility_profile` | user_enrichment | `accessibility_profile` | directo |

---

## DIM_CURSO ← MoodleCourseCache

| Campo en DIM_CURSO | Tabla origen | Campo origen | Transformación |
|---|---|---|---|
| `course_id` | MoodleCourseCache | `moodle_course_id` | directo |
| `course_name` | MoodleCourseCache | `course_name` | directo — **este es el campo que agregamos en el DDL corregido (FIX 1)** |

---

## DIM_SESION ← Sessions

| Campo en DIM_SESION | Tabla origen | Campo origen | Transformación |
|---|---|---|---|
| `session_id` | Sessions | `session_id` | directo |
| `user_id` | Sessions | `moodle_user_sub` | directo |
| `course_id` | Sessions | `moodle_course_id` | directo (ojo: en el DDL original el campo se llama `moodle_coourse_id`, con typo — corregir antes de usar) |
| `device_category` | Sessions | `user_agent` | requiere parsear el user agent para extraer categoría de dispositivo (móvil/desktop/tablet) |
| `operating_system` | Sessions | `user_agent` | idem — parsear del user agent |
| `session_duration_seconds` | Sessions | `ended_at` − `started_at` | calculado; **este es el KPI bloqueado** — `ended_at` viene NULL del backend hoy |

---

## DIM_FECHA ← EventLog.timestamp

| Campo en DIM_FECHA | Tabla origen | Campo origen | Transformación |
|---|---|---|---|
| `event_date` | EventLog | `timestamp` | `DATE(timestamp)` |
| `mes` / `semana` | EventLog | `timestamp` | extraído con funciones de fecha (`EXTRACT(MONTH ...)`, etc.) |
| `periodo_comparacion` | — | — | no es un campo de tabla; se resuelve en Looker Studio con "Comparar rango de fechas" |

---

## FACT_EVENTOS ← EventLog + synthetic_events

| Campo en FACT_EVENTOS | Tabla origen | Campo origen | Transformación |
|---|---|---|---|
| `event_id` | EventLog | `event_id` | directo |
| `session_id` | EventLog | `session_id` | directo |
| `event_date` | EventLog | `timestamp` | `DATE(timestamp)` |
| `event_name` | EventLog | `event_type` | directo (renombrado) |
| `feature` | EventLog | `payload.field` (accessibility_changed) o `payload.feature` (navigation_event) | extraído del JSON — ver estructura documentada en el DDL |
| `feature_value` | EventLog | `payload.new_value` / `payload.feature` según evento | extraído del JSON |
| `mode` | synthetic_events | `ai_request_type` | directo (ya desnormalizado) |
| `preset` | synthetic_events | `preset_name` | directo |
| `activity_id` | EventLog | `payload.activity_id` | extraído del JSON |
| `action` | synthetic_events | `tts_action` | directo |
| `status` | EventLog | `resultado` | directo (renombrado) |

**Nota clave:** hoy `FACT_EVENTOS` se arma combinando `EventLog` (fuente cruda con JSON) + `synthetic_events` (ya desnormalizado por Data Analytics para 3 tipos de evento específicos). Si preferís no depender de `synthetic_events`, todo se puede sacar directo de `EventLog.payload`, pero vas a tener que escribir la extracción JSON vos mismos en la query en vez de que ya venga aplanado.

---

## Resumen de gaps para el pipeline real (no aplica al dataset sintético)

Estos son los campos que el esquema en estrella necesita pero que **no existen todavía** en el DDL transaccional:

1. `user_name` (nombre visible del usuario)
2. `province`, `latitude`, `longitude` (solo hay `city`)
3. `age_range`
4. Parseo de `device_category` / `operating_system` desde `user_agent`
5. `ended_at` en `Sessions` — bloqueado, ya reportado a Leandro

Con el dataset sintético actual (`innovalab_eventos_v3.csv`) estos gaps no aplican porque el CSV ya trae todo aplanado — este mapeo es para cuando conectes el pipeline a los datos reales de Moodle.

---

## Archivos relacionados en este repo
- `innova-lab-ddl-corregido.sql` — DDL de las 8 tablas transaccionales
- `innova-lab-campos-calculados.md` — fórmulas de Looker Studio panel por panel
- Diagrama FigJam: modelo estrella (fact + dimensiones) — ver link en ClickUp
