import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/task.dart';
import '../services/review_service.dart';
import '../config.dart';
import '../theme.dart';
import '../widgets/fun.dart';

class ProofScreen extends StatefulWidget {
  final Task task;
  const ProofScreen({super.key, required this.task});
  @override
  State<ProofScreen> createState() => _ProofScreenState();
}

class _ProofScreenState extends State<ProofScreen> {
  static const icons = {'Write-up': '✍️', 'Link': '🔗', 'Commit': '💻', 'Screenshot': '📸'};
  static const hints = {'Write-up': 'Describe exactly what you did and the result...', 'Link': 'https://...', 'Commit': 'github.com/you/repo/commit/abc1234', 'Screenshot': 'Optional: what the screenshot shows'};
  String type = 'Write-up';
  final c = TextEditingController();
  Uint8List? img;
  bool busy = false;

  Future<void> pick() async {
    final f = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1024, imageQuality: 70);
    if (f != null) {
      final b = await f.readAsBytes();
      setState(() => img = b);
    }
  }

  Future<void> go() async {
    setState(() => busy = true);
    final v = await review(widget.task, type, c.text, img);
    if (mounted) Navigator.pop(context, v);
  }

  @override
  Widget build(BuildContext context) {
    final ready = type == 'Screenshot' ? img != null : c.text.trim().isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: const Text('Submit proof 🧾')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Text(widget.task.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(Config.hasGemini ? '🧑‍⚖️ Our AI judge will review this. Be convincing 😏' : '🤖 AI is not set up yet, so simple offline checks will review this.', style: TextStyle(color: ink.withValues(alpha: .6))),
        const SizedBox(height: 18),
        Wrap(spacing: 8, children: [for (final t in hints.keys) ChoiceChip(label: Text('${icons[t]} $t'), selected: type == t, onSelected: (_) => setState(() => type = t))]),
        const SizedBox(height: 16),
        if (type == 'Screenshot') ...[
          OutlinedButton.icon(onPressed: pick, icon: const Icon(Icons.image_outlined), label: Text(img == null ? 'Choose screenshot' : 'Change screenshot')),
          if (img != null) Padding(padding: const EdgeInsets.only(top: 12), child: ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.memory(img!, height: 180, fit: BoxFit.cover))),
          const SizedBox(height: 12),
        ],
        TextField(controller: c, minLines: type == 'Write-up' ? 5 : 2, maxLines: 8, onChanged: (_) => setState(() {}), decoration: fieldStyle(hints[type]!)),
        const SizedBox(height: 20),
        FunButton(label: 'Verify it 🔍', onTap: ready && !busy ? go : null, busy: busy, color: sun),
        if (busy) const JudgingBubble(),
      ]),
    );
  }
}