import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/repositories/project_repository.dart';
import 'project_list_state.dart';

/// Cubit managing the project list screen state.

class ProjectListCubit extends Cubit<ProjectListState> {
  final ProjectRepository projectRepository;

  ProjectListCubit({required this.projectRepository})
      : super(const ProjectListInitial());

  /// Load projects for the given organization.
  Future<void> loadProjects(String orgId) async {
    emit(const ProjectListLoading());
    try {
      final projects = await projectRepository.getProjectsByOrgId(orgId);
      if (projects.isEmpty) {
        emit(const ProjectListEmpty());
      } else {
        emit(ProjectListSuccess(projects: projects));
      }
    } on NetworkException catch (e) {
      emit(ProjectListError(message: e.message));
    } on ServerException catch (e) {
      emit(ProjectListError(message: e.message));
    } catch (e) {
      emit(ProjectListError(
          message: 'Failed to load projects: ${e.toString()}'));
    }
  }

  /// Delete a project after repository-level organization/role validation.
  Future<void> deleteProject(
    String projectId,
    String orgId, {
    required String actorRole,
  }) async {
    try {
      await projectRepository.deleteProject(
        projectId,
        actorOrgId: orgId,
        actorRole: actorRole,
      );
      // Reload the list after deletion
      await loadProjects(orgId);
    } on UnauthorizedException catch (e) {
      emit(ProjectListError(message: e.message));
    } catch (e) {
      emit(ProjectListError(
          message: 'Failed to delete project: ${e.toString()}'));
    }
  }

  /// Create a new project.
  Future<void> createProject({
    required String orgId,
    required String name,
    required String description,
  }) async {
    try {
      await projectRepository.createProject(
        orgId: orgId,
        name: name,
        description: description,
      );
      await loadProjects(orgId);
    } catch (e) {
      emit(ProjectListError(
          message: 'Failed to create project: ${e.toString()}'));
    }
  }

  /// Update a project.
  Future<void> updateProject({
    required String id,
    required String name,
    required String description,
    required String orgId,
  }) async {
    try {
      await projectRepository.updateProject(
        id: id,
        name: name,
        description: description,
      );
      await loadProjects(orgId);
    } catch (e) {
      emit(ProjectListError(
          message: 'Failed to update project: ${e.toString()}'));
    }
  }
}
