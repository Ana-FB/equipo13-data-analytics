# Data Analytics | Innova Lab

Repositorio del equipo de Data Analytics del proyecto **MVP de accesibilidad** (LTI 1.3 + Moodle API), desarrollado en el marco del programa **Innova Lab**.

## 🎯 Objetivo del proyecto

Construir un dashboard analítico que permita visualizar el uso, navegación, progreso y accesibilidad de los usuarios de la herramienta, basado en la telemetría capturada por el backend (EventLog, Sessions, UserProgress, etc.).

**Demo Day:** 7 de agosto de 2026.

## 👥 Equipo 13 

- **Ana Ferreira** - Team Lead, Data Analytics
- **Aldana** - Data Analytics

## 📁 Estructura del repositorio

---

## 📐 data-model

Contiene el modelo de datos del proyecto: esquema estrella (star schema) con `FACT_EVENTOS` y cinco dimensiones (`DIM_USUARIO`, `DIM_SESION`, `DIM_ACTIVIDAD`, `DIM_TIEMPO`, `DIM_SINTETICO`).

| Archivo | Descripción |
|---|---|
| `innova-lab-ddl-corregido.sql` | DDL completo con CREATE TABLE de todas las tablas |
| `innova-lab-mapeo-modelo-transaccional-vs-estrella.md` | Mapeo entre modelo transaccional (MongoDB) y modelo estrella (BigQuery) |
| `innova-lab-campos-calculados.md` | Campos calculados para Looker Studio |
| `Schema.png` | Diagrama del modelo estrella |
| `diagrama.png` | Diagrama entidad-relación (ERD) |

---

## 📊 metricas

Definición de KPIs y métricas del dashboard de accesibilidad.

| Archivo | Descripción |
|---|---|
| `innova-lab-kpis-metricas.md` | KPIs principales, fórmulas y fuentes de datos |

---

## 🎨 visualizacion

Wireframes y capturas del dashboard.

| Archivo | Descripción |
|---|---|
| `Dashboard Accesibilidad Wireframe.pdf` | Wireframe completo del panel de accesibilidad |
| `Dashboard Visual.png` | Vista del dashboard en Looker Studio |

---

## 🛠️ Stack técnico

- **Backend:** Node.js · MongoDB · LTI 1.3 (ltijs)
- **Pipeline:** PostgreSQL → BigQuery → Looker Studio
- **Dataset sintético:** `innovalab_eventos_v3.csv` (5.327 filas · 28 columnas · 8 event types)
- **IA:** Claude Haiku 4.5 (Anthropic) — resumen, simplificación y conceptos clave

---

## 👥 Equipo

| Rol | Integrante |
|---|---|
| Data Analytics Lead | Ana Ferreira |
| Backend | Leandro |
| Data Analytics | Aldana |
        
## 🛠️ Stack

- **Fuente de datos (MVP):** dataset sintético `innovalab_eventos_v3.csv`
- **Modelado:** esquema en estrella (fact + dimensiones)
- **Visualización:** Looker Studio
- **Gestión de tareas:** ClickUp

## 🔗 Recursos

- Tablero de tareas (ClickUp): [Equipo 13 - Tareas del equipo](https://app.clickup.com/9018785435/v/l/li/901714369288)
- Documentación del modelo de datos: ver carpeta [`docs/data-model/`](docs)

## 🗓️ Reuniones

Kickoff semanal: miércoles 19:00 hs (Ana & Aldana)
