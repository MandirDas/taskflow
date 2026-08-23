import '../entities/project_entity.dart';

/// Abstract repository for project operations.
/// Interface designed to be swappable for real HTTP implementation.

abstract class ProjectRepository {
  /// Get all projects for a specific organization.
  Future<List<ProjectEntity>> getProjectsByOrgId(String orgId);

  /// Get a single project by ID.
  Future<ProjectEntity> getProjectById(String id);

  /// Create a new project.
  Future<ProjectEntity> createProject({
    required String orgId,
    required String name,
    required String description,
  });

  /// Update an existing project.
  Future<ProjectEntity> updateProject({
    required String id,
    required String name,
    required String description,
  });

  /// Delete a project by ID when the actor is an admin in its organization.
  Future<void> deleteProject(
    String id, {
    required String actorOrgId,
    required String actorRole,
  });
}
