import 'package:flutter/material.dart';

class MeshBackground extends StatefulWidget {
  final List<Color> colors;
  const MeshBackground({super.key, required this.colors});

  @override
  State<MeshBackground> createState() => _MeshBackgroundState();
}

class _MeshBackgroundState extends State<MeshBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctl,
      builder: (_, _) {
        final t = _ctl.value;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1.0 + t * 0.5, -1.0 + t * 0.3),
              end: Alignment(1.0 - t * 0.5, 1.0 - t * 0.3),
              colors: [
                widget.colors[0],
                widget.colors[1],
                widget.colors[2],
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -80 + t * 40,
                left: -60 + t * 30,
                child: const _Blob(size: 280, alpha: 0.06),
              ),
              Positioned(
                bottom: -100 + t * 50,
                right: -80 + t * 40,
                child: const _Blob(size: 320, alpha: 0.05),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.3,
                right: -40 + t * 20,
                child: const _Blob(size: 200, alpha: 0.04),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final double alpha;
  const _Blob({required this.size, required this.alpha});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: alpha),
      ),
    );
  }
}
