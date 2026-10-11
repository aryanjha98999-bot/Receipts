import 'package:flutter/material.dart';
<<<<<<< HEAD
import '../services/task_service.dart';
import '../theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
=======
import '../services/storage_service.dart';
import '../theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final c = TextEditingController(text: store.apiKey);

  void snack(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
>>>>>>> 355c55f9fd903c0da6ba3a40fad0d4eb49765624

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: ListView(padding: const EdgeInsets.all(20), children: [
<<<<<<< HEAD
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
=======
          const Text('AI review', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text('Paste an Anthropic API key to let Claude judge your proof. It stays on this device. Leave empty to use simple offline checks.', style: TextStyle(color: ink.withValues(alpha: .65))),
          const SizedBox(height: 12),
          TextField(controller: c, obscureText: true, decoration: fieldStyle('sk-ant-...')),
          const SizedBox(height: 12),
          FilledButton(onPressed: () { store.apiKey = c.text.trim(); snack('Saved'); }, style: bigButton(), child: const Text('Save key')),
>>>>>>> 355c55f9fd903c0da6ba3a40fad0d4eb49765624
          const SizedBox(height: 32),
          const Text('Data', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          OutlinedButton.icon(
<<<<<<< HEAD
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
=======
            onPressed: () async { await store.clearTasks(); snack('All tasks cleared'); },
>>>>>>> 355c55f9fd903c0da6ba3a40fad0d4eb49765624
            icon: const Icon(Icons.delete_sweep_outlined, color: red),
            label: const Text('Clear all tasks', style: TextStyle(color: red)),
            style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 52)),
          ),
<<<<<<< HEAD
=======
          const SizedBox(height: 8),
          Text('Tasks live only on this device. Clearing data also removes the freeze, so consider this a speed bump, not a lock.', style: TextStyle(fontSize: 12, color: ink.withValues(alpha: .55))),
>>>>>>> 355c55f9fd903c0da6ba3a40fad0d4eb49765624
        ]),
      );
}