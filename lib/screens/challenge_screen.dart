import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/task.dart';
import '../services/review_service.dart';
import '../services/task_service.dart';
import '../theme.dart';
import '../widgets/fun.dart';

enum Kind { excuse, tiny, apology, roast, headline, plan, buddy }

class ChallengeScreen extends StatefulWidget {
  final Task task;
  const ChallengeScreen({super.key, required this.task});
  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  static const stakes = ['Buy chai ☕', 'No scrolling tonight 📵', 'Samosas for a friend 🥟', 'Post my shame 😭'];
  static const deadlines = ['1 hour', 'Tonight', 'Tomorrow'];
  static const instr = {
    Kind.excuse: 'You are a dramatic judge in Excuse Court. Score the excuse out of 10 for creativity and believability and give a funny mock verdict. Always set ok to true. Start the feedback with "Score X/10."',
    Kind.apology: 'Accept any sincere apology about not finishing this task, even if it is plain, short, or has typos. Humor is NOT required and must never be a reason to reject. Reject only if the text is gibberish, is not an apology, or is clearly mocking rather than sincere. If rejecting, say in one friendly sentence what is missing. If accepting, give a short warm or lightly playful acknowledgement.',
    Kind.roast: 'Accept only a genuinely funny roast of the user\'s own procrastination on this task (at least 5/10 funny, specific to the task). Otherwise ok false with a teasing hint.',
    Kind.headline: 'Accept only text that reads like a newspaper headline about the user finally completing this task. Otherwise ok false with a hint.',
  };

  Task get task => widget.task;
  late final Kind kind = _pick();
  final c = TextEditingController();
  Timer? timer;
  int step = 0, left = 120;
  bool busy = false, done = false, good = false;
  String? msg;
  List<String> items = [];
  int? picked;
  String deadline = 'Tonight', stake = stakes[0];

  Kind _pick() {
    if (task.attempts >= 3) return Kind.buddy;
    if (task.attempts == 2) return Kind.plan;
    const pool = [Kind.excuse, Kind.tiny, Kind.apology, Kind.roast, Kind.headline];
    return pool[Random(task.id.codeUnits.fold<int>(0, (a, b) => a + b)).nextInt(pool.length)];
  }

  @override
  void initState() {
    super.initState();
    if (kind == Kind.plan) makeChecklist(task).then((v) { if (mounted) setState(() => items = v); });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  String get name => task.title.length > 50 ? '${task.title.substring(0, 50)}...' : task.title;
  int get words => c.text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  String two(int n) => n.toString().padLeft(2, '0');
  String get buddyText {
    final d = task.deadline;
    final by = d == null ? 'tomorrow night' : '${two(d.hour)}:${two(d.minute)} on ${d.day}/${d.month}';
    return 'If I don\'t finish "$name" by $by, I owe you ${task.stake ?? 'samosas'}. Hold me to it. 🧾';
  }

  void pop() => Navigator.pop(context);

  Future<void> judge(int minWords) async {
    setState(() { busy = true; msg = null; });
    final (ok, m) = await judgeText(instr[kind]!, task, c.text, minWords: minWords);
    if (!mounted) return;
    setState(() {
      busy = false; msg = m; good = ok;
      if (ok && kind == Kind.excuse) { step = 1; c.clear(); } else if (ok) { done = true; }
    });
    if (ok) burstConfetti(context);
  }

  void startTiny() {
    setState(() => step = 1);
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() { if (left > 0) left--; });
      if (left == 0) t.cancel();
    });
  }

  Future<void> sign() async {
    final now = DateTime.now();
    task.deadline = switch (deadline) {
      '1 hour' => now.add(const Duration(hours: 1)),
      'Tonight' => now.hour >= 21 ? now.add(const Duration(hours: 2)) : DateTime(now.year, now.month, now.day, 21),
      _ => DateTime(now.year, now.month, now.day + 1, 18),
    };
    task.stake = stake;
    setState(() => busy = true);
    try { await tasksApi.update(task); } catch (_) {}
    if (mounted) pop();
  }

  Future<void> share() async {
    final r = await SharePlus.instance.share(ShareParams(text: buddyText));
    if (r.status != ShareResultStatus.dismissed && mounted) pop();
  }

  Widget field(String hint, {int lines = 2}) => TextField(controller: c, minLines: lines, maxLines: lines + 2, onChanged: (_) => setState(() {}), decoration: fieldStyle(hint));

  Widget chips(List<String> opts, String sel, void Function(String) on) => Wrap(spacing: 8, children: [for (final o in opts) ChoiceChip(label: Text(o), selected: sel == o, onSelected: (_) => setState(() => on(o)))]);

  String get title => switch (kind) {
        Kind.excuse => '⚖️ Excuse Court is in session',
        Kind.tiny => '🐜 Make it tiny. Then start.',
        Kind.apology => '🥺 Apologise to your task',
        Kind.roast => '🔥 Roast yourself',
        Kind.headline => "📰 Write tomorrow's headline",
        Kind.plan => '🦸 Plan your comeback',
        Kind.buddy => '🫂 Time to tell a friend',
      };

  List<Widget> body() {
    const gap = SizedBox(height: 12);
    switch (kind) {
      case Kind.excuse:
        return step == 0
            ? [Text('State your excuse for not finishing "$name". The judge is already unimpressed.'), gap, field('My excuse is...')]
            : [const Text('Now turn that excuse into a promise.'), gap, field('I promise to...')];
      case Kind.tiny:
        return step == 0
            ? [Text('What is the smallest possible first step on "$name"? Embarrassingly tiny.'), gap, field('e.g. Open Canva and create the file')]
            : [Text('Do this for 2 minutes: ${c.text}'), gap, Center(child: Text('${left ~/ 60}:${two(left % 60)}', style: const TextStyle(fontSize: 72, fontWeight: FontWeight.w900, fontFamily: mono)))];
      case Kind.apology:
        return [Text('Write a short, sincere apology to "$name" for leaving it hanging.'), gap, field('Dear $name, I am sorry...')];
      case Kind.roast:
        return [Text('Roast your own procrastination on "$name". One line. Make it sting.'), gap, field('I put off "$name" like...')];
      case Kind.headline:
        return [Text('Write the newspaper headline for the day you finally finish "$name".'), gap, field('Local Student Finally...')];
      case Kind.plan:
        return step == 0
            ? [
                const Text('Your next proof needs these. Pick the one you will deliver first:'),
                gap,
                if (items.isEmpty) const Center(child: CircularProgressIndicator()),
                for (var i = 0; i < items.length; i++)
                  Card(color: picked == i ? accent.withValues(alpha: .12) : Colors.white, elevation: 0, child: ListTile(title: Text(items[i]), leading: Icon(picked == i ? Icons.radio_button_checked : Icons.radio_button_off), onTap: () => setState(() => picked = i))),
              ]
            : [const Text('Sign a contract with yourself.', style: TextStyle(fontWeight: FontWeight.w700)), gap, const Text('Deadline'), chips(deadlines, deadline, (v) => deadline = v), gap, const Text('If I miss it, my stake is'), chips(stakes, stake, (v) => stake = v)];
      case Kind.buddy:
        return [const Text('Third strike. Real accountability needs a real human. 🫵'), gap, Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)), child: Text(buddyText, style: const TextStyle(fontSize: 16)))];
    }
  }

  (String, VoidCallback?) action() {
    String judgeLabel = 'Submit 🚀';
    final ready = busy ? null : () {};
    switch (kind) {
      case Kind.excuse:
        return step == 0 ? ('Present to the court ⚖️', words >= 4 && !busy ? () => judge(4) : null) : ('Unfreeze my tasks 🔓', words >= 5 ? pop : null);
      case Kind.tiny:
        return step == 0 ? ('Start the 2-minute timer ⏱️', words >= 3 ? startTiny : null) : ('I did it. Unfreeze 🎉', left == 0 ? pop : null);
      case Kind.apology:
      case Kind.roast:
      case Kind.headline:
        final min = kind == Kind.apology ? 6 : (kind == Kind.roast ? 5 : 4);
        return done ? ('Unfreeze my tasks 🔓', pop) : (judgeLabel, words >= min && ready != null ? () => judge(min) : null);
      case Kind.plan:
        return step == 0 ? ('That is my first piece 👉', picked != null ? () => setState(() => step = 1) : null) : ('Sign the contract ✍️', busy ? null : sign);
      case Kind.buddy:
        return ('Send to a friend 📲', share);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (label, onTap) = action();
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF1EE),
        body: SafeArea(
          child: ListView(padding: const EdgeInsets.all(24), children: [
            const SizedBox(height: 16),
            const Align(alignment: Alignment.centerLeft, child: Wiggle(amount: .05, child: Text('🥶 Accountability checkpoint', style: TextStyle(color: red, fontWeight: FontWeight.w900)))),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(task.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                if ((task.reason ?? '').isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6), child: Text('Why it failed: ${task.reason}', style: TextStyle(color: ink.withValues(alpha: .7)))),
                Padding(padding: const EdgeInsets.only(top: 6), child: Text('Attempt ${task.attempts}', style: const TextStyle(fontFamily: mono, fontSize: 12))),
              ]),
            ),
            const SizedBox(height: 20),
            ...body(),
            if (msg != null) Padding(padding: const EdgeInsets.only(top: 12), child: SpeechBubble(msg!, good)),
            const SizedBox(height: 24),
            FunButton(label: label, onTap: onTap, busy: busy, color: sun),
          ]),
        ),
      ),
    );
  }
}