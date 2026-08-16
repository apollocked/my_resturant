import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/presentation/widgets/admin/category_manage_list.dart';
import 'package:my_resturant/presentation/widgets/admin/delete_confirm_dialog.dart';

class CategoryManagementPage extends StatelessWidget {
  const CategoryManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<OrderCubit>();
    final settings = context.watch<SettingsCubit>().state;
    String t(String key) => Tr.get(key, settings.locale);

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
          child: CategoryManageList(
            categories: context.read<OrderCubit>().state.categories,
            t: t,
            onDelete: (c) => _confirmDelete(context, c, t),
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
            SnackBar(
              content: Text('${t('error_occurred')}: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
}
