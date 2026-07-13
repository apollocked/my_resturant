import 'package:flutter/material.dart';

class TableSelector extends StatelessWidget {
  final int selectedTable;
  final ValueChanged<int> onChanged;

  const TableSelector({
    super.key,
    required this.selectedTable,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showTablePicker(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF2EC153), width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.table_restaurant, color: Color(0xFF2EC153), size: 20),
            const SizedBox(width: 6),
            Text('ژمارەی مێز: $selectedTable',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF2EC153))),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, color: Color(0xFF2EC153)),
          ],
        ),
      ),
    );
  }

  void _showTablePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Center(
                child: Text('هەڵبژاردنی مێز',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10, runSpacing: 10,
                children: List.generate(20, (i) {
                  final tableNum = i + 1;
                  final isSelected = tableNum == selectedTable;
                  return SizedBox(
                    width: 64, height: 48,
                    child: OutlinedButton(
                      onPressed: () {
                        onChanged(tableNum);
                        Navigator.of(ctx).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: isSelected ? const Color(0xFF2EC153) : Colors.white,
                        side: BorderSide(
                          color: isSelected ? const Color(0xFF2EC153) : Colors.grey[300]!,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text('$tableNum',
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}
