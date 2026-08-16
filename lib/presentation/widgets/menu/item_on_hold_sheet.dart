import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/domain/entities/recipe.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/presentation/widgets/menu/item_hold_header_image.dart';
import 'package:my_resturant/presentation/widgets/menu/item_hold_header_info.dart';
import 'package:my_resturant/presentation/widgets/menu/item_hold_notes_field.dart';
import 'package:my_resturant/presentation/widgets/menu/item_hold_save_button.dart';

class ItemOnHoldSheet extends StatefulWidget {
  final Recipe recipe;
  final String initialNotes;
  const ItemOnHoldSheet({
    super.key,
    required this.recipe,
    required this.initialNotes,
  });
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
    final radius = isDesktop
        ? 28.0
        : isTablet
        ? 24.0
        : 20.0;
    final imgHeight = isDesktop
        ? 280.0
        : isTablet
        ? 240.0
        : 200.0;
    final hPad = isDesktop
        ? 24.0
        : isTablet
        ? 20.0
        : 16.0;
    final vPad = isDesktop
        ? 20.0
        : isTablet
        ? 16.0
        : 14.0;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
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
                    ItemHoldHeaderImage(
                      imageUrl: r.imageUrl,
                      radius: radius,
                      height: imgHeight,
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(hPad, vPad, hPad, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ItemHoldHeaderInfo(
                            name: r.name,
                            price: r.price,
                            priceLabel: t('currency_suffix'),
                            description: r.description,
                            cs: cs,
                            isDesktop: isDesktop,
                            isTablet: isTablet,
                          ),
                          const SizedBox(height: 20),
                          ItemHoldNotesField(
                            controller: _notesCtrl,
                            cs: cs,
                            label: t('notes_title'),
                            hint: t('notes_hint_dialog'),
                            isDesktop: isDesktop,
                            isTablet: isTablet,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ItemHoldSaveButton(
              label: t('save'),
              onTap: () => Navigator.pop(context, _notesCtrl.text),
              isDesktop: isDesktop,
              isTablet: isTablet,
            ),
          ],
        ),
      ),
    );
  }
}
