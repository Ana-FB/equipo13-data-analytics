# Equipo 13 - Data Analytics | Innova Lab

Repositorio del equipo de Data Analytics del proyecto **MVP de accesibilidad** (LTI 1.3 + Moodle API), desarrollado en el marco del programa **Innova Lab**.

## 🎯 Objetivo del proyecto

Construir un dashboard analítico que permita visualizar el uso, navegación, progreso y accesibilidad de los usuarios de la herramienta, basado en la telemetría capturada por el backend (EventLog, Sessions, UserProgress, etc.).

**Demo Day:** 30 de agosto de 2026.

## 👥 Equipo

- **Ana Ferreira** - Team Lead, Data Analytics
- **Aldana** - Data Analytics

## 📁 Estructura del repositorio

```
.
├── docs/           # Documentación: arquitectura del backend, esquema de datos, eventos a trackear, decisiones técnicas
├── datasets/        # Datasets sintéticos para pruebas del dashboard (no hay datos reales para Demo Day)
├── dashboard/        # Queries, exports y configuración del dashboard (Looker Studio / herramienta a definir)
└── notebooks/        # Scripts y notebooks de análisis exploratorio
```

## 📊 Estado del MVP

- ✅ Definidos los 5 eventos clave a trackear (SESSION_START, ACCESSIBILITY_CHANGED, TTS_INTERACTION, AI_COGNITIVE_REQUEST, TASK_COMPLETED)
- ✅ Validada estructura de datos con backend (6 entidades: Users, Sessions, EventLog, MoodleCourseCache, AiCache, UserProgress)
- 🔄 En definición: herramienta de tracking (Firebase/Firestore) y herramienta de visualización del dashboard
- 🔄 En construcción: dataset sintético para pruebas

## 📌 Importante: política de datos

No se inventan datos. Toda la información se basa en documentación oficial provista por el equipo de backend o se marca explícitamente como **dato sintético / de prueba**.

## 🔗 Recursos

- Tablero de tareas (ClickUp): [Equipo 13 - Tareas del equipo](https://app.clickup.com/9018785435/v/l/li/901714369288)
- Documentación de arquitectura backend: ver carpeta `docs/`

## 🗓️ Reuniones

Kickoff semanal: miércoles 19:00 hs (Ana & Aldana)
