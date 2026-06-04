// lib/screens/home_screen.dart
//
// Pantalla principal que orquesta la UI y maneja el estado con setState.
// Solo llama al TaskService — nunca manipula la lista de tareas directamente.

import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import '../widgets/task_tile.dart';
import '../widgets/task_form_dialog.dart';
import '../widgets/progress_header.dart';

/// Pestaña activa del TabBar inferior.
enum _Tab { pendientes, completadas }

/// Pantalla principal con estado. Mantiene el [TaskService] y
/// reconstruye la UI cada vez que hay un cambio.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Instancia única del servicio — toda la lógica pasa por aquí.
  final TaskService _service = TaskService();

  /// Pestaña actualmente visible.
  _Tab _currentTab = _Tab.pendientes;

  // ──────────────────────────────────────────────
  // ACCIONES — cada una actualiza estado en try-catch
  // ──────────────────────────────────────────────

  /// Abre el diálogo para agregar una nueva tarea.
  Future<void> _openAddDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const TaskFormDialog(),
    );

    // El usuario canceló
    if (result == null) return;

    try {
      _service.addTask(
        title: result['title'] as String,
        description: result['description'] as String,
        priority: result['priority'] as Priority,
      );
      setState(() {}); // reconstruir con la nueva tarea
      _showSnackBar('Tarea agregada correctamente.', isError: false);
    } on TaskValidationException catch (e) {
      // Error de validación esperado — mensaje amigable
      _showSnackBar(e.message, isError: true);
    } catch (e) {
      // Error inesperado
      _showSnackBar('Ocurrió un error inesperado: $e', isError: true);
    }
  }

  /// Abre el diálogo de edición para una tarea existente.
  Future<void> _openEditDialog(Task task) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => TaskFormDialog(taskToEdit: task),
    );

    if (result == null) return;

    try {
      _service.editTask(
        id: task.id,
        newTitle: result['title'] as String,
        newDescription: result['description'] as String,
        newPriority: result['priority'] as Priority,
      );
      setState(() {});
      _showSnackBar('Tarea actualizada.', isError: false);
    } on TaskValidationException catch (e) {
      _showSnackBar(e.message, isError: true);
    } catch (e) {
      _showSnackBar('Error al editar la tarea: $e', isError: true);
    }
  }

  /// Alterna el estado completado/pendiente de una tarea.
  void _toggleTask(String id) {
    try {
      _service.toggleTask(id);
      setState(() {});
    } on TaskValidationException catch (e) {
      _showSnackBar(e.message, isError: true);
    }
  }

  /// Solicita confirmación y elimina la tarea.
  Future<void> _deleteTask(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.delete_outline, color: Colors.red),
        title: const Text('Eliminar tarea'),
        content: Text('¿Seguro que deseas eliminar "${task.title}"? '
            'Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      _service.deleteTask(task.id);
      setState(() {});
      _showSnackBar('Tarea eliminada.', isError: false);
    } on TaskValidationException catch (e) {
      _showSnackBar(e.message, isError: true);
    }
  }

  /// Elimina todas las tareas completadas después de confirmación.
  Future<void> _clearCompleted() async {
    if (_service.completedTasks.isEmpty) {
      _showSnackBar('No hay tareas completadas para eliminar.', isError: false);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Limpiar completadas'),
        content: Text(
          'Se eliminarán ${_service.completedCount} tarea(s) completada(s). '
          '¿Continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      _service.clearCompleted();
      setState(() {});
      _showSnackBar('Tareas completadas eliminadas.', isError: false);
    } catch (e) {
      _showSnackBar('Error al limpiar: $e', isError: true);
    }
  }

  // ──────────────────────────────────────────────
  // HELPERS DE UI
  // ──────────────────────────────────────────────

  /// Muestra un SnackBar con mensaje de éxito o error.
  void _showSnackBar(String message, {required bool isError}) {
    // Verificar que el widget siga montado antes de usar el context
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 3),
        ),
      );
  }

  // ──────────────────────────────────────────────
  // BUILD
  // ──────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final pendingList = _service.pendingTasks;
    final completedList = _service.completedTasks;
    final isShowingPending = _currentTab == _Tab.pendientes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Tareas'),
        centerTitle: false,
        actions: [
          // Botón para limpiar completadas
          IconButton(
            icon: const Icon(Icons.cleaning_services_outlined),
            tooltip: 'Eliminar completadas',
            onPressed: _clearCompleted,
          ),
        ],
      ),

      body: Column(
        children: [
          // ── Encabezado de progreso ──
          ProgressHeader(
            total: _service.totalCount,
            completed: _service.completedCount,
            progress: _service.progressRatio,
          ),

          // ── Tab selector ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<_Tab>(
              segments: [
                ButtonSegment(
                  value: _Tab.pendientes,
                  label: Text('Pendientes (${pendingList.length})'),
                  icon: const Icon(Icons.radio_button_unchecked, size: 16),
                ),
                ButtonSegment(
                  value: _Tab.completadas,
                  label: Text('Completadas (${completedList.length})'),
                  icon: const Icon(Icons.check_circle_outline, size: 16),
                ),
              ],
              selected: {_currentTab},
              onSelectionChanged: (sel) =>
                  setState(() => _currentTab = sel.first),
            ),
          ),

          // ── Lista de tareas ──
          Expanded(
            child: _buildTaskList(
              isShowingPending ? pendingList : completedList,
              isShowingPending,
            ),
          ),
        ],
      ),

      // ── FAB para agregar tarea ──
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('Nueva tarea'),
        tooltip: 'Agregar nueva tarea',
      ),
    );
  }

  /// Construye la lista de tareas o un estado vacío si no hay ninguna.
  Widget _buildTaskList(List<Task> tasks, bool isPending) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPending ? Icons.task_alt : Icons.inbox_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            const SizedBox(height: 16),
            Text(
              isPending
                  ? '¡No tienes tareas pendientes!'
                  : 'Aún no has completado ninguna tarea.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
              textAlign: TextAlign.center,
            ),
            if (isPending) ...[
              const SizedBox(height: 8),
              Text(
                'Toca el botón + para agregar una nueva.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80), // espacio para el FAB
      itemCount: tasks.length,
      itemBuilder: (_, index) {
        final task = tasks[index];
        return TaskTile(
          key: ValueKey(task.id), // key semántica para eficiencia del framework
          task: task,
          onToggle: () => _toggleTask(task.id),
          onEdit: () => _openEditDialog(task),
          onDelete: () => _deleteTask(task),
        );
      },
    );
  }
}
