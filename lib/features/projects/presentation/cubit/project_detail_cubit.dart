import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/exceptions.dart';
import '../../../tasks/domain/repositories/task_repository.dart';
import '../../domain/repositories/project_repository.dart';
import 'project_detail_state.dart';

/// Cubit managing the project detail screen state.

class ProjectDetailCubit extends Cubit<ProjectDetailState> {
  final ProjectRepository projectRepository;
  final TaskRepository taskRepository;

  ProjectDetailCubit({
    required this.projectRepository,
    required this.taskRepository,
  }) : super(const ProjectDetailInitial());

  /// Load project details and its tasks.
  Future<void> loadProject(String projectId) async {
    emit(const ProjectDetailLoading());
    try {
      final project = await projectRepository.getProjectById(projectId);
      final tasks = await taskRepository.getTasks(projectId: projectId);

      // Calculate status counts
      final statusCounts = <String, int>{};
      for (final task in tasks) {
        statusCounts[task.status] = (statusCounts[task.status] ?? 0) + 1;
      }

      emit(ProjectDetailSuccess(
        project: project,
        tasks: tasks,
        statusCounts: statusCounts,
      ));
    } on NotFoundException catch (e) {
      emit(ProjectDetailError(message: e.message));
    } on NetworkException catch (e) {
      emit(ProjectDetailError(message: e.message));
    } catch (e) {
      emit(ProjectDetailError(
          message: 'Failed to load project: ${e.toString()}'));
    }
  }
}
