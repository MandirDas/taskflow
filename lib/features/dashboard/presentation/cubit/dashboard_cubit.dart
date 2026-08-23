import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../../projects/domain/repositories/project_repository.dart';
import '../../../tasks/domain/repositories/task_repository.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final ProjectRepository projectRepository;
  final TaskRepository taskRepository;
  final NetworkInfo networkInfo;

  String? _orgId;
  String _userName = '';

  DashboardCubit({
    required this.projectRepository,
    required this.taskRepository,
    required this.networkInfo,
  }) : super(const DashboardInitial());

  Future<void> load({required String orgId, required String userName}) async {
    _orgId = orgId;
    _userName = userName;
    emit(const DashboardLoading());
    try {
      final projects = await projectRepository.getProjectsByOrgId(orgId);
      if (projects.isEmpty) {
        emit(DashboardEmpty(
          userName: userName,
          isOffline: !networkInfo.isConnected,
        ));
        return;
      }
      final tasks = await taskRepository.getTasksByOrgProjects(
        projects.map((project) => project.id).toList(),
      );
      emit(DashboardSuccess(
        userName: userName,
        projects: projects,
        tasks: tasks,
        isOffline: !networkInfo.isConnected,
      ));
    } on NetworkException catch (error) {
      emit(DashboardError(message: error.message));
    } on ServerException catch (error) {
      emit(DashboardError(message: error.message));
    } catch (error) {
      emit(DashboardError(message: 'Could not load your workspace: $error'));
    }
  }

  Future<void> refresh() async {
    if (_orgId != null) await load(orgId: _orgId!, userName: _userName);
  }
}
