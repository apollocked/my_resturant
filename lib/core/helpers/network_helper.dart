import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Wraps [call] with a timeout and one automatic retry on network errors
/// (timeout / socket). Business-logic exceptions are never caught here.
Future<T> safeCall<T>(Future<T> Function() call) async {
  try {
    return await call().timeout(const Duration(seconds: 20));
  } on TimeoutException {
    debugPrint('[safeCall] timeout – retrying once');
    return await call().timeout(const Duration(seconds: 30));
  } on SocketException {
    debugPrint('[safeCall] socket error – retrying once');
    return await call().timeout(const Duration(seconds: 30));
  }
}

/// Lightweight connectivity singleton.
///
/// Call `NetworkService.instance.init()` once at app start.
/// Other code can read `connected` or listen to `onConnectivityChanged`.
class NetworkService {
  NetworkService._();
  static final instance = NetworkService._();

  bool _connected = true;
  bool get connected => _connected;

  final _controller = StreamController<bool>.broadcast();
  Stream<bool> get onConnectivityChanged => _controller.stream;

  Future<void> init() async {
    final results = await Connectivity().checkConnectivity();
    _connected = results.any((r) => r != ConnectivityResult.none);
    Connectivity().onConnectivityChanged.listen((results) {
      final now = results.any((r) => r != ConnectivityResult.none);
      if (now != _connected) {
        _connected = now;
        _controller.add(now);
      }
    });
  }

  void dispose() => _controller.close();
}
