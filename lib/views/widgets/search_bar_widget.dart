import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const TextField(
        textAlignVertical: TextAlignVertical.center,
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          hintText: 'گەڕان بەدوای خواردن',
          hintStyle: TextStyle(color: Color.fromRGBO(0, 0, 0, 0.4), fontSize: 15),
          suffixIcon: Icon(Icons.search, color: Colors.black87, size: 24),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
