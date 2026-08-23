import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Types of operations that can be queued while offline.
enum OperationType {
  createProject,
  updateProject,
  deleteProject,
  createTask,
  updateTask,
  deleteTask,
  assignTask,
  unassignTask,
  updateTaskStatus,
}

/// A single pending operation stored for offline-first replay.
class PendingOperation {
  final String id;
  final OperationType type;
  final Map<String, dynamic> params;
  final DateTime createdAt;
  int retryCount;

  PendingOperation({
    required this.id,
    required this.type,
    required this.params,
    required this.createdAt,
    this.retryCount = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'params': params,
        'createdAt': createdAt.toIso8601String(),
        'retryCount': retryCount,
      };

  factory PendingOperation.fromJson(Map<String, dynamic> json) {
    return PendingOperation(
      id: json['id'] as String,
      type: OperationType.values.firstWhere((e) => e.name == json['type']),
      params: Map<String, dynamic>.from(json['params'] as Map),
      createdAt: DateTime.parse(json['createdAt'] as String),
      retryCount: json['retryCount'] as int? ?? 0,
    );
  }
}

/// Result of a sync attempt for a single operation.
class SyncResult {
  final PendingOperation operation;
  final bool success;
  final String? error;

  const SyncResult({
    required this.operation,
    required this.success,
    this.error,
  });
}

/// Persistent queue for operations performed while offline.
/// Operations are serialized to SharedPreferences so they survive app restarts.
class PendingOperationsQueue {
  static const _storageKey = 'taskflow_pending_operations';

  final SharedPreferences _prefs;
  List<PendingOperation> _operations = [];

  PendingOperationsQueue({required SharedPreferences prefs}) : _prefs = prefs {
    _loadFromStorage();
  }

  /// All currently queued operations.
  List<PendingOperation> get operations => List.unmodifiable(_operations);

  /// Whether there are operations pending sync.
  bool get hasPending => _operations.isNotEmpty;

  /// Number of pending operations.
  int get count => _operations.length;

  /// Add a new operation to the queue.
  Future<void> enqueue(PendingOperation operation) async {
    _operations.add(operation);
    await _persist();
  }

  /// Remove a successfully synced operation.
  Future<void> remove(String operationId) async {
    _operations.removeWhere((op) => op.id == operationId);
    await _persist();
  }

  /// Increment retry count for a failed operation.
  Future<void> markRetried(String operationId) async {
    final op = _operations.firstWhere(
      (op) => op.id == operationId,
      orElse: () => throw StateError('Operation not found: $operationId'),
    );
    op.retryCount++;
    // Drop operations that have failed too many times.
    if (op.retryCount >= 3) {
      _operations.remove(op);
    }
    await _persist();
  }

  /// Remove all pending operations (user cleared queue).
  Future<void> clearAll() async {
    _operations.clear();
    await _persist();
  }

  /// Get all operations in insertion order for sequential replay.
  List<PendingOperation> getAll() => List.unmodifiable(_operations);

  void _loadFromStorage() {
    final raw = _prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      _operations = [];
      return;
    }
    try {
      final list = jsonDecode(raw) as List;
      _operations = list
          .map((e) => PendingOperation.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      _operations = [];
    }
  }

  Future<void> _persist() async {
    final json = jsonEncode(_operations.map((op) => op.toJson()).toList());
    await _prefs.setString(_storageKey, json);
  }
}
