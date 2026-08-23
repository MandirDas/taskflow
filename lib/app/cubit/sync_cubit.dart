import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../core/network/network_info.dart';
import '../../core/services/pending_operations_queue.dart';
import '../../features/projects/domain/repositories/project_repository.dart';
import '../../features/tasks/domain/repositories/task_repository.dart';

/// State for the sync queue.
class SyncState extends Equatable {
  final int pendingCount;
  final bool isSyncing;
  final List<SyncResult> lastResults;

  const SyncState({
    this.pendingCount = 0,
    this.isSyncing = false,
    this.lastResults = const [],
  });

  SyncState copyWith({
    int? pendingCount,
    bool? isSyncing,
    List<SyncResult>? lastResults,
  }) {
    return SyncState(
      pendingCount: pendingCount ?? this.pendingCount,
      isSyncing: isSyncing ?? this.isSyncing,
      lastResults: lastResults ?? this.lastResults,
    );
  }

  @override
  List<Object> get props => [pendingCount, isSyncing, lastResults];
}

/// Manages the offline queue and automatic sync on reconnect.
class SyncCubit extends Cubit<SyncState> {
  final PendingOperationsQueue queue;
  final NetworkInfo networkInfo;
  final ProjectRepository projectRepository;
  final TaskRepository taskRepository;
  late final StreamSubscription<bool> _connectivitySubscription;

  static const _uuid = Uuid();

  SyncCubit({
    required this.queue,
    required this.networkInfo,
    required this.projectRepository,
    required this.taskRepository,
  }) : super(SyncState(pendingCount: queue.count)) {
    _connectivitySubscription =
        networkInfo.onConnectivityChanged.listen(_onConnectivityChanged);
  }

  void _onConnectivityChanged(bool connected) {
    if (connected && queue.hasPending) {
      syncAll();
    }
  }

  /// Queue an operation for later sync. Used when the device is offline.
  Future<void> enqueue(OperationType type, Map<String, dynamic> params) async {
    final operation = PendingOperation(
      id: _uuid.v4(),
      type: type,
      params: params,
      createdAt: DateTime.now(),
    );
    await queue.enqueue(operation);
    emit(state.copyWith(pendingCount: queue.count));
  }

  /// Attempt to sync all pending operations sequentially.
  Future<void> syncAll() async {
    if (state.isSyncing || !networkInfo.isConnected || !queue.hasPending) {
      return;
    }

    emit(state.copyWith(isSyncing: true));
    final results = <SyncResult>[];

    final operations = queue.getAll();
    for (final op in operations) {
      try {
        await _executeOperation(op);
        await queue.remove(op.id);
        results.add(SyncResult(operation: op, success: true));
      } catch (e) {
        await queue.markRetried(op.id);
        results.add(SyncResult(operation: op, success: false, error: '$e'));
      }
    }

    emit(SyncState(
      pendingCount: queue.count,
      isSyncing: false,
      lastResults: results,
    ));
  }

  /// Clear all pending operations.
  Future<void> clearQueue() async {
    await queue.clearAll();
    emit(state.copyWith(pendingCount: 0, lastResults: []));
  }

  Future<void> _executeOperation(PendingOperation op) async {
    switch (op.type) {
      case OperationType.createProject:
        await projectRepository.createProject(
          orgId: op.params['orgId'] as String,
          name: op.params['name'] as String,
          description: op.params['description'] as String? ?? '',
        );
      case OperationType.updateProject:
        await projectRepository.updateProject(
          id: op.params['id'] as String,
          name: op.params['name'] as String,
          description: op.params['description'] as String? ?? '',
        );
      case OperationType.deleteProject:
        await projectRepository.deleteProject(
          op.params['id'] as String,
          actorOrgId: op.params['actorOrgId'] as String,
          actorRole: op.params['actorRole'] as String,
        );
      case OperationType.createTask:
        await taskRepository.createTask(
          projectId: op.params['projectId'] as String,
          title: op.params['title'] as String,
          description: op.params['description'] as String? ?? '',
          priority: op.params['priority'] as String? ?? 'medium',
          assigneeId: op.params['assigneeId'] as String?,
          dueDate: op.params['dueDate'] != null
              ? DateTime.parse(op.params['dueDate'] as String)
              : null,
        );
      case OperationType.updateTask:
        await taskRepository.updateTask(
          id: op.params['id'] as String,
          title: op.params['title'] as String?,
          description: op.params['description'] as String?,
          priority: op.params['priority'] as String?,
          status: op.params['status'] as String?,
        );
      case OperationType.deleteTask:
        await taskRepository.deleteTask(op.params['id'] as String);
      case OperationType.assignTask:
        await taskRepository.assignTask(
          op.params['taskId'] as String,
          op.params['userId'] as String,
        );
      case OperationType.unassignTask:
        await taskRepository.assignTask(
          op.params['taskId'] as String,
          null,
        );
      case OperationType.updateTaskStatus:
        await taskRepository.updateTask(
          id: op.params['id'] as String,
          status: op.params['status'] as String,
        );
    }
  }

  @override
  Future<void> close() {
    _connectivitySubscription.cancel();
    return super.close();
  }
}
