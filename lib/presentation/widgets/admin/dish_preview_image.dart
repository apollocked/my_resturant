import 'package:flutter/material.dart';
import 'package:my_resturant/shared/app_image.dart';

class DishPreviewImage extends StatelessWidget {
  const DishPreviewImage({super.key, required this.url});

  final ValueNotifier<String> url;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: url,
      builder: (_, v, _) => v.isEmpty
          ? const SizedBox(height: 130)
          : ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AppImage(v, width: double.infinity, height: 130),
            ),
    );
  }
}
