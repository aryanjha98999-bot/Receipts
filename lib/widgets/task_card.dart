import 'package:flutter/material.dart';
import '../models/task.dart';
import '../theme.dart';
import 'stamp.dart';

class TaskCard extends StatelessWidget {
  final Task t;
  final bool frozen;
  final VoidCallback onProof, onDelete;
  const TaskCard(this.t, {super.key, required this.frozen, required this.onProof, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final rej = t.verdict == 'rejected';
    final soft = ink.withValues(alpha: .6);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ink.withValues(alpha: .08)),
        boxShadow: [BoxShadow(color: ink.withValues(alpha: .05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(t.title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: t.done ? soft : ink, decoration: t.done ? TextDecoration.lineThrough : null))),
          if (t.done) const Stamp('VERIFIED', green) else if (rej) const Stamp('UNCONVINCING', red),
        ]),
        if (t.attempts > 0) Padding(padding: const EdgeInsets.only(top: 4), child: Text('Attempts: ${t.attempts}', style: TextStyle(fontSize: 12, color: soft, fontFamily: mono))),
        if (rej && (t.roast ?? '').isNotEmpty) Padding(padding: const EdgeInsets.only(top: 10), child: Text('"${t.roast}"', style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 15))),
        if ((t.reason ?? '').isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6), child: Text('${t.reason}  · ${t.source}', style: TextStyle(fontSize: 13, color: soft))),
        const SizedBox(height: 12),
        Row(children: [
          if (!t.done)
            Expanded(child: FilledButton.icon(onPressed: frozen ? null : onProof, icon: const Icon(Icons.receipt_long, size: 18), label: Text(rej ? 'Try again' : 'Submit proof'), style: bigButton().copyWith(minimumSize: const WidgetStatePropertyAll(Size(0, 46)))))
          else
            const Spacer(),
          IconButton(onPressed: frozen ? null : onDelete, icon: const Icon(Icons.delete_outline)),
        ]),
      ]),
    );
  }
}