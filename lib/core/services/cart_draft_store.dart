import 'dart:convert';

import 'package:my_resturant/domain/entities/cart_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartDraft {
  final List<CartItem> items;
  final int selectedTable;
  final Map<String, String> pendingNotes;
  final DateTime createdAt;

  CartDraft({
    required this.items,
    required this.selectedTable,
    required this.pendingNotes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

class CartDraftStore {
  CartDraftStore._();

  static final CartDraftStore instance = CartDraftStore._();

  static const _key = 'cart_draft_v1';

  Future<void> _pending = Future.value();
  SharedPreferences? _prefs;

  Future<CartDraft?> load() async {
    try {
      final prefs = await _ensure();
      final raw = prefs.getString(_key);
      if (raw == null || raw.isEmpty) return null;
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final items =
          (data['items'] as List? ?? const [])
              .map((e) => CartItem.fromMap((e as Map).cast<String, dynamic>()))
              .toList();
      final pending = (data['pendingNotes'] as Map? ?? const {})
          .map((k, v) => MapEntry(k.toString(), v.toString()));
      return CartDraft(
        items: items,
        selectedTable: (data['selectedTable'] as num?)?.toInt() ?? 0,
        pendingNotes: Map<String, String>.from(pending),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> save(CartDraft draft) {
    _pending = _pending.then((_) async {
      try {
        final prefs = await _ensure();
        await prefs.setString(
          _key,
          jsonEncode({
            'items': draft.items.map((i) => i.toMap()).toList(),
            'selectedTable': draft.selectedTable,
            'pendingNotes': draft.pendingNotes,
            'createdAt': draft.createdAt.toIso8601String(),
          }),
        );
      } catch (_) {
        // Persistence must never interrupt order flow.
      }
    });
    return _pending;
  }

  Future<void> clear() {
    _pending = _pending.then((_) async {
      try {
        final prefs = await _ensure();
        await prefs.remove(_key);
      } catch (_) {
        // Best effort; a stale draft is restored harmlessly on next start.
      }
    });
    return _pending;
  }

  Future<SharedPreferences> _ensure() async =>
      _prefs ??= await SharedPreferences.getInstance();
}