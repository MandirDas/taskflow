import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/constants.dart';
import '../../../../data/datasources/mock_data_source.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/repositories/project_repository.dart';
import '../models/project_model.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final MockDataSource mockDataSource;
  final NetworkInfo networkInfo;
  final SharedPreferences sharedPreferences;

  final List<ProjectEntity> _localProjects = [];
  final Set<String> _deletedIds = {};
  final Set<String> _initializedOrgIds = {};

  ProjectRepositoryImpl({
    required this.mockDataSource,
    required this.networkInfo,
    required this.sharedPreferences,
  });

  Future<void> _ensureInitialized(String orgId) async {
    if (_initializedOrgIds.contains(orgId)) return;
    final models = await mockDataSource.getProjectsByOrgId(orgId);
    final entities = models.map((model) => model.toEntity());
    for (final project in entities) {
      if (!_localProjects.any((existing) => existing.id == project.id)) {
        _localProjects.add(project);
      }
    }
    _initializedOrgIds.add(orgId);
    await _cacheProjects();
  }

  Future<void> _cacheProjects() async {
    final jsonList = _localProjects
        .map((project) => ProjectModel.fromEntity(project).toJson())
        .toList();
    await sharedPreferences.setString(
        AppConstants.cachedProjectsKey, json.encode(jsonList));
  }

  List<ProjectEntity>? _getCachedProjects() {
    final cached = sharedPreferences.getString(AppConstants.cachedProjectsKey);
    if (cached == null) return null;
    try {
      final list = json.decode(cached) as List;
      return list
          .map((item) =>
              ProjectModel.fromJson(item as Map<String, dynamic>).toEntity())
          .toList();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<ProjectEntity>> getProjectsByOrgId(String orgId) async {
    if (!networkInfo.isConnected) {
      final cached = _getCachedProjects();
      if (cached != null) {
        return cached
            .where((project) =>
                project.orgId == orgId && !_deletedIds.contains(project.id))
            .toList();
      }
      throw const NetworkException(
          message: 'No internet connection and no cached data available');
    }
    await _ensureInitialized(orgId);
    return _localProjects
        .where((project) =>
            project.orgId == orgId && !_deletedIds.contains(project.id))
        .toList();
  }

  @override
  Future<ProjectEntity> getProjectById(String id) async {
    if (!networkInfo.isConnected) {
      final match = _getCachedProjects()?.where((project) => project.id == id);
      if (match != null && match.isNotEmpty) return match.first;
      throw const NetworkException(message: 'No internet connection');
    }
    if (_deletedIds.contains(id)) {
      throw const NotFoundException(message: 'Project not found');
    }
    final local = _localProjects.where((project) => project.id == id);
    if (local.isNotEmpty) return local.first;
    final model = await mockDataSource.getProjectById(id);
    if (model == null) {
      throw const NotFoundException(message: 'Project not found');
    }
    final project = model.toEntity();
    _localProjects.add(project);
    _initializedOrgIds.add(project.orgId);
    await _cacheProjects();
    return project;
  }

  @override
  Future<ProjectEntity> createProject(
      {required String orgId,
      required String name,
      required String description}) async {
    if (!networkInfo.isConnected) {
      throw const NetworkException(message: 'No internet connection');
    }
    await _ensureInitialized(orgId);
    const uuid = Uuid();
    final project = ProjectEntity(
      id: 'proj_${uuid.v4().substring(0, 8)}',
      orgId: orgId,
      name: name,
      description: description,
      taskCount: 0,
      status: 'active',
      createdAt: DateTime.now(),
    );
    _localProjects.add(project);
    await _cacheProjects();
    return project;
  }

  @override
  Future<ProjectEntity> updateProject(
      {required String id,
      required String name,
      required String description}) async {
    if (!networkInfo.isConnected) {
      throw const NetworkException(message: 'No internet connection');
    }
    final index = _localProjects.indexWhere((project) => project.id == id);
    if (index == -1) {
      throw const NotFoundException(message: 'Project not found');
    }
    final updated =
        _localProjects[index].copyWith(name: name, description: description);
    _localProjects[index] = updated;
    await _cacheProjects();
    return updated;
  }

  @override
  Future<void> deleteProject(
    String id, {
    required String actorOrgId,
    required String actorRole,
  }) async {
    if (!networkInfo.isConnected) {
      throw const NetworkException(message: 'No internet connection');
    }

    final project = await getProjectById(id);
    if (actorRole != OrgRole.orgAdmin || project.orgId != actorOrgId) {
      throw const UnauthorizedException(
        message: 'You are not authorized to delete this project',
      );
    }

    _localProjects.removeWhere((project) => project.id == id);
    _deletedIds.add(id);
    await _cacheProjects();
  }
}
