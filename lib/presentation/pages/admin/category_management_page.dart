import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/presentation/widgets/admin/delete_confirm_dialog.dart';
import 'package:my_resturant/shared/empty_state.dart';

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
              : R.isPhone(context)
                  ? ListView.builder(
                      padding: EdgeInsets.all(R.padding(context)),
                      itemCount: categories.length,
                      itemBuilder: (context, index) => _categoryTile(context, categories[index], cs, t, compact: false),
                    )
                  : GridView.builder(
                      padding: EdgeInsets.all(R.padding(context)),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: R.tableGridColumns(context),
                        childAspectRatio: 0.7,
                        crossAxisSpacing: R.gridSpacing(context),
                        mainAxisSpacing: R.gridSpacing(context),
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) => _categoryTile(context, categories[index], cs, t, compact: true),
                    ),
        ),
      ),
    );
  }

  Widget _categoryTile(
    BuildContext context,
    Map<String, String> c,
    ColorScheme cs,
    String Function(String) t, {
    required bool compact,
  }) {
    final emoji = c['icon'] ?? 'ðŸ½';
    final name = c['name'] ?? '';
    final key = c['key'] ?? '';
    final deleteBtn = IconButton(
      icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
      onPressed: () => _confirmDelete(context, c, t),
    );
    if (!compact) {
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: Text(emoji, style: TextStyle(fontSize: R.fontXl(context))),
          title: Text(
            name,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: R.fontMd(context), color: cs.onSurface),
          ),
          subtitle: Text(key, style: TextStyle(fontSize: R.fontSm(context), color: cs.onSurfaceVariant)),
          trailing: deleteBtn,
        ),
      );
    }
    return Card(
      child: Padding(
        padding: EdgeInsets.all(R.cardPadding(context)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: TextStyle(fontSize: R.fontXl(context))),
            const SizedBox(height: 6),
            Flexible(
              child: Text(name,
                  maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: R.fontMd(context), color: cs.onSurface)),
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Text(key,
                  maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                  style: TextStyle(fontSize: R.fontSm(context), color: cs.onSurfaceVariant)),
            ),
            const SizedBox(height: 4),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
              visualDensity: VisualDensity.compact,
              onPressed: () => _confirmDelete(context, c, t),
            ),
          ],
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
