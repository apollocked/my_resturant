import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/domain/entities/order_model.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/cubits/order_state.dart';
import 'package:my_resturant/presentation/cubits/printer_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';

class AutoPrintListener extends StatefulWidget {
  const AutoPrintListener({super.key, required this.child});
  final Widget child;

  @override
  State<AutoPrintListener> createState() => _AutoPrintListenerState();
}

class _AutoPrintListenerState extends State<AutoPrintListener> {
  final Set<String> _printed = {};

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderCubit, OrderState>(
      listenWhen: _shouldListen,
      listener: _onStatusChange,
      child: widget.child,
    );
  }

  bool _shouldListen(OrderState prev, OrderState curr) {
    if (prev.orders.length != curr.orders.length) return false;
    final prevById = {for (final o in prev.orders) o.id: o};
    for (final currOrder in curr.orders) {
      final prevOrder = prevById[currOrder.id];
      if (prevOrder != null && prevOrder.status != currOrder.status) {
        return true;
      }
    }
    return false;
  }

  void _onStatusChange(BuildContext context, OrderState state) {
    final printer = context.read<PrinterCubit>();
    if (!printer.state.config.autoPrintKitchen) return;
    final locale = context.read<SettingsCubit>().state.locale;
    for (final o in state.orders) {
      if (o.status == OrderStatus.preparing && !_printed.contains(o.id)) {
        _printed.add(o.id);
        printer.printKitchen(o, locale);
        return;
      }
    }
  }
}