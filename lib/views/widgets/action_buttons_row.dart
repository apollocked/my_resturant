import 'package:flutter/material.dart';

class ActionButtonsRow extends StatelessWidget {
  final VoidCallback? onAddSection;
  final VoidCallback? onAddFood;

  const ActionButtonsRow({super.key, this.onAddSection, this.onAddFood});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36.0),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: onAddSection ?? () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF2EC153), width: 1.2),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_circle,
                        color: Color(0xFF2EC153),
                        size: 22,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'زیادکردنی بەش',
                        style: TextStyle(
                          color: Color(0xFF2EC153),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: onAddFood ?? () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2EC153),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle, color: Colors.white, size: 20),
                      SizedBox(width: 6),
                      Text(
                        'زیادکردنی خواردن',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
