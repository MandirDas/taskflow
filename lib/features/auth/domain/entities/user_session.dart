import 'package:equatable/equatable.dart';

/// Represents the currently authenticated user session.
/// This is the domain entity used by the presentation layer.

class UserSession extends Equatable {
  final String userId;
  final String email;
  final String name;
  final String orgId;
  final String role;
  final String accessToken;
  final String refreshToken;
  final DateTime tokenIssuedAt;

  const UserSession({
    required this.userId,
    required this.email,
    required this.name,
    required this.orgId,
    required this.role,
    required this.accessToken,
    required this.refreshToken,
    required this.tokenIssuedAt,
  });

  bool get isOrgAdmin => role == 'org_admin';
  bool get isMember => role == 'member';

  /// Check if the access token has expired (15 minutes)
  bool get isAccessTokenExpired {
    final expiresAt = tokenIssuedAt.add(const Duration(seconds: 900));
    return DateTime.now().isAfter(expiresAt);
  }

  /// Check if the refresh token has expired (7 days)
  bool get isRefreshTokenExpired {
    final expiresAt = tokenIssuedAt.add(const Duration(seconds: 604800));
    return DateTime.now().isAfter(expiresAt);
  }

  UserSession copyWith({
    String? userId,
    String? email,
    String? name,
    String? orgId,
    String? role,
    String? accessToken,
    String? refreshToken,
    DateTime? tokenIssuedAt,
  }) {
    return UserSession(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      name: name ?? this.name,
      orgId: orgId ?? this.orgId,
      role: role ?? this.role,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenIssuedAt: tokenIssuedAt ?? this.tokenIssuedAt,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        email,
        name,
        orgId,
        role,
        accessToken,
        refreshToken,
        tokenIssuedAt,
      ];
}
