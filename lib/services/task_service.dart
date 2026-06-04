// lib/services/task_service.dart
//
// Capa de lógica de negocio completamente separada de la UI.
// Toda operación sobre tareas pasa por aquí.
// La UI nunca manipula la lista directamente.

import '../models/task.dart';

/// Excepción personalizada para errores de validación de tareas.
class TaskValidationException implements Exception {
  final String message;
  const TaskValidationException(this.message);

  @override
  String toString() => 'TaskValidationException: $message';
}

/// Servicio que encapsula toda la lógica de negocio relacionada con tareas.
class TaskService {
  // Lista interna privada — la UI no puede modificarla directamente.
  final List<Task> _tasks = [];

  /// Retorna una copia inmutable de la lista de tareas.
  List<Task> get tasks => List.unmodifiable(_tasks);

  /// Retorna solo las tareas pendientes, ordenadas por prioridad descendente.
  List<Task> get pendingTasks {
    final pending = _tasks.where((t) => !t.isCompleted).toList();
    pending.sort((a, b) => b.priority.index.compareTo(a.priority.index));
    return List.unmodifiable(pending);
  }

  /// Retorna solo las tareas completadas, más reciente primero.
  List<Task> get completedTasks {
    final completed = _tasks.where((t) => t.isCompleted).toList();
    completed.sort((a, b) =>
        (b.completedAt ?? b.createdAt)
            .compareTo(a.completedAt ?? a.createdAt));
    return List.unmodifiable(completed);
  }

  /// Número total de tareas.
  int get totalCount => _tasks.length;

  /// Número de tareas completadas.
  int get completedCount => _tasks.where((t) => t.isCompleted).length;

  /// Porcentaje de progreso (0.0 a 1.0).
  double get progressRatio =>
      _tasks.isEmpty ? 0.0 : completedCount / _tasks.length;

  // ─────────────────────────────────────────────
  // OPERACIONES CRUD
  // ─────────────────────────────────────────────

  /// Agrega una nueva tarea. Lanza [TaskValidationException] si el título
  /// es inválido o ya existe una tarea con el mismo título.
  void addTask({
    required String title,
    String description = '',
    Priority priority = Priority.media,
  }) {
    // Validación 1: título no puede estar vacío
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      throw const TaskValidationException(
        'El título de la tarea no puede estar vacío.',
      );
    }

    // Validación 2: título no puede exceder 100 caracteres
    if (trimmedTitle.length > 100) {
      throw const TaskValidationException(
        'El título no puede superar los 100 caracteres.',
      );
    }

    // Validación 3: no duplicados (ignorando mayúsculas/minúsculas)
    final duplicate = _tasks.any(
      (t) => t.title.toLowerCase() == trimmedTitle.toLowerCase(),
    );
    if (duplicate) {
      throw TaskValidationException(
        'Ya existe una tarea con el título "$trimmedTitle".',
      );
    }

    final newTask = Task.create(
      title: trimmedTitle,
      description: description.trim(),
      priority: priority,
    );

    _tasks.add(newTask);
    // Log de negocio para trazabilidad
    // ignore: avoid_print
    print('[TaskService] Tarea agregada: $newTask');
  }

  /// Alterna el estado completado/pendiente de una tarea por su ID.
  /// Lanza [TaskValidationException] si el ID no existe.
  void toggleTask(String id) {
    final index = _findIndexById(id);
    final task = _tasks[index];

    task.isCompleted = !task.isCompleted;
    task.completedAt = task.isCompleted ? DateTime.now() : null;

    // ignore: avoid_print
    print('[TaskService] Tarea ${task.isCompleted ? "completada" : "reabierta"}: $task');
  }

  /// Elimina una tarea por su ID.
  /// Lanza [TaskValidationException] si el ID no existe.
  void deleteTask(String id) {
    final index = _findIndexById(id);
    final removed = _tasks.removeAt(index);
    // ignore: avoid_print
    print('[TaskService] Tarea eliminada: $removed');
  }

  /// Edita el título, descripción y prioridad de una tarea existente.
  /// Aplica las mismas validaciones que [addTask].
  void editTask({
    required String id,
    required String newTitle,
    String newDescription = '',
    required Priority newPriority,
  }) {
    final trimmedTitle = newTitle.trim();

    if (trimmedTitle.isEmpty) {
      throw const TaskValidationException(
        'El título de la tarea no puede estar vacío.',
      );
    }

    if (trimmedTitle.length > 100) {
      throw const TaskValidationException(
        'El título no puede superar los 100 caracteres.',
      );
    }

    // Verificar duplicado excluyendo la propia tarea editada
    final duplicate = _tasks.any(
      (t) =>
          t.id != id &&
          t.title.toLowerCase() == trimmedTitle.toLowerCase(),
    );
    if (duplicate) {
      throw TaskValidationException(
        'Ya existe otra tarea con el título "$trimmedTitle".',
      );
    }

    final index = _findIndexById(id);
    _tasks[index].title = trimmedTitle;
    _tasks[index].description = newDescription.trim();
    _tasks[index].priority = newPriority;

    // ignore: avoid_print
    print('[TaskService] Tarea editada: ${_tasks[index]}');
  }

  /// Elimina todas las tareas completadas de la lista.
  void clearCompleted() {
    _tasks.removeWhere((t) => t.isCompleted);
    // ignore: avoid_print
    print('[TaskService] Tareas completadas eliminadas.');
  }

  // ─────────────────────────────────────────────
  // MÉTODOS PRIVADOS DE APOYO
  // ─────────────────────────────────────────────

  /// Busca el índice de una tarea por ID. Lanza excepción si no la encuentra.
  int _findIndexById(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) {
      throw TaskValidationException('No se encontró ninguna tarea con ID "$id".');
    }
    return index;
  }
}
