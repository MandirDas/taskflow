// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectModel _$ProjectModelFromJson(Map<String, dynamic> json) => ProjectModel(
      id: json['id'] as String,
      orgId: json['org_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      taskCount: (json['task_count'] as num).toInt(),
      status: json['status'] as String,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$ProjectModelToJson(ProjectModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'org_id': instance.orgId,
      'name': instance.name,
      'description': instance.description,
      'task_count': instance.taskCount,
      'status': instance.status,
      'created_at': instance.createdAt,
    };
