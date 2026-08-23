import 'package:equatable/equatable.dart';

/// Domain entity representing a notification.

class AppNotification extends Equatable {
  final String id;
  final String userId;
  final String type;
  final String? taskId;
  final String message;
  final bool read;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    this.taskId,
    required this.message,
    required this.read,
    required this.createdAt,
  });

  AppNotification copyWith({
    String? id,
    String? userId,
    String? type,
    String? Function()? taskId,
    String? message,
    bool? read,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      taskId: taskId != null ? taskId() : this.taskId,
      message: message ?? this.message,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, userId, type, taskId, message, read, createdAt];
}
