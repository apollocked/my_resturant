import 'package:flutter/material.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/presentation/widgets/admin/promo_code_helpers.dart';

class PromoCodeList extends StatelessWidget {
  const PromoCodeList({super.key, required this.codes, required this.onDelete});

  final List<Map<String, dynamic>> codes;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListView.builder(
      padding: EdgeInsets.all(R.padding(context)),
      itemCount: codes.length,
      itemBuilder: (context, i) {
        final c = codes[i];
        final status = promoStatusText(c);
        final color = promoStatusColor(c);
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(promoStatusIcon(c), color: color, size: 20),
            ),
            title: Text(
              c['code'] ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace',
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              '$status • expires ${formatPromoDate(c['expires_at'])}',
              style: TextStyle(color: color, fontSize: 12),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.copy_rounded, size: 18, color: cs.primary),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: c['code'] ?? ''));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Copied'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                if (c['used_by'] == null)
                  IconButton(
                    icon: Icon(Icons.delete_outline, size: 18, color: cs.error),
                    onPressed: () => onDelete(c['code']),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
