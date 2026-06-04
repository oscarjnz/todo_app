// lib/models/task.dart
//
// Modelo de datos que representa una tarea.
// Usa null safety y constructores con nombre.
// Incluye fromJson/toJson para serialización futura.

/// Enumeración de prioridades posibles de una tarea.
enum Priority { baja, media, alta }

/// Clase que modela una tarea de la lista To-Do.
class Task {
  final String id;
  String title;
  String description;
  bool isCompleted;
  Priority priority;
  final DateTime createdAt;
  DateTime? completedAt;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    this.priority = Priority.media,
    required this.createdAt,
    this.completedAt,
  });

  /// Constructor de nombre para crear una tarea nueva desde cero.
  factory Task.create({
    required String title,
    String description = '',
    Priority priority = Priority.media,
  }) {
    return Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      priority: priority,
      createdAt: DateTime.now(),
    );
  }

  /// Serialización a Map para persistencia o debug.
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'isCompleted': isCompleted,
        'priority': priority.name,
        'createdAt': createdAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
      };

  /// Deserialización desde Map.
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
      priority: Priority.values.firstWhere(
        (p) => p.name == json['priority'],
        orElse: () => Priority.media,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  /// Crea una copia de la tarea con campos opcionales modificados.
  Task copyWith({
    String? title,
    String? description,
    bool? isCompleted,
    Priority? priority,
    DateTime? completedAt,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  String toString() => 'Task(id: $id, title: $title, completed: $isCompleted)';
}
