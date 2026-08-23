/// A token that can be used to cancel asynchronous operations.
/// Pass this to data-layer methods; check [isCancelled] after each
/// awaitable point to abort early if the request is no longer needed.
///
/// This mirrors the CancelToken pattern used by libraries like Dio
/// and allows cancellation of local mock-data operations as well as
/// future real HTTP requests.
class CancellationToken {
  bool _isCancelled = false;
  String? _reason;

  /// Whether this token has been cancelled.
  bool get isCancelled => _isCancelled;

  /// The reason the operation was cancelled (if provided).
  String? get reason => _reason;

  /// Cancel this token, causing any operation checking it to abort.
  void cancel([String? reason]) {
    _isCancelled = true;
    _reason = reason;
  }

  /// Throw [CancelledException] if this token has been cancelled.
  /// Call this after each async gap in your operation to check for
  /// cancellation and bail out early.
  void throwIfCancelled() {
    if (_isCancelled) {
      throw CancelledException(reason: _reason);
    }
  }
}

/// Exception thrown when an operation is cancelled via [CancellationToken].
class CancelledException implements Exception {
  final String? reason;

  const CancelledException({this.reason});

  @override
  String toString() =>
      'CancelledException: ${reason ?? 'Operation was cancelled'}';
}
