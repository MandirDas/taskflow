import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/cancellation_token.dart';
import '../../../projects/domain/repositories/project_repository.dart';
import '../../domain/entities/task_filter.dart';
import '../../domain/repositories/task_repository.dart';
import 'task_list_state.dart';

/// Cubit managing the task list screen state.
/// Supports loading by project or across all org projects with filtering.
/// Uses [CancellationToken] to cancel in-flight requests when superseded.

class TaskListCubit extends Cubit<TaskListState> {
  final TaskRepository taskRepository;
  final ProjectRepository projectRepository;

  String? _currentOrgId;
  String? _currentProjectId;
  TaskFilter _currentFilter = const TaskFilter();
  CancellationToken? _activeToken;

  TaskListCubit({
    required this.taskRepository,
    required this.projectRepository,
  }) : super(const TaskListInitial());

  TaskFilter get currentFilter => _currentFilter;

  /// Cancel any in-flight request and issue a fresh token.
  CancellationToken _newToken() {
    _activeToken?.cancel('Superseded by new request');
    final token = CancellationToken();
    _activeToken = token;
    return token;
  }

  /// Load all tasks for the user's org projects.
  Future<void> loadTasksForOrg(String orgId) async {
    _currentOrgId = orgId;
    _currentProjectId = null;
    final token = _newToken();
    emit(const TaskListLoading());
    try {
      final projects = await projectRepository.getProjectsByOrgId(orgId);
      token.throwIfCancelled();
      final projectIds = projects.map((p) => p.id).toList();
      final tasks = await taskRepository.getTasksByOrgProjects(
        projectIds,
        filter: _currentFilter,
      );
      token.throwIfCancelled();

      if (tasks.isEmpty) {
        emit(TaskListEmpty(activeFilter: _currentFilter));
      } else {
        emit(TaskListSuccess(tasks: tasks, activeFilter: _currentFilter));
      }
    } on CancelledException {
      // Request was superseded — do not emit; a newer request is handling state.
    } on NetworkException catch (e) {
      if (!token.isCancelled) emit(TaskListError(message: e.message));
    } catch (e) {
      if (!token.isCancelled) {
        emit(TaskListError(message: 'Failed to load tasks: ${e.toString()}'));
      }
    }
  }

  /// Load tasks for a specific project.
  Future<void> loadTasksForProject(String projectId) async {
    _currentProjectId = projectId;
    final token = _newToken();
    emit(const TaskListLoading());
    try {
      final tasks = await taskRepository.getTasks(
        projectId: projectId,
        filter: _currentFilter,
      );
      token.throwIfCancelled();

      if (tasks.isEmpty) {
        emit(TaskListEmpty(activeFilter: _currentFilter));
      } else {
        emit(TaskListSuccess(tasks: tasks, activeFilter: _currentFilter));
      }
    } on CancelledException {
      // Superseded.
    } on NetworkException catch (e) {
      if (!token.isCancelled) emit(TaskListError(message: e.message));
    } catch (e) {
      if (!token.isCancelled) {
        emit(TaskListError(message: 'Failed to load tasks: ${e.toString()}'));
      }
    }
  }

  /// Apply a filter and reload.
  Future<void> applyFilter(TaskFilter filter) async {
    _currentFilter = filter;
    await _reload();
  }

  /// Clear all filters and reload.
  Future<void> clearFilters() async {
    _currentFilter = const TaskFilter();
    await _reload();
  }

  /// Delete a task.
  Future<void> deleteTask(String taskId) async {
    try {
      await taskRepository.deleteTask(taskId);
      await _reload();
    } catch (e) {
      emit(TaskListError(message: 'Failed to delete task: ${e.toString()}'));
    }
  }

  /// Refresh current list.
  Future<void> refresh() => _reload();

  Future<void> _reload() async {
    if (_currentProjectId != null) {
      await loadTasksForProject(_currentProjectId!);
    } else if (_currentOrgId != null) {
      await loadTasksForOrg(_currentOrgId!);
    }
  }

  @override
  Future<void> close() {
    _activeToken?.cancel('Cubit closed');
    return super.close();
  }
}
