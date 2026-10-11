import 'package:flutter/material.dart';
import '../theme.dart';

class Stamp extends StatelessWidget {
  final String text;
  final Color color;
  final bool animate;
  final double size;
  const Stamp(this.text, this.color, {super.key, this.animate = true, this.size = 12});

  @override
  Widget build(BuildContext c) {
    final s = Transform.rotate(
      angle: -.12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: .85), border: Border.all(color: color, width: 2.5), borderRadius: BorderRadius.circular(6)),
        child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: size, fontFamily: mono)),
      ),
    );
    if (!animate) return s;
    // Slams down like a real rubber stamp.
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 550),
      curve: Curves.bounceOut,
      builder: (_, v, child) => Opacity(opacity: (v * 2).clamp(0.0, 1.0), child: Transform.scale(scale: 2.6 - 1.6 * v, child: child)),
      child: s,
    );
  }
}