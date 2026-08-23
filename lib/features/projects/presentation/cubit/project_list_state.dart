import 'package:equatable/equatable.dart';
import '../../domain/entities/project_entity.dart';

/// States for the project list screen.

abstract class ProjectListState extends Equatable {
  const ProjectListState();

  @override
  List<Object?> get props => [];
}

class ProjectListInitial extends ProjectListState {
  const ProjectListInitial();
}

class ProjectListLoading extends ProjectListState {
  const ProjectListLoading();
}

class ProjectListSuccess extends ProjectListState {
  final List<ProjectEntity> projects;

  const ProjectListSuccess({required this.projects});

  @override
  List<Object?> get props => [projects];
}

class ProjectListEmpty extends ProjectListState {
  const ProjectListEmpty();
}

class ProjectListError extends ProjectListState {
  final String message;

  const ProjectListError({required this.message});

  @override
  List<Object?> get props => [message];
}
