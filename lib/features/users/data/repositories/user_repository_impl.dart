import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../../../data/datasources/mock_data_source.dart';
import '../../domain/entities/org_member.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';

/// Implementation of UserRepository using mock data source.

class UserRepositoryImpl implements UserRepository {
  final MockDataSource mockDataSource;
  final NetworkInfo networkInfo;

  UserRepositoryImpl({
    required this.mockDataSource,
    required this.networkInfo,
  });

  @override
  Future<List<UserEntity>> getUsers() async {
    if (!networkInfo.isConnected) {
      throw const NetworkException(message: 'No internet connection');
    }
    final models = await mockDataSource.getUsers();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<UserEntity> getUserById(String id) async {
    if (!networkInfo.isConnected) {
      throw const NetworkException(message: 'No internet connection');
    }
    final model = await mockDataSource.getUserById(id);
    if (model == null) {
      throw const NotFoundException(message: 'User not found');
    }
    return model.toEntity();
  }

  @override
  Future<List<OrgMember>> getOrgMembers(String orgId) async {
    if (!networkInfo.isConnected) {
      throw const NetworkException(message: 'No internet connection');
    }
    final models = await mockDataSource.getOrgMembersByOrgId(orgId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<UserEntity>> getOrgMemberUsers(String orgId) async {
    if (!networkInfo.isConnected) {
      throw const NetworkException(message: 'No internet connection');
    }
    final members = await mockDataSource.getOrgMembersByOrgId(orgId);
    final memberUserIds = members.map((m) => m.userId).toSet();
    final allUsers = await mockDataSource.getUsers();
    return allUsers
        .where((u) => memberUserIds.contains(u.id))
        .map((u) => u.toEntity())
        .toList();
  }

  @override
  Future<bool> isUserInOrg(String userId, String orgId) async {
    if (!networkInfo.isConnected) {
      throw const NetworkException(message: 'No internet connection');
    }
    final membership = await mockDataSource.getOrgMembership(orgId, userId);
    return membership != null;
  }

  @override
  Future<OrgMember?> getUserOrgMembership(String userId, String orgId) async {
    if (!networkInfo.isConnected) {
      throw const NetworkException(message: 'No internet connection');
    }
    final model = await mockDataSource.getOrgMembership(orgId, userId);
    return model?.toEntity();
  }
}
