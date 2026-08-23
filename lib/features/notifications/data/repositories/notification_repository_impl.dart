import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../../../data/datasources/mock_data_source.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final MockDataSource mockDataSource;
  final NetworkInfo networkInfo;

  final List<AppNotification> _localNotifications = [];
  final Set<String> _initializedUserIds = {};

  NotificationRepositoryImpl({
    required this.mockDataSource,
    required this.networkInfo,
  });

  Future<void> _ensureInitialized(String userId) async {
    if (_initializedUserIds.contains(userId)) return;
    final models = await mockDataSource.getNotificationsByUserId(userId);
    for (final item in models.map((model) => model.toEntity())) {
      if (!_localNotifications.any((existing) => existing.id == item.id)) {
        _localNotifications.add(item);
      }
    }
    _initializedUserIds.add(userId);
  }

  @override
  Future<List<AppNotification>> getNotificationsByUserId(String userId) async {
    if (!networkInfo.isConnected && !_initializedUserIds.contains(userId)) {
      throw const NetworkException(message: 'No internet connection');
    }
    if (networkInfo.isConnected) await _ensureInitialized(userId);
    return _localNotifications.where((item) => item.userId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<AppNotification> markAsRead(String notificationId) async {
    if (!networkInfo.isConnected) {
      throw const NetworkException(message: 'No internet connection');
    }
    final index =
        _localNotifications.indexWhere((item) => item.id == notificationId);
    if (index == -1) {
      throw const NotFoundException(message: 'Notification not found');
    }
    final updated = _localNotifications[index].copyWith(read: true);
    _localNotifications[index] = updated;
    return updated;
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    if (!networkInfo.isConnected) {
      throw const NetworkException(message: 'No internet connection');
    }
    for (var index = 0; index < _localNotifications.length; index++) {
      if (_localNotifications[index].userId == userId) {
        _localNotifications[index] =
            _localNotifications[index].copyWith(read: true);
      }
    }
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    if (networkInfo.isConnected) await _ensureInitialized(userId);
    return _localNotifications
        .where((item) => item.userId == userId && !item.read)
        .length;
  }
}
