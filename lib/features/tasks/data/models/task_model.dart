import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/task_entity.dart';

part 'task_model.g.dart';

/// Data model for Task, handles JSON serialization.

@JsonSerializable()
class TaskModel {
  final String id;
  @JsonKey(name: 'project_id')
  final String projectId;
  final String title;
  final String description;
  final String status;
  final String priority;
  @JsonKey(name: 'assignee_id')
  final String? assigneeId;
  @JsonKey(name: 'due_date')
  final String? dueDate;
  @JsonKey(name: 'created_at')
  final String createdAt;

  const TaskModel({
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

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);

  Map<String, dynamic> toJson() => _$TaskModelToJson(this);

  /// Convert to domain entity
  TaskEntity toEntity() => TaskEntity(
        id: id,
        projectId: projectId,
        title: title,
        description: description,
        status: status,
        priority: priority,
        assigneeId: assigneeId,
        dueDate: dueDate != null ? DateTime.parse(dueDate!) : null,
        createdAt: DateTime.parse(createdAt),
      );

  /// Create from domain entity
  factory TaskModel.fromEntity(TaskEntity entity) => TaskModel(
        id: entity.id,
        projectId: entity.projectId,
        title: entity.title,
        description: entity.description,
        status: entity.status,
        priority: entity.priority,
        assigneeId: entity.assigneeId,
        dueDate: entity.dueDate?.toIso8601String().split('T').first,
        createdAt: entity.createdAt.toIso8601String(),
      );
}
