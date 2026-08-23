import '../../domain/entities/user_session.dart';

/// Abstract repository for authentication operations.
/// This interface is implemented by AuthRepositoryImpl in the data layer.
/// If swapped for real HTTP, only the implementation changes.

abstract class AuthRepository {
  /// Authenticate user with email and password.
  /// Returns UserSession on success, throws on failure.
  Future<UserSession> login({
    required String email,
    required String password,
  });

  /// Register a new user (simulated — stores locally only).
  Future<UserSession> register({
    required String name,
    required String email,
    required String password,
  });

  /// Check if there's an existing valid session.
  /// Returns UserSession if valid, null if no session or expired.
  Future<UserSession?> checkSession();

  /// Refresh the access token using the refresh token.
  /// Returns updated UserSession on success.
  Future<UserSession> refreshToken();

  /// Clear all session data and log out.
  Future<void> logout();

  /// Check if the access token is expired.
  Future<bool> isTokenExpired();
}
