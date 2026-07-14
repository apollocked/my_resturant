import 'dart:io';
import 'package:flutter/material.dart';

class AppImage extends StatelessWidget {
  final String src;
  final double? width, height;
  final BoxFit fit;

  const AppImage(this.src, {super.key, this.width, this.height, this.fit = BoxFit.cover});

  bool get _isNetwork => src.startsWith('http://') || src.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    if (_isNetwork) {
      return Image.network(src, width: width, height: height, fit: fit,
        loadingBuilder: (c, child, p) => p == null ? child : _placeholder(),
        errorBuilder: (c, e, s) => _placeholder());
    }
    if (src.isNotEmpty) {
      return Image.file(File(src), width: width, height: height, fit: fit,
        errorBuilder: (c, e, s) => _placeholder());
    }
    return _placeholder();
  }

  Widget _placeholder() => Container(color: const Color(0xFFF0EDEA),
    child: const Icon(Icons.restaurant, color: Color(0xFFD4D0CC), size: 40));
}
