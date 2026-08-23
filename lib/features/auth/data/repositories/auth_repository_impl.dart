import 'package:uuid/uuid.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../../../data/datasources/mock_data_source.dart';
import '../../domain/entities/user_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';

/// Implementation of AuthRepository using mock data and secure local storage.

class AuthRepositoryImpl implements AuthRepository {
  final MockDataSource mockDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.mockDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<UserSession> login({
    required String email,
    required String password,
  }) async {
    if (!networkInfo.isConnected) {
      throw const NetworkException(message: 'No internet connection');
    }

    // Validate credentials against mock data
    final credential =
        await mockDataSource.validateCredentials(email, password);
    if (credential == null) {
      throw const UnauthorizedException(
        message: 'Invalid email or password',
      );
    }

    // Get the mock token response
    final tokenResponse = await mockDataSource.getMockLoginResponse();

    // Get user details
    final user = await mockDataSource.getUserByEmail(email);
    if (user == null) {
      throw const NotFoundException(message: 'User not found');
    }

    final now = DateTime.now();
    // Generate unique tokens per session
    final accessToken =
        '${tokenResponse.accessToken}.${now.millisecondsSinceEpoch}';
    final refreshToken =
        '${tokenResponse.refreshToken}.${now.millisecondsSinceEpoch}';

    // Save tokens securely
    await localDataSource.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: user.id,
      orgId: credential.orgId,
      role: credential.role,
    );

    return UserSession(
      userId: user.id,
      email: user.email,
      name: user.name,
      orgId: credential.orgId,
      role: credential.role,
      accessToken: accessToken,
      refreshToken: refreshToken,
      tokenIssuedAt: now,
    );
  }

  @override
  Future<UserSession> register({
    required String name,
    required String email,
    required String password,
  }) async {
    if (!networkInfo.isConnected) {
      throw const NetworkException(message: 'No internet connection');
    }

    // Simulate registration — in real app this would call the backend
    // For mock purposes, we create a local session without persisting user
    final now = DateTime.now();
    const uuid = Uuid();
    final userId = 'user_${uuid.v4().substring(0, 8)}';
    const orgId = 'org_a1b2c3'; // Default to first org for demo
    const accessToken = 'mock.access.token.registered';
    const refreshToken = 'mock.refresh.token.registered';

    await localDataSource.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: userId,
      orgId: orgId,
      role: 'member',
    );

    return UserSession(
      userId: userId,
      email: email,
      name: name,
      orgId: orgId,
      role: 'member',
      accessToken: accessToken,
      refreshToken: refreshToken,
      tokenIssuedAt: now,
    );
  }

  @override
  Future<UserSession?> checkSession() async {
    final hasSession = await localDataSource.hasSession();
    if (!hasSession) return null;

    final accessToken = await localDataSource.getAccessToken();
    final refreshToken = await localDataSource.getRefreshToken();
    final userId = await localDataSource.getUserId();
    final orgId = await localDataSource.getOrgId();
    final role = await localDataSource.getUserRole();
    final timestampStr = await localDataSource.getTokenTimestamp();

    if (accessToken == null ||
        refreshToken == null ||
        userId == null ||
        orgId == null ||
        role == null ||
        timestampStr == null) {
      return null;
    }

    final tokenIssuedAt = DateTime.tryParse(timestampStr);
    if (tokenIssuedAt == null) return null;

    // Check if refresh token is expired (7 days)
    final refreshExpiry = tokenIssuedAt.add(const Duration(seconds: 604800));
    if (DateTime.now().isAfter(refreshExpiry)) {
      await localDataSource.clearAll();
      return null;
    }

    // Get user info
    final user = await mockDataSource.getUserById(userId);
    final email = user?.email ?? '';
    final name = user?.name ?? '';

    return UserSession(
      userId: userId,
      email: email,
      name: name,
      orgId: orgId,
      role: role,
      accessToken: accessToken,
      refreshToken: refreshToken,
      tokenIssuedAt: tokenIssuedAt,
    );
  }

  @override
  Future<UserSession> refreshToken() async {
    final session = await checkSession();
    if (session == null) {
      throw const UnauthorizedException(message: 'No active session');
    }

    // Generate a new access token
    final now = DateTime.now();
    final newAccessToken =
        'mock.access.token.refreshed.${now.millisecondsSinceEpoch}';

    await localDataSource.updateAccessToken(newAccessToken);

    return session.copyWith(
      accessToken: newAccessToken,
      tokenIssuedAt: now,
    );
  }

  @override
  Future<void> logout() async {
    await localDataSource.clearAll();
  }

  @override
  Future<bool> isTokenExpired() async {
    final timestampStr = await localDataSource.getTokenTimestamp();
    if (timestampStr == null) return true;

    final tokenIssuedAt = DateTime.tryParse(timestampStr);
    if (tokenIssuedAt == null) return true;

    final expiresAt = tokenIssuedAt.add(const Duration(seconds: 900));
    return DateTime.now().isAfter(expiresAt);
  }
}
