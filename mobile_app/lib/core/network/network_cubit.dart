import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum NetworkState { initial, online, offline }

class NetworkCubit extends Cubit<NetworkState> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _subscription;

  NetworkCubit() : super(NetworkState.initial) {
    _checkInitialStatus();
    
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final hasInternet = !results.contains(ConnectivityResult.none);
      emit(hasInternet ? NetworkState.online : NetworkState.offline);
    });
  }

  Future<void> _checkInitialStatus() async {
    final results = await _connectivity.checkConnectivity();
    final hasInternet = !results.contains(ConnectivityResult.none);
    emit(hasInternet ? NetworkState.online : NetworkState.offline);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}