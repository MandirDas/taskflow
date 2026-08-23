import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/app_notification.dart';

part 'notification_model.g.dart';

/// Data model for Notification, handles JSON serialization.

@JsonSerializable()
class NotificationModel {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  final String type;
  @JsonKey(name: 'task_id')
  final String? taskId;
  final String message;
  final bool read;
  @JsonKey(name: 'created_at')
  final String createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    this.taskId,
    required this.message,
    required this.read,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);

  /// Convert to domain entity
  AppNotification toEntity() => AppNotification(
        id: id,
        userId: userId,
        type: type,
        taskId: taskId,
        message: message,
        read: read,
        createdAt: DateTime.parse(createdAt),
      );

  /// Create from domain entity
  factory NotificationModel.fromEntity(AppNotification entity) =>
      NotificationModel(
        id: entity.id,
        userId: entity.userId,
        type: entity.type,
        taskId: entity.taskId,
        message: entity.message,
        read: entity.read,
        createdAt: entity.createdAt.toIso8601String(),
      );
}
