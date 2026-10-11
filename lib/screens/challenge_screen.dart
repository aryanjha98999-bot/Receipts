import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key});
  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  static const sentences = ['I solemnly swear I will attach actual evidence next time.', 'A screenshot of my intentions is not a screenshot of my work.', 'Vibes are not a deliverable and I accept this.'];
  static const titles = ['Retype this, slowly:', 'Sit with your choices.', 'Make a concrete commitment.'];
  final kind = Random().nextInt(3);
  late final String sentence = sentences[Random().nextInt(sentences.length)];
  final c = TextEditingController();
  int left = 15;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    if (kind == 1) timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() { if (left > 0) left--; }));
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  bool get ok => switch (kind) {
        0 => c.text.trim() == sentence,
        1 => left == 0,
        _ => c.text.trim().length >= 12 && RegExp(r'\d').hasMatch(c.text),
      };

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: const Color(0xFFFFF1EE),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: 24),
                const Text('❄️ Accountability checkpoint', style: TextStyle(color: red, fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                Text(titles[kind], style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                const SizedBox(height: 20),
                if (kind == 0) Text('"$sentence"', style: const TextStyle(fontFamily: mono, fontSize: 16)),
                if (kind == 1) Center(child: Text('$left', style: const TextStyle(fontSize: 96, fontWeight: FontWeight.w900, fontFamily: mono))),
                if (kind == 2) const Text('Write one specific action with a time, e.g. "Export the poster at 6 pm today".'),
                if (kind != 1) ...[const SizedBox(height: 16), TextField(controller: c, autofocus: true, onChanged: (_) => setState(() {}), decoration: fieldStyle('Type here'))],
                const Spacer(),
                FilledButton(onPressed: ok ? () => Navigator.pop(context) : null, style: bigButton(), child: const Text('Unfreeze my tasks')),
              ]),
            ),
          ),
        ),
      );
}