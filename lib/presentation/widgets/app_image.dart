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
    final cs = Theme.of(context).colorScheme;
    if (_isNetwork) {
      return Image.network(src, width: width, height: height, fit: fit,
        loadingBuilder: (c, child, p) => p == null ? child : _placeholder(cs),
        errorBuilder: (c, e, s) => _placeholder(cs));
    }
    if (src.isNotEmpty) {
      return Image.file(File(src), width: width, height: height, fit: fit,
        errorBuilder: (c, e, s) => _placeholder(cs));
    }
    return _placeholder(cs);
  }

  Widget _placeholder(ColorScheme cs) => Container(color: cs.surfaceContainerHighest,
    child: Icon(Icons.restaurant, color: cs.onSurfaceVariant, size: 40));
}
