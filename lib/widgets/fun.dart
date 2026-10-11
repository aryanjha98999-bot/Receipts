import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';

/// Sticker-style card: thick outline + hard offset shadow.
class Sticker extends StatelessWidget {
  final Widget child;
  final Color color, shadow;
  final EdgeInsets padding;
  final double radius;
  const Sticker({super.key, required this.child, this.color = card, this.shadow = ink, this.padding = const EdgeInsets.all(16), this.radius = 20});

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: ink, width: 2.5),
          boxShadow: [BoxShadow(color: shadow, offset: const Offset(4, 4))],
        ),
        child: child,
      );
}

/// Chunky button that physically presses down.
class FunButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final Color color, textColor;
  final bool busy;
  const FunButton({super.key, required this.label, required this.onTap, this.color = sun, this.textColor = ink, this.busy = false});
  @override
  State<FunButton> createState() => _FunButtonState();
}

class _FunButtonState extends State<FunButton> {
  bool down = false;
  @override
  Widget build(BuildContext context) {
    final active = widget.onTap != null;
    final pressable = active && !widget.busy;
    final dy = down ? 4.0 : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: pressable ? (_) => setState(() => down = true) : null,
        onTapUp: (_) => setState(() => down = false),
        onTapCancel: () => setState(() => down = false),
        onTap: pressable ? () { HapticFeedback.mediumImpact(); widget.onTap!(); } : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, dy, 0),
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? widget.color : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: active ? ink : ink.withValues(alpha: .35), width: 2.5),
            boxShadow: [BoxShadow(color: active ? ink : ink.withValues(alpha: .25), offset: Offset(0, 4 - dy))],
          ),
          child: widget.busy
              ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 3, color: ink))
              : Text(widget.label, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: active ? widget.textColor : ink.withValues(alpha: .4))),
        ),
      ),
    );
  }
}

/// Elastic pop-in, with an optional delay so lists stagger nicely.
class PopIn extends StatefulWidget {
  final Widget child;
  final int delay;
  const PopIn({super.key, required this.child, this.delay = 0});
  @override
  State<PopIn> createState() => _PopInState();
}

class _PopInState extends State<PopIn> with SingleTickerProviderStateMixin {
  late final AnimationController c = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
  Timer? t;
  @override
  void initState() {
    super.initState();
    t = Timer(Duration(milliseconds: widget.delay), () { if (mounted) c.forward(); });
  }

  @override
  void dispose() {
    t?.cancel();
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: c,
        child: widget.child,
        builder: (_, child) => Opacity(
          opacity: (c.value * 3).clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 28 * (1 - Curves.easeOut.transform(c.value))),
            child: Transform.scale(scale: .6 + .4 * Curves.elasticOut.transform(c.value), child: child),
          ),
        ),
      );
}

/// Gentle up/down bobbing, forever.
class Floaty extends StatefulWidget {
  final Widget child;
  final double dy;
  final int ms;
  const Floaty({super.key, required this.child, this.dy = 10, this.ms = 1800});
  @override
  State<Floaty> createState() => _FloatyState();
}

class _FloatyState extends State<Floaty> with SingleTickerProviderStateMixin {
  late final AnimationController c = AnimationController(vsync: this, duration: Duration(milliseconds: widget.ms))..repeat(reverse: true);
  @override
  void dispose() { c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: c, child: widget.child, builder: (_, child) => Transform.translate(offset: Offset(0, -widget.dy * Curves.easeInOut.transform(c.value)), child: child));
}

/// Cute side-to-side rocking.
class Wiggle extends StatefulWidget {
  final Widget child;
  final double amount;
  final int ms;
  const Wiggle({super.key, required this.child, this.amount = .08, this.ms = 1600});
  @override
  State<Wiggle> createState() => _WiggleState();
}

class _WiggleState extends State<Wiggle> with SingleTickerProviderStateMixin {
  late final AnimationController c = AnimationController(vsync: this, duration: Duration(milliseconds: widget.ms))..repeat();
  @override
  void dispose() { c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: c, child: widget.child, builder: (_, child) => Transform.rotate(angle: sin(c.value * 2 * pi) * widget.amount, child: child));
}

/// Shakes whenever [trigger] changes (use a counter).
class Shake extends StatelessWidget {
  final int trigger;
  final Widget child;
  const Shake({super.key, required this.trigger, required this.child});
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        key: ValueKey(trigger),
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 550),
        child: child,
        builder: (_, v, ch) => Transform.translate(offset: Offset(sin(v * pi * 6) * (1 - v) * 12, 0), child: ch),
      );
}

class _Bit {
  final String e;
  final double x, phase, size, seed;
  _Bit(this.e, this.x, this.phase, this.size, this.seed);
}

/// Faint emojis drifting upward behind everything.
class EmojiRain extends StatefulWidget {
  final List<String> emojis;
  final int count;
  final double opacity;
  const EmojiRain({super.key, required this.emojis, this.count = 12, this.opacity = .2});
  @override
  State<EmojiRain> createState() => _EmojiRainState();
}

class _EmojiRainState extends State<EmojiRain> with SingleTickerProviderStateMixin {
  late final AnimationController c = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
  late final List<_Bit> bits = () {
    final r = Random(11);
    return List.generate(widget.count, (i) => _Bit(widget.emojis[i % widget.emojis.length], r.nextDouble(), r.nextDouble(), 22 + r.nextDouble() * 26, r.nextDouble() * 2 * pi));
  }();
  @override
  void dispose() { c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: SizedBox.expand(
          child: LayoutBuilder(
            builder: (_, box) => AnimatedBuilder(
              animation: c,
              builder: (_, __) => Stack(children: [
                for (final b in bits)
                  Positioned(
                    left: b.x * (box.maxWidth - 40) + sin(c.value * 2 * pi + b.seed) * 14,
                    top: box.maxHeight - ((b.phase + c.value) % 1.0) * (box.maxHeight + 80),
                    child: Opacity(opacity: widget.opacity, child: Transform.rotate(angle: sin(c.value * 2 * pi + b.seed) * .4, child: Text(b.e, style: TextStyle(fontSize: b.size)))),
                  ),
              ]),
            ),
          ),
        ),
      );
}

/// Pop-up speech bubble used for the AI's feedback.
class SpeechBubble extends StatelessWidget {
  final String text;
  final bool good;
  const SpeechBubble(this.text, this.good, {super.key});
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        key: ValueKey(text),
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 700),
        curve: Curves.elasticOut,
        builder: (_, v, child) => Transform.scale(scale: v, alignment: Alignment.topLeft, child: child),
        child: Sticker(
          color: good ? const Color(0xFFDFF8E8) : const Color(0xFFFFE3DE),
          shadow: good ? green : red,
          padding: const EdgeInsets.all(14),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(good ? '🧑‍⚖️' : '😬', style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 10),
            Expanded(child: Text(text, style: TextStyle(color: good ? green : red, fontWeight: FontWeight.w800, fontSize: 15, height: 1.3))),
          ]),
        ),
      );
}

/// Shown while the AI judge is thinking.
class JudgingBubble extends StatefulWidget {
  const JudgingBubble({super.key});
  @override
  State<JudgingBubble> createState() => _JudgingBubbleState();
}

class _JudgingBubbleState extends State<JudgingBubble> {
  static const msgs = ['Judge is squinting at your proof… 🧐', 'Consulting the receipt gods… 🙏', 'Sniffing for nonsense… 👃', 'Pretending to read very carefully… 📖', 'Sharpening the roast… 🔥', 'Checking if this is a screenshot of a screenshot… 🪞'];
  int i = 0;
  Timer? t;
  @override
  void initState() {
    super.initState();
    t = Timer.periodic(const Duration(milliseconds: 1400), (_) { if (mounted) setState(() => i++); });
  }

  @override
  void dispose() { t?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 16),
        child: PopIn(
          child: Sticker(
            color: sky,
            child: Row(children: [
              const Wiggle(amount: .25, ms: 700, child: Text('🧑‍⚖️', style: TextStyle(fontSize: 34))),
              const SizedBox(width: 12),
              Expanded(child: AnimatedSwitcher(duration: const Duration(milliseconds: 350), child: Text(msgs[i % msgs.length], key: ValueKey(i), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)))),
            ]),
          ),
        ),
      );
}

/// Fires a burst of confetti over the whole screen.
void burstConfetti(BuildContext context) {
  HapticFeedback.heavyImpact();
  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  entry = OverlayEntry(builder: (_) => Positioned.fill(child: _Confetti(onDone: () => entry.remove())));
  overlay.insert(entry);
}

class _Piece {
  final double a, v, spin, size;
  final Color color;
  final bool round;
  _Piece(this.a, this.v, this.spin, this.size, this.color, this.round);
}

class _Confetti extends StatefulWidget {
  final VoidCallback onDone;
  const _Confetti({required this.onDone});
  @override
  State<_Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<_Confetti> with SingleTickerProviderStateMixin {
  late final AnimationController c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..forward();
  late final List<_Piece> ps = () {
    final r = Random();
    const cols = [sun, pink, accent, green, sky, Color(0xFFFF8A3D)];
    return List.generate(90, (_) => _Piece(-pi * (.05 + r.nextDouble() * .9), 250 + r.nextDouble() * 550, r.nextDouble() * 12, 7 + r.nextDouble() * 8, cols[r.nextInt(cols.length)], r.nextBool()));
  }();
  @override
  void initState() {
    super.initState();
    c.addStatusListener((s) { if (s == AnimationStatus.completed) widget.onDone(); });
  }

  @override
  void dispose() { c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => IgnorePointer(child: AnimatedBuilder(animation: c, builder: (_, __) => CustomPaint(painter: _ConfettiPainter(c.value, ps))));
}

class _ConfettiPainter extends CustomPainter {
  final double t;
  final List<_Piece> ps;
  _ConfettiPainter(this.t, this.ps);
  @override
  void paint(Canvas canvas, Size size) {
    final o = Offset(size.width / 2, size.height * .38);
    final fade = (1 - ((t - .7) / .3)).clamp(0.0, 1.0);
    final tt = t * 1.7;
    for (final p in ps) {
      final pos = o + Offset(cos(p.a) * p.v * tt, sin(p.a) * p.v * tt + 450 * tt * tt);
      final paint = Paint()..color = p.color.withValues(alpha: fade);
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(p.spin * t);
      if (p.round) {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * .55), paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}