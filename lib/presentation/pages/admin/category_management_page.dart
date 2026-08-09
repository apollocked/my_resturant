import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/presentation/widgets/admin/delete_confirm_dialog.dart';
import 'package:my_resturant/presentation/widgets/shared/empty_state.dart';

class CategoryManagementPage extends StatelessWidget {
  const CategoryManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<OrderCubit>();
    final settings = context.watch<SettingsCubit>().state;
    String t(String key) => Tr.get(key, settings.locale);
    final cs = Theme.of(context).colorScheme;
    final categories = context.read<OrderCubit>().state.categories;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(t('category_management')),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: t('add_category'),
              onPressed: () => context.push('/category-form'),
            ),
          ],
        ),
        body: SafeArea(
          child: categories.isEmpty
              ? EmptyState(
                  icon: Icons.category_outlined,
                  title: t('categories_empty'),
                  subtitle: t('categories_empty_subtitle'),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(R.padding(context)),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final c = categories[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Text(c['icon'] ?? '🍽', style: const TextStyle(fontSize: 26)),
                        title: Text(
                          c['name'] ?? '',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: R.fontMd(context), color: cs.onSurface),
                        ),
                        subtitle: Text(c['key'] ?? '', style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                          onPressed: () => _confirmDelete(context, c, t),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    Map<String, String> c,
    String Function(String) t,
  ) async {
    final orderCubit = context.read<OrderCubit>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteConfirmDialog(
        title: t('delete_category'),
        content: t('delete_confirm').replaceAll('{name}', c['name'] ?? ''),
        cancelLabel: t('cancel'),
        deleteLabel: t('delete'),
      ),
    );
    if (ok == true && context.mounted) {
      try {
        await orderCubit.removeCategory(c['key']!);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${t('error_occurred')}: $e'), backgroundColor: AppColors.error),
          );
        }
      }
    }
  }
}
