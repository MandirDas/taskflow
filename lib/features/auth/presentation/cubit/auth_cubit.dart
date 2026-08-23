import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/biometric_service.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

/// Global auth cubit — manages the authentication state for the entire app.
/// Used by the router to determine auth redirects.

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;
  final BiometricService biometricService;

  /// Whether biometric unlock should be required on session resume.
  bool _biometricRequired = false;

  AuthCubit({
    required this.authRepository,
    required this.biometricService,
  }) : super(const AuthInitial());

  /// Set whether biometric is required on next session check.
  void setBiometricRequired(bool required) {
    _biometricRequired = required;
  }

  /// Check if there's an existing valid session on app start.
  Future<void> checkSession({bool biometricEnabled = false}) async {
    emit(const AuthLoading());
    try {
      final session = await authRepository.checkSession();
      if (session != null) {
        // Check if access token is expired and refresh if needed
        if (session.isAccessTokenExpired && !session.isRefreshTokenExpired) {
          final refreshed = await authRepository.refreshToken();
          if (biometricEnabled || _biometricRequired) {
            emit(AuthLocked(session: refreshed));
          } else {
            emit(AuthAuthenticated(session: refreshed));
          }
        } else if (session.isRefreshTokenExpired) {
          await authRepository.logout();
          emit(const AuthUnauthenticated(
              message: 'Session expired. Please login again.'));
        } else {
          if (biometricEnabled || _biometricRequired) {
            emit(AuthLocked(session: session));
          } else {
            emit(AuthAuthenticated(session: session));
          }
        }
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(const AuthUnauthenticated());
    }
  }

  /// Attempt biometric unlock when in locked state.
  Future<void> unlockWithBiometric() async {
    final currentState = state;
    if (currentState is! AuthLocked) return;

    final success = await biometricService.authenticate();
    if (success) {
      _biometricRequired = false;
      emit(AuthAuthenticated(session: currentState.session));
    }
    // On failure, remain in AuthLocked state — user can retry.
  }

  /// Skip biometric and use password re-entry.
  /// In this demo, just unlock directly (avoids full re-login flow for bonus).
  void unlockWithoutBiometric() {
    final currentState = state;
    if (currentState is AuthLocked) {
      _biometricRequired = false;
      emit(AuthAuthenticated(session: currentState.session));
    }
  }

  /// Lock the session (used by inactivity timeout).
  void lockSession() {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      _biometricRequired = true;
      emit(AuthLocked(session: currentState.session));
    }
  }

  /// Login with email and password.
  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());
    try {
      final session = await authRepository.login(
        email: email,
        password: password,
      );
      _biometricRequired = false;
      emit(AuthAuthenticated(session: session));
    } catch (e) {
      emit(AuthError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  /// Register a new user.
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());
    try {
      final session = await authRepository.register(
        name: name,
        email: email,
        password: password,
      );
      _biometricRequired = false;
      emit(AuthAuthenticated(session: session));
    } catch (e) {
      emit(AuthError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  /// Refresh the access token.
  Future<void> refreshToken() async {
    try {
      final session = await authRepository.refreshToken();
      emit(AuthAuthenticated(session: session));
    } catch (e) {
      emit(const AuthUnauthenticated(message: 'Session expired'));
    }
  }

  /// Logout and clear session.
  Future<void> logout() async {
    _biometricRequired = false;
    await authRepository.logout();
    emit(const AuthUnauthenticated());
  }
}
