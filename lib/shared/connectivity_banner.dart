import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/network_helper.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConnectivityBanner extends StatefulWidget {
  final Widget child;
  const ConnectivityBanner({super.key, required this.child});
  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner>
    with SingleTickerProviderStateMixin {
  late bool _connected;
  StreamSubscription<bool>? _sub;
  late AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _connected = NetworkService.instance.connected;
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _sub = NetworkService.instance.onConnectivityChanged.listen((connected) {
      if (!mounted) return;
      setState(() => _connected = connected);
      if (connected) {
        _animCtrl.reverse();
      } else {
        _animCtrl.forward();
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final locale = context.watch<SettingsCubit>().state.locale;
    final msg = Tr.get(_connected ? 'back_online' : 'no_connection', locale);

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _animCtrl,
            builder: (context, child) {
              final height = _animCtrl.value * 48;
              return ClipRect(
                child: AnimatedOpacity(
                  opacity: _animCtrl.value,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    height: height,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _connected
                          ? AppColors.success
                          : AppColors.error,
                      boxShadow: [
                        BoxShadow(
                          color: cs.shadow.withValues(alpha: 0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: height > 0
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Icon(
                                  _connected ? Icons.wifi : Icons.wifi_off,
                                  size: 18,
                                  color: cs.onPrimary,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    msg,
                                    style: TextStyle(
                                      color: cs.onPrimary,
                                      fontSize: R.fontSm(context),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : null,
                  ),
                ),
              );
            },
          ),
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}
