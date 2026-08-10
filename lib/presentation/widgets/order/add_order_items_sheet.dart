import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/domain/entities/cart_item.dart';
import 'package:my_resturant/domain/entities/recipe.dart';
import 'package:my_resturant/presentation/widgets/shared/app_image.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/presentation/widgets/shared/pressable_scale.dart';

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

  int get _totalCount {
    var sum = 0;
    for (final q in _selection.values) {
      sum += q;
    }
    return sum;
  }

  double get _totalPrice {
    var sum = 0.0;
    for (final r in widget.recipes) {
      final q = _selection[r.id] ?? 0;
      if (q > 0) sum += r.price * q;
    }
    return sum;
  }

  void _inc(Recipe r) => setState(() => _selection[r.id] = (_selection[r.id] ?? 0) + 1);
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

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    String t(String key) => Tr.get(key, settings.locale);
    final cs = Theme.of(context).colorScheme;
    final screen = R.screenSize(context);
    final isDesktop = screen == ScreenSize.desktop;
    final isTablet = screen == ScreenSize.tablet;
    final radius = isDesktop ? 28.0 : isTablet ? 24.0 : 20.0;
    final meals = _available;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(color: cs.onSurfaceVariant.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: EdgeInsets.fromLTRB(isDesktop ? 24 : 16, 14, isDesktop ? 24 : 16, 8),
              child: Row(children: [
                Expanded(child: Text(t('add_items'), style: TextStyle(fontSize: isDesktop ? 18 : 16, fontWeight: FontWeight.w800, color: cs.onSurface))),
                if (_totalCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(20)),
                    child: Text(t('items').replaceAll('{count}', '$_totalCount'),
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.primary)),
                  ),
              ]),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 16),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v),
                style: TextStyle(fontSize: 14, color: cs.onSurface),
                decoration: InputDecoration(
                  hintText: t('search_hint'),
                  hintStyle: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
                  prefixIcon: const Icon(Icons.search, size: 20),
                  filled: true,
                  fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: meals.isEmpty
                  ? Center(child: Text(t('add_items_empty'), style: TextStyle(color: cs.onSurfaceVariant)))
                  : ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.fromLTRB(isDesktop ? 24 : 16, 4, isDesktop ? 24 : 16, 8),
                      itemCount: meals.length,
                      itemBuilder: (ctx, i) {
                        final r = meals[i];
                        final qty = _selection[r.id] ?? 0;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(children: [
                            ClipRRect(borderRadius: BorderRadius.circular(8), child: AppImage(r.imageUrl, width: 46, height: 46, fit: BoxFit.cover)),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(r.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 2),
                              Text('${r.price.toInt()} ${t('currency_suffix')}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                            ])),
                            const SizedBox(width: 8),
                            if (qty == 0)
                              PressableScale(
                                onTap: () => _inc(r),
                                child: Container(
                                  width: 34, height: 34,
                                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                                  child: const Icon(Icons.add, size: 20, color: Colors.white),
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                height: 34,
                                decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.primary, width: 1.5)),
                                child: Row(mainAxisSize: MainAxisSize.min, children: [
                                  InkWell(onTap: () => _dec(r), borderRadius: BorderRadius.circular(8),
                                    child: const SizedBox(width: 28, height: 30, child: Icon(Icons.remove, size: 18, color: AppColors.primary))),
                                  Text('$qty', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.primary)),
                                  InkWell(onTap: () => _inc(r), borderRadius: BorderRadius.circular(8),
                                    child: const SizedBox(width: 28, height: 30, child: Icon(Icons.add, size: 18, color: AppColors.primary))),
                                ]),
                              ),
                          ]),
                        );
                      },
                    ),
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(isDesktop ? 24 : 16, 8, isDesktop ? 24 : 16, isDesktop ? 16 : 12),
                child: SizedBox(
                  width: double.infinity,
                  height: isDesktop ? 52 : 46,
                  child: PressableScale(
                    onTap: _totalCount == 0
                        ? null
                        : () {
                            final items = <CartItem>[];
                            for (final r in widget.recipes) {
                              final q = _selection[r.id] ?? 0;
                              if (q > 0) items.add(CartItem(recipe: r, quantity: q));
                            }
                            Navigator.pop(context, items);
                          },
                    child: FilledButton(
                      onPressed: null,
                      style: FilledButton.styleFrom(
                        backgroundColor: _totalCount == 0 ? cs.surfaceContainerHighest : AppColors.primary,
                        disabledBackgroundColor: cs.surfaceContainerHighest,
                        disabledForegroundColor: cs.onSurfaceVariant,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        _totalCount == 0
                            ? t('add_to_order')
                            : '${t('add_to_order')}  (${_totalPrice.toInt()} ${t('currency_suffix')})',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
