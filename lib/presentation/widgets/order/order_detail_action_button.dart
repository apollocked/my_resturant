import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/shared/pressable_scale.dart';

class OrderDetailActionButton extends StatelessWidget {
  const OrderDetailActionButton({
    super.key,
    required this.hasNext,
    required this.color,
    required this.nextLabel,
    required this.t,
    required this.onNext,
    required this.onReset,
    this.isDesktop = false,
  });

  final bool hasNext;
  final Color color;
  final String nextLabel;
  final String Function(String) t;
  final VoidCallback onNext;
  final VoidCallback onReset;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pad = EdgeInsets.symmetric(vertical: isDesktop ? 18 : 14);
    final style = TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: isDesktop ? R.fontLg(context) : R.fontMd(context),
    );
    return SizedBox(
      width: double.infinity,
      child: hasNext
          ? PressableScale(
              onTap: onNext,
              child: FilledButton(
                onPressed: null,
                style: FilledButton.styleFrom(
                  backgroundColor: color,
                  disabledBackgroundColor: color,
                  disabledForegroundColor: cs.onPrimary,
                  padding: pad,
                ),
                child: Text(nextLabel, style: style),
              ),
            )
          : PressableScale(
              onTap: onReset,
              child: OutlinedButton(
                onPressed: null,
                style: OutlinedButton.styleFrom(
                  disabledForegroundColor: cs.onSurface,
                  padding: pad,
                ),
                child: Text(t('again'), style: style),
              ),
            ),
    );
  }
}
