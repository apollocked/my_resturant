import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/data/repositories/data_repository.dart';
import 'package:my_resturant/domain/repositories/data_repository.dart';
import 'package:my_resturant/presentation/cubits/order_notifier.dart';
import 'package:my_resturant/presentation/cubits/order_state.dart';

class OrderCubitBase extends Cubit<OrderState> {
  final DataRepository repo;
  final OrderNotifier notifier = OrderNotifier();

  OrderCubitBase({DataRepository? repo})
    : repo = repo ?? AppRepository(),
      super(const OrderState());
}
