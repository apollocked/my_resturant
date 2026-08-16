import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';

class HistoryMonthNav extends StatelessWidget {
  const HistoryMonthNav({
    super.key,
    required this.t,
    required this.year,
    required this.month,
    required this.onPrev,
    required this.onNext,
    required this.onPick,
  });

  final String Function(String) t;
  final int year;
  final int month;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: R.padding(context),
        vertical: 4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(onPressed: onPrev, icon: const Icon(Icons.chevron_left)),
          TextButton.icon(
            onPressed: onPick,
            icon: const Icon(Icons.calendar_month, size: 18),
            label: Text(
              '$year / ${month.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: R.fontLg(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(onPressed: onNext, icon: const Icon(Icons.chevron_right)),
        ],
      ),
    );
  }
}
