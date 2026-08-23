import 'package:equatable/equatable.dart';

/// Filter criteria for task lists.

class TaskFilter extends Equatable {
  final String? status;
  final String? priority;
  final String? assigneeId;
  final DateTime? dueDateFrom;
  final DateTime? dueDateTo;
  final String? projectId;

  const TaskFilter({
    this.status,
    this.priority,
    this.assigneeId,
    this.dueDateFrom,
    this.dueDateTo,
    this.projectId,
  });

  /// Check if any filter is active
  bool get isActive =>
      status != null ||
      priority != null ||
      assigneeId != null ||
      dueDateFrom != null ||
      dueDateTo != null ||
      projectId != null;

  /// Number of active filters
  int get activeCount {
    int count = 0;
    if (status != null) count++;
    if (priority != null) count++;
    if (assigneeId != null) count++;
    if (dueDateFrom != null || dueDateTo != null) count++;
    if (projectId != null) count++;
    return count;
  }

  TaskFilter copyWith({
    String? Function()? status,
    String? Function()? priority,
    String? Function()? assigneeId,
    DateTime? Function()? dueDateFrom,
    DateTime? Function()? dueDateTo,
    String? Function()? projectId,
  }) {
    return TaskFilter(
      status: status != null ? status() : this.status,
      priority: priority != null ? priority() : this.priority,
      assigneeId: assigneeId != null ? assigneeId() : this.assigneeId,
      dueDateFrom: dueDateFrom != null ? dueDateFrom() : this.dueDateFrom,
      dueDateTo: dueDateTo != null ? dueDateTo() : this.dueDateTo,
      projectId: projectId != null ? projectId() : this.projectId,
    );
  }

  /// Reset all filters
  static const TaskFilter empty = TaskFilter();

  @override
  List<Object?> get props =>
      [status, priority, assigneeId, dueDateFrom, dueDateTo, projectId];
}
