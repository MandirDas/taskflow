import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/features/tasks/domain/entities/task_entity.dart';
import 'package:taskflow/features/tasks/domain/entities/task_filter.dart';

void main() {
  final testTasks = [
    TaskEntity(
      id: 'task_1',
      projectId: 'proj_1',
      title: 'Task 1',
      description: 'Desc 1',
      status: 'todo',
      priority: 'high',
      assigneeId: 'user_001',
      dueDate: DateTime(2026, 1, 15),
      createdAt: DateTime(2025, 12, 1),
    ),
    TaskEntity(
      id: 'task_2',
      projectId: 'proj_1',
      title: 'Task 2',
      description: 'Desc 2',
      status: 'in_progress',
      priority: 'medium',
      assigneeId: 'user_002',
      dueDate: DateTime(2026, 2, 10),
      createdAt: DateTime(2025, 12, 5),
    ),
    TaskEntity(
      id: 'task_3',
      projectId: 'proj_1',
      title: 'Task 3',
      description: 'Desc 3',
      status: 'done',
      priority: 'low',
      assigneeId: null,
      dueDate: DateTime(2026, 1, 20),
      createdAt: DateTime(2025, 12, 10),
    ),
    TaskEntity(
      id: 'task_4',
      projectId: 'proj_1',
      title: 'Task 4',
      description: 'Desc 4',
      status: 'todo',
      priority: 'urgent',
      assigneeId: 'user_001',
      dueDate: DateTime(2026, 3, 1),
      createdAt: DateTime(2026, 1, 1),
    ),
  ];

  List<TaskEntity> applyFilter(List<TaskEntity> tasks, TaskFilter filter) {
    return tasks.where((task) {
      if (filter.status != null && task.status != filter.status) return false;
      if (filter.priority != null && task.priority != filter.priority) {
        return false;
      }
      if (filter.assigneeId != null && task.assigneeId != filter.assigneeId) {
        return false;
      }
      if (filter.dueDateFrom != null && task.dueDate != null) {
        if (task.dueDate!.isBefore(filter.dueDateFrom!)) return false;
      }
      if (filter.dueDateTo != null && task.dueDate != null) {
        if (task.dueDate!.isAfter(filter.dueDateTo!)) return false;
      }
      return true;
    }).toList();
  }

  group('TaskFilter', () {
    test('empty filter returns all tasks', () {
      const filter = TaskFilter();
      expect(filter.isActive, false);
      expect(applyFilter(testTasks, filter).length, 4);
    });

    test('filter by status=todo returns only todo tasks', () {
      const filter = TaskFilter(status: 'todo');
      expect(filter.isActive, true);
      final results = applyFilter(testTasks, filter);
      expect(results.length, 2);
      expect(results.every((t) => t.status == 'todo'), true);
    });

    test('filter by priority=high returns only high priority', () {
      const filter = TaskFilter(priority: 'high');
      final results = applyFilter(testTasks, filter);
      expect(results.length, 1);
      expect(results.first.id, 'task_1');
    });

    test('filter by assignee returns only that user\'s tasks', () {
      const filter = TaskFilter(assigneeId: 'user_001');
      final results = applyFilter(testTasks, filter);
      expect(results.length, 2);
      expect(results.every((t) => t.assigneeId == 'user_001'), true);
    });

    test('filter by due date range returns tasks within range', () {
      final filter = TaskFilter(
        dueDateFrom: DateTime(2026, 1, 10),
        dueDateTo: DateTime(2026, 2, 1),
      );
      final results = applyFilter(testTasks, filter);
      expect(results.length, 2); // task_1 (Jan 15) and task_3 (Jan 20)
    });

    test('combined filters narrow results', () {
      const filter = TaskFilter(status: 'todo', assigneeId: 'user_001');
      final results = applyFilter(testTasks, filter);
      expect(results.length, 2);
    });

    test('activeCount reflects number of active criteria', () {
      const filter1 = TaskFilter(status: 'todo');
      expect(filter1.activeCount, 1);

      const filter2 = TaskFilter(status: 'todo', priority: 'high');
      expect(filter2.activeCount, 2);

      final filter3 = TaskFilter(
        status: 'todo',
        priority: 'high',
        dueDateFrom: DateTime(2026, 1, 1),
      );
      expect(filter3.activeCount, 3);
    });

    test('copyWith creates modified copy', () {
      const original = TaskFilter(status: 'todo', priority: 'high');
      final modified = original.copyWith(status: () => 'done');
      expect(modified.status, 'done');
      expect(modified.priority, 'high');
    });

    test('copyWith can nullify fields', () {
      const original = TaskFilter(status: 'todo');
      final modified = original.copyWith(status: () => null);
      expect(modified.status, isNull);
      expect(modified.isActive, false);
    });
  });

  group('TaskEntity', () {
    test('isOverdue returns true when due date is in the past', () {
      final pastTask = TaskEntity(
        id: 'past',
        projectId: 'proj_1',
        title: 'Past task',
        description: '',
        status: 'todo',
        priority: 'high',
        dueDate: DateTime(2020, 1, 1),
        createdAt: DateTime(2019, 12, 1),
      );
      expect(pastTask.isOverdue, true);
    });

    test('isOverdue returns false when status is done', () {
      final doneTask = TaskEntity(
        id: 'done',
        projectId: 'proj_1',
        title: 'Done task',
        description: '',
        status: 'done',
        priority: 'high',
        dueDate: DateTime(2020, 1, 1),
        createdAt: DateTime(2019, 12, 1),
      );
      expect(doneTask.isOverdue, false);
    });

    test('isOverdue returns false when no due date', () {
      final noDueTask = TaskEntity(
        id: 'nodue',
        projectId: 'proj_1',
        title: 'No due task',
        description: '',
        status: 'todo',
        priority: 'high',
        dueDate: null,
        createdAt: DateTime(2019, 12, 1),
      );
      expect(noDueTask.isOverdue, false);
    });

    test('isAssigned returns true when assigneeId is set', () {
      expect(testTasks[0].isAssigned, true);
      expect(testTasks[2].isAssigned, false);
    });

    test('isDone returns true only for done status', () {
      expect(testTasks[2].isDone, true);
      expect(testTasks[0].isDone, false);
    });
  });
}
