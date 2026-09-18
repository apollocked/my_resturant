import 'dart:ui';

import 'package:my_resturant/core/helpers/network_helper.dart';
import 'package:my_resturant/features/auth/domain/entities/role.dart';
import 'package:my_resturant/features/orders/presentation/cubits/order_actions_mixin.dart';
import 'package:my_resturant/features/orders/presentation/cubits/order_auth_mixin.dart';
import 'package:my_resturant/features/orders/presentation/cubits/order_cart_mixin.dart';
import 'package:my_resturant/features/orders/presentation/cubits/order_crud_mixin.dart';
import 'package:my_resturant/features/orders/presentation/cubits/order_cubit_base.dart';
import 'package:my_resturant/features/orders/presentation/cubits/order_stream_mixin.dart';
import 'package:my_resturant/features/orders/presentation/cubits/order_submit_mixin.dart';
import 'package:my_resturant/features/orders/presentation/cubits/order_table_mixin.dart';

String errorKey(Object e) => networkErrorKey(e);

/// Orders orchestration: wires the streaming/table/cart/submit/crud behavior
/// into the orders state and keeps the realtime subscription in sync with the
/// device session and connectivity.
class OrderCubit extends OrderCubitBase
    with
        OrderStreamMixin,
        OrderCartMixin,
        OrderTableMixin,
        OrderCrudMixin,
        OrderActionsMixin,
        OrderSubmitMixin,
        OrderAuthMixin {
  OrderCubit({required super.repo}) {
    notifier.init();
    restoreDraft();
    loadAndSubscribe();
    initLifecycle();
  }

  void setCurrentRole(Role? role) => notifier.setRole(role);

  void setCurrentLocale(Locale locale) => notifier.setLocale(locale);

  void clearError() {
    if (!isClosed) emit(state.copyWith(errorMessage: null));
  }

  @override
  Future<void> close() {
    disposeLifecycle();
    return super.close();
  }
}