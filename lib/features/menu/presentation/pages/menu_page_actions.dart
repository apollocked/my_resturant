import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/features/menu/domain/entities/recipe.dart';
import 'package:my_resturant/features/menu/presentation/widgets/item_on_hold_sheet.dart';
import 'package:my_resturant/features/orders/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/shared/confirm_dialog.dart';

/// Dialogs and sheets triggered from a meal tile on the menu screen.
Future<void> deleteOrderItem(
  BuildContext context,
  Recipe r, {
  required String Function(String) t,
}) async {
  if (!context.mounted) return;
  final ok = await showConfirmDialog(
    context,
    title: t('delete_from_order'),
    message: t('delete_confirm').replaceAll('{name}', r.name),
    confirmLabel: t('delete'),
    cancelLabel: t('cancel'),
    confirmColor: AppColors.error,
  );
  if (ok && context.mounted) {
    context.read<OrderCubit>().removeFromCartById(r.id);
  }
}

Future<void> editItemNotes(
  BuildContext context,
  Recipe recipe, {
  required String Function(String) t,
}) async {
  if (!context.mounted) return;
  final orderCubit = context.read<OrderCubit>();
  final result = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ItemOnHoldSheet(
      recipe: recipe,
      initialNotes: orderCubit.state.getNotes(recipe.id),
    ),
  );
  if (!context.mounted) return;
  if (result != null) orderCubit.updateNotesByRecipe(recipe.id, result);
}