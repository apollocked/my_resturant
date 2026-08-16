import 'package:flutter/material.dart';
import 'package:my_resturant/shared/app_image.dart';

class ItemHoldHeaderImage extends StatelessWidget {
  const ItemHoldHeaderImage({
    super.key,
    required this.imageUrl,
    required this.radius,
    required this.height,
  });

  final String imageUrl;
  final double radius;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: AppImage(
          imageUrl,
          width: double.infinity,
          height: height,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
