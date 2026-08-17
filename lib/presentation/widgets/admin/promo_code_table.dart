import 'package:flutter/material.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/presentation/widgets/admin/promo_code_helpers.dart';

class PromoCodeTable extends StatelessWidget {
  const PromoCodeTable({
    super.key,
    required this.codes,
    required this.onDelete,
  });

  final List<Map<String, dynamic>> codes;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: EdgeInsets.all(R.padding(context)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(1.5),
              2: FlexColumnWidth(1.5),
              3: FlexColumnWidth(1.5),
              4: FlexColumnWidth(1),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                children: [
                  _th(context, 'Code', cs),
                  _th(context, 'Status', cs),
                  _th(context, 'Created', cs),
                  _th(context, 'Expires', cs),
                  _th(context, '', cs),
                ],
              ),
              for (var i = 0; i < codes.length; i++)
                TableRow(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: cs.outlineVariant.withValues(alpha: 0.3),
                      ),
                    ),
                    borderRadius: i == codes.length - 1
                        ? const BorderRadius.vertical(
                            bottom: Radius.circular(16),
                          )
                        : null,
                  ),
                  children: [
                    _td(context, codes[i]['code'] ?? '', cs, bold: true),
                    _td(
                      context,
                      promoStatusText(codes[i]),
                      cs,
                      color: promoStatusColor(codes[i]),
                    ),
                    _td(context, formatPromoDate(codes[i]['created_at']), cs),
                    _td(context, formatPromoDate(codes[i]['expires_at']), cs),
                    _tdAction(context, codes[i], cs),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _th(BuildContext context, String text, ColorScheme cs) => Padding(
    padding: const EdgeInsets.all(12),
    child: Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        color: cs.onSurfaceVariant,
        fontSize: R.fontSm(context),
      ),
    ),
  );

  Widget _td(
    BuildContext context,
    String text,
    ColorScheme cs, {
    bool bold = false,
    Color? color,
  }) => Padding(
    padding: const EdgeInsets.all(12),
    child: Text(
      text,
      style: TextStyle(
        fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
        color: color ?? cs.onSurface,
        fontSize: R.fontMd(context),
      ),
    ),
  );

  Widget _tdAction(
    BuildContext context,
    Map<String, dynamic> code,
    ColorScheme cs,
  ) {
    final canDelete = code['used_by'] == null;
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.copy_rounded, size: 18, color: cs.primary),
            tooltip: 'Copy',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code['code'] ?? ''));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Copied'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          if (canDelete)
            IconButton(
              icon: Icon(Icons.delete_outline, size: 18, color: cs.error),
              tooltip: 'Delete',
              onPressed: () => onDelete(code['code']),
            ),
        ],
      ),
    );
  }
}
