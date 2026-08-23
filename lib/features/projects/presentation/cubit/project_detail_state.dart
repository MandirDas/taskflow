import 'package:equatable/equatable.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../domain/entities/project_entity.dart';

/// States for the project detail screen.

abstract class ProjectDetailState extends Equatable {
  const ProjectDetailState();

  @override
  List<Object?> get props => [];
}

class ProjectDetailInitial extends ProjectDetailState {
  const ProjectDetailInitial();
}

class ProjectDetailLoading extends ProjectDetailState {
  const ProjectDetailLoading();
}

class ProjectDetailSuccess extends ProjectDetailState {
  final ProjectEntity project;
  final List<TaskEntity> tasks;
  final Map<String, int> statusCounts;

  const ProjectDetailSuccess({
    required this.project,
    required this.tasks,
    required this.statusCounts,
  });

  @override
  List<Object?> get props => [project, tasks, statusCounts];
}

class ProjectDetailError extends ProjectDetailState {
  final String message;

  const ProjectDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}
