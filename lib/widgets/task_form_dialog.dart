// lib/widgets/task_form_dialog.dart
//
// Diálogo reutilizable para crear y editar tareas.
// Incluye validación de campos y selección de prioridad.

import 'package:flutter/material.dart';
import '../models/task.dart';

/// Diálogo modal para agregar o editar una tarea.
///
/// Si se pasa [taskToEdit], el formulario se prellenará con sus datos
/// y el botón dirá "Guardar cambios". De lo contrario, dirá "Agregar".
class TaskFormDialog extends StatefulWidget {
  final Task? taskToEdit;

  const TaskFormDialog({super.key, this.taskToEdit});

  @override
  State<TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends State<TaskFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late Priority _selectedPriority;

  bool get _isEditing => widget.taskToEdit != null;

  @override
  void initState() {
    super.initState();
    // Prellenar si estamos editando
    _titleController = TextEditingController(
      text: widget.taskToEdit?.title ?? '',
    );
    _descController = TextEditingController(
      text: widget.taskToEdit?.description ?? '',
    );
    _selectedPriority = widget.taskToEdit?.priority ?? Priority.media;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  /// Valida el formulario y, si es válido, cierra el diálogo
  /// retornando un Map con los datos ingresados.
  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop({
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'priority': _selectedPriority,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(_isEditing ? 'Editar tarea' : 'Nueva tarea'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Campo de título ──
              TextFormField(
                controller: _titleController,
                autofocus: true,
                maxLength: 100,
                decoration: const InputDecoration(
                  labelText: 'Título *',
                  hintText: 'Ej: Comprar víveres',
                  prefixIcon: Icon(Icons.title),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El título es obligatorio.';
                  }
                  if (value.trim().length > 100) {
                    return 'Máximo 100 caracteres.';
                  }
                  return null; // válido
                },
              ),
              const SizedBox(height: 8),

              // ── Campo de descripción (opcional) ──
              TextFormField(
                controller: _descController,
                maxLines: 2,
                maxLength: 200,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  hintText: 'Agrega más detalles…',
                  prefixIcon: Icon(Icons.notes),
                ),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 12),

              // ── Selector de prioridad ──
              Text(
                'Prioridad',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 6),
              SegmentedButton<Priority>(
                segments: const [
                  ButtonSegment(
                    value: Priority.baja,
                    label: Text('Baja'),
                    icon: Icon(Icons.arrow_downward, size: 16),
                  ),
                  ButtonSegment(
                    value: Priority.media,
                    label: Text('Media'),
                    icon: Icon(Icons.remove, size: 16),
                  ),
                  ButtonSegment(
                    value: Priority.alta,
                    label: Text('Alta'),
                    icon: Icon(Icons.arrow_upward, size: 16),
                  ),
                ],
                selected: {_selectedPriority},
                onSelectionChanged: (newSelection) {
                  setState(() => _selectedPriority = newSelection.first);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // cancelar → null
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: _submit,
          icon: Icon(_isEditing ? Icons.save : Icons.add),
          label: Text(_isEditing ? 'Guardar cambios' : 'Agregar'),
        ),
      ],
    );
  }
}
