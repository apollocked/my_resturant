import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:my_resturant/core/constants/app_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<String> uploadDishImage(String recipeId, String localPath) async {
  final file = File(localPath);
  final bytes = await FlutterImageCompress.compressWithFile(
    file.path,
    quality: 75,
    minWidth: 1024,
    minHeight: 1024,
    format: CompressFormat.jpeg,
  );
  if (bytes == null || bytes.isEmpty) throw Exception('Compression failed');
  if (bytes.length > AppConstants.maxImageSizeBytes) {
    throw Exception(
      'Image too large. Maximum size is '
      '${AppConstants.maxImageSizeBytes ~/ (1024 * 1024)}MB',
    );
  }
  final uid = Supabase.instance.client.auth.currentUser?.id;
  if (uid == null) throw Exception('Not logged in');
  final path = '$uid/$recipeId.jpg';
  await Supabase.instance.client.storage
      .from('recipe_images')
      .uploadBinary(path, bytes, fileOptions: const FileOptions(upsert: true));
  return Supabase.instance.client.storage
      .from('recipe_images')
      .getPublicUrl(path);
}
