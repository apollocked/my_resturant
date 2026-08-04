import 'package:flutter/material.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/presentation/widgets/shared/pressable_scale.dart';

class CartBottomBar extends StatelessWidget {
  final TextEditingController notesCtrl;
  final String notesHint, totalLabel, sendLabel, currencySuffix;
  final double total;
  final bool canSubmit;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  const CartBottomBar({super.key, required this.notesCtrl, required this.notesHint,
    required this.totalLabel, required this.sendLabel, required this.currencySuffix,
    required this.total, required this.canSubmit, required this.isSubmitting, required this.onSubmit});

  Widget _buttonChild(ColorScheme cs, double fontSize) => isSubmitting
      ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: cs.onPrimary))
      : Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.send_rounded, size: 18),
          const SizedBox(width: 8),
          Text(sendLabel, style: TextStyle(fontWeight: FontWeight.w700, fontSize: fontSize)),
        ]);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDesktop = R.isDesktop(context);
    return Container(
      padding: EdgeInsets.fromLTRB(R.padding(context), 16, R.padding(context), 116),
      decoration: BoxDecoration(
        color: cs.surface,
        boxShadow: [BoxShadow(color: cs.shadow.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, -4))],
        border: Border(top: BorderSide(color: cs.outlineVariant)),
      ),
      child: isDesktop
        ? Row(children: [
            PressableScale(
              onTap: canSubmit && !isSubmitting ? onSubmit : null,
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary, foregroundColor: cs.onPrimary,
                    disabledBackgroundColor: AppColors.primary, disabledForegroundColor: cs.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 32),
                  ),
                  child: _buttonChild(cs, 16),
                ),
              ),
            ),
            const Spacer(),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${total.toInt()} $currencySuffix',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 26, color: AppColors.primary)),
              Text(totalLabel, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: cs.onSurfaceVariant)),
            ]),
          ])
        : Column(children: [
            TextField(controller: notesCtrl, textAlign: TextAlign.right, textDirection: TextDirection.rtl,
              maxLength: 200,
              decoration: InputDecoration(hintText: notesHint,
                hintStyle: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.5), fontSize: 12),
                counterText: '',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: cs.outlineVariant)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: cs.outlineVariant)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                filled: true, fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.3),
              )),
            const SizedBox(height: 14),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              PressableScale(
                onTap: canSubmit && !isSubmitting ? onSubmit : null,
                child: SizedBox(height: 48,
                  child: ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary, foregroundColor: cs.onPrimary,
                      disabledBackgroundColor: AppColors.primary, disabledForegroundColor: cs.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 24),
                    ),
                    child: _buttonChild(cs, 14),
                  ),
                ),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('${total.toInt()} $currencySuffix',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22, color: AppColors.primary)),
                Text(totalLabel, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: cs.onSurfaceVariant)),
              ]),
            ]),
          ]),
    );
  }
}
