import '../entities/app_notification.dart';

/// Abstract repository for notification operations.

abstract class NotificationRepository {
  /// Get all notifications for a user.
  Future<List<AppNotification>> getNotificationsByUserId(String userId);

  /// Mark a notification as read.
  Future<AppNotification> markAsRead(String notificationId);

  /// Mark all notifications as read for a user.
  Future<void> markAllAsRead(String userId);

  /// Get unread notification count for a user.
  Future<int> getUnreadCount(String userId);
}
