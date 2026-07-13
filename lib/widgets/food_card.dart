import 'package:flutter/material.dart';
import 'package:my_resturant/models/recipe.dart';

class FoodCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final int quantity;

  const FoodCard({
    super.key,
    required this.recipe,
    this.onIncrement,
    this.onDecrement,
    this.onEdit,
    this.onDelete,
    this.quantity = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = quantity > 0;
    return GestureDetector(
      onTap: onIncrement,
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: const Color(0xFF2EC153), width: 2)
              : null,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: AspectRatio(
                    aspectRatio: 1.3,
                    child: Image.network(recipe.imageUrl, width: double.infinity, fit: BoxFit.cover),
                  ),
                ),
                if (isSelected)
                  Positioned(
                    top: 6, right: 6,
                    child: Container(
                      width: 24, height: 24,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2EC153), shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                      ),
                      child: Text('$quantity',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(recipe.name, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right,
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, height: 1.0, color: Colors.black87)),
                          const SizedBox(height: 2),
                          Text(recipe.description, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right,
                              style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 10, height: 1.0)),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (isSelected)
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F0F0),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              InkWell(onTap: onDecrement, child: const Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Icon(Icons.remove, size: 15, color: Color(0xFF2EC153)))),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: Text('$quantity',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2EC153))),
                              ),
                              InkWell(onTap: onIncrement, child: const Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Icon(Icons.add, size: 15, color: Color(0xFF2EC153)))),
                            ]),
                          )
                        else
                          Row(mainAxisSize: MainAxisSize.min, children: [
                            InkWell(onTap: onEdit, child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
                                child: const Icon(Icons.edit_square, color: Color(0xFF2EC153), size: 18))),
                            InkWell(onTap: onDelete, child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
                                child: const Icon(Icons.delete_outline, color: Color(0xFFE53935), size: 18))),
                          ]),
                        SizedBox(
                          width: 50,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${recipe.price.toInt()} ', textAlign: TextAlign.right,
                                  style: const TextStyle(color: Color(0xFF2EC153), fontWeight: FontWeight.w800, fontSize: 13, height: 1.25)),
                              const Text('دینار', textAlign: TextAlign.left,
                                  style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w800, fontSize: 10, height: 1)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
