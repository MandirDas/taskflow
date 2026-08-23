import 'package:equatable/equatable.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_filter.dart';

/// States for the task list screen.

abstract class TaskListState extends Equatable {
  const TaskListState();

  @override
  List<Object?> get props => [];
}

class TaskListInitial extends TaskListState {
  const TaskListInitial();
}

class TaskListLoading extends TaskListState {
  const TaskListLoading();
}

class TaskListSuccess extends TaskListState {
  final List<TaskEntity> tasks;
  final TaskFilter activeFilter;

  const TaskListSuccess({
    required this.tasks,
    this.activeFilter = const TaskFilter(),
  });

  @override
  List<Object?> get props => [tasks, activeFilter];
}

class TaskListEmpty extends TaskListState {
  final TaskFilter activeFilter;

  const TaskListEmpty({this.activeFilter = const TaskFilter()});

  @override
  List<Object?> get props => [activeFilter];
}

class TaskListError extends TaskListState {
  final String message;

  const TaskListError({required this.message});

  @override
  List<Object?> get props => [message];
}
