import 'package:equatable/equatable.dart';

/// Domain entity representing a task.

class TaskEntity extends Equatable {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final String status;
  final String priority;
  final String? assigneeId;
  final DateTime? dueDate;
  final DateTime createdAt;

  const TaskEntity({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    this.assigneeId,
    this.dueDate,
    required this.createdAt,
  });

  bool get isAssigned => assigneeId != null;
  bool get isDone => status == 'done';
  bool get isTodo => status == 'todo';
  bool get isInProgress => status == 'in_progress';
  bool get isInReview => status == 'review';

  bool get isOverdue {
    if (dueDate == null || isDone) return false;
    final now = DateTime.now();
    return dueDate!.isBefore(DateTime(now.year, now.month, now.day));
  }

  TaskEntity copyWith({
    String? id,
    String? projectId,
    String? title,
    String? description,
    String? status,
    String? priority,
    String? Function()? assigneeId,
    DateTime? Function()? dueDate,
    DateTime? createdAt,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      assigneeId: assigneeId != null ? assigneeId() : this.assigneeId,
      dueDate: dueDate != null ? dueDate() : this.dueDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        projectId,
        title,
        description,
        status,
        priority,
        assigneeId,
        dueDate,
        createdAt,
      ];
}
