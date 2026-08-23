import '../entities/comment_entity.dart';
import '../entities/task_entity.dart';
import '../entities/task_filter.dart';

/// Abstract repository for task operations.
/// Interface designed to be swappable for real HTTP implementation.

abstract class TaskRepository {
  /// Get all tasks for a project, optionally filtered.
  Future<List<TaskEntity>> getTasks({
    required String projectId,
    TaskFilter? filter,
  });

  /// Get all tasks across all projects for an org (filtered by project IDs).
  Future<List<TaskEntity>> getTasksByOrgProjects(List<String> projectIds,
      {TaskFilter? filter});

  /// Get a single task by ID.
  Future<TaskEntity> getTaskById(String id);

  /// Create a new task.
  Future<TaskEntity> createTask({
    required String projectId,
    required String title,
    required String description,
    required String priority,
    String? assigneeId,
    DateTime? dueDate,
  });

  /// Update an existing task.
  Future<TaskEntity> updateTask({
    required String id,
    String? title,
    String? description,
    String? status,
    String? priority,
    String? Function()? assigneeId,
    DateTime? Function()? dueDate,
  });

  /// Delete a task by ID.
  Future<void> deleteTask(String id);

  /// Assign a user to a task.
  Future<TaskEntity> assignTask(String taskId, String? userId);

  /// Get comments for a task.
  Future<List<CommentEntity>> getTaskComments(String taskId);

  /// Add a comment to a task.
  Future<CommentEntity> addComment({
    required String taskId,
    required String authorId,
    required String body,
  });
}
