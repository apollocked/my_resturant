import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/domain/entities/recipe.dart';
import 'package:my_resturant/presentation/widgets/menu/menu_desktop_layout.dart';
import 'package:my_resturant/presentation/widgets/menu/menu_mobile_layout.dart';

class MenuLayout extends StatelessWidget {
  const MenuLayout({
    super.key,
    required this.cs,
    required this.t,
    required this.state,
    required this.meals,
    required this.cats,
    required this.selectedIndex,
    required this.onCategoryChanged,
    required this.onSearchChanged,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    required this.onLongPress,
  });

  final ColorScheme cs;
  final String Function(String) t;
  final dynamic state;
  final List<Recipe> meals;
  final List<Map<String, String>> cats;
  final int selectedIndex;
  final ValueChanged<int> onCategoryChanged;
  final ValueChanged<String> onSearchChanged;
  final void Function(Recipe) onIncrement;
  final void Function(Recipe) onDecrement;
  final void Function(Recipe) onRemove;
  final void Function(Recipe) onLongPress;

  @override
  Widget build(BuildContext context) {
    if (R.isDesktop(context)) {
      return MenuDesktopLayout(
        cs: cs,
        t: t,
        state: state,
        meals: meals,
        cats: cats,
        selectedIndex: selectedIndex,
        onCategoryChanged: onCategoryChanged,
        onSearchChanged: onSearchChanged,
        onIncrement: onIncrement,
        onDecrement: onDecrement,
        onRemove: onRemove,
        onLongPress: onLongPress,
      );
    }
    return MenuMobileLayout(
      cs: cs,
      t: t,
      state: state,
      meals: meals,
      cats: cats,
      selectedIndex: selectedIndex,
      onCategoryChanged: onCategoryChanged,
      onSearchChanged: onSearchChanged,
      onIncrement: onIncrement,
      onDecrement: onDecrement,
      onRemove: onRemove,
      onLongPress: onLongPress,
    );
  }
}
