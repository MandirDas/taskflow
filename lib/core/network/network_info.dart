import 'dart:async';

/// Abstraction for network connectivity status.
/// In this app, connectivity is simulated via a debug toggle.
/// This allows demonstrating offline behavior without real network dependency.

abstract class NetworkInfo {
  /// Whether the app is currently "online"
  bool get isConnected;

  /// Stream of connectivity changes
  Stream<bool> get onConnectivityChanged;

  /// Toggle connectivity state (debug feature)
  void setConnected(bool connected);
}

/// Simulated implementation of NetworkInfo.
/// Default state is connected. Can be toggled via Settings screen.
class SimulatedNetworkInfo implements NetworkInfo {
  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  bool _isConnected = true;

  @override
  bool get isConnected => _isConnected;

  @override
  Stream<bool> get onConnectivityChanged => _controller.stream;

  @override
  void setConnected(bool connected) {
    if (_isConnected != connected) {
      _isConnected = connected;
      _controller.add(connected);
    }
  }

  void dispose() {
    _controller.close();
  }
}
