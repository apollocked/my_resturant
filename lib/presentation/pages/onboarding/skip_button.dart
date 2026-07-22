import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/presentation/pages/onboarding/onb_colors.dart';
import 'package:my_resturant/presentation/widgets/shared/pressable_scale.dart';

class SkipButton extends StatelessWidget {
  final int page;
  final int total;
  final VoidCallback onFinish;
  const SkipButton({super.key, required this.page, required this.total, required this.onFinish});

  @override
  Widget build(BuildContext context) {
    if (page >= total - 1) return const SizedBox(height: 52);
    final settings = context.watch<SettingsCubit>().state;
    final label = Tr.get('onboarding_skip', settings.locale);
    final ob = OnbColors.of(context);

    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.only(top: 8, right: 8),
        child: PressableScale(
          onTap: onFinish,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: ob.skipBg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: ob.skipBorder),
            ),
            child: Text(label, style: TextStyle(color: ob.skipText, fontWeight: FontWeight.w600, fontSize: 14, letterSpacing: 0.5)),
          ),
        ),
      ),
    );
  }
}
