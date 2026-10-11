import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/task.dart';
import '../theme.dart';
import '../widgets/fun.dart';
import '../widgets/stamp.dart';

/// Shown for ~3.5s when proof is rejected, then pops so the challenge can open.
class RejectedScreen extends StatefulWidget {
  final Task task;
  const RejectedScreen({super.key, required this.task});
  @override
  State<RejectedScreen> createState() => _RejectedScreenState();
}

class _RejectedScreenState extends State<RejectedScreen> with SingleTickerProviderStateMixin {
  late final AnimationController c = AnimationController(vsync: this, duration: const Duration(milliseconds: 3600));

  @override
  void initState() {
    super.initState();
    HapticFeedback.heavyImpact();
    c.forward().whenComplete(() { if (mounted) Navigator.pop(context); });
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  double seg(double a, double b, [Curve k = Curves.linear]) => Interval(a, b, curve: k).transform(c.value);

  @override
  Widget build(BuildContext context) {
    final t = widget.task;
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: red,
        body: Stack(children: [
          const EmojiRain(emojis: ['💀', '🙅', '🚫', '😬', '🫠'], count: 14, opacity: .25),
          SafeArea(
            child: AnimatedBuilder(
              animation: c,
              builder: (_, __) {
                final hit = seg(.05, .2, Curves.easeIn);
                final thud = seg(.2, .4);
                final shake = (thud > 0 && thud < 1) ? sin(thud * pi * 10) * (1 - thud) * 10 : 0.0;
                return Transform.translate(
                  offset: Offset(shake, 0),
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Transform.scale(scale: seg(0, .15, Curves.elasticOut), child: const Text('🚫', style: TextStyle(fontSize: 88))),
                      const SizedBox(height: 18),
                      Opacity(
                        opacity: (hit * 2).clamp(0.0, 1.0),
                        child: Transform.scale(scale: 3 - 2 * hit, child: const Stamp('UNACCEPTABLE', red, animate: false, size: 28)),
                      ),
                      const SizedBox(height: 28),
                      Opacity(
                        opacity: seg(.3, .45).clamp(0.0, 1.0),
                        child: Sticker(
                          color: Colors.white,
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('"${t.title}"', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                            if ((t.roast ?? '').isNotEmpty) Padding(padding: const EdgeInsets.only(top: 10), child: Text('🔥 ${t.roast}', style: const TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.w700, fontSize: 15))),
                            if ((t.reason ?? '').isNotEmpty) Padding(padding: const EdgeInsets.only(top: 10), child: Text('🧑‍⚖️ ${t.reason}', style: TextStyle(color: ink.withValues(alpha: .75), height: 1.3))),
                          ]),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Opacity(opacity: seg(.45, .6).clamp(0.0, 1.0), child: const Text('Heading to the accountability checkpoint… 🥶', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16))),
                      const SizedBox(height: 12),
                      Container(
                        width: 220,
                        height: 16,
                        decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white, width: 2.5)),
                        child: ClipRRect(borderRadius: BorderRadius.circular(7), child: Align(alignment: Alignment.centerLeft, child: FractionallySizedBox(widthFactor: c.value, child: Container(color: sun)))),
                      ),
                    ]),
                  ),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}