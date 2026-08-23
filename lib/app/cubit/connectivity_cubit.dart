import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/network/network_info.dart';

class ConnectivityState extends Equatable {
  final bool isConnected;
  final bool justReconnected;

  const ConnectivityState({
    required this.isConnected,
    this.justReconnected = false,
  });

  bool get isOffline => !isConnected;

  @override
  List<Object> get props => [isConnected, justReconnected];
}

class ConnectivityCubit extends Cubit<ConnectivityState> {
  final NetworkInfo networkInfo;
  late final StreamSubscription<bool> _subscription;
  Timer? _reconnectedTimer;

  ConnectivityCubit({required this.networkInfo})
      : super(ConnectivityState(isConnected: networkInfo.isConnected)) {
    _subscription = networkInfo.onConnectivityChanged.listen(_onChanged);
  }

  void _onChanged(bool connected) {
    final reconnected = connected && !state.isConnected;
    emit(ConnectivityState(
      isConnected: connected,
      justReconnected: reconnected,
    ));
    _reconnectedTimer?.cancel();
    if (reconnected) {
      _reconnectedTimer = Timer(const Duration(seconds: 2), () {
        if (!isClosed) {
          emit(const ConnectivityState(isConnected: true));
        }
      });
    }
  }

  void setConnected(bool connected) => networkInfo.setConnected(connected);

  @override
  Future<void> close() async {
    _reconnectedTimer?.cancel();
    await _subscription.cancel();
    return super.close();
  }
}
