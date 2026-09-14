import 'package:flutter/material.dart';
import 'package:my_resturant/core/theme/app_colors.dart';

class AddItemsSheetHeader extends StatelessWidget {
  const AddItemsSheetHeader({
    super.key,
    required this.t,
    required this.count,
    required this.cs,
    this.isDesktop = false,
  });

  final String Function(String) t;
  final int count;
  final ColorScheme cs;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.only(top: 12),
          decoration: BoxDecoration(
            color: cs.onSurfaceVariant.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            isDesktop ? 24 : 16,
            14,
            isDesktop ? 24 : 16,
            8,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  t('add_items'),
                  style: TextStyle(
                    fontSize: isDesktop ? 18 : 16,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
              ),
              if (count > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.softSurface(context),
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  child: Text(
                    t('items').replaceAll('{count}', '$count'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
