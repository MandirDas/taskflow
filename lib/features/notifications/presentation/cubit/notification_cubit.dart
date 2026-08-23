import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/notification_repository.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository repository;
  String? _userId;

  NotificationCubit({required this.repository})
      : super(const NotificationInitial());

  int get unreadCount => state is NotificationLoaded
      ? (state as NotificationLoaded).unreadCount
      : 0;

  Future<void> load(String userId) async {
    _userId = userId;
    emit(const NotificationLoading());
    try {
      final items = await repository.getNotificationsByUserId(userId);
      emit(items.isEmpty
          ? const NotificationEmpty()
          : NotificationLoaded(notifications: items));
    } catch (error) {
      emit(NotificationError(message: 'Could not load notifications: $error'));
    }
  }

  Future<void> refresh() async {
    if (_userId != null) await load(_userId!);
  }

  void setUnreadOnly(bool value) {
    final current = state;
    if (current is NotificationLoaded) {
      emit(current.copyWith(showUnreadOnly: value));
    }
  }

  Future<void> markAsRead(String id) async {
    final current = state;
    if (current is! NotificationLoaded) return;
    final updatedItems = current.notifications
        .map((item) => item.id == id ? item.copyWith(read: true) : item)
        .toList();
    emit(current.copyWith(notifications: updatedItems));
    try {
      await repository.markAsRead(id);
    } catch (error) {
      emit(current);
      emit(NotificationError(
          message: 'Could not mark notification as read: $error'));
    }
  }

  Future<void> markAllAsRead() async {
    final current = state;
    if (current is! NotificationLoaded || _userId == null) return;
    emit(current.copyWith(isMutating: true));
    try {
      await repository.markAllAsRead(_userId!);
      final items = current.notifications
          .map((item) => item.copyWith(read: true))
          .toList();
      emit(NotificationLoaded(
        notifications: items,
        showUnreadOnly: current.showUnreadOnly,
      ));
    } catch (error) {
      emit(NotificationError(
          message: 'Could not mark notifications as read: $error'));
    }
  }

  void clear() {
    _userId = null;
    emit(const NotificationInitial());
  }
}
