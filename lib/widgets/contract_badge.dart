import 'dart:async';
import 'package:flutter/material.dart';
import '../models/task.dart';
import '../theme.dart';

class ContractBadge extends StatefulWidget {
  final Task t;
  const ContractBadge(this.t, {super.key});
  @override
  State<ContractBadge> createState() => _ContractBadgeState();
}

class _ContractBadgeState extends State<ContractBadge> {
  Timer? timer;
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 30), (_) => setState(() {}));
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final left = widget.t.deadline!.difference(DateTime.now());
    final over = left.isNegative;
    final stake = widget.t.stake ?? 'something painful';
    final txt = over ? '🚨 STAKE OWED: $stake' : '⏳ ${left.inHours}h ${left.inMinutes % 60}m left · stake: $stake';
    final col = over ? red : accent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: col.withValues(alpha: .1), borderRadius: BorderRadius.circular(10)),
      child: Text(txt, style: TextStyle(color: col, fontWeight: FontWeight.w700, fontSize: 13)),
    );
  }
}