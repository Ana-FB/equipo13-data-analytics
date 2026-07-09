-- ============================================================================
-- INNOVA LAB — DDL corregido (v2)
-- Cambios vs. versión original: ver comentarios marcados con [FIX]
-- ============================================================================

-- 1. USERS — Perfil y ajustes del usuario
CREATE TABLE Users (
    moodle_user_sub TEXT PRIMARY KEY,
    accessibility_settings JSON NOT NULL DEFAULT '{}',
    -- accessibility_settings estructura:
    -- { "contrast_mode": "Normal|Alto contraste",
    --   "font_size": 14-24,
    --   "font_family": "Arial|Georgia|OpenDyslexic",
    --   "spacing": "normal|increased",
    --   "color_palette": "default|monochromatic|deuteranopia" }
    onboarding_completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
-- Nota: panel "Contraste preferido" del dashboard debe leer
-- accessibility_settings.contrast_mode (estado ACTUAL), no contar
-- eventos accessibility_changed — contar eventos infla el número si
-- el usuario cambió de opinión varias veces.

-- 2. SESSIONS — Tiempo de uso y contexto
CREATE TABLE Sessions (
    session_id TEXT PRIMARY KEY,
    moodle_user_sub TEXT NOT NULL,
    moodle_user_id INTEGER NOT NULL,
    started_at TIMESTAMP NOT NULL,
    ended_at TIMESTAMP,
    user_agent TEXT
);

-- 3. EVENTLOG — Fuente principal del dashboard
CREATE TABLE EventLog (
    event_id TEXT PRIMARY KEY,
    session_id TEXT NOT NULL,
    event_type TEXT NOT NULL,
    -- Valores válidos: accessibility_changed, ai_cognitive_request, tts_interaction,
    -- preset_selected, navigation_event, task_completed, session_start, concentration_mode_toggle
    payload JSON NOT NULL,
    resultado TEXT NOT NULL DEFAULT 'SUCCESS',
    -- SUCCESS, FAILED, CANCELLED
    timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
-- [FIX 3] Estructura de payload por event_type — antes solo estaba
-- documentada accessibility_settings (perfil), no el evento de cambio en sí:
--
-- accessibility_changed:
--   { "field": "contrast_mode|font_size|font_family|spacing|color_palette",
--     "old_value": "...", "new_value": "..." }
--
-- navigation_event:
--   { "feature": "Mi progreso|Próximos pasos|Navegación clara" }
--
-- concentration_mode_toggle:
--   { "state": "Activado|No activado" }
--
-- ai_cognitive_request:
--   { "request_type": "summary|simplify|key_concepts", "activity_id": "..." }
--
-- tts_interaction:
--   { "action": "play|pause|stop", "activity_id": "..." }
--
-- preset_selected:
--   { "preset_name": "Lectura asistida|Concentración (TDAH)|Contraste visual|Daltonismo|Personalizado" }
--
-- task_completed:
--   { "activity_id": "...", "course_id": "..." }
--
-- session_start:
--   { "device_category": "...", "operating_system": "..." }

-- 4. MOODLECOURSECACHE — Contexto de cursos y actividades
CREATE TABLE MoodleCourseCache (
    moodle_course_id TEXT PRIMARY KEY,
    course_name TEXT NOT NULL,  -- [FIX 1] agregado: faltaba el nombre del curso.
    -- Sin este campo no se puede armar el mapa "Uso por curso", el eje de
    -- "Progreso promedio por curso" (Matemática I, Historia Contemp., etc.)
    -- ni la columna "Curso" de la tabla en tiempo real del dashboard.
    -- Traer desde la API de Moodle (course.fullname o similar).
    activity_id TEXT NOT NULL UNIQUE,
    content_text_raw TEXT,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 5. AICACHE — Respuestas generadas por IA
CREATE TABLE AiCache (
    activity_id TEXT NOT NULL,
    text_hash TEXT NOT NULL UNIQUE,
    generated_summary TEXT,
    simplified_text TEXT
);

-- 6. USERPROGRESS — Progreso y pendientes
CREATE TABLE UserProgress (
    moodle_user_sub TEXT NOT NULL,
    moodle_activity_id TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'PENDING',
    -- PENDING, IN_PROGRESS, COMPLETED
    progress_percentage NUMERIC(5,2),  -- [FIX 2] agregado: faltaba un campo numérico.
    -- El panel "Progreso promedio por curso" del dashboard muestra %
    -- (78%, 65%, 58%...). Con solo 3 estados categóricos no se puede
    -- promediar un porcentaje real. Si Moodle expone el % de avance
    -- de la actividad, traerlo acá; si no, definir una regla de
    -- conversión explícita (ej. PENDING=0, IN_PROGRESS=50, COMPLETED=100)
    -- y documentarla como aproximación, no como dato real.
    due_date TIMESTAMP,
    last_interaction_timestamp TIMESTAMP
);

-- ============================================================================
-- TABLAS SINTÉTICAS (Generadas por Data Analytics)
-- ============================================================================

-- 7. USER_ENRICHMENT
CREATE TABLE user_enrichment (
    moodle_user_sub TEXT NOT NULL UNIQUE,
    city TEXT,
    -- Buenos Aires, Córdoba, Rosario, Mendoza, Otras
    accessibility_profile TEXT,
    -- Inferido del patrón de accessibility_settings más usado
    user_type TEXT,
    -- Clasificación derivada
    is_new_user BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (moodle_user_sub) REFERENCES Users(moodle_user_sub)
);

-- 8. SYNTHETIC_EVENTS — Desnormalización de payloads
CREATE TABLE synthetic_events (
    event_id TEXT NOT NULL UNIQUE,
    moodle_user_sub TEXT NOT NULL,
    session_id TEXT NOT NULL,
    preset_name TEXT,
    -- Para preset_selected
    tts_action TEXT,
    -- Para tts_interaction: play, pause, stop
    ai_request_type TEXT,
    -- Para ai_cognitive_request: summary, simplify, key_concepts
    concentration_mode_state TEXT
    -- [FIX complementario] Para concentration_mode_toggle: Activado, No activado
    -- Agregado porque event_type ya distingue este evento aparte de
    -- navigation_event, pero synthetic_events no tenía dónde desnormalizarlo.
);

-- ============================================================================
-- RESUMEN DE CAMBIOS
-- ============================================================================
-- [FIX 1] MoodleCourseCache.course_name        -> desbloquea 3 paneles del dashboard
-- [FIX 2] UserProgress.progress_percentage     -> desbloquea "Progreso promedio por curso"
-- [FIX 3] Documentación de payload por evento  -> desbloquea desarrollo de synthetic_events
-- [FIX complementario] synthetic_events.concentration_mode_state
-- ============================================================================
