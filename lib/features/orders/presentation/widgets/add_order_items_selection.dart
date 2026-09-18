import 'package:flutter/material.dart';
import 'package:my_resturant/features/orders/domain/entities/cart_item.dart';
import 'package:my_resturant/features/menu/domain/entities/recipe.dart';

/// Selected-quantity model backing the "add items" bottom sheet. Owns the map,
/// the search text, and the built item list; calls [onChanged] after edits so
/// the owning State can rebuild.
class AddOrderItemsSelection {
  AddOrderItemsSelection(this.recipes, this.onChanged);

  final List<Recipe> recipes;
  final VoidCallback onChanged;
  final Map<String, int> _quantities = {};
  final searchController = TextEditingController();
  String _query = '';

  List<Recipe> get available {
    final all = recipes.where((r) => r.available).toList();
    if (_query.trim().isEmpty) return all;
    return all.where((r) => r.name.contains(_query.trim())).toList();
  }

  int get totalCount =>
      _quantities.values.fold(0, (sum, q) => sum + q);

  double get totalPrice =>
      recipes.fold(0.0, (s, r) => s + (_quantities[r.id] ?? 0) * r.price);

  int qtyOf(Recipe r) => _quantities[r.id] ?? 0;

  void setQuery(String v) {
    _query = v;
    onChanged();
  }

  void inc(Recipe r) {
    _quantities[r.id] = (_quantities[r.id] ?? 0) + 1;
    onChanged();
  }

  void dec(Recipe r) {
    final q = _quantities[r.id] ?? 0;
    if (q <= 1) {
      _quantities.remove(r.id);
    } else {
      _quantities[r.id] = q - 1;
    }
    onChanged();
  }

  List<CartItem> submit() {
    final items = <CartItem>[];
    for (final r in recipes) {
      final q = _quantities[r.id] ?? 0;
      if (q > 0) items.add(CartItem(recipe: r, quantity: q));
    }
    return items;
  }

  void dispose() => searchController.dispose();
}