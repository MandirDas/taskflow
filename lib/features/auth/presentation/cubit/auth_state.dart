import 'package:equatable/equatable.dart';
import '../../domain/entities/user_session.dart';

/// Authentication states for the app-level auth cubit.

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state — app just launched, checking session.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Checking if there's an existing session.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// User is authenticated.
class AuthAuthenticated extends AuthState {
  final UserSession session;

  const AuthAuthenticated({required this.session});

  @override
  List<Object?> get props => [session];
}

/// User is not authenticated.
class AuthUnauthenticated extends AuthState {
  final String? message;

  const AuthUnauthenticated({this.message});

  @override
  List<Object?> get props => [message];
}

/// Authentication error (e.g., login failed).
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Session exists but the user must unlock via biometric or PIN.
class AuthLocked extends AuthState {
  final UserSession session;

  const AuthLocked({required this.session});

  @override
  List<Object?> get props => [session];
}
