import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/domain/entities/order_model.dart';
import 'package:my_resturant/presentation/widgets/order/order_status_style.dart';
import 'package:my_resturant/shared/pressable_scale.dart';

class OrderActionBar extends StatelessWidget {
  const OrderActionBar({
    super.key,
    required this.status,
    required this.locale,
    required this.total,
    this.clockTime,
    this.onNextStatus,
    this.onReset,
    this.isDesktop = false,
  });

  final OrderStatus status;
  final Locale locale;
  final double total;
  final String? clockTime;
  final VoidCallback? onNextStatus;
  final VoidCallback? onReset;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = OrderStatusStyle.color(status);
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
        else if (onNextStatus != null)
          Flexible(
            child: PressableScale(
              onTap: onNextStatus,
              child: SizedBox(
                height: isDesktop ? 38.0 : 32.0,
                child: FilledButton.icon(
                  onPressed: null,
                  icon: Icon(
                    Directionality.of(context) == TextDirection.rtl ? Icons.arrow_back : Icons.arrow_forward,
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
            ),
          )
        else if (onReset != null)
          Flexible(
            child: PressableScale(
              onTap: onReset,
              child: SizedBox(
                height: isDesktop ? 38.0 : 32.0,
                child: OutlinedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.refresh, size: 14),
                  label: Text(
                    Tr.get('again', locale),
                    style: TextStyle(
                      fontSize: R.fontSm(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    disabledForegroundColor: cs.onSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                ),
              ),
            ),
          ),
        _totalBadge(context, cs),
      ],
    );
  }

  Widget _totalBadge(BuildContext context, ColorScheme cs) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 16.0 : 12.0,
        vertical: isDesktop ? 8.0 : 6.0,
      ),
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
