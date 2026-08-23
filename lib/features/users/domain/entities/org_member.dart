import 'package:equatable/equatable.dart';

/// Domain entity representing an organization membership record.

class OrgMember extends Equatable {
  final String orgId;
  final String userId;
  final String role;

  const OrgMember({
    required this.orgId,
    required this.userId,
    required this.role,
  });

  bool get isAdmin => role == 'org_admin';
  bool get isMember => role == 'member';

  @override
  List<Object?> get props => [orgId, userId, role];
}
