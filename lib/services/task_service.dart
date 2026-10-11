import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task.dart';

class TaskService {
  SupabaseClient get _db => Supabase.instance.client;
  String get uid => _db.auth.currentUser!.id;
  String get email => _db.auth.currentUser?.email ?? '';

  Future<List<Task>> load() async {
    final rows = await _db.from('tasks').select().order('created_at', ascending: false);
    return rows.map<Task>((r) => Task.fromJson(r)).toList();
  }

  Future<Task> add(String title) async {
    final r = await _db.from('tasks').insert({'title': title}).select().single();
    return Task.fromJson(r);
  }

  Future<void> update(Task t) async {
    await _db.from('tasks').update({
      'done': t.done,
      'attempts': t.attempts,
      'verdict': t.verdict,
      'reason': t.reason,
      'roast': t.roast,
      'source': t.source,
      'deadline': t.deadline?.toUtc().toIso8601String(),
      'stake': t.stake,
    }).eq('id', t.id);
  }

  Future<void> delete(Task t) async {
    await _db.from('tasks').delete().eq('id', t.id);
  }

  Future<void> clearAll() async {
    await _db.from('tasks').delete().eq('user_id', uid);
    await setFreeze(null);
  }

  Future<String?> getFreeze() async {
    final r = await _db.from('profiles').select('frozen_task').eq('id', uid).maybeSingle();
    return r?['frozen_task']?.toString();
  }

  Future<void> setFreeze(String? taskId) async {
    await _db.from('profiles').upsert({'id': uid, 'frozen_task': taskId});
  }

  Future<void> signOut() => _db.auth.signOut();
}

/// Global instance used by the screens.
final tasksApi = TaskService();