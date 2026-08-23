import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/constants.dart';
import '../../../../data/datasources/mock_data_source.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_filter.dart';
import '../../domain/repositories/task_repository.dart';
import '../models/task_model.dart';

/// Implementation of TaskRepository using mock data source.

class TaskRepositoryImpl implements TaskRepository {
  final MockDataSource mockDataSource;
  final NetworkInfo networkInfo;
  final SharedPreferences sharedPreferences;

  // In-memory storage for mutations
  final List<TaskEntity> _localTasks = [];
  final List<CommentEntity> _localComments = [];
  final Set<String> _deletedTaskIds = {};
  bool _initialized = false;

  TaskRepositoryImpl({
    required this.mockDataSource,
    required this.networkInfo,
    required this.sharedPreferences,
  });

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    final models = await mockDataSource.getTasks();
    _localTasks.addAll(models.map((m) => m.toEntity()));

    final commentModels = await mockDataSource.getComments();
    _localComments.addAll(commentModels.map((m) => m.toEntity()));

    _initialized = true;
    _cacheTasks();
  }

  void _cacheTasks() {
    final jsonList =
        _localTasks.map((t) => TaskModel.fromEntity(t).toJson()).toList();
    sharedPreferences.setString(
      AppConstants.cachedTasksKey,
      json.encode(jsonList),
    );
  }

  List<TaskEntity>? _getCachedTasks() {
    final cached = sharedPreferences.getString(AppConstants.cachedTasksKey);
    if (cached == null) return null;
    try {
      final list = json.decode(cached) as List;
      return list
          .map((j) => TaskModel.fromJson(j as Map<String, dynamic>).toEntity())
          .toList();
    } catch (_) {
      return null;
    }
  }

  List<TaskEntity> _applyFilter(List<TaskEntity> tasks, TaskFilter? filter) {
    if (filter == null || !filter.isActive) return tasks;

    return tasks.where((task) {
      if (filter.status != null && task.status != filter.status) return false;
      if (filter.priority != null && task.priority != filter.priority) {
        return false;
      }
      if (filter.assigneeId != null && task.assigneeId != filter.assigneeId) {
        return false;
      }
      if (filter.projectId != null && task.projectId != filter.projectId) {
        return false;
      }
      if (filter.dueDateFrom != null) {
        if (task.dueDate == null ||
            task.dueDate!.isBefore(filter.dueDateFrom!)) {
          return false;
        }
      }
      if (filter.dueDateTo != null) {
        if (task.dueDate == null || task.dueDate!.isAfter(filter.dueDateTo!)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  @override
  Future<List<TaskEntity>> getTasks({
    required String projectId,
    TaskFilter? filter,
  }) async {
    if (!networkInfo.isConnected) {
      final cached = _getCachedTasks();
      if (cached != null) {
        final filtered = cached.where((t) => t.projectId == projectId).toList();
        return _applyFilter(filtered, filter);
      }
      throw const NetworkException(
        message: 'No internet connection and no cached data available',
      );
    }

    await _ensureInitialized();
    final tasks = _localTasks
        .where(
            (t) => t.projectId == projectId && !_deletedTaskIds.contains(t.id))
        .toList();
    return _applyFilter(tasks, filter);
  }

  @override
  Future<List<TaskEntity>> getTasksByOrgProjects(
    List<String> projectIds, {
    TaskFilter? filter,
  }) async {
    if (!networkInfo.isConnected) {
      final cached = _getCachedTasks();
      if (cached != null) {
        final filtered =
            cached.where((t) => projectIds.contains(t.projectId)).toList();
        return _applyFilter(filtered, filter);
      }
      throw const NetworkException(
        message: 'No internet connection and no cached data available',
      );
    }

    await _ensureInitialized();
    final tasks = _localTasks
        .where((t) =>
            projectIds.contains(t.projectId) && !_deletedTaskIds.contains(t.id))
        .toList();
    return _applyFilter(tasks, filter);
  }

  @override
  Future<TaskEntity> getTaskById(String id) async {
    if (!networkInfo.isConnected) {
      final cached = _getCachedTasks();
      final match = cached?.where((t) => t.id == id);
      if (match != null && match.isNotEmpty) return match.first;
      throw const NetworkException(message: 'No internet connection');
    }

    await _ensureInitialized();

    if (_deletedTaskIds.contains(id)) {
      throw const NotFoundException(message: 'Task not found');
    }

    final match = _localTasks.where((t) => t.id == id);
    if (match.isEmpty) {
      throw const NotFoundException(message: 'Task not found');
    }
    return match.first;
  }

  @override
  Future<TaskEntity> createTask({
    required String projectId,
    required String title,
    required String description,
    required String priority,
    String? assigneeId,
    DateTime? dueDate,
  }) async {
    if (!networkInfo.isConnected) {
      throw const NetworkException(message: 'No internet connection');
    }

    await _ensureInitialized();

    const uuid = Uuid();
    final task = TaskEntity(
      id: 'task_${uuid.v4().substring(0, 8)}',
      projectId: projectId,
      title: title,
      description: description,
      status: 'todo',
      priority: priority,
      assigneeId: assigneeId,
      dueDate: dueDate,
      createdAt: DateTime.now(),
    );

    _localTasks.add(task);
    _cacheTasks();
    return task;
  }

  @override
  Future<TaskEntity> updateTask({
    required String id,
    String? title,
    String? description,
    String? status,
    String? priority,
    String? Function()? assigneeId,
    DateTime? Function()? dueDate,
  }) async {
    if (!networkInfo.isConnected) {
      throw const NetworkException(message: 'No internet connection');
    }

    await _ensureInitialized();

    final index = _localTasks.indexWhere((t) => t.id == id);
    if (index == -1) {
      throw const NotFoundException(message: 'Task not found');
    }

    final current = _localTasks[index];
    final updated = TaskEntity(
      id: current.id,
      projectId: current.projectId,
      title: title ?? current.title,
      description: description ?? current.description,
      status: status ?? current.status,
      priority: priority ?? current.priority,
      assigneeId: assigneeId != null ? assigneeId() : current.assigneeId,
      dueDate: dueDate != null ? dueDate() : current.dueDate,
      createdAt: current.createdAt,
    );

    _localTasks[index] = updated;
    _cacheTasks();
    return updated;
  }

  @override
  Future<void> deleteTask(String id) async {
    if (!networkInfo.isConnected) {
      throw const NetworkException(message: 'No internet connection');
    }

    await _ensureInitialized();
    _localTasks.removeWhere((t) => t.id == id);
    _deletedTaskIds.add(id);
    _cacheTasks();
  }

  @override
  Future<TaskEntity> assignTask(String taskId, String? userId) async {
    return updateTask(
      id: taskId,
      assigneeId: () => userId,
    );
  }

  @override
  Future<List<CommentEntity>> getTaskComments(String taskId) async {
    if (!networkInfo.isConnected) {
      throw const NetworkException(message: 'No internet connection');
    }

    await _ensureInitialized();
    return _localComments.where((c) => c.taskId == taskId).toList();
  }

  @override
  Future<CommentEntity> addComment({
    required String taskId,
    required String authorId,
    required String body,
  }) async {
    if (!networkInfo.isConnected) {
      throw const NetworkException(message: 'No internet connection');
    }

    const uuid = Uuid();
    final comment = CommentEntity(
      id: 'cmt_${uuid.v4().substring(0, 8)}',
      taskId: taskId,
      authorId: authorId,
      body: body,
      createdAt: DateTime.now(),
    );

    _localComments.add(comment);
    return comment;
  }
}
