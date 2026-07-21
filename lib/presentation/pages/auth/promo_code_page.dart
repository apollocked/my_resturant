import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/presentation/cubits/account_cubit.dart';
import 'package:my_resturant/presentation/widgets/shared/pressable_scale.dart';

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
    final acct = context.watch<AccountCubit>().state;
    if (acct.isActivated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/setup');
      });
    }
    return Scaffold(
      body: SafeArea(child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: R.padding(context)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.vpn_key, size: 40, color: AppColors.primary),
              ),
              const SizedBox(height: 24),
              Text('Enter Promo Code', style: TextStyle(fontSize: R.fontXl(context), fontWeight: FontWeight.w800, color: cs.onSurface)),
              const SizedBox(height: 8),
              Text('Contact the developer to get your activation code.',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: R.fontMd(context), color: cs.onSurfaceVariant)),
              const SizedBox(height: 32),
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: true,
                textCapitalization: TextCapitalization.characters,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: 6, color: cs.onSurface),
                decoration: InputDecoration(
                  hintText: 'XXXX-XXXX',
                  hintStyle: TextStyle(letterSpacing: 6, color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
                  filled: true,
                  fillColor: cs.surfaceContainerHighest,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\-]')),
                  LengthLimitingTextInputFormatter(9),
                ],
                onSubmitted: (_) => _submit(),
              ),
              if (acct.errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  acct.errorMessage == 'err_invalid_promo' ? 'Invalid or already used promo code.' : 'Something went wrong.',
                  style: TextStyle(color: cs.error, fontSize: R.fontSm(context)),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 52,
                child: PressableScale(
                  onTap: _loading ? null : _submit,
                  child: FilledButton(
                    onPressed: null,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _loading
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                        : const Text('Activate', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ]),
          ),
        ),
      )),
    );
  }
}
