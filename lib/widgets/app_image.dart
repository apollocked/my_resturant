import 'dart:io';
import 'package:flutter/material.dart';

class AppImage extends StatelessWidget {
  final String src;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;

  const AppImage(this.src, {super.key, this.width, this.height, this.fit = BoxFit.cover, this.borderRadius = 0});

  bool get _isNetwork => src.startsWith('http://') || src.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    final child = _isNetwork
        ? Image.network(src, width: width, height: height, fit: fit,
            loadingBuilder: (c, child, p) => p == null ? child : Container(color: const Color(0xFFF0F0F0)),
            errorBuilder: (c, e, s) => Container(color: const Color(0xFFF0F0F0),
                child: const Icon(Icons.restaurant, color: Color(0xFFD0D0D0), size: 40)))
        : (src.isNotEmpty
            ? Image.file(File(src), width: width, height: height, fit: fit,
                errorBuilder: (c, e, s) => Container(color: const Color(0xFFF0F0F0),
                    child: const Icon(Icons.restaurant, color: Color(0xFFD0D0D0), size: 40)))
            : Container(color: const Color(0xFFF0F0F0),
                child: const Icon(Icons.restaurant, color: Color(0xFFD0D0D0), size: 40)));
    if (borderRadius > 0) {
      return ClipRRect(borderRadius: BorderRadius.circular(borderRadius), child: child);
    }
    return child;
  }
}
