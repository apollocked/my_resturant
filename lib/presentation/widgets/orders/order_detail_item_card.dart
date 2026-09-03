import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/domain/entities/cart_item.dart';
import 'package:my_resturant/presentation/widgets/orders/qty_stepper.dart';
import 'package:my_resturant/shared/app_image.dart';

class OrderDetailItemCard extends StatelessWidget {
  const OrderDetailItemCard({
    super.key,
    required this.item,
    required this.t,
    required this.cs,
    this.isDesktop = false,
    this.canEdit = false,
    this.onRemove,
    this.onQuantityChanged,
  });

  final CartItem item;
  final String Function(String) t;
  final ColorScheme cs;
  final bool isDesktop;
  final bool canEdit;
  final VoidCallback? onRemove;
  final ValueChanged<int>? onQuantityChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 16 : 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: AppImage(
                item.recipe.imageUrl,
                width: isDesktop ? 64 : 52,
                height: isDesktop ? 64 : 52,
              ),
            ),
            SizedBox(width: isDesktop ? 16 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      if (canEdit && onQuantityChanged != null)
                        QtyStepper(
                          quantity: item.quantity,
                          onChanged: onQuantityChanged!,
                        )
                      else
                        _QtyBadge(quantity: item.quantity),
                      const Spacer(),
                      Flexible(
                        child: Text(
                          item.recipe.name,
                          maxLines: 1,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: R.fontMd(context),
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                      if (canEdit && onRemove != null)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(end: 6),
                          child: GestureDetector(
                            onTap: onRemove,
                            child: Icon(
                              Icons.remove_circle_outline,
                              size: 18,
                              color: cs.error,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          '${item.totalPrice.toInt()} ${t('currency_suffix')}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: R.fontMd(context),
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${item.recipe.price.toInt()} ${t('currency_suffix')}',
                        style: TextStyle(
                          fontSize: R.fontSm(context),
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  if (item.notes.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.notes,
                      style: TextStyle(
                        fontSize: R.fontSm(context),
                        color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QtyBadge extends StatelessWidget {
  const _QtyBadge({required this.quantity});
  final int quantity;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        '\u00d7$quantity',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: R.fontSm(context),
          color: AppColors.primary,
        ),
      ),
    );
  }
}
