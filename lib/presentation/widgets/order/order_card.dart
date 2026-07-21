import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/domain/entities/order_model.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/presentation/widgets/shared/pressable_scale.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final bool showTime;
  final bool showTimeline;
  final VoidCallback? onNextStatus;
  final VoidCallback? onReset;
  const OrderCard({super.key, required this.order, this.showTime = false, this.showTimeline = false, this.onNextStatus, this.onReset});

  static const _colors = {OrderStatus.pending: AppColors.warning, OrderStatus.preparing: AppColors.info, OrderStatus.served: AppColors.success};

  static String _label(OrderStatus s, Locale locale) => Tr.get(
    s == OrderStatus.pending ? 'status_pending' : s == OrderStatus.preparing ? 'status_preparing' : 'status_served', locale);

  static String _nextLabel(OrderStatus s, Locale locale) => Tr.get(
    s == OrderStatus.pending ? 'next_prepare' : 'next_serve', locale);

  String _elapsed(DateTime dt, Locale locale) {
    final min = DateTime.now().difference(dt).inMinutes;
    if (min < 1) return Tr.get('time_under_1m', locale);
    if (min < 60) return Tr.get('time_m', locale).replaceAll('{m}', '$min');
    return Tr.get('time_hm', locale).replaceAll('{h}', '${min ~/ 60}').replaceAll('{m}', '${min % 60}');
  }

  Color _urgencyColor(int minutes) {
    if (minutes < 5) return AppColors.success;
    if (minutes < 15) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>();
    final locale = settings.state.locale;
    final cs = Theme.of(context).colorScheme;
    final screen = R.screenSize(context);
    final isDesktop = screen == ScreenSize.desktop;
    final isTablet = screen == ScreenSize.tablet;
    final color = _colors[order.status]!;
    final elapsedMin = DateTime.now().difference(order.createdAt).inMinutes;
    final urgency = _urgencyColor(elapsedMin);
    final cardPadding = isDesktop ? 20.0 : isTablet ? 18.0 : 16.0;
    final statusFont = isDesktop ? 13.0 : isTablet ? 12.0 : 11.0;
    final tableFont = isDesktop ? 20.0 : isTablet ? 18.0 : 16.0;
    final totalFont = isDesktop ? 15.0 : isTablet ? 14.0 : 13.0;
    final itemFont = isDesktop ? 13.0 : isTablet ? 12.5 : 12.0;
    final notesFont = isDesktop ? 12.0 : isTablet ? 11.5 : 11.0;
    final timelineFont = isDesktop ? 10.0 : isTablet ? 9.5 : 9.0;

    return Card(
      margin: EdgeInsets.only(bottom: isDesktop ? 0 : 10),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isDesktop ? 18 : 16),
        side: BorderSide(color: order.status == OrderStatus.served ? cs.outlineVariant : Colors.transparent)),
      child: Padding(padding: EdgeInsets.all(cardPadding), child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 14 : 10, vertical: isDesktop ? 7 : 5),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color.withValues(alpha: 0.8), color], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(_label(order.status, locale), style: TextStyle(color: cs.onPrimary, fontWeight: FontWeight.w700, fontSize: statusFont)),
              if (order.trackingCode.isNotEmpty || order.displayTrackingCode.isNotEmpty) ...[
                const SizedBox(width: 6),
                Text(order.displayTrackingCode, style: TextStyle(color: cs.onPrimary.withValues(alpha: 0.7), fontWeight: FontWeight.w500, fontSize: statusFont - 1)),
              ],
            ]),
          ),
          Row(children: [
            if (order.status != OrderStatus.served && elapsedMin > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: urgency.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.schedule, size: 12, color: urgency),
                  const SizedBox(width: 3),
                  Text(_elapsed(order.createdAt, locale), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: urgency)),
                ]),
              ),
            if (order.status != OrderStatus.served && elapsedMin > 0) const SizedBox(width: 8),
            Text(order.displayTable, style: TextStyle(fontWeight: FontWeight.w800, fontSize: tableFont, color: cs.onSurface)),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.table_restaurant_outlined, size: isDesktop ? 20 : 16, color: AppColors.primary),
            ),
          ]),
        ]),
        if (showTimeline) ...[
          SizedBox(height: isDesktop ? 16.0 : 14.0),
          _timeline(order.status, cs, locale, timelineFont),
        ],
        SizedBox(height: isDesktop ? 16.0 : 14.0),
        _itemList(order, locale, cs, itemFont),
        if (order.notes.isNotEmpty)
          Padding(padding: const EdgeInsets.only(top: 8.0),
            child: Row(children: [
              Expanded(child: Text(order.notes, textAlign: TextAlign.right,
                  style: TextStyle(fontSize: notesFont, color: cs.onSurfaceVariant.withValues(alpha: 0.7), fontStyle: FontStyle.italic))),
            ])),
        SizedBox(height: isDesktop ? 14.0 : 12.0),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          if (showTime)
            Text('${order.createdAt.hour.toString().padLeft(2, '0')}:${order.createdAt.minute.toString().padLeft(2, '0')}',
                style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant))
          else if (onNextStatus != null)
            PressableScale(onTap: onNextStatus,
              child: SizedBox(
                height: isDesktop ? 38.0 : 32.0,
                child: FilledButton.icon(
                  onPressed: null,
                  icon: Icon(Icons.arrow_forward, size: isDesktop ? 16.0 : 14.0),
                  label: Text(_nextLabel(order.status, locale), style: TextStyle(fontWeight: FontWeight.w700, fontSize: isDesktop ? 14.0 : 12.0)),
                  style: FilledButton.styleFrom(backgroundColor: color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                ),
              ))
          else if (onReset != null)
            PressableScale(onTap: onReset,
              child: SizedBox(
                height: isDesktop ? 38.0 : 32.0,
                child: OutlinedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.refresh, size: 14),
                  label: Text(Tr.get('again', locale), style: TextStyle(fontSize: isDesktop ? 14.0 : 12.0, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                ),
              )),
          Container(
            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 16.0 : 12.0, vertical: isDesktop ? 8.0 : 6.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.primary.withValues(alpha: 0.8), AppColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 6, offset: const Offset(0, 2))],
            ),
                child: Text('${order.totalPrice.toInt()} ${Tr.get('currency_suffix', locale)}',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: totalFont, color: cs.onPrimary)),
          ),
        ]),
      ])),
    );
  }

  Widget _itemList(Order order, Locale locale, ColorScheme cs, double itemFont) {
    return Column(children: order.items.map((item) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Row(children: [
          Container(
            width: 26, height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(6)),
            child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.primary)),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(item.recipe.name, textAlign: TextAlign.right,
              style: TextStyle(fontSize: itemFont, fontWeight: FontWeight.w500, color: cs.onSurface))),
        ]),
        if (item.notes.isNotEmpty)
          Padding(padding: const EdgeInsets.only(top: 3, right: 34),
            child: Text(item.notes, textAlign: TextAlign.right,
                style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant.withValues(alpha: 0.6), fontStyle: FontStyle.italic))),
      ]),
    )).toList());
  }

  static const nextStatus = {OrderStatus.pending: OrderStatus.preparing, OrderStatus.preparing: OrderStatus.served};

  Widget _timeline(OrderStatus current, ColorScheme cs, Locale locale, double timelineFont) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(color: cs.surfaceContainerHighest.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Row(children: [
          _dot(OrderStatus.served, current, cs),
          Expanded(child: Container(height: 2, color: current == OrderStatus.served ? _colors[OrderStatus.served] : cs.outlineVariant)),
          _dot(OrderStatus.preparing, current, cs),
          Expanded(child: Container(height: 2, color: current == OrderStatus.preparing || current == OrderStatus.served ? _colors[OrderStatus.preparing] : cs.outlineVariant)),
          _dot(OrderStatus.pending, current, cs),
        ]),
        const SizedBox(height: 4),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(Tr.get('timeline_served', locale), style: TextStyle(fontSize: timelineFont, color: current == OrderStatus.served ? AppColors.success : cs.onSurfaceVariant)),
          Text(Tr.get('timeline_preparing', locale), style: TextStyle(fontSize: timelineFont, color: current == OrderStatus.preparing || current == OrderStatus.served ? _colors[OrderStatus.preparing] : cs.onSurfaceVariant)),
          Text(Tr.get('timeline_pending', locale), style: TextStyle(fontSize: timelineFont, color: current == OrderStatus.pending ? _colors[OrderStatus.pending] : cs.onSurfaceVariant)),
        ]),
      ]),
    );
  }

  Widget _dot(OrderStatus dot, OrderStatus current, ColorScheme cs) {
    final isReached = dot.index <= current.index;
    final c = _colors[dot]!;
    return AnimatedContainer(duration: const Duration(milliseconds: 200),
      width: isReached ? 14 : 10, height: isReached ? 14 : 10,
      decoration: BoxDecoration(
        color: isReached ? c : cs.surface,
        shape: BoxShape.circle,
        border: Border.all(color: isReached ? c : cs.outlineVariant, width: 2),
        boxShadow: isReached ? [BoxShadow(color: c.withValues(alpha: 0.3), blurRadius: 4)] : null,
      ),
      child: isReached ? Icon(Icons.check, size: 8, color: cs.onPrimary) : null);
  }
}
