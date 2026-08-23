import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/exceptions.dart';
import '../../../projects/domain/entities/project_entity.dart';
import '../../../projects/domain/repositories/project_repository.dart';
import '../../../users/domain/entities/user_entity.dart';
import '../../../users/domain/repositories/user_repository.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';

abstract class TaskFormState extends Equatable {
  const TaskFormState();
  @override
  List<Object?> get props => [];
}

class TaskFormInitial extends TaskFormState {
  const TaskFormInitial();
}

class TaskFormLoading extends TaskFormState {
  const TaskFormLoading();
}

class TaskFormReady extends TaskFormState {
  final TaskEntity? existingTask;
  final List<UserEntity> orgMembers;
  final List<ProjectEntity> projects;

  const TaskFormReady({
    this.existingTask,
    this.orgMembers = const [],
    this.projects = const [],
  });

  @override
  List<Object?> get props => [existingTask, orgMembers, projects];
}

class TaskFormSubmitting extends TaskFormState {
  const TaskFormSubmitting();
}

class TaskFormSuccess extends TaskFormState {
  final TaskEntity task;
  const TaskFormSuccess({required this.task});
  @override
  List<Object?> get props => [task];
}

class TaskFormError extends TaskFormState {
  final String message;
  const TaskFormError({required this.message});
  @override
  List<Object?> get props => [message];
}

class TaskFormCubit extends Cubit<TaskFormState> {
  final TaskRepository taskRepository;
  final UserRepository userRepository;
  final ProjectRepository projectRepository;
  final String orgId;

  TaskFormReady? _readyState;

  TaskFormCubit({
    required this.taskRepository,
    required this.userRepository,
    required this.projectRepository,
    required this.orgId,
  }) : super(const TaskFormInitial());

  TaskFormReady? get readyState => _readyState;

  Future<void> initCreate() async {
    emit(const TaskFormLoading());
    try {
      final results = await Future.wait([
        userRepository.getOrgMemberUsers(orgId),
        projectRepository.getProjectsByOrgId(orgId),
      ]);
      _readyState = TaskFormReady(
        orgMembers: results[0] as List<UserEntity>,
        projects: results[1] as List<ProjectEntity>,
      );
      emit(_readyState!);
    } catch (error) {
      emit(TaskFormError(message: 'Failed to load form data: $error'));
    }
  }

  Future<void> initEdit(String taskId) async {
    emit(const TaskFormLoading());
    try {
      final task = await taskRepository.getTaskById(taskId);
      final results = await Future.wait([
        userRepository.getOrgMemberUsers(orgId),
        projectRepository.getProjectsByOrgId(orgId),
      ]);
      _readyState = TaskFormReady(
        existingTask: task,
        orgMembers: results[0] as List<UserEntity>,
        projects: results[1] as List<ProjectEntity>,
      );
      emit(_readyState!);
    } on NotFoundException catch (error) {
      emit(TaskFormError(message: error.message));
    } catch (error) {
      emit(TaskFormError(message: 'Failed to load task: $error'));
    }
  }

  bool _projectIsValid(String projectId) {
    return _readyState?.projects.any(
          (project) => project.id == projectId && project.orgId == orgId,
        ) ??
        false;
  }

  Future<void> createTask({
    required String projectId,
    required String title,
    required String description,
    required String priority,
    String? assigneeId,
    DateTime? dueDate,
  }) async {
    if (!_projectIsValid(projectId)) {
      emit(const TaskFormError(
        message:
            'Select a project from your organization before creating this task.',
      ));
      return;
    }
    emit(const TaskFormSubmitting());
    try {
      final task = await taskRepository.createTask(
        projectId: projectId,
        title: title,
        description: description,
        priority: priority,
        assigneeId: assigneeId,
        dueDate: dueDate,
      );
      emit(TaskFormSuccess(task: task));
    } on ValidationException catch (error) {
      emit(TaskFormError(message: error.message));
    } on NetworkException catch (error) {
      emit(TaskFormError(message: error.message));
    } catch (error) {
      emit(TaskFormError(message: 'Failed to create task: $error'));
    }
  }

  Future<void> updateTask({
    required String taskId,
    required String title,
    required String description,
    required String priority,
    String? assigneeId,
    DateTime? dueDate,
  }) async {
    emit(const TaskFormSubmitting());
    try {
      final task = await taskRepository.updateTask(
        id: taskId,
        title: title,
        description: description,
        priority: priority,
        assigneeId: () => assigneeId,
        dueDate: () => dueDate,
      );
      emit(TaskFormSuccess(task: task));
    } on ValidationException catch (error) {
      emit(TaskFormError(message: error.message));
    } on NetworkException catch (error) {
      emit(TaskFormError(message: error.message));
    } catch (error) {
      emit(TaskFormError(message: 'Failed to update task: $error'));
    }
  }
}
