// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_resturant/core/theme/app_colors.dart';

class DishImagePicker {
  DishImagePicker({required this.t, required this.onPicked});

  final String Function(String) t;
  final ValueChanged<String> onPicked;
  final ImagePicker _picker = ImagePicker();

  void showSourceSheet(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  t('pick_image_source'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: Text(t('gallery')),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickFromGallery(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: Text(t('camera')),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickFromCamera(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.folder_open),
                  title: Text(t('files')),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickFromFile(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickFromGallery(BuildContext context) async {
    try {
      final xFile = await _picker.pickImage(source: ImageSource.gallery);
      if (xFile == null) return;
      await _cropAndSet(context, xFile.path);
    } catch (_) {
      if (context.mounted) _showError(context);
    }
  }

  Future<void> _pickFromCamera(BuildContext context) async {
    try {
      final xFile = await _picker.pickImage(source: ImageSource.camera);
      if (xFile == null) return;
      await _cropAndSet(context, xFile.path);
    } catch (_) {
      if (context.mounted) _showError(context);
    }
  }

  Future<void> _pickFromFile(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result == null || result.files.isEmpty) return;
      final path = result.files.first.path;
      if (path == null) return;
      await _cropAndSet(context, path);
    } catch (_) {
      if (context.mounted) _showError(context);
    }
  }

  Future<void> _cropAndSet(BuildContext context, String path) async {
    final cropped = await ImageCropper().cropImage(
      sourcePath: path,
      aspectRatio: const CropAspectRatio(ratioX: 4, ratioY: 3),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: t('crop_image'),
          toolbarColor: AppColors.primary,
        ),
        IOSUiSettings(title: t('crop_image')),
      ],
    );
    if (cropped != null) onPicked(cropped.path);
  }

  void _showError(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(t('error_occurred'))));
  }
}
