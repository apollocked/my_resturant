import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/presentation/cubits/role_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/presentation/widgets/profile/profile_info_section.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    final role = context.watch<RoleCubit>().state.role;
    String t(String key) => Tr.get(key, settings.locale);
    final p = R.padding(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t('info_section_title')),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(p, 0, p, p + 60),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: R.isTablet(context) || R.isDesktop(context)
                  ? 720
                  : double.infinity,
            ),
            child: ProfileInfoSection(role: role, t: t, showHeader: false),
          ),
        ),
      ),
    );
  }
}
