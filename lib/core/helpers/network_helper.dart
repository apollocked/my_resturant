import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Thrown by the `safeCall` helpers when the device is known to be offline, so
/// callers fail fast instead of waiting for the platform timeout.
class OfflineException implements Exception {
  const OfflineException();
  @override
  String toString() => 'OfflineException: device is offline';
}

/// Best-effort detection of connectivity failures from exceptions raised by
/// Supabase, dart:io or the http package. Used to map failures to the
/// localized `err_network` message.
bool isNetworkError(Object e) {
  if (e is OfflineException ||
      e is TimeoutException ||
      e is SocketException ||
      e is HandshakeException ||
      e is HttpException ||
      e is OSError) {
    return true;
  }
  final s = e.toString().toLowerCase();
  return s.contains('socketexception') ||
      s.contains('offline') ||
      s.contains('handshake') ||
      s.contains('host lookup') ||
      s.contains('failed host') ||
      s.contains('connection failed') ||
      s.contains('connection refused') ||
      s.contains('connection reset') ||
      s.contains('failed to connect') ||
      s.contains('unable to connect') ||
      s.contains('no route to host') ||
      s.contains('unreachable') ||
      s.contains('clientexception') ||
      s.contains('network') ||
      s.contains('internet') ||
      s.contains('timeout');
}

/// Maps an exception to a localized message key: `err_network` for
/// connectivity failures, `error_occurred` otherwise.
String networkErrorKey(Object e) =>
    isNetworkError(e) ? 'err_network' : 'error_occurred';

/// Wraps [call] with a timeout and one automatic retry on network errors
/// (timeout / socket / connection failures). Business-logic exceptions are
/// never caught here. Fails fast when the device is known to be offline.
Future<T> safeCall<T>(Future<T> Function() call) async {
  if (!NetworkService.instance.connected) {
    debugPrint('[safeCall] offline – failing fast');
    throw const OfflineException();
  }
  try {
    return await call().timeout(const Duration(seconds: 15));
  } on TimeoutException {
    debugPrint('[safeCall] timeout – retrying once');
    return await call().timeout(const Duration(seconds: 30));
  } on IOException {
    // SocketException, HandshakeException, etc.
    debugPrint('[safeCall] connection error – retrying once');
    return await call().timeout(const Duration(seconds: 30));
  }
}

/// Like [safeCall] but never retries. Use for non-idempotent writes
/// (e.g. RPCs) where a retry could double-apply the side effect after the
/// first attempt actually succeeded but timed out while responding.
Future<T> safeCallNoRetry<T>(Future<T> Function() call) async {
  if (!NetworkService.instance.connected) {
    debugPrint('[safeCall] offline – failing fast (non-idempotent)');
    throw const OfflineException();
  }
  try {
    return await call().timeout(const Duration(seconds: 20));
  } on TimeoutException {
    debugPrint('[safeCall] timeout – not retrying (non-idempotent)');
    rethrow;
  } on IOException {
    debugPrint('[safeCall] connection error – not retrying (non-idempotent)');
    rethrow;
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
