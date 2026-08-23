import 'package:equatable/equatable.dart';

import '../../domain/entities/app_notification.dart';

sealed class NotificationState extends Equatable {
  const NotificationState();
  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

class NotificationEmpty extends NotificationState {
  const NotificationEmpty();
}

class NotificationLoaded extends NotificationState {
  final List<AppNotification> notifications;
  final bool showUnreadOnly;
  final bool isMutating;

  const NotificationLoaded({
    required this.notifications,
    this.showUnreadOnly = false,
    this.isMutating = false,
  });

  int get unreadCount => notifications.where((item) => !item.read).length;
  List<AppNotification> get visibleNotifications => showUnreadOnly
      ? notifications.where((item) => !item.read).toList()
      : notifications;

  NotificationLoaded copyWith({
    List<AppNotification>? notifications,
    bool? showUnreadOnly,
    bool? isMutating,
  }) =>
      NotificationLoaded(
        notifications: notifications ?? this.notifications,
        showUnreadOnly: showUnreadOnly ?? this.showUnreadOnly,
        isMutating: isMutating ?? this.isMutating,
      );

  @override
  List<Object?> get props => [notifications, showUnreadOnly, isMutating];
}

class NotificationError extends NotificationState {
  final String message;
  const NotificationError({required this.message});
  @override
  List<Object?> get props => [message];
}
