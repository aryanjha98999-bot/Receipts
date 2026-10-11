import 'package:flutter/material.dart';
import '../models/task.dart';
import '../theme.dart';
import 'contract_badge.dart';
import 'fun.dart';
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
    final tone = t.done ? green : rej ? red : accent;
    final bg = t.done ? const Color(0xFFEAF8EF) : rej ? const Color(0xFFFFEEEA) : card;
    final mood = t.done ? '✅' : rej ? '😬' : '📝';
    return Padding(
      padding: const EdgeInsets.only(bottom: 18, right: 4),
      child: Sticker(
        color: bg,
        shadow: tone,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(mood, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Expanded(child: Text(t.title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: t.done ? soft : ink, decoration: t.done ? TextDecoration.lineThrough : null))),
            if (t.done) const Stamp('VERIFIED', green) else if (rej) const Stamp('UNCONVINCING', red),
          ]),
          if (t.attempts > 0) Padding(padding: const EdgeInsets.only(top: 6), child: Text('🎯 Attempt${t.attempts == 1 ? '' : 's'}: ${t.attempts}', style: TextStyle(fontSize: 12, color: soft, fontFamily: mono, fontWeight: FontWeight.w700))),
          if (rej && (t.roast ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: ink.withValues(alpha: .15), width: 1.5)),
                child: Text('🔥 "${t.roast}"', style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          if ((t.reason ?? '').isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text('🧑‍⚖️ ${t.reason}  · ${t.source}', style: TextStyle(fontSize: 13, color: soft, height: 1.3))),
          if (!t.done && t.deadline != null) Padding(padding: const EdgeInsets.only(top: 8), child: ContractBadge(t)),
          const SizedBox(height: 14),
          Row(children: [
            if (!t.done)
              Expanded(child: FunButton(label: rej ? 'Try again 💪' : 'Submit proof 🧾', color: rej ? pink : sun, onTap: frozen ? null : onProof))
            else
              const Expanded(child: Text('Look at you, keeping promises 🥹', style: TextStyle(fontWeight: FontWeight.w800, color: green))),
            const SizedBox(width: 6),
            IconButton(tooltip: 'Delete', onPressed: frozen ? null : onDelete, icon: const Icon(Icons.delete_outline)),
          ]),
        ]),
      ),
    );
  }
}