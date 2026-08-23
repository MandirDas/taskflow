// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: json['type'] as String,
      taskId: json['task_id'] as String?,
      message: json['message'] as String,
      read: json['read'] as bool,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$NotificationModelToJson(NotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'type': instance.type,
      'task_id': instance.taskId,
      'message': instance.message,
      'read': instance.read,
      'created_at': instance.createdAt,
    };
