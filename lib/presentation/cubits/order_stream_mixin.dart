import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/cubits/order_cubit_base.dart';

mixin OrderStreamMixin on OrderCubitBase {
  final List<StreamSubscription> subs = [];
  Timer? pollTimer;
  int gen = 0;

  static const int maxReconnectAttempts = 10;

  Future<void> loadAndSubscribe() async {
    final g = ++gen;
    disposeSubs();
    try {
      final recipes = await repo.loadRecipes();
      final orders = await repo.loadOrders();
      final settings = await repo.loadSettings();
      final cats = await repo.loadCategories();
      applySettings(settings);
      if (!isClosed) {
        emit(
          state.copyWith(
            recipes: recipes,
            orders: orders,
            categories: cats,
            isLoading: false,
          ),
        );
      }
    } catch (e) {
      if (!isClosed) {
        debugPrint('OrderCubit._load error: $e');
        emit(state.copyWith(isLoading: false, errorMessage: errorKey(e)));
      }
    }

    if (isClosed || g != gen) return;

    subscribe(repo.watchOrders, (o) {
      notifier.onOrdersChanged(o);
      if (!isClosed) emit(state.copyWith(orders: o));
    });
    subscribe(repo.watchRecipes, (r) {
      if (!isClosed) emit(state.copyWith(recipes: r));
    });
    subscribe(repo.watchSettings, (s) {
      if (!isClosed) applySettings(s);
    });
    subscribe(repo.watchCategories, (c) {
      if (!isClosed) emit(state.copyWith(categories: c));
    });

    pollTimer = Timer.periodic(const Duration(seconds: 30), (_) => poll());
  }

  void subscribe<T>(
    Stream<T> Function() streamFactory,
    void Function(T) onData,
  ) {
    final sub = streamFactory().listen(
      onData,
      onError: (_, _) => reconnect(streamFactory, onData),
    );
    subs.add(sub);
  }

  void reconnect<T>(
    Stream<T> Function() streamFactory,
    void Function(T) onData, [
    int attempt = 0,
  ]) {
    if (isClosed || attempt >= maxReconnectAttempts) return;
    final delay = Duration(seconds: min(1 << attempt, 30));
    Future.delayed(delay, () {
      if (isClosed) return;
      final sub = streamFactory().listen(
        onData,
        onError: (_, _) => reconnect(streamFactory, onData, attempt + 1),
      );
      subs.add(sub);
    });
  }

  Future<void> poll() async {
    if (isClosed) return;
    try {
      final recipes = await repo.loadRecipes();
      final orders = await repo.loadOrders();
      if (!isClosed) emit(state.copyWith(recipes: recipes, orders: orders));
    } catch (e) {
      debugPrint('OrderCubit.poll error: $e');
    }
  }

  void applySettings(Map<String, String> settings) {
    if (isClosed) return;
    final tableCount = int.tryParse(settings['tableCount'] ?? '10') ?? 10;
    final names = <int, String>{};
    final cleared = <int>{};
    for (final e in settings.entries) {
      if (e.key.startsWith('tableName_')) {
        final n = int.tryParse(e.key.split('_').last);
        if (n != null) names[n] = e.value;
      }
      if (e.key.startsWith('cleared_') && e.value == 'true') {
        final n = int.tryParse(e.key.split('_').last);
        if (n != null) cleared.add(n);
      }
    }
    emit(
      state.copyWith(
        tableCount: tableCount,
        tableNames: names,
        clearedTables: cleared,
      ),
    );
  }

  void disposeSubs() {
    pollTimer?.cancel();
    pollTimer = null;
    for (final s in subs) {
      s.cancel();
    }
    subs.clear();
  }
}
