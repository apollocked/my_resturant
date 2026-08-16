import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/domain/entities/cart_item.dart';
import 'package:my_resturant/presentation/widgets/order/cart_item_card.dart';

class CartItemsList extends StatelessWidget {
  const CartItemsList({
    super.key,
    required this.cart,
    required this.notesCtl,
    required this.notesHint,
  });

  final List<CartItem> cart;
  final TextEditingController Function(String, String) notesCtl;
  final String notesHint;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: R.isPhone(context)
          ? _list(context)
          : R.isTablet(context)
          ? _tabletGrid(context)
          : _desktopGrid(context),
    );
  }

  EdgeInsets _padding(BuildContext context) {
    return EdgeInsets.fromLTRB(R.padding(context), 0, R.padding(context), 100);
  }

  Widget _list(BuildContext context) {
    return ListView.builder(
      padding: _padding(context),
      itemCount: cart.length,
      itemBuilder: (context, index) => _card(context, index),
    );
  }

  Widget _tabletGrid(BuildContext context) {
    return GridView.builder(
      padding: _padding(context),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 380,
        childAspectRatio: 1.35,
        crossAxisSpacing: R.gridSpacing(context),
        mainAxisSpacing: R.gridSpacing(context),
      ),
      itemCount: cart.length,
      itemBuilder: (context, index) => _card(context, index),
    );
  }

  Widget _desktopGrid(BuildContext context) {
    return GridView.builder(
      padding: _padding(context),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: R.menuGridColumns(context),
        childAspectRatio: R.menuGridAspectRatio(context),
        crossAxisSpacing: R.gridSpacing(context),
        mainAxisSpacing: R.gridSpacing(context),
      ),
      itemCount: cart.length,
      itemBuilder: (context, index) => _card(context, index),
    );
  }

  Widget _card(BuildContext context, int index) {
    return CartItemCard(
      item: cart[index],
      index: index,
      notesCtl: notesCtl,
      notesHint: notesHint,
    );
  }
}
