import 'package:flutter/material.dart';
import '../models/task.dart';
<<<<<<< HEAD
import '../services/task_service.dart';
=======
import '../services/storage_service.dart';
>>>>>>> 355c55f9fd903c0da6ba3a40fad0d4eb49765624
import '../theme.dart';
import '../widgets/task_card.dart';
import 'challenge_screen.dart';
import 'proof_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
<<<<<<< HEAD
  List<Task> tasks = [];
  bool frozen = false, loading = true;
=======
  late List<Task> tasks = store.loadTasks();
  late bool frozen = store.frozen;
>>>>>>> 355c55f9fd903c0da6ba3a40fad0d4eb49765624

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    load();
  }

  void snack(String m) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  Future<void> load() async {
    try {
      final t = await tasksApi.load();
      final f = await tasksApi.getFrozen();
      if (!mounted) return;
      setState(() { tasks = t; frozen = f; loading = false; });
      if (f) openChallenge();
    } catch (_) {
      if (mounted) setState(() => loading = false);
      snack("Couldn't load your tasks. Pull down to retry.");
    }
=======
    if (frozen) WidgetsBinding.instance.addPostFrameCallback((_) => openChallenge());
  }

  void save() {
    store.saveTasks(tasks);
    store.frozen = frozen;
>>>>>>> 355c55f9fd903c0da6ba3a40fad0d4eb49765624
  }

  Future<void> addTask() async {
    final c = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('What are you claiming to do?'),
        content: TextField(controller: c, autofocus: true, textCapitalization: TextCapitalization.sentences, decoration: fieldStyle('e.g. Finish the poster draft'), onSubmitted: (v) => Navigator.pop(context, v)),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, c.text), child: const Text('Add'))],
      ),
    );
<<<<<<< HEAD
    if (title == null || title.trim().isEmpty) return;
    try {
      final t = await tasksApi.add(title.trim());
      setState(() => tasks.insert(0, t));
    } catch (_) {
      snack("Couldn't add the task.");
=======
    if (title != null && title.trim().isNotEmpty) {
      setState(() => tasks.insert(0, Task(DateTime.now().microsecondsSinceEpoch.toString(), title.trim())));
      save();
>>>>>>> 355c55f9fd903c0da6ba3a40fad0d4eb49765624
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
      frozen = !v.ok;
    });
<<<<<<< HEAD
    try {
      await tasksApi.update(t);
      await tasksApi.setFrozen(frozen);
    } catch (_) {
      snack("Couldn't save the verdict.");
    }
=======
    save();
>>>>>>> 355c55f9fd903c0da6ba3a40fad0d4eb49765624
    if (!v.ok) openChallenge();
  }

  Future<void> openChallenge() async {
    await Navigator.push(context, MaterialPageRoute(fullscreenDialog: true, builder: (_) => const ChallengeScreen()));
    setState(() => frozen = false);
<<<<<<< HEAD
    try { await tasksApi.setFrozen(false); } catch (_) {}
=======
    save();
>>>>>>> 355c55f9fd903c0da6ba3a40fad0d4eb49765624
  }

  Future<void> openSettings() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
<<<<<<< HEAD
    if (mounted && tasksApi.email.isNotEmpty) load();
  }

  Future<void> remove(Task t) async {
    setState(() => tasks.remove(t));
    try { await tasksApi.delete(t); } catch (_) { snack("Couldn't delete the task."); }
=======
    setState(() {
      tasks = store.loadTasks();
      frozen = store.frozen;
    });
>>>>>>> 355c55f9fd903c0da6ba3a40fad0d4eb49765624
  }

  @override
  Widget build(BuildContext context) {
    final done = tasks.where((t) => t.done).length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipts', style: TextStyle(fontFamily: mono, fontWeight: FontWeight.w800, letterSpacing: 1)),
        actions: [IconButton(tooltip: 'Settings', onPressed: openSettings, icon: const Icon(Icons.settings_outlined))],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: frozen ? openChallenge : addTask,
        backgroundColor: frozen ? red : ink,
        foregroundColor: Colors.white,
        icon: Icon(frozen ? Icons.lock : Icons.add),
        label: Text(frozen ? 'Frozen: do the challenge' : 'New task'),
      ),
<<<<<<< HEAD
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: load,
              child: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 100), children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: ink, borderRadius: BorderRadius.circular(22)),
                  child: Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('No proof, no progress.', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(tasks.isEmpty ? 'Add a task to get started.' : '$done of ${tasks.length} verified', style: const TextStyle(color: Colors.white70)),
                    ])),
                    SizedBox(width: 48, height: 48, child: Stack(alignment: Alignment.center, children: [
                      CircularProgressIndicator(value: tasks.isEmpty ? 0 : done / tasks.length, backgroundColor: Colors.white24, color: Colors.greenAccent, strokeWidth: 5),
                      const Icon(Icons.verified, color: Colors.white, size: 22),
                    ])),
                  ]),
                ),
                if (frozen)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: red.withValues(alpha: .1), borderRadius: BorderRadius.circular(14)),
                    child: const Row(children: [Icon(Icons.ac_unit, color: red, size: 18), SizedBox(width: 8), Expanded(child: Text('Everything is frozen until you finish the checkpoint.', style: TextStyle(color: red, fontWeight: FontWeight.w600)))]),
                  ),
                const SizedBox(height: 12),
                if (tasks.isEmpty) const Padding(padding: EdgeInsets.all(48), child: Center(child: Text('🧾\nNothing here yet.', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, height: 1.6)))),
                for (final t in tasks) TaskCard(t, frozen: frozen, onProof: () => submit(t), onDelete: () => remove(t)),
              ]),
            ),
=======
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 100), children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: ink, borderRadius: BorderRadius.circular(22)),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('No proof, no progress.', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(tasks.isEmpty ? 'Add a task to get started.' : '$done of ${tasks.length} verified', style: const TextStyle(color: Colors.white70)),
            ])),
            SizedBox(width: 48, height: 48, child: Stack(alignment: Alignment.center, children: [
              CircularProgressIndicator(value: tasks.isEmpty ? 0 : done / tasks.length, backgroundColor: Colors.white24, color: Colors.greenAccent, strokeWidth: 5),
              const Icon(Icons.verified, color: Colors.white, size: 22),
            ])),
          ]),
        ),
        if (frozen)
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: red.withValues(alpha: .1), borderRadius: BorderRadius.circular(14)),
            child: const Row(children: [Icon(Icons.ac_unit, color: red, size: 18), SizedBox(width: 8), Expanded(child: Text('Everything is frozen until you finish the checkpoint.', style: TextStyle(color: red, fontWeight: FontWeight.w600)))]),
          ),
        const SizedBox(height: 12),
        if (tasks.isEmpty) const Padding(padding: EdgeInsets.all(48), child: Center(child: Text('🧾\nNothing here yet.', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, height: 1.6)))),
        for (final t in tasks) TaskCard(t, frozen: frozen, onProof: () => submit(t), onDelete: () { setState(() => tasks.remove(t)); save(); }),
      ]),
>>>>>>> 355c55f9fd903c0da6ba3a40fad0d4eb49765624
    );
  }
}