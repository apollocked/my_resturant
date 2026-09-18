import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AppImage extends StatelessWidget {
  final String src;
  final double? width, height;
  final BoxFit fit;

  const AppImage(
    this.src, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  bool get _isNetwork =>
      src.startsWith('http://') || src.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (_isNetwork) {
      return CachedNetworkImage(
        imageUrl: src,
        width: width,
        height: height,
        fit: fit,
        placeholder: (c, _) => _placeholder(cs),
        errorWidget: (c, _, _) => _placeholder(cs),
      );
    }
    if (src.isNotEmpty) {
      return Image.file(
        File(src),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (c, e, s) => _placeholder(cs),
      );
    }
    return _placeholder(cs);
  }

  Widget _placeholder(ColorScheme cs) => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [cs.surfaceContainerHigh, cs.surfaceContainerHighest],
      ),
    ),
    child: Center(
      child: Icon(
        Icons.restaurant,
        color: cs.onSurfaceVariant.withValues(alpha: 0.45),
        size: 40,
      ),
    ),
  );
}
