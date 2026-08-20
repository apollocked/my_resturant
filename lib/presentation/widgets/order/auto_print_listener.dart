import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/domain/entities/order_model.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/cubits/order_state.dart';
import 'package:my_resturant/presentation/cubits/printer_cubit.dart';

class AutoPrintListener extends StatelessWidget {
  const AutoPrintListener({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderCubit, OrderState>(
      listenWhen: _shouldListen,
      listener: _onStatusChange,
      child: child,
    );
  }

  bool _shouldListen(OrderState prev, OrderState curr) {
    if (prev.orders.length != curr.orders.length) return false;
    for (int i = 0; i < curr.orders.length; i++) {
      final p = prev.orders.where((o) => o.id == curr.orders[i].id).firstOrNull;
      if (p != null && p.status != curr.orders[i].status) return true;
    }
    return false;
  }

  void _onStatusChange(BuildContext context, OrderState state) {
    final printer = context.read<PrinterCubit>();
    if (!printer.state.config.autoPrintKitchen) return;
    for (final o in state.orders) {
      if (o.status == OrderStatus.preparing) {
        printer.printKitchen(o);
        return;
      }
    }
  }
}
