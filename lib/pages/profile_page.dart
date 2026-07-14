import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/theme/app_theme.dart';
import 'package:my_resturant/models/recipe.dart';
import 'package:my_resturant/data/mock_data.dart';
import 'package:my_resturant/cubits/order_cubit.dart';
import 'package:my_resturant/widgets/action_buttons_row.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primarySoft,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.primary, width: 2),
                ),
                child: const Icon(
                  Icons.person,
                  size: 40,
                  color: AppTheme.primary,
                ),
              ),
            ),

            const SizedBox(height: 12),
            const Center(
              child: Text(
                'بەڕێوەبەر',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Center(
              child: Text(
                'ڕێستۆرانتەکەم',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
            ),
            const SizedBox(height: 10),
            ActionButtonsRow(
              onAddSection: () async {
                final ok = await context.push<bool>('/category-form');
                if (ok == true) context.read<OrderCubit>().refresh();
              },
              onAddFood: () async {
                final r = await context.push<Recipe>('/dish-form');
                if (r != null) {
                  mockRecipes.add(r);
                  context.read<OrderCubit>().refresh();
                }
              },
            ),

            const SizedBox(height: 24),
            _card(context, Icons.table_restaurant_outlined, 'مێزەکان', 'بەڕێوەبردنی ژمارە و ناوی مێزەکان', '/table-management'),
            _card(context, Icons.restaurant_menu, 'خواردنەکان', 'سڕینەوەی خواردن بە پێی بەش', '/food-management'),
            _card(context, Icons.toggle_on_outlined, 'خواردنە بەردەستەکان', 'کردنەوە و داخستنی خواردنەکان', '/availability'),
            const SizedBox(height: 4),
            _card(context, Icons.history, 'مێژووی داواکاری', 'بینینی داواکاریەکانی ڕۆژانی پێشوو', '/order-history'),
            _card(context, Icons.bar_chart, 'ڕاپۆرت', 'ئامار و ڕیزبەندی خواردنەکان', '/report'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.error,
                  side: const BorderSide(color: AppTheme.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, size: 18),
                    SizedBox(width: 8),
                    Text('چوونەدەرەوە'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _card(BuildContext context, IconData icon, String title, String sub, String route) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: ListTile(
          leading: Icon(icon, color: AppTheme.primary),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          subtitle: Text(sub, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          trailing: const Icon(Icons.chevron_left, color: AppTheme.textSecondary),
          onTap: () => context.push(route),
        ),
      ),
    );
  }
}
