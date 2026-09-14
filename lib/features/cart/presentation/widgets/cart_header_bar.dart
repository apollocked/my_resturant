import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/shared/table_selector.dart';

class CartHeaderBar extends StatelessWidget {
  const CartHeaderBar({
    super.key,
    required this.cartNotEmpty,
    required this.t,
    required this.onClear,
    required this.selectedTable,
    required this.onTableChanged,
    required this.reservedTables,
  });

  final bool cartNotEmpty;
  final String Function(String) t;
  final VoidCallback onClear;
  final int selectedTable;
  final ValueChanged<int> onTableChanged;
  final Set<int> reservedTables;

  @override
  Widget build(BuildContext context) {
    final isDesktop = R.isDesktop(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        R.padding(context),
        8,
        R.padding(context),
        0,
      ),
      child: Row(
        children: [
          const Spacer(),
          if (cartNotEmpty) ...[
            Flexible(
              child: TextButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.delete_sweep, size: 18),
                label: Text(
                  t('clear'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: R.fontSm(context),
                  ),
                ),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
              ),
            ),
            SizedBox(width: isDesktop ? 16 : 8),
            TableSelector(
              selectedTable: selectedTable,
              onChanged: onTableChanged,
              reservedTables: reservedTables,
            ),
          ],
        ],
      ),
    );
  }
}
