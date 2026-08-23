import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/features/auth/domain/entities/user_session.dart';

void main() {
  group('UserSession token expiry', () {
    test('isAccessTokenExpired returns false within 15 minutes', () {
      final session = UserSession(
        userId: 'user_001',
        email: 'test@test.com',
        name: 'Test User',
        orgId: 'org_1',
        role: 'member',
        accessToken: 'mock.token',
        refreshToken: 'mock.refresh',
        tokenIssuedAt: DateTime.now().subtract(const Duration(minutes: 10)),
      );
      expect(session.isAccessTokenExpired, false);
    });

    test('isAccessTokenExpired returns true after 15 minutes', () {
      final session = UserSession(
        userId: 'user_001',
        email: 'test@test.com',
        name: 'Test User',
        orgId: 'org_1',
        role: 'member',
        accessToken: 'mock.token',
        refreshToken: 'mock.refresh',
        tokenIssuedAt: DateTime.now().subtract(const Duration(minutes: 20)),
      );
      expect(session.isAccessTokenExpired, true);
    });

    test('isRefreshTokenExpired returns false within 7 days', () {
      final session = UserSession(
        userId: 'user_001',
        email: 'test@test.com',
        name: 'Test User',
        orgId: 'org_1',
        role: 'member',
        accessToken: 'mock.token',
        refreshToken: 'mock.refresh',
        tokenIssuedAt: DateTime.now().subtract(const Duration(days: 3)),
      );
      expect(session.isRefreshTokenExpired, false);
    });

    test('isRefreshTokenExpired returns true after 7 days', () {
      final session = UserSession(
        userId: 'user_001',
        email: 'test@test.com',
        name: 'Test User',
        orgId: 'org_1',
        role: 'member',
        accessToken: 'mock.token',
        refreshToken: 'mock.refresh',
        tokenIssuedAt: DateTime.now().subtract(const Duration(days: 10)),
      );
      expect(session.isRefreshTokenExpired, true);
    });

    test('isOrgAdmin returns true for org_admin role', () {
      final session = UserSession(
        userId: 'user_001',
        email: 'test@test.com',
        name: 'Test User',
        orgId: 'org_1',
        role: 'org_admin',
        accessToken: 'mock.token',
        refreshToken: 'mock.refresh',
        tokenIssuedAt: DateTime.now(),
      );
      expect(session.isOrgAdmin, true);
      expect(session.isMember, false);
    });

    test('isMember returns true for member role', () {
      final session = UserSession(
        userId: 'user_001',
        email: 'test@test.com',
        name: 'Test User',
        orgId: 'org_1',
        role: 'member',
        accessToken: 'mock.token',
        refreshToken: 'mock.refresh',
        tokenIssuedAt: DateTime.now(),
      );
      expect(session.isMember, true);
      expect(session.isOrgAdmin, false);
    });

    test('copyWith creates updated session', () {
      final session = UserSession(
        userId: 'user_001',
        email: 'test@test.com',
        name: 'Test User',
        orgId: 'org_1',
        role: 'member',
        accessToken: 'old.token',
        refreshToken: 'mock.refresh',
        tokenIssuedAt: DateTime(2026, 1, 1),
      );

      final newTime = DateTime.now();
      final refreshed = session.copyWith(
        accessToken: 'new.token',
        tokenIssuedAt: newTime,
      );

      expect(refreshed.accessToken, 'new.token');
      expect(refreshed.tokenIssuedAt, newTime);
      expect(refreshed.userId, 'user_001');
      expect(refreshed.refreshToken, 'mock.refresh');
    });
  });
}
