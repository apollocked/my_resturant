import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/presentation/cubits/account_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/presentation/widgets/auth/promo_activate_button.dart';
import 'package:my_resturant/presentation/widgets/auth/promo_error_text.dart';
import 'package:my_resturant/presentation/widgets/auth/promo_hero_icon.dart';
import 'package:my_resturant/presentation/widgets/auth/promo_text_field.dart';

class PromoCodePage extends StatefulWidget {
  const PromoCodePage({super.key});
  @override
  State<PromoCodePage> createState() => _PromoCodePageState();
}

class _PromoCodePageState extends State<PromoCodePage> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final code = _controller.text.trim();
    if (code.isEmpty) return;
    setState(() => _loading = true);
    await context.read<AccountCubit>().claimPromoCode(code);
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final settings = context.watch<SettingsCubit>().state;
    final locale = settings.locale;
    String t(String key) => Tr.get(key, locale);
    final acct = context.watch<AccountCubit>().state;
    if (acct.isActivated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/setup');
      });
    }
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: R.padding(context)),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const PromoHeroIcon(),
                  const SizedBox(height: 24),
                  Text(
                    t('promo_title'),
                    style: TextStyle(
                      fontSize: R.fontXl(context),
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t('promo_subtitle'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: R.fontMd(context),
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  PromoTextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    onSubmitted: (_) => _submit(),
                  ),
                  if (acct.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    PromoErrorText(
                      message: acct.errorMessage == 'err_invalid_promo'
                          ? t('promo_invalid')
                          : t('promo_error_general'),
                      cs: cs,
                    ),
                  ],
                  const SizedBox(height: 24),
                  PromoActivateButton(
                    loading: _loading,
                    onTap: _loading ? null : _submit,
                    t: t,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
