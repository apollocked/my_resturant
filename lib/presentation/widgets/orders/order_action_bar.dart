import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/domain/entities/order_model.dart';
import 'package:my_resturant/presentation/widgets/orders/order_status_style.dart';
import 'package:my_resturant/shared/haptics.dart';
import 'package:my_resturant/shared/pressable_scale.dart';

class OrderActionBar extends StatelessWidget {
  final OrderStatus status;
  final Locale locale;
  final double total;
  final String? clockTime;
  final VoidCallback? onNextStatus;
  final VoidCallback? onReset;
  final VoidCallback? onCancel;
  final bool isDesktop;

  const OrderActionBar({
    super.key,
    required this.status,
    required this.locale,
    required this.total,
    this.clockTime,
    this.onNextStatus,
    this.onReset,
    this.onCancel,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (clockTime != null)
          Text(
            clockTime!,
            style: TextStyle(
              fontSize: R.fontSm(context),
              color: cs.onSurfaceVariant,
            ),
          )
        else if (onNextStatus != null || onCancel != null)
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onCancel != null) ...[
                  _outlined(context, cs, Icons.close, Tr.get('cancel', locale),
                      onCancel, cs.error),
                  const SizedBox(width: 8),
                ],
                if (onNextStatus != null) _next(context, cs),
              ],
            ),
          )
        else if (onReset != null)
          Flexible(
            child: _outlined(
                context, cs, Icons.refresh, Tr.get('again', locale), onReset, cs.onSurface),
          ),
        _totalBadge(context, cs),
      ],
    );
  }

  Widget _outlined(BuildContext context, ColorScheme cs, IconData icon, String label, VoidCallback? onTap, Color color) {
    return PressableScale(
      onTap: onTap,
      child: SizedBox(
        height: isDesktop ? 38.0 : 32.0,
        child: OutlinedButton.icon(
          onPressed: null,
          icon: Icon(icon, size: 14),
          label: Text(label,
              style: TextStyle(
                fontSize: R.fontSm(context),
                fontWeight: FontWeight.w600,
              )),
          style: OutlinedButton.styleFrom(
            disabledForegroundColor: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        ),
      ),
    );
  }

  Widget _next(BuildContext context, ColorScheme cs) {
    final color = OrderStatusStyle.color(status);
    return PressableScale(
      onTap: () {
        Haptics.heavy();
        onNextStatus?.call();
      },
      child: SizedBox(
        height: isDesktop ? 38.0 : 32.0,
        child: FilledButton.icon(
          onPressed: null,
          icon: Icon(Directionality.of(context) == TextDirection.rtl ? Icons.arrow_back : Icons.arrow_forward,
            size: isDesktop ? 16.0 : 14.0,
          ),
          label: Text(
            OrderStatusStyle.nextLabel(status, locale),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: R.fontSm(context),
            ),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: color,
            disabledBackgroundColor: color,
            disabledForegroundColor: cs.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        ),
      ),
    );
  }

  Widget _totalBadge(BuildContext context, ColorScheme cs) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 16.0 : 12.0, vertical: isDesktop ? 8.0 : 6.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withValues(alpha: 0.8), AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        '${total.toInt()} ${Tr.get('currency_suffix', locale)}',
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: R.fontMd(context),
          color: cs.onPrimary,
        ),
      ),
    );
  }
}
