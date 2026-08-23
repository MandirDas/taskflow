import 'package:equatable/equatable.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/entities/task_entity.dart';
import '../../../users/domain/entities/user_entity.dart';

/// States for the task detail screen.

abstract class TaskDetailState extends Equatable {
  const TaskDetailState();

  @override
  List<Object?> get props => [];
}

class TaskDetailInitial extends TaskDetailState {
  const TaskDetailInitial();
}

class TaskDetailLoading extends TaskDetailState {
  const TaskDetailLoading();
}

class TaskDetailSuccess extends TaskDetailState {
  final TaskEntity task;
  final List<CommentEntity> comments;
  final UserEntity? assignee;
  final List<UserEntity> orgMembers;

  const TaskDetailSuccess({
    required this.task,
    required this.comments,
    this.assignee,
    this.orgMembers = const [],
  });

  @override
  List<Object?> get props => [task, comments, assignee, orgMembers];
}

class TaskDetailError extends TaskDetailState {
  final String message;

  const TaskDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}
