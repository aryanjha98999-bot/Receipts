import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/fun.dart';
import '../widgets/stamp.dart';

/// The receipt drops in, letters bounce, a VERIFIED stamp slams down,
/// a tomato gets thrown at it, it dodges, then we iris-wipe into the app.
class SplashScreen extends StatefulWidget {
  final Widget next;
  const SplashScreen({super.key, required this.next});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  static const word = 'RECEIPTS';
  static const lines = ['Loading your excuses… 🙈', 'Sharpening the roasts… 🔥', 'Hiding the snooze button… ⏰', 'Bribing the AI judge… 🍪'];

  late final AnimationController c = AnimationController(vsync: this, duration: const Duration(milliseconds: 4800));
  Timer? t;
  int line = 0;
  bool left = false;

  @override
  void initState() {
    super.initState();
    c.forward().whenComplete(go);
    t = Timer.periodic(const Duration(milliseconds: 1000), (_) { if (mounted) setState(() => line = (line + 1) % lines.length); });
  }

  @override
  void dispose() {
    t?.cancel();
    c.dispose();
    super.dispose();
  }

  void go() {
    if (!mounted || left) return;
    left = true;
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 900),
      pageBuilder: (ctx, a, sec) => widget.next,
      transitionsBuilder: (ctx, a, sec, child) => AnimatedBuilder(
        animation: a,
        builder: (_, __) => ClipPath(clipper: _CircleReveal(Curves.easeInOut.transform(a.value)), child: child),
      ),
    ));
  }

  double seg(double a, double b, [Curve k = Curves.linear]) => Interval(a, b, curve: k).transform(c.value);

  Widget letter(int i) {
    final a = .2 + i * .03;
    final p = seg(a, a + .16, Curves.elasticOut);
    final o = seg(a, a + .05).clamp(0.0, 1.0);
    return Opacity(
      opacity: o,
      child: Transform.translate(
        offset: Offset(0, (1 - p) * -40),
        child: Transform.scale(scale: p, child: Text(word[i], style: TextStyle(fontFamily: mono, fontSize: 42, fontWeight: FontWeight.w900, color: i.isEven ? ink : accent))),
      ),
    );
  }

  Widget receipt(double w) {
    final stampT = seg(.58, .66, Curves.easeIn);
    return SizedBox(
      width: min(w - 56, 330),
      child: Stack(clipBehavior: Clip.none, children: [
        Sticker(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 26, 20, 34),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('🧾', style: TextStyle(fontSize: 84)),
            const SizedBox(height: 6),
            FittedBox(fit: BoxFit.scaleDown, child: Row(mainAxisSize: MainAxisSize.min, children: [for (var i = 0; i < word.length; i++) letter(i)])),
            const SizedBox(height: 8),
            Opacity(opacity: seg(.5, .6).clamp(0.0, 1.0), child: const Text('No proof, no progress.', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
          ]),
        ),
        Positioned(
          right: -10,
          bottom: -16,
          child: Opacity(opacity: (stampT * 2).clamp(0.0, 1.0), child: Transform.scale(scale: 3 - 2 * stampT, child: const Stamp('VERIFIED', green, animate: false, size: 15))),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: sun,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: go,
        child: AnimatedBuilder(
          animation: c,
          builder: (_, __) {
            final drop = 1 - seg(0, .2, Curves.bounceOut);
            final thud = seg(.66, .76);
            final shake = (thud > 0 && thud < 1) ? sin(thud * pi * 8) * (1 - thud) * 7 : 0.0;
            final dodge = seg(.78, .92);
            final jump = sin(dodge * pi);
            final tomatoX = size.width + 60 - seg(.76, .9) * (size.width + 160);
            final msg = c.value > .93 ? 'Nice dodge. Now go prove yourself 😎' : lines[line];
            return Stack(children: [
              const EmojiRain(emojis: ['✅', '🧾', '⏰', '🙈', '🫠', '🔥', '📝', '🎯'], count: 16, opacity: .3),
              Center(
                child: Transform.translate(
                  offset: Offset(shake - jump * 90, -drop * size.height * .6 - jump * 28),
                  child: Transform.rotate(angle: -jump * .3, child: receipt(size.width)),
                ),
              ),
              Positioned(left: tomatoX, top: size.height * .5 - 30, child: Transform.rotate(angle: dodge * 12, child: const Text('🍅', style: TextStyle(fontSize: 46)))),
              Positioned(
                left: 0,
                right: 0,
                bottom: 56,
                child: Column(children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (ch, a) => FadeTransition(opacity: a, child: SlideTransition(position: Tween<Offset>(begin: const Offset(0, .5), end: Offset.zero).animate(a), child: ch)),
                    child: Text(msg, key: ValueKey(msg), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: 220,
                    height: 18,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: ink, width: 2.5)),
                    child: ClipRRect(borderRadius: BorderRadius.circular(9), child: Align(alignment: Alignment.centerLeft, child: FractionallySizedBox(widthFactor: c.value, child: Container(color: pink)))),
                  ),
                  const SizedBox(height: 10),
                  const Text('tap to skip', style: TextStyle(fontSize: 12, color: Colors.black54)),
                ]),
              ),
            ]);
          },
        ),
      ),
    );
  }
}

class _CircleReveal extends CustomClipper<Path> {
  final double f;
  _CircleReveal(this.f);
  @override
  Path getClip(Size s) => Path()..addOval(Rect.fromCircle(center: Offset(s.width / 2, s.height / 2), radius: s.longestSide * f));
  @override
  bool shouldReclip(_CircleReveal old) => old.f != f;
}