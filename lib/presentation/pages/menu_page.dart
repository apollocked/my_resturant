import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/domain/entities/recipe.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/presentation/widgets/shared/search_bar_widget.dart';
import 'package:my_resturant/presentation/widgets/admin/category_chip.dart';
import 'package:my_resturant/presentation/widgets/menu/food_card.dart';
import 'package:my_resturant/presentation/widgets/shared/menu_cart_bar.dart';
import 'package:my_resturant/presentation/widgets/menu/notes_dialog.dart';
import 'package:my_resturant/data/models/categories.dart';
import 'package:my_resturant/core/helpers/responsive.dart';

class RestaurantMenuScreen extends StatefulWidget {
  const RestaurantMenuScreen({super.key});
  @override
  State<RestaurantMenuScreen> createState() => _RestaurantMenuScreenState();
}

class _RestaurantMenuScreenState extends State<RestaurantMenuScreen> {
  int _selectedCategoryIndex = 0;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  List<Recipe> _filteredMeals(List<Recipe> allRecipes) {
    var list = allRecipes.where((r) => r.available).toList();
    final key = categories[_selectedCategoryIndex]['key'];
    if (key != 'all') list = list.where((r) => r.category == key).toList();
    if (_searchQuery.isNotEmpty) {
      list = list.where((r) => r.name.contains(_searchQuery)).toList();
    }
    return list;
  }

  void _increment(Recipe r) => context.read<OrderCubit>().addToCart(r);
  void _decrement(Recipe r) =>
      context.read<OrderCubit>().decrementOrRemove(r.id);
  void _remove(Recipe r) =>
      context.read<OrderCubit>().removeFromCartById(r.id);

  Future<void> _notes(Recipe recipe) async {
    if (!mounted) return;
    final orderCubit = context.read<OrderCubit>();
    final s = orderCubit.state;
    final r = await showDialog<String>(
      context: context,
      builder: (_) => NotesDialog(initialNotes: s.getNotes(recipe.id)),
    );
    if (!mounted) return;
    if (r != null) {
      orderCubit.updateNotesByRecipe(recipe.id, r);
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    String t(String key) => Tr.get(key, settings.locale);
    final cs = Theme.of(context).colorScheme;
    final state = context.watch<OrderCubit>().state;
    if (state.selectedTable == 0) return _buildTablePicker();
    final meals = _filteredMeals(state.recipes);

    if (R.isDesktop(context)) {
      return _buildDesktopLayout(cs, t, state, meals);
    }

    return _buildMobileLayout(cs, t, state, meals);
  }

  Widget _buildDesktopLayout(ColorScheme cs, String Function(String) t, dynamic state, List<Recipe> meals) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => context.read<OrderCubit>().refresh(),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 180,
                      padding: EdgeInsets.fromLTRB(R.padding(context), 24, 0, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(t('categories'),
                            style: TextStyle(fontSize: R.fontMd(context), fontWeight: FontWeight.w700, color: cs.onSurface.withValues(alpha: 0.6))),
                          const SizedBox(height: 16),
                          Expanded(
                            child: ListView.builder(
                              itemCount: categories.length,
                              itemBuilder: (context, index) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: CategoryChip(
                                  icon: categories[index]['icon']!,
                                  name: t('cat_${categories[index]['key']!}'),
                                  isSelected: _selectedCategoryIndex == index,
                                  index: index,
                                  onTap: () => setState(() => _selectedCategoryIndex = index),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(R.padding(context), 16, R.padding(context), 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SearchBarWidget(onChanged: (v) => setState(() => _searchQuery = v)),
                            const SizedBox(height: 28),
                            if (meals.isEmpty)
                              SizedBox(height: 200, child: Center(
                                child: Text(t('no_food_found'), style: TextStyle(color: cs.onSurfaceVariant, fontSize: R.fontMd(context))),
                              ))
                            else
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: meals.length,
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  childAspectRatio: R.menuGridAspectRatio(context),
                                  crossAxisSpacing: R.gridSpacing(context),
                                  mainAxisSpacing: R.gridSpacing(context),
                                ),
                                itemBuilder: (context, index) {
                                  final r = meals[index];
                                  return FoodCard(
                                    recipe: r,
                                    quantity: state.getQuantity(r.id),
                                    notes: state.getNotes(r.id),
                                    onIncrement: () => _increment(r),
                                    onDecrement: () => _decrement(r),
                                    onRemove: () => _remove(r),
                                    onLongPress: () => _notes(r),
                                  );
                                },
                              ),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (state.cartCount > 0)
              MenuCartBar(
                cartCount: state.cartCount,
                cartTotal: state.cartTotal.toInt(),
                onViewCart: () => context.go('/cart'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(ColorScheme cs, String Function(String) t, dynamic state, List<Recipe> meals) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => context.read<OrderCubit>().refresh(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(height: R.isTablet(context) ? 20 : 16),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: R.padding(context)),
                        child: SearchBarWidget(onChanged: (v) => setState(() => _searchQuery = v)),
                      ),
                      SizedBox(height: R.isTablet(context) ? 32 : 28),
                      Padding(
                        padding: EdgeInsets.only(right: R.padding(context)),
                        child: Text(t('categories'),
                          style: TextStyle(fontSize: R.isTablet(context) ? 16 : 14, fontWeight: FontWeight.w700, color: cs.onSurface.withValues(alpha: 0.6))),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: R.isTablet(context) ? 48 : 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          reverse: true,
                          itemCount: categories.length,
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) => CategoryChip(
                            icon: categories[index]['icon']!,
                            name: t('cat_${categories[index]['key']!}'),
                            isSelected: _selectedCategoryIndex == index,
                            index: index,
                            onTap: () => setState(() => _selectedCategoryIndex = index),
                          ),
                        ),
                      ),
                      SizedBox(height: R.isTablet(context) ? 28 : 24),
                      if (meals.isEmpty)
                        SizedBox(height: 160, child: Center(
                          child: Text(t('no_food_found'), style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14)),
                        ))
                      else
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: R.padding(context)),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: meals.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: R.menuGridColumns(context),
                              childAspectRatio: R.menuGridAspectRatio(context),
                              crossAxisSpacing: R.gridSpacing(context),
                              mainAxisSpacing: R.gridSpacing(context),
                            ),
                            itemBuilder: (context, index) {
                              final r = meals[index];
                              return FoodCard(
                                recipe: r,
                                quantity: state.getQuantity(r.id),
                                notes: state.getNotes(r.id),
                                onIncrement: () => _increment(r),
                                onDecrement: () => _decrement(r),
                                onRemove: () => _remove(r),
                                onLongPress: () => _notes(r),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
            if (state.cartCount > 0)
              MenuCartBar(
                cartCount: state.cartCount,
                cartTotal: state.cartTotal.toInt(),
                onViewCart: () => context.go('/cart'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTablePicker() {
    final s = context.watch<OrderCubit>().state;
    final settings = context.watch<SettingsCubit>().state;
    String t(String key) => Tr.get(key, settings.locale);
    final cs = Theme.of(context).colorScheme;
    final screen = R.screenSize(context);
    final avatarSize = screen == ScreenSize.desktop ? 140.0 : screen == ScreenSize.tablet ? 120.0 : 100.0;
    final iconSize = screen == ScreenSize.desktop ? 72.0 : screen == ScreenSize.tablet ? 60.0 : 48.0;
    final tableFontSize = screen == ScreenSize.desktop ? 32.0 : screen == ScreenSize.tablet ? 28.0 : 24.0;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(R.padding(context)),
          child: Column(
            children: [
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: R.hp(context, screen == ScreenSize.desktop ? 4 : 2)),
                      Container(
                        width: avatarSize, height: avatarSize,
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary, width: 2),
                        ),
                        child: Icon(Icons.table_restaurant, size: iconSize, color: AppColors.primary),
                      ),
                      SizedBox(height: screen == ScreenSize.desktop ? R.hp(context, 5) : R.hp(context, 3)),
                      Text(t('select_table'), textAlign: TextAlign.center,
                        style: TextStyle(fontSize: screen == ScreenSize.desktop ? R.fontXxl(context) : R.fontXl(context), fontWeight: FontWeight.w800, color: cs.onSurface),
                      ),
                      SizedBox(height: screen == ScreenSize.desktop ? R.hp(context, 4) : R.hp(context, 3)),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: R.tableGridColumns(context),
                          crossAxisSpacing: R.gridSpacing(context),
                          mainAxisSpacing: R.gridSpacing(context),
                          childAspectRatio: 1,
                        ),
                        itemCount: s.tableCount,
                        itemBuilder: (context, i) {
                          final n = i + 1;
                          final locked = s.reservedTables.contains(n);
                          return Material(
                            color: locked ? cs.outline : AppColors.primary,
                            borderRadius: BorderRadius.circular(screen == ScreenSize.desktop ? 18 : 14),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(screen == ScreenSize.desktop ? 18 : 14),
                              onTap: locked ? null : () => context.read<OrderCubit>().setSelectedTable(n),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (locked) ...[
                                    Icon(Icons.lock, color: cs.surface, size: screen == ScreenSize.desktop ? 28 : 20),
                                    const SizedBox(height: 2),
                                    Text('${t('table')} $n', style: TextStyle(color: cs.surface, fontSize: screen == ScreenSize.desktop ? 16 : 13, fontWeight: FontWeight.w600)),
                                  ] else ...[
                                    Text('$n', style: TextStyle(color: cs.surface, fontSize: tableFontSize, fontWeight: FontWeight.w800)),
                                    const SizedBox(height: 2),
                                    Text(t('table'), style: TextStyle(color: cs.surface.withValues(alpha: 0.7), fontSize: screen == ScreenSize.desktop ? 14 : 11)),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
