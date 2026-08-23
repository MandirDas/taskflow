import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

/// Tracks user inactivity and emits a timeout event.
/// The parent widget should feed activity signals and session timeout duration.
class InactivityCubit extends Cubit<InactivityState> {
  Timer? _timer;
  Duration _timeout;

  InactivityCubit({Duration timeout = Duration.zero})
      : _timeout = timeout,
        super(const InactivityActive());

  /// Update the timeout duration (when settings change).
  void setTimeout(Duration timeout) {
    _timeout = timeout;
    _resetTimer();
  }

  /// Signal that the user interacted with the app.
  void recordActivity() {
    if (state is InactivityTimedOut) return; // Already locked — ignore taps.
    _resetTimer();
    if (state is! InactivityActive) {
      emit(const InactivityActive());
    }
  }

  /// Call when the app goes to background — start timeout immediately
  /// with a shorter effective period for background lock.
  void onAppPaused() {
    _cancelTimer();
    if (_timeout == Duration.zero) return;
    // Use the configured timeout directly even in background.
    _timer = Timer(_timeout, _onTimeout);
  }

  /// Call when the app resumes from background.
  void onAppResumed() {
    // If already timed out, do nothing; otherwise reset normally.
    if (state is! InactivityTimedOut) {
      _resetTimer();
    }
  }

  /// Acknowledge the timeout (parent reacts to this state).
  void acknowledge() {
    emit(const InactivityActive());
  }

  void _resetTimer() {
    _cancelTimer();
    if (_timeout == Duration.zero) return;
    _timer = Timer(_timeout, _onTimeout);
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _onTimeout() {
    emit(const InactivityTimedOut());
  }

  @override
  Future<void> close() {
    _cancelTimer();
    return super.close();
  }
}

/// States for inactivity tracking.
abstract class InactivityState {
  const InactivityState();
}

class InactivityActive extends InactivityState {
  const InactivityActive();
}

class InactivityTimedOut extends InactivityState {
  const InactivityTimedOut();
}
