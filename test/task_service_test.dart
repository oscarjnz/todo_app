// test/task_service_test.dart
//
// Pruebas unitarias básicas del TaskService.
// Verifica que la lógica de negocio funcione correctamente
// independientemente de la UI.

import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/services/task_service.dart';

void main() {
  late TaskService service;

  // setUp se ejecuta antes de CADA test — estado limpio garantizado
  setUp(() {
    service = TaskService();
  });

  // ─────────────────────────────────────
  // GRUPO: Agregar tareas
  // ─────────────────────────────────────
  group('addTask', () {
    test('agrega una tarea válida correctamente', () {
      service.addTask(title: 'Comprar leche');
      expect(service.totalCount, 1);
      expect(service.tasks.first.title, 'Comprar leche');
    });

    test('lanza excepción si el título está vacío', () {
      expect(
        () => service.addTask(title: '   '),
        throwsA(isA<TaskValidationException>()),
      );
    });

    test('lanza excepción si el título supera 100 caracteres', () {
      expect(
        () => service.addTask(title: 'A' * 101),
        throwsA(isA<TaskValidationException>()),
      );
    });

    test('lanza excepción si existe una tarea con el mismo título', () {
      service.addTask(title: 'Duplicada');
      expect(
        () => service.addTask(title: 'Duplicada'),
        throwsA(isA<TaskValidationException>()),
      );
    });
  });

  // ─────────────────────────────────────
  // GRUPO: Alternar estado
  // ─────────────────────────────────────
  group('toggleTask', () {
    test('marca una tarea como completada', () {
      service.addTask(title: 'Tarea A');
      final id = service.tasks.first.id;
      service.toggleTask(id);
      expect(service.tasks.first.isCompleted, true);
      expect(service.tasks.first.completedAt, isNotNull);
    });

    test('reabre una tarea completada', () {
      service.addTask(title: 'Tarea B');
      final id = service.tasks.first.id;
      service.toggleTask(id); // completar
      service.toggleTask(id); // reabrir
      expect(service.tasks.first.isCompleted, false);
      expect(service.tasks.first.completedAt, isNull);
    });
  });

  // ─────────────────────────────────────
  // GRUPO: Progreso
  // ─────────────────────────────────────
  group('progressRatio', () {
    test('es 0.0 sin tareas', () {
      expect(service.progressRatio, 0.0);
    });

    test('es 0.5 con 1 de 2 tareas completadas', () {
      service.addTask(title: 'T1');
      service.addTask(title: 'T2');
      service.toggleTask(service.tasks.first.id);
      expect(service.progressRatio, 0.5);
    });
  });

  // ─────────────────────────────────────
  // GRUPO: Eliminar
  // ─────────────────────────────────────
  group('deleteTask', () {
    test('elimina la tarea correctamente', () {
      service.addTask(title: 'Borrable');
      final id = service.tasks.first.id;
      service.deleteTask(id);
      expect(service.totalCount, 0);
    });

    test('lanza excepción con ID inexistente', () {
      expect(
        () => service.deleteTask('id_que_no_existe'),
        throwsA(isA<TaskValidationException>()),
      );
    });
  });
}
