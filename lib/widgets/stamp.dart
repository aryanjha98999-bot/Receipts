import 'package:flutter/material.dart';
import '../theme.dart';

class Stamp extends StatelessWidget {
  final String text;
  final Color color;
  const Stamp(this.text, this.color, {super.key});
  @override
  Widget build(BuildContext c) => Transform.rotate(
        angle: -.12,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(border: Border.all(color: color, width: 2.5), borderRadius: BorderRadius.circular(6)),
          child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 12, fontFamily: mono)),
        ),
      );
}