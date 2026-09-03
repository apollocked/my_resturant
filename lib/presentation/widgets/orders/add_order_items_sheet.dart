import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/domain/entities/cart_item.dart';
import 'package:my_resturant/domain/entities/recipe.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/presentation/widgets/orders/add_items_footer_button.dart';
import 'package:my_resturant/presentation/widgets/orders/add_items_search_field.dart';
import 'package:my_resturant/presentation/widgets/orders/add_items_sheet_header.dart';
import 'package:my_resturant/presentation/widgets/orders/add_items_tile.dart';

class AddOrderItemsSheet extends StatefulWidget {
  final List<Recipe> recipes;
  const AddOrderItemsSheet({super.key, required this.recipes});
  @override
  State<AddOrderItemsSheet> createState() => _AddOrderItemsSheetState();
}

class _AddOrderItemsSheetState extends State<AddOrderItemsSheet> {
  final Map<String, int> _selection = {};
  String _query = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Recipe> get _available {
    final all = widget.recipes.where((r) => r.available).toList();
    if (_query.trim().isEmpty) return all;
    return all.where((r) => r.name.contains(_query.trim())).toList();
  }

  int get _totalCount => _selection.values.fold(0, (sum, q) => sum + q);

  double get _totalPrice =>
      widget.recipes.fold(0.0, (s, r) => s + (_selection[r.id] ?? 0) * r.price);

  void _inc(Recipe r) =>
      setState(() => _selection[r.id] = (_selection[r.id] ?? 0) + 1);

  void _dec(Recipe r) {
    setState(() {
      final q = _selection[r.id] ?? 0;
      if (q <= 1) {
        _selection.remove(r.id);
      } else {
        _selection[r.id] = q - 1;
      }
    });
  }

  void _submit() {
    final items = <CartItem>[];
    for (final r in widget.recipes) {
      final q = _selection[r.id] ?? 0;
      if (q > 0) items.add(CartItem(recipe: r, quantity: q));
    }
    Navigator.pop(context, items);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    String t(String key) => Tr.get(key, settings.locale);
    final cs = Theme.of(context).colorScheme;
    final screen = R.screenSize(context);
    final isDesktop = screen == ScreenSize.desktop;
    final isTablet = screen == ScreenSize.tablet;
    final radius = isDesktop
        ? 28.0
        : isTablet
        ? 24.0
        : 20.0;
    final hPad = isDesktop ? 24.0 : 16.0;
    final meals = _available;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AddItemsSheetHeader(
            t: t,
            count: _totalCount,
            cs: cs,
            isDesktop: isDesktop,
          ),
          AddItemsSearchField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _query = v),
            t: t,
            cs: cs,
            isDesktop: isDesktop,
          ),
          const SizedBox(height: 8),
          Flexible(
            child: meals.isEmpty
                ? Center(
                    child: Text(
                      t('add_items_empty'),
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.fromLTRB(hPad, 4, hPad, 8),
                    itemCount: meals.length,
                    itemBuilder: (ctx, i) {
                      final r = meals[i];
                      return AddItemsTile(
                        recipe: r,
                        qty: _selection[r.id] ?? 0,
                        t: t,
                        cs: cs,
                        onInc: () => _inc(r),
                        onDec: () => _dec(r),
                      );
                    },
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(hPad, 8, hPad, isDesktop ? 16 : 12),
              child: AddItemsFooterButton(
                count: _totalCount,
                totalPrice: _totalPrice,
                t: t,
                cs: cs,
                isDesktop: isDesktop,
                onTap: _totalCount == 0 ? null : _submit,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
