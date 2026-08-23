import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import '../../core/error/exceptions.dart';
import '../../core/network/cancellation_token.dart';
import '../../core/utils/constants.dart';
import '../../features/auth/data/models/auth_credentials_model.dart';
import '../../features/auth/data/models/token_response_model.dart';
import '../../features/notifications/data/models/notification_model.dart';
import '../../features/projects/data/models/organization_model.dart';
import '../../features/projects/data/models/project_model.dart';
import '../../features/tasks/data/models/comment_model.dart';
import '../../features/tasks/data/models/task_model.dart';
import '../../features/users/data/models/org_member_model.dart';
import '../../features/users/data/models/user_model.dart';

/// Central data source that reads from the bundled mock-data.json asset.
/// Provides typed access to all collections and simulates network conditions.
///
/// This class is the ONLY place that interacts with the raw JSON asset.
/// All other layers access data through repository interfaces.

class MockDataSource {
  Map<String, dynamic>? _cachedData;
  final Random _random = Random();

  // Debug toggles
  bool forceError = false;
  bool forceTimeout = false;

  /// Load and cache the raw JSON data from the asset bundle.
  Future<Map<String, dynamic>> _loadRawData() async {
    if (_cachedData != null) return _cachedData!;

    final jsonString =
        await rootBundle.loadString(AppConstants.mockDataAssetPath);
    _cachedData = json.decode(jsonString) as Map<String, dynamic>;
    return _cachedData!;
  }

  /// Simulate network delay (300–800ms).
  /// If a [CancellationToken] is provided, the operation can be aborted
  /// during the delay or immediately after.
  Future<void> _simulateDelay({CancellationToken? cancellationToken}) async {
    cancellationToken?.throwIfCancelled();
    final delay = AppConstants.minNetworkDelay +
        _random.nextInt(
            AppConstants.maxNetworkDelay - AppConstants.minNetworkDelay);
    await Future.delayed(Duration(milliseconds: delay));
    cancellationToken?.throwIfCancelled();
  }

  /// Check for error trigger IDs and throw appropriate simulated errors.
  void _checkErrorTrigger(String? id) {
    if (forceError) {
      throw const ServerException(
        message: 'Simulated server error (debug toggle active)',
        statusCode: 500,
      );
    }
    if (forceTimeout) {
      throw const TimeoutException(
        message: 'Simulated network timeout (debug toggle active)',
      );
    }
    if (id == AppConstants.errorNotFoundId) {
      throw const NotFoundException(
        message: 'Simulated 404 — resource not found',
      );
    }
    if (id == AppConstants.errorTimeoutId) {
      throw const TimeoutException(
        message: 'Simulated network timeout',
      );
    }
    if (id == AppConstants.errorValidationId) {
      throw const ValidationException(
        message: 'Simulated validation error',
        fieldErrors: {'title': 'Title is already taken'},
      );
    }
  }

  /// Get a typed list from a top-level JSON key.
  Future<List<Map<String, dynamic>>> _getCollection(String key) async {
    final data = await _loadRawData();
    final collection = data[key];
    if (collection == null) return [];
    return List<Map<String, dynamic>>.from(collection as List);
  }

  // ─── Organizations ─────────────────────────────────────────────────────────

  Future<List<OrganizationModel>> getOrganizations() async {
    await _simulateDelay();
    final items = await _getCollection('organizations');
    return items.map((json) => OrganizationModel.fromJson(json)).toList();
  }

  Future<OrganizationModel?> getOrganizationById(String id) async {
    await _simulateDelay();
    _checkErrorTrigger(id);
    final items = await _getCollection('organizations');
    final match = items.where((item) => item['id'] == id);
    if (match.isEmpty) return null;
    return OrganizationModel.fromJson(match.first);
  }

  // ─── Users ─────────────────────────────────────────────────────────────────

  Future<List<UserModel>> getUsers() async {
    await _simulateDelay();
    final items = await _getCollection('users');
    return items.map((json) => UserModel.fromJson(json)).toList();
  }

  Future<UserModel?> getUserById(String id) async {
    await _simulateDelay();
    _checkErrorTrigger(id);
    final items = await _getCollection('users');
    final match = items.where((item) => item['id'] == id);
    if (match.isEmpty) return null;
    return UserModel.fromJson(match.first);
  }

  Future<UserModel?> getUserByEmail(String email) async {
    await _simulateDelay();
    final items = await _getCollection('users');
    final match = items.where((item) => item['email'] == email);
    if (match.isEmpty) return null;
    return UserModel.fromJson(match.first);
  }

  // ─── Org Members ───────────────────────────────────────────────────────────

  Future<List<OrgMemberModel>> getOrgMembers() async {
    await _simulateDelay();
    final items = await _getCollection('org_members');
    return items.map((json) => OrgMemberModel.fromJson(json)).toList();
  }

  Future<List<OrgMemberModel>> getOrgMembersByOrgId(String orgId) async {
    await _simulateDelay();
    _checkErrorTrigger(orgId);
    final items = await _getCollection('org_members');
    return items
        .where((item) => item['org_id'] == orgId)
        .map((json) => OrgMemberModel.fromJson(json))
        .toList();
  }

  Future<OrgMemberModel?> getOrgMembership(String orgId, String userId) async {
    await _simulateDelay();
    final items = await _getCollection('org_members');
    final match = items.where(
      (item) => item['org_id'] == orgId && item['user_id'] == userId,
    );
    if (match.isEmpty) return null;
    return OrgMemberModel.fromJson(match.first);
  }

  // ─── Projects ──────────────────────────────────────────────────────────────

  Future<List<ProjectModel>> getProjects() async {
    await _simulateDelay();
    final items = await _getCollection('projects');
    return items.map((json) => ProjectModel.fromJson(json)).toList();
  }

  Future<List<ProjectModel>> getProjectsByOrgId(String orgId,
      {CancellationToken? cancellationToken}) async {
    await _simulateDelay(cancellationToken: cancellationToken);
    _checkErrorTrigger(orgId);
    final items = await _getCollection('projects');
    return items
        .where((item) => item['org_id'] == orgId)
        .map((json) => ProjectModel.fromJson(json))
        .toList();
  }

  Future<ProjectModel?> getProjectById(String id) async {
    await _simulateDelay();
    _checkErrorTrigger(id);
    final items = await _getCollection('projects');
    final match = items.where((item) => item['id'] == id);
    if (match.isEmpty) return null;
    return ProjectModel.fromJson(match.first);
  }

  // ─── Tasks ─────────────────────────────────────────────────────────────────

  Future<List<TaskModel>> getTasks() async {
    await _simulateDelay();
    final items = await _getCollection('tasks');
    return items.map((json) => TaskModel.fromJson(json)).toList();
  }

  Future<List<TaskModel>> getTasksByProjectId(String projectId,
      {CancellationToken? cancellationToken}) async {
    await _simulateDelay(cancellationToken: cancellationToken);
    _checkErrorTrigger(projectId);
    final items = await _getCollection('tasks');
    return items
        .where((item) => item['project_id'] == projectId)
        .map((json) => TaskModel.fromJson(json))
        .toList();
  }

  Future<TaskModel?> getTaskById(String id) async {
    await _simulateDelay();
    _checkErrorTrigger(id);
    final items = await _getCollection('tasks');
    final match = items.where((item) => item['id'] == id);
    if (match.isEmpty) return null;
    return TaskModel.fromJson(match.first);
  }

  // ─── Comments ──────────────────────────────────────────────────────────────

  Future<List<CommentModel>> getComments() async {
    await _simulateDelay();
    final items = await _getCollection('comments');
    return items.map((json) => CommentModel.fromJson(json)).toList();
  }

  Future<List<CommentModel>> getCommentsByTaskId(String taskId) async {
    await _simulateDelay();
    _checkErrorTrigger(taskId);
    final items = await _getCollection('comments');
    return items
        .where((item) => item['task_id'] == taskId)
        .map((json) => CommentModel.fromJson(json))
        .toList();
  }

  // ─── Notifications ─────────────────────────────────────────────────────────

  Future<List<NotificationModel>> getNotifications() async {
    await _simulateDelay();
    final items = await _getCollection('notifications');
    return items.map((json) => NotificationModel.fromJson(json)).toList();
  }

  Future<List<NotificationModel>> getNotificationsByUserId(String userId,
      {CancellationToken? cancellationToken}) async {
    await _simulateDelay(cancellationToken: cancellationToken);
    _checkErrorTrigger(userId);
    final items = await _getCollection('notifications');
    return items
        .where((item) => item['user_id'] == userId)
        .map((json) => NotificationModel.fromJson(json))
        .toList();
  }

  // ─── Auth Mock ─────────────────────────────────────────────────────────────

  Future<List<AuthCredentialsModel>> getTestCredentials() async {
    await _simulateDelay();
    final data = await _loadRawData();
    final authMock = data['auth_mock'] as Map<String, dynamic>;
    final credentials = authMock['test_credentials'] as List;
    return credentials
        .map((json) =>
            AuthCredentialsModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<TokenResponseModel> getMockLoginResponse() async {
    await _simulateDelay();
    final data = await _loadRawData();
    final authMock = data['auth_mock'] as Map<String, dynamic>;
    final response = authMock['mock_login_response'] as Map<String, dynamic>;
    return TokenResponseModel.fromJson(response);
  }

  /// Validate credentials against mock data.
  /// Returns the matching credential if valid, null otherwise.
  Future<AuthCredentialsModel?> validateCredentials(
    String email,
    String password,
  ) async {
    await _simulateDelay();
    final credentials = await getTestCredentials();
    try {
      return credentials.firstWhere(
        (cred) => cred.email == email && cred.password == password,
      );
    } catch (_) {
      return null;
    }
  }

  /// Clear the in-memory cache (useful for testing or logout)
  void clearCache() {
    _cachedData = null;
  }
}
