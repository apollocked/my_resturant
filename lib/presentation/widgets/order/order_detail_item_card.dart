import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/domain/entities/cart_item.dart';
import 'package:my_resturant/shared/app_image.dart';

class OrderDetailItemCard extends StatelessWidget {
  const OrderDetailItemCard({
    super.key,
    required this.item,
    required this.t,
    required this.cs,
    this.isDesktop = false,
  });

  final CartItem item;
  final String Function(String) t;
  final ColorScheme cs;
  final bool isDesktop;

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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          '\u00d7${item.quantity}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: R.fontSm(context),
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Flexible(
                        child: Text(
                          item.recipe.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: R.fontMd(context),
                            color: cs.onSurface,
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.notes,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: R.fontSm(context),
                              color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
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
