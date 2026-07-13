import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_resturant/viewmodels/order_viewmodel.dart';
import 'package:my_resturant/widgets/quantity_selector.dart';
import 'package:my_resturant/widgets/table_selector.dart';

class CartPage extends StatefulWidget {
  final VoidCallback? onViewKitchen;
  const CartPage({super.key, this.onViewKitchen});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _orderNotesController = TextEditingController();

  @override
  void dispose() {
    _orderNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OrderViewModel>();
    final cart = viewModel.cart;

    if (cart.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'داواکاری نییە',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[500],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'لە مینیو خواردن هەڵبژێرە',
              style: TextStyle(fontSize: 14, color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () => viewModel.clearCart(),
                icon: const Icon(
                  Icons.delete_sweep,
                  color: Color(0xFFE53935),
                  size: 20,
                ),
                label: const Text(
                  'سڕینەوە',
                  style: TextStyle(
                    color: Color(0xFFE53935),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TableSelector(
                selectedTable: viewModel.selectedTable,
                onChanged: (t) => viewModel.selectedTable = t,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: cart.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = cart[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.recipe.imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              item.recipe.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${item.recipe.price.toInt()} دینار',
                              style: const TextStyle(
                                color: Color(0xFF2EC153),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(
                              height: 32,
                              child: TextField(
                                textAlign: TextAlign.right,
                                textDirection: TextDirection.rtl,
                                decoration: InputDecoration(
                                  hintText: 'تێبینی...',
                                  hintStyle: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 11,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  isDense: true,
                                ),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                                onChanged: (v) =>
                                    viewModel.updateNotes(index, v),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      QuantitySelector(
                        quantity: item.quantity,
                        onChanged: (d) => viewModel.updateQuantity(index, d),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${item.totalPrice.toInt()}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: () => viewModel.removeFromCart(index),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.close, size: 16, color: Color(0xFFE53935)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          TextField(
            controller: _orderNotesController,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              hintText: 'تێبینی گشتی بۆ داواکاری...',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: 42,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      viewModel.submitOrder(_orderNotesController.text);
                      _orderNotesController.clear();
                      widget.onViewKitchen?.call();
                    },
                    icon: const Icon(Icons.send, size: 18),
                    label: const Text(
                      'ناردنی داواکاری',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2EC153),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${viewModel.cartTotal.toInt()} دینار',
                      style: const TextStyle(
                        color: Color(0xFF2EC153),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'کۆی گشتی',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
