import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import '../theme.dart';
import '../widgets/fun.dart';
import '../widgets/task_card.dart';
import 'challenge_screen.dart';
import 'proof_screen.dart';
import 'rejected_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const winLines = ['Receipt verified! 🎉 Look at you go', 'The judge is shook. Verified! 😳', 'Plot twist: you actually did it 🤯', 'Verified! Go tell your mum 🥹', 'Promise kept. Legend behaviour 👑'];
  static const ideas = ['Finish the poster draft', 'Reply to that email', 'Go for a walk', 'Stop doomscrolling'];

  List<Task> tasks = [];
  String? frozenId;
  bool loading = true, inChallenge = false;
  bool get frozen => frozenId != null;
  Task? get frozenTask {
    for (final t in tasks) { if (t.id == frozenId) return t; }
    return null;
  }

  int get doneCount => tasks.where((t) => t.done).length;
  bool get allDone => tasks.isNotEmpty && doneCount == tasks.length;

  String get hello {
    final h = DateTime.now().hour;
    return h < 5 ? 'Still up? 🦉' : h < 12 ? 'Morning, legend ☀️' : h < 17 ? 'Afternoon grind 💪' : h < 21 ? 'Evening hustle 🌆' : 'Night owl mode 🦉';
  }

  String get quip {
    if (tasks.isEmpty) return 'No promises yet. Suspiciously peaceful 😌';
    if (allDone) return 'Everything verified?! Who even are you 🤯';
    if (doneCount == 0) return '0 verified. The receipts are watching 👀';
    return '$doneCount of ${tasks.length} verified. Keep cooking 🔥';
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  void snack(String m) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  Future<void> load() async {
    try {
      final t = await tasksApi.load();
      final f = await tasksApi.getFreeze();
      if (!mounted) return;
      setState(() { tasks = t; frozenId = f; loading = false; });
      final ft = frozenTask;
      if (f != null && ft == null) {
        setState(() => frozenId = null);
        await tasksApi.setFreeze(null);
      } else if (ft != null) {
        openChallenge(ft);
      }
    } catch (_) {
      if (mounted) setState(() => loading = false);
      snack("📡 Couldn't load your tasks. Pull down to retry.");
    }
  }

  Future<void> addTask() async {
    final c = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (dctx) => AlertDialog(
        backgroundColor: paper,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: const BorderSide(color: ink, width: 2.5)),
        title: const Text('What are you claiming to do? 🤥', style: TextStyle(fontWeight: FontWeight.w900)),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextField(controller: c, autofocus: true, textCapitalization: TextCapitalization.sentences, decoration: fieldStyle('e.g. Finish the poster draft'), onSubmitted: (v) => Navigator.pop(dctx, v)),
          const SizedBox(height: 12),
          const Text('Need ideas? 💡', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Wrap(spacing: 6, runSpacing: 6, children: [for (final s in ideas) ActionChip(label: Text(s, style: const TextStyle(fontSize: 12)), onPressed: () => c.text = s)]),
        ]),
        actions: [TextButton(onPressed: () => Navigator.pop(dctx), child: const Text('Nah 🙈')), FilledButton(style: bigButton(sun).copyWith(minimumSize: const WidgetStatePropertyAll(Size(110, 46)), foregroundColor: const WidgetStatePropertyAll(ink)), onPressed: () => Navigator.pop(dctx, c.text), child: const Text('Promise it 🤞'))],
      ),
    );
    if (title == null || title.trim().isEmpty) return;
    try {
      final t = await tasksApi.add(title.trim());
      HapticFeedback.mediumImpact();
      setState(() => tasks.insert(0, t));
      snack('Claim logged 📝 Now go prove it.');
    } catch (_) {
      snack("😵 Couldn't add the task.");
    }
  }

  Future<void> submit(Task t) async {
    final v = await Navigator.push<Verdict>(context, MaterialPageRoute(builder: (_) => ProofScreen(task: t)));
    if (v == null) return;
    setState(() {
      t.attempts++;
      t.verdict = v.ok ? 'verified' : 'rejected';
      t.done = v.ok;
      t.reason = v.reason;
      t.roast = v.roast;
      t.source = v.source;
    });
    if (v.ok && mounted) {
      burstConfetti(context);
      snack(winLines[Random().nextInt(winLines.length)]);
    }
    if (!v.ok) setState(() => frozenId = t.id);
    // Save in the background while the rejection screen plays.
    final saving = () async {
      try {
        await tasksApi.update(t);
        if (!v.ok) await tasksApi.setFreeze(t.id);
      } catch (_) {
        snack("😵 Couldn't save the verdict.");
      }
    }();
    if (!v.ok && mounted) {
      await Navigator.push(context, MaterialPageRoute(fullscreenDialog: true, builder: (_) => RejectedScreen(task: t)));
    }
    await saving;
    if (!v.ok) openChallenge(t);
  }

  Future<void> openChallenge(Task t) async {
    if (inChallenge) return;
    inChallenge = true;
    await Navigator.push(context, MaterialPageRoute(fullscreenDialog: true, builder: (_) => ChallengeScreen(task: t)));
    inChallenge = false;
    if (mounted) setState(() => frozenId = null);
    try { await tasksApi.setFreeze(null); } catch (_) {}
  }

  Future<void> openSettings() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
    if (mounted && tasksApi.email.isNotEmpty) load();
  }

  Future<void> remove(Task t) async {
    setState(() => tasks.remove(t));
    snack('Poof! 💨 Task vanished.');
    try { await tasksApi.delete(t); } catch (_) { snack("😵 Couldn't delete the task."); }
  }

  @override
  Widget build(BuildContext context) {
    final fab = FloatingActionButton.extended(
      onPressed: frozen ? () { final t = frozenTask; if (t != null) openChallenge(t); } : addTask,
      backgroundColor: frozen ? pink : sun,
      foregroundColor: ink,
      elevation: 0,
      highlightElevation: 0,
      shape: const StadiumBorder(side: BorderSide(color: ink, width: 2.5)),
      icon: Icon(frozen ? Icons.lock : Icons.add),
      label: Text(frozen ? 'Frozen: do the challenge 🥶' : 'New task ✨', style: const TextStyle(fontWeight: FontWeight.w900)),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Row(mainAxisSize: MainAxisSize.min, children: [
          Wiggle(amount: .2, child: Text('🧾', style: TextStyle(fontSize: 24))),
          SizedBox(width: 8),
          Text('Receipts', style: TextStyle(fontFamily: mono, fontWeight: FontWeight.w900, letterSpacing: 1)),
        ]),
        actions: [IconButton(tooltip: 'Settings', onPressed: openSettings, icon: const Icon(Icons.settings_outlined))],
      ),
      floatingActionButton: frozen ? Wiggle(amount: .04, ms: 600, child: fab) : fab,
      body: loading
          ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Floaty(dy: 16, ms: 700, child: Text('🧾', style: TextStyle(fontSize: 64))), SizedBox(height: 10), Text('Fetching your promises… 📜', style: TextStyle(fontWeight: FontWeight.w800))]))
          : RefreshIndicator(
              onRefresh: load,
              child: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 110), children: [
                PopIn(
                  child: Sticker(
                    color: ink,
                    shadow: sun,
                    radius: 24,
                    padding: const EdgeInsets.all(18),
                    child: Row(children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(hello, style: const TextStyle(color: sun, fontSize: 14, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          const Text('No proof, no progress.', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          AnimatedSwitcher(duration: const Duration(milliseconds: 300), child: Text(quip, key: ValueKey(quip), style: const TextStyle(color: Colors.white70))),
                        ]),
                      ),
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: tasks.isEmpty ? 0.0 : doneCount / tasks.length),
                        duration: const Duration(milliseconds: 900),
                        curve: Curves.easeOutCubic,
                        builder: (_, v, __) => SizedBox(
                          width: 62,
                          height: 62,
                          child: Stack(alignment: Alignment.center, children: [
                            SizedBox(width: 62, height: 62, child: CircularProgressIndicator(value: v, backgroundColor: Colors.white24, color: Colors.greenAccent, strokeWidth: 7)),
                            Text(allDone ? '🏆' : '🧾', style: const TextStyle(fontSize: 24)),
                          ]),
                        ),
                      ),
                    ]),
                  ),
                ),
                if (frozen)
                  PopIn(
                    child: Container(
                      margin: const EdgeInsets.only(top: 14),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: sky, borderRadius: BorderRadius.circular(16), border: Border.all(color: ink, width: 2.5)),
                      child: const Row(children: [
                        Wiggle(amount: .3, ms: 500, child: Text('🥶', style: TextStyle(fontSize: 24))),
                        SizedBox(width: 10),
                        Expanded(child: Text('Everything is frozen until you finish the checkpoint.', style: TextStyle(fontWeight: FontWeight.w800))),
                      ]),
                    ),
                  ),
                const SizedBox(height: 18),
                if (tasks.isEmpty)
                  const PopIn(
                    delay: 150,
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                        child: Column(children: [
                          Floaty(child: Text('🦗', style: TextStyle(fontSize: 72))),
                          SizedBox(height: 12),
                          Text('Crickets…', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                          SizedBox(height: 6),
                          Text('Add a task and make a promise\nyou (might) keep 🤞', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, height: 1.4)),
                        ]),
                      ),
                    ),
                  ),
                for (var i = 0; i < tasks.length; i++)
                  PopIn(key: ValueKey(tasks[i].id), delay: min(i, 6) * 90, child: TaskCard(tasks[i], frozen: frozen, onProof: () => submit(tasks[i]), onDelete: () => remove(tasks[i]))),
              ]),
            ),
    );
  }
}