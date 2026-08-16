import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/presentation/widgets/order/cart_notes_field.dart';
import 'package:my_resturant/presentation/widgets/order/cart_send_button.dart';
import 'package:my_resturant/presentation/widgets/order/cart_total_column.dart';

class CartBottomBar extends StatelessWidget {
  final TextEditingController notesCtrl;
  final String notesHint, totalLabel, sendLabel, currencySuffix;
  final double total;
  final bool canSubmit;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  const CartBottomBar({
    super.key,
    required this.notesCtrl,
    required this.notesHint,
    required this.totalLabel,
    required this.sendLabel,
    required this.currencySuffix,
    required this.total,
    required this.canSubmit,
    required this.isSubmitting,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDesktop = R.isDesktop(context);
    return Container(
      padding: EdgeInsets.fromLTRB(
        R.padding(context),
        16,
        R.padding(context),
        R.isPhone(context) ? 116 : 72,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(top: BorderSide(color: cs.outlineVariant)),
      ),
      child: isDesktop
          ? Row(
              children: [
                CartSendButton(
                  canSubmit: canSubmit,
                  isSubmitting: isSubmitting,
                  onSubmit: onSubmit,
                  cs: cs,
                  label: sendLabel,
                  fontSize: 16,
                  padH: 32,
                ),
                const Spacer(),
                CartTotalColumn(
                  total: total,
                  currencySuffix: currencySuffix,
                  totalLabel: totalLabel,
                  cs: cs,
                ),
              ],
            )
          : Column(
              children: [
                CartNotesField(controller: notesCtrl, hint: notesHint, cs: cs),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CartSendButton(
                      canSubmit: canSubmit,
                      isSubmitting: isSubmitting,
                      onSubmit: onSubmit,
                      cs: cs,
                      label: sendLabel,
                      fontSize: 14,
                      padH: 24,
                    ),
                    Flexible(
                      child: CartTotalColumn(
                        total: total,
                        currencySuffix: currencySuffix,
                        totalLabel: totalLabel,
                        cs: cs,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
