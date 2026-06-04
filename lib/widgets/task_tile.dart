// lib/widgets/task_tile.dart
//
// Widget sin estado que representa una sola tarea en la lista.
// Recibe callbacks del padre — no modifica estado directamente.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

/// Tile que muestra la información de una [Task] con acciones inline.
class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  /// Devuelve color e ícono según la prioridad de la tarea.
  ({Color color, IconData icon}) _priorityStyle(
      BuildContext context, Priority priority) {
    final cs = Theme.of(context).colorScheme;
    return switch (priority) {
      Priority.alta => (color: cs.error, icon: Icons.keyboard_double_arrow_up),
      Priority.media => (color: cs.tertiary, icon: Icons.remove),
      Priority.baja => (color: cs.primary, icon: Icons.keyboard_double_arrow_down),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = _priorityStyle(context, task.priority);
    final dateFormatter = DateFormat('dd MMM yyyy', 'es');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      // Opacidad reducida para tareas completadas
      color: task.isCompleted
          ? theme.colorScheme.surfaceContainerHighest
          : theme.colorScheme.surfaceContainerLow,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),

        // ── Checkbox de completado ──
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (_) => onToggle(),
          activeColor: theme.colorScheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),

        // ── Título y descripción ──
        title: Text(
          task.title,
          style: theme.textTheme.bodyLarge?.copyWith(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted
                ? theme.colorScheme.onSurfaceVariant
                : theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                task.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                // Badge de prioridad
                Icon(style.icon, size: 14, color: style.color),
                const SizedBox(width: 3),
                Text(
                  task.priority.name[0].toUpperCase() +
                      task.priority.name.substring(1),
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: style.color),
                ),
                const SizedBox(width: 12),
                // Fecha de creación o completado
                Icon(
                  task.isCompleted ? Icons.check_circle_outline : Icons.calendar_today,
                  size: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 3),
                Text(
                  task.isCompleted && task.completedAt != null
                      ? 'Completada ${dateFormatter.format(task.completedAt!)}'
                      : 'Creada ${dateFormatter.format(task.createdAt)}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),

        // ── Menú de acciones ──
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          tooltip: 'Opciones',
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit_outlined),
                title: Text('Editar'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete_outline),
                title: Text('Eliminar'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
