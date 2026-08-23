import 'package:equatable/equatable.dart';

import '../../../projects/domain/entities/project_entity.dart';
import '../../../tasks/domain/entities/task_entity.dart';

sealed class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardEmpty extends DashboardState {
  final String userName;
  final bool isOffline;

  const DashboardEmpty({required this.userName, this.isOffline = false});

  @override
  List<Object?> get props => [userName, isOffline];
}

class DashboardSuccess extends DashboardState {
  final String userName;
  final List<ProjectEntity> projects;
  final List<TaskEntity> tasks;
  final bool isOffline;

  const DashboardSuccess({
    required this.userName,
    required this.projects,
    required this.tasks,
    this.isOffline = false,
  });

  int get todoCount => tasks.where((task) => task.isTodo).length;
  int get inProgressCount => tasks.where((task) => task.isInProgress).length;
  int get doneCount => tasks.where((task) => task.isDone).length;
  int get overdueCount => tasks.where((task) => task.isOverdue).length;
  double get completion => tasks.isEmpty ? 0 : doneCount / tasks.length;

  List<TaskEntity> get focusTasks {
    final items = tasks.where((task) => !task.isDone).toList()
      ..sort((a, b) {
        if (a.isOverdue != b.isOverdue) return a.isOverdue ? -1 : 1;
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });
    return items.take(4).toList();
  }

  List<TaskEntity> get recentTasks {
    final items = List<TaskEntity>.from(tasks)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items.take(5).toList();
  }

  @override
  List<Object?> get props => [userName, projects, tasks, isOffline];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError({required this.message});

  @override
  List<Object?> get props => [message];
}
