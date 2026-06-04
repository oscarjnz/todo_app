# Todo App — Flutter & Dart

Aplicación de lista de tareas desarrollada como actividad académica de Flutter y Dart.

## Estructura del proyecto

```
lib/
├── main.dart                    # Punto de entrada, MaterialApp con M3
├── models/
│   └── task.dart                # Modelo de datos con null safety y fromJson/toJson
├── services/
│   └── task_service.dart        # LÓGICA DE NEGOCIO (separada de la UI)
├── screens/
│   └── home_screen.dart         # Pantalla principal con setState
└── widgets/
    ├── task_tile.dart           # Tile reutilizable para cada tarea
    ├── task_form_dialog.dart    # Diálogo para crear/editar tareas
    └── progress_header.dart     # Encabezado con barra de progreso
test/
└── task_service_test.dart       # Pruebas unitarias de la lógica
```

## Cómo ejecutar

```bash
# 1. Instalar dependencias
flutter pub get

# 2. Ejecutar la app
flutter run

# 3. Ejecutar los tests
flutter test
```

## Funcionalidades

- Agregar tareas con título, descripción y prioridad (baja / media / alta)
- Marcar tareas como completadas o reabrirlas
- Editar tareas existentes
- Eliminar tareas individualmente (con confirmación)
- Eliminar todas las completadas de una vez
- Barra de progreso general
- Vista separada: pendientes y completadas
- Soporte para modo oscuro automático
- Manejo de errores con mensajes amigables (SnackBar + AlertDialog)
- Validación de formularios antes de procesar

## Criterios de evaluación cubiertos

| Criterio | Implementación |
|---|---|
| Cumplimiento (4 pts) | Todos los requisitos funcionales implementados y probados |
| Lógica de negocio (3 pts) | `TaskService` completamente separado de la UI |
| Diseño de UI (2 pts) | Material Design 3, feedback visual, responsive |
| Manejo de errores (1 pt) | `try-catch` en todas las acciones, validación de campos, mensajes amigables |
