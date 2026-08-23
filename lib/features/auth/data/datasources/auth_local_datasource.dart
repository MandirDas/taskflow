import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/utils/constants.dart';

/// Local data source for authentication tokens.
/// Uses FlutterSecureStorage to persist tokens securely.

abstract class AuthLocalDataSource {
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String orgId,
    required String role,
  });
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<String?> getUserId();
  Future<String?> getOrgId();
  Future<String?> getUserRole();
  Future<String?> getTokenTimestamp();
  Future<void> updateAccessToken(String accessToken);
  Future<void> clearAll();
  Future<bool> hasSession();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;

  AuthLocalDataSourceImpl({required this.secureStorage});

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String orgId,
    required String role,
  }) async {
    await Future.wait([
      secureStorage.write(key: AppConstants.accessTokenKey, value: accessToken),
      secureStorage.write(
          key: AppConstants.refreshTokenKey, value: refreshToken),
      secureStorage.write(key: AppConstants.userIdKey, value: userId),
      secureStorage.write(key: AppConstants.orgIdKey, value: orgId),
      secureStorage.write(key: AppConstants.userRoleKey, value: role),
      secureStorage.write(
        key: AppConstants.tokenTimestampKey,
        value: DateTime.now().toIso8601String(),
      ),
    ]);
  }

  @override
  Future<String?> getAccessToken() =>
      secureStorage.read(key: AppConstants.accessTokenKey);

  @override
  Future<String?> getRefreshToken() =>
      secureStorage.read(key: AppConstants.refreshTokenKey);

  @override
  Future<String?> getUserId() =>
      secureStorage.read(key: AppConstants.userIdKey);

  @override
  Future<String?> getOrgId() => secureStorage.read(key: AppConstants.orgIdKey);

  @override
  Future<String?> getUserRole() =>
      secureStorage.read(key: AppConstants.userRoleKey);

  @override
  Future<String?> getTokenTimestamp() =>
      secureStorage.read(key: AppConstants.tokenTimestampKey);

  @override
  Future<void> updateAccessToken(String accessToken) async {
    await secureStorage.write(
        key: AppConstants.accessTokenKey, value: accessToken);
    await secureStorage.write(
      key: AppConstants.tokenTimestampKey,
      value: DateTime.now().toIso8601String(),
    );
  }

  @override
  Future<void> clearAll() => secureStorage.deleteAll();

  @override
  Future<bool> hasSession() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
