import 'package:flutter/material.dart';
import '../services/task_service.dart';
import '../theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: ListView(padding: const EdgeInsets.all(20), children: [
          const Text('Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(tasksApi.email, style: TextStyle(color: ink.withValues(alpha: .65))),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () async { await tasksApi.signOut(); if (context.mounted) Navigator.pop(context); },
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
            style: bigButton(),
          ),
          const SizedBox(height: 32),
          const Text('Data', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              final yes = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Clear all tasks?'),
                  content: const Text('This deletes every task and lifts any freeze.'),
                  actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Clear'))],
                ),
              );
              if (yes == true) {
                await tasksApi.clearAll();
                if (context.mounted) Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.delete_sweep_outlined, color: red),
            label: const Text('Clear all tasks', style: TextStyle(color: red)),
            style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 52)),
          ),
        ]),
      );
}