import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/domain/entities/recipe.dart';
import 'package:my_resturant/presentation/widgets/shared/app_image.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/presentation/widgets/shared/pressable_scale.dart';

class ItemOnHoldSheet extends StatefulWidget {
  final Recipe recipe;
  final String initialNotes;
  const ItemOnHoldSheet({super.key, required this.recipe, required this.initialNotes});
  @override
  State<ItemOnHoldSheet> createState() => _ItemOnHoldSheetState();
}

class _ItemOnHoldSheetState extends State<ItemOnHoldSheet> {
  late final TextEditingController _notesCtrl;

  @override
  void initState() {
    super.initState();
    _notesCtrl = TextEditingController(text: widget.initialNotes);
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    String t(String key) => Tr.get(key, settings.locale);
    final cs = Theme.of(context).colorScheme;
    final r = widget.recipe;
    final screen = R.screenSize(context);
    final isDesktop = screen == ScreenSize.desktop;
    final isTablet = screen == ScreenSize.tablet;
    final radius = isDesktop ? 28.0 : isTablet ? 24.0 : 20.0;
    final imgHeight = isDesktop ? 280.0 : isTablet ? 240.0 : 200.0;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
                      child: SizedBox(
                        width: double.infinity,
                        height: imgHeight,
                        child: AppImage(r.imageUrl, width: double.infinity, height: imgHeight, fit: BoxFit.cover),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(isDesktop ? 24 : isTablet ? 20 : 16, isDesktop ? 20 : isTablet ? 16 : 14, isDesktop ? 24 : isTablet ? 20 : 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(r.name,
                                  style: TextStyle(fontSize: isDesktop ? 22 : isTablet ? 20 : 18, fontWeight: FontWeight.w800, color: cs.onSurface)),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: isDesktop ? 14 : isTablet ? 12 : 10, vertical: isDesktop ? 6 : 5),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySoft,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text('${r.price.toInt()} ${t('currency_suffix')}',
                                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: isDesktop ? 16 : isTablet ? 14 : 13, color: AppColors.primary)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (r.description.isNotEmpty)
                            Text(r.description,
                              style: TextStyle(fontSize: isDesktop ? 15 : isTablet ? 14 : 13, color: cs.onSurfaceVariant, height: 1.5)),
                          const SizedBox(height: 20),
                          Text(t('notes_title'),
                            style: TextStyle(fontSize: isDesktop ? 15 : isTablet ? 14 : 13, fontWeight: FontWeight.w700, color: cs.onSurface)),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: cs.outline.withValues(alpha: 0.2)),
                            ),
                            child: TextField(
                              controller: _notesCtrl,
                              maxLines: 3,
                              style: TextStyle(fontSize: isDesktop ? 15 : isTablet ? 14 : 13, color: cs.onSurface),
                              decoration: InputDecoration(
                                hintText: t('notes_hint_dialog'),
                                hintStyle: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(isDesktop ? 16 : isTablet ? 14 : 12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(isDesktop ? 24 : isTablet ? 20 : 16, 0, isDesktop ? 24 : isTablet ? 20 : 16, isDesktop ? 16 : 12),
                child: SizedBox(
                  width: double.infinity,
                  height: isDesktop ? 52 : isTablet ? 48 : 46,
                  child: PressableScale(
                    onTap: () => Navigator.pop(context, _notesCtrl.text),
                    child: FilledButton(
                      onPressed: null,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(t('save'), style: TextStyle(fontSize: isDesktop ? 16 : isTablet ? 15 : 14, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
