import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/exceptions.dart';
import '../../../users/domain/repositories/user_repository.dart';
import '../../domain/repositories/task_repository.dart';
import 'task_detail_state.dart';

/// Cubit managing the task detail screen state.

class TaskDetailCubit extends Cubit<TaskDetailState> {
  final TaskRepository taskRepository;
  final UserRepository userRepository;
  final String orgId;

  TaskDetailCubit({
    required this.taskRepository,
    required this.userRepository,
    required this.orgId,
  }) : super(const TaskDetailInitial());

  /// Load task details including comments and assignee info.
  /// When [silent] is true, does not emit Loading state (used after mutations).
  Future<void> loadTask(String taskId, {bool silent = false}) async {
    if (!silent) emit(const TaskDetailLoading());
    try {
      final task = await taskRepository.getTaskById(taskId);
      final comments = await taskRepository.getTaskComments(taskId);
      final orgMembers = await userRepository.getOrgMemberUsers(orgId);

      // Get assignee user details
      final assignee = task.assigneeId != null
          ? orgMembers.where((u) => u.id == task.assigneeId).firstOrNull
          : null;

      emit(TaskDetailSuccess(
        task: task,
        comments: comments,
        assignee: assignee,
        orgMembers: orgMembers,
      ));
    } on NotFoundException catch (e) {
      emit(TaskDetailError(message: e.message));
    } on NetworkException catch (e) {
      emit(TaskDetailError(message: e.message));
    } catch (e) {
      emit(TaskDetailError(message: 'Failed to load task: ${e.toString()}'));
    }
  }

  /// Update task status.
  Future<void> updateStatus(String taskId, String newStatus) async {
    try {
      await taskRepository.updateTask(id: taskId, status: newStatus);
      await loadTask(taskId, silent: true);
    } catch (e) {
      emit(
          TaskDetailError(message: 'Failed to update status: ${e.toString()}'));
    }
  }

  /// Update task priority.
  Future<void> updatePriority(String taskId, String newPriority) async {
    try {
      await taskRepository.updateTask(id: taskId, priority: newPriority);
      await loadTask(taskId, silent: true);
    } catch (e) {
      emit(TaskDetailError(
          message: 'Failed to update priority: ${e.toString()}'));
    }
  }

  /// Assign a user to the task.
  Future<void> assignUser(String taskId, String? userId) async {
    try {
      // Business logic validation: check user belongs to org
      if (userId != null) {
        final isInOrg = await userRepository.isUserInOrg(userId, orgId);
        if (!isInOrg) {
          emit(const TaskDetailError(
            message:
                'Cannot assign a user who does not belong to this organization',
          ));
          return;
        }
      }
      await taskRepository.assignTask(taskId, userId);
      await loadTask(taskId, silent: true);
    } catch (e) {
      emit(TaskDetailError(message: 'Failed to assign user: ${e.toString()}'));
    }
  }

  /// Add a comment.
  Future<void> addComment(String taskId, String authorId, String body) async {
    try {
      await taskRepository.addComment(
        taskId: taskId,
        authorId: authorId,
        body: body,
      );
      await loadTask(taskId, silent: true);
    } catch (e) {
      emit(TaskDetailError(message: 'Failed to add comment: ${e.toString()}'));
    }
  }
}
