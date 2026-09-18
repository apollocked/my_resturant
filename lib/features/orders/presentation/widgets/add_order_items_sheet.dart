import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/features/menu/domain/entities/recipe.dart';
import 'package:my_resturant/features/settings/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/features/orders/presentation/widgets/add_items_footer_button.dart';
import 'package:my_resturant/features/orders/presentation/widgets/add_items_search_field.dart';
import 'package:my_resturant/features/orders/presentation/widgets/add_items_sheet_header.dart';
import 'package:my_resturant/features/orders/presentation/widgets/add_items_tile.dart';
import 'package:my_resturant/features/orders/presentation/widgets/add_order_items_selection.dart';
import 'package:my_resturant/shared/empty_state.dart';

class AddOrderItemsSheet extends StatefulWidget {
  final List<Recipe> recipes;
  const AddOrderItemsSheet({super.key, required this.recipes});
  @override
  State<AddOrderItemsSheet> createState() => _AddOrderItemsSheetState();
}

class _AddOrderItemsSheetState extends State<AddOrderItemsSheet> {
  late final AddOrderItemsSelection _sel = AddOrderItemsSelection(
    widget.recipes,
    () => setState(() {}),
  );

  @override
  void dispose() {
    _sel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    String t(String key) => Tr.get(key, settings.locale);
    final cs = Theme.of(context).colorScheme;
    final screen = R.screenSize(context);
    final isDesktop = screen == ScreenSize.desktop;
    final isTablet = screen == ScreenSize.tablet;
    final radius =
        isDesktop ? 28.0 : isTablet ? 24.0 : 20.0;
    final hPad = isDesktop ? 24.0 : 16.0;
    final meals = _sel.available;

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
            count: _sel.totalCount,
            cs: cs,
            isDesktop: isDesktop,
          ),
          AddItemsSearchField(
            controller: _sel.searchController,
            onChanged: _sel.setQuery,
            t: t,
            cs: cs,
            isDesktop: isDesktop,
          ),
          const SizedBox(height: 8),
          Flexible(
            child: meals.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: EmptyState(
                      icon: Icons.search_off_rounded,
                      title: t('add_items_empty'),
                      subtitle: t('add_items_empty_subtitle'),
                      compact: true,
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
                        qty: _sel.qtyOf(r),
                        t: t,
                        cs: cs,
                        onInc: () => _sel.inc(r),
                        onDec: () => _sel.dec(r),
                      );
                    },
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(hPad, 8, hPad, isDesktop ? 16 : 12),
              child: AddItemsFooterButton(
                count: _sel.totalCount,
                totalPrice: _sel.totalPrice,
                t: t,
                cs: cs,
                isDesktop: isDesktop,
                onTap: _sel.totalCount == 0
                    ? null
                    : () => Navigator.pop(context, _sel.submit()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}