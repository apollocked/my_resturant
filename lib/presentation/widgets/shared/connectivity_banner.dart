import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityBanner extends StatefulWidget {
  final Widget child;
  const ConnectivityBanner({super.key, required this.child});
  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner> {
  bool _connected = true;
  late StreamSubscription<List<ConnectivityResult>> _sub;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final results = await Connectivity().checkConnectivity();
    if (mounted) setState(() => _connected = results.any((r) => r != ConnectivityResult.none));
    _sub = Connectivity().onConnectivityChanged.listen((results) {
      if (mounted) setState(() => _connected = results.any((r) => r != ConnectivityResult.none));
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: _connected ? 0 : 36,
        width: double.infinity,
        color: Colors.red.shade700,
        child: _connected
          ? null
          : const Center(child: Text('No internet connection', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))),
      ),
      Expanded(child: widget.child),
    ]);
  }
}
