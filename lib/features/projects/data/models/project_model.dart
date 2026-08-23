import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/project_entity.dart';

part 'project_model.g.dart';

/// Data model for Project, handles JSON serialization.

@JsonSerializable()
class ProjectModel {
  final String id;
  @JsonKey(name: 'org_id')
  final String orgId;
  final String name;
  final String description;
  @JsonKey(name: 'task_count')
  final int taskCount;
  final String status;
  @JsonKey(name: 'created_at')
  final String createdAt;

  const ProjectModel({
    required this.id,
    required this.orgId,
    required this.name,
    required this.description,
    required this.taskCount,
    required this.status,
    required this.createdAt,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) =>
      _$ProjectModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectModelToJson(this);

  /// Convert to domain entity
  ProjectEntity toEntity() => ProjectEntity(
        id: id,
        orgId: orgId,
        name: name,
        description: description,
        taskCount: taskCount,
        status: status,
        createdAt: DateTime.parse(createdAt),
      );

  /// Create from domain entity
  factory ProjectModel.fromEntity(ProjectEntity entity) => ProjectModel(
        id: entity.id,
        orgId: entity.orgId,
        name: entity.name,
        description: entity.description,
        taskCount: entity.taskCount,
        status: entity.status,
        createdAt: entity.createdAt.toIso8601String(),
      );
}
