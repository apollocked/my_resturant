// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/domain/entities/recipe.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/presentation/widgets/admin/dish_form_fields.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/presentation/widgets/shared/pressable_scale.dart';

class DishFormPage extends StatefulWidget {
  final Recipe? recipe;
  const DishFormPage({super.key, this.recipe});
  @override
  State<DishFormPage> createState() => _DishFormPageState();
}

class _DishFormPageState extends State<DishFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  late final TextEditingController _nameCtrl, _priceCtrl, _descCtrl;
  final _imageUrl = ValueNotifier<String>('');
  late String _category;
  bool get _isEditing => widget.recipe != null;

  @override
  void initState() {
    super.initState();
    final r = widget.recipe;
    _nameCtrl = TextEditingController(text: r?.name ?? '');
    _priceCtrl = TextEditingController(text: r?.price.toInt().toString() ?? '');
    _descCtrl = TextEditingController(text: r?.description ?? '');
    _imageUrl.value = r?.imageUrl ?? '';
    _category = r?.category ?? 'burger';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    _imageUrl.dispose();
    super.dispose();
  }

  String _t(String key) =>
      Tr.get(key, context.read<SettingsCubit>().state.locale);

  void _showImageSourceSheet() {
    final cs = Theme.of(context).colorScheme;
    final settings = context.read<SettingsCubit>().state;
    String t(String key) => Tr.get(key, settings.locale);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
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
                  _pickFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(t('camera')),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.folder_open),
                title: Text(t('files')),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickFromFile();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    try {
      final xFile = await _picker.pickImage(source: ImageSource.gallery);
      if (xFile == null) return;
      await _cropAndSet(xFile.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_t('error_occurred'))));
      }
    }
  }

  Future<void> _pickFromCamera() async {
    try {
      final xFile = await _picker.pickImage(source: ImageSource.camera);
      if (xFile == null) return;
      await _cropAndSet(xFile.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_t('error_occurred'))));
      }
    }
  }

  Future<void> _pickFromFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result == null || result.files.isEmpty) return;
      final path = result.files.first.path;
      if (path == null) return;
      await _cropAndSet(path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_t('error_occurred'))));
      }
    }
  }

  Future<void> _cropAndSet(String path) async {
    final cropped = await ImageCropper().cropImage(
      sourcePath: path,
      aspectRatio: const CropAspectRatio(ratioX: 4, ratioY: 3),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: _t('crop_image'),
          toolbarColor: AppColors.primary,
        ),
        IOSUiSettings(title: _t('crop_image')),
      ],
    );
    if (cropped != null) _imageUrl.value = cropped.path;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final id = _isEditing ? widget.recipe!.id : const Uuid().v4();
    String imageUrl = _imageUrl.value.isEmpty
        ? 'https://picsum.photos/seed/${_nameCtrl.text.trim()}/400/300'
        : _imageUrl.value;
    if (!imageUrl.startsWith('http')) {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      try {
        imageUrl = await _uploadImage(id, imageUrl);
      } catch (e) {
        if (mounted) Navigator.pop(context);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_t('error_occurred')),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      if (mounted) Navigator.pop(context);
    }
    final r = Recipe(
      id: id,
      name: _nameCtrl.text.trim(),
      price: double.tryParse(_priceCtrl.text) ?? 0,
      description: _descCtrl.text.trim(),
      category: _category,
      imageUrl: imageUrl,
    );
    if (mounted) Navigator.pop(context, r);
  }

  Future<String> _uploadImage(String recipeId, String localPath) async {
    final file = File(localPath);
    final bytes = await FlutterImageCompress.compressWithFile(
      file.path,
      quality: 75,
      minWidth: 1024,
      minHeight: 1024,
      format: CompressFormat.jpeg,
    );
    if (bytes == null || bytes.isEmpty) throw Exception('Compression failed');
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) throw Exception('Not logged in');
    final path = '$uid/$recipeId.jpg';
    await Supabase.instance.client.storage
        .from('recipe_images')
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );
    return Supabase.instance.client.storage
        .from('recipe_images')
        .getPublicUrl(path);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? _t('edit_dish') : _t('add_dish')),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(R.padding(context)),
            child: Column(
              children: [
                DishFormFields(
                  formKey: _formKey,
                  nameCtrl: _nameCtrl,
                  priceCtrl: _priceCtrl,
                  descCtrl: _descCtrl,
                  imageUrl: _imageUrl,
                  initialCategory: _category,
                  t: _t,
                  isEditing: _isEditing,
                  onPickImage: _showImageSourceSheet,
                  onCategoryChanged: (v) => _category = v,
                  categories: context.read<OrderCubit>().state.categories,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: R.isDesktop(context) ? 56 : 48,
                  child: PressableScale(
                    onTap: _save,
                    child: ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        disabledBackgroundColor: Theme.of(context).colorScheme.primary,
                        disabledForegroundColor: Theme.of(context).colorScheme.onPrimary,
                      ),
                      child: Text(
                        _isEditing ? _t('update_btn') : _t('add_btn'),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: R.fontMd(context),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
