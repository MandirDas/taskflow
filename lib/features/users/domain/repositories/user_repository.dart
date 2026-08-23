import '../entities/org_member.dart';
import '../entities/user_entity.dart';

/// Abstract repository for user and org member operations.

abstract class UserRepository {
  /// Get all users.
  Future<List<UserEntity>> getUsers();

  /// Get a single user by ID.
  Future<UserEntity> getUserById(String id);

  /// Get all members of an organization (user entities + role info).
  Future<List<OrgMember>> getOrgMembers(String orgId);

  /// Get user entities for all members of an organization.
  Future<List<UserEntity>> getOrgMemberUsers(String orgId);

  /// Check if a user belongs to a specific organization.
  Future<bool> isUserInOrg(String userId, String orgId);

  /// Get the role of a user in an organization.
  Future<OrgMember?> getUserOrgMembership(String userId, String orgId);
}
