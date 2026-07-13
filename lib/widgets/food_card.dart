import 'package:flutter/material.dart';
import 'package:my_resturant/models/recipe.dart';

class FoodCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback? onAdd;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const FoodCard({
    super.key,
    required this.recipe,
    this.onAdd,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onAdd,
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: AspectRatio(
                aspectRatio: 1.3,
                child: Image.network(recipe.imageUrl, width: double.infinity, fit: BoxFit.cover),
              ),
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
