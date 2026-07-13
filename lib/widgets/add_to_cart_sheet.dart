import 'package:flutter/material.dart';
import 'package:my_resturant/models/recipe.dart';

class AddToCartSheet extends StatefulWidget {
  final Recipe recipe;
  const AddToCartSheet({super.key, required this.recipe});

  @override
  State<AddToCartSheet> createState() => _AddToCartSheetState();
}

class _AddToCartSheetState extends State<AddToCartSheet> {
  int _quantity = 1;
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20, right: 20, top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(widget.recipe.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${widget.recipe.price.toInt()} دینار',
                  style: const TextStyle(fontSize: 16, color: Color(0xFF2EC153), fontWeight: FontWeight.bold)),
              Row(children: [
                const Text('ژمارە: ', style: TextStyle(fontSize: 14)),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    InkWell(
                      onTap: _quantity > 1 ? () => setState(() => _quantity--) : null,
                      child: const Padding(padding: EdgeInsets.all(8), child: Icon(Icons.remove, size: 18)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('$_quantity',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    InkWell(
                      onTap: _quantity < 99 ? () => setState(() => _quantity++) : null,
                      child: const Padding(padding: EdgeInsets.all(8), child: Icon(Icons.add, size: 18)),
                    ),
                  ]),
                ),
              ]),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              hintText: 'تێبینی (ئارەزوومەندی، برژاو و...)',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              filled: true, fillColor: const Color(0xFFF5F5F5),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop({
                'quantity': _quantity,
                'notes': _notesController.text,
              }),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2EC153),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('زیادکردن بۆ داواکاری',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
