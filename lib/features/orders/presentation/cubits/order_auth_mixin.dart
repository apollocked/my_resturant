import 'dart:async';

import 'package:my_resturant/core/helpers/network_helper.dart';
import 'package:my_resturant/features/orders/presentation/cubits/order_stream_mixin.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

/// Watches the Supabase auth session and device connectivity so the order
/// streams (which give up with capped backoff while offline) are reloaded the
/// moment the device logs in or comes back online.
mixin OrderAuthMixin on OrderStreamMixin {
  StreamSubscription? _authSub;
  StreamSubscription<bool>? _connSub;
  bool _wasAuthed = false;

  void initLifecycle() {
    _wasAuthed = _sessionActive();
    _authSub = _listenAuth();
    _connSub = NetworkService.instance.onConnectivityChanged.listen(
      _onConnectivityChanged,
    );
  }

  bool _sessionActive() {
    try {
      return Supabase.instance.client.auth.currentSession != null;
    } catch (_) {
      return false;
    }
  }

  StreamSubscription? _listenAuth() {
    try {
      return Supabase.instance.client.auth.onAuthStateChange.listen((state) {
        final authed = state.session != null;
        if (authed && !_wasAuthed) {
          loadAndSubscribe();
        } else if (!authed && _wasAuthed) {
          disposeSubs();
        }
        _wasAuthed = authed;
      });
    } catch (_) {
      return null;
    }
  }

  /// When connectivity comes back, re-fetch everything and re-subscribe to the
  /// realtime streams (they give up with capped backoff while offline).
  void _onConnectivityChanged(bool connected) {
    if (connected && _wasAuthed) {
      loadAndSubscribe();
    }
  }

  Future<void> disposeLifecycle() {
    disposeSubs();
    _authSub?.cancel();
    _connSub?.cancel();
    return Future.value();
  }
}