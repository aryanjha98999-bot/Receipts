import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class Storage {
  late SharedPreferences _sp;
  Future<void> init() async => _sp = await SharedPreferences.getInstance();

  List<Task> loadTasks() => (jsonDecode(_sp.getString('tasks') ?? '[]') as List).map((e) => Task.fromJson(e)).toList();
  void saveTasks(List<Task> t) => _sp.setString('tasks', jsonEncode(t.map((e) => e.toJson()).toList()));

  bool get frozen => _sp.getBool('frozen') ?? false;
  set frozen(bool v) => _sp.setBool('frozen', v);

  String get apiKey => _sp.getString('key') ?? '';
  set apiKey(String v) => _sp.setString('key', v);

  Future<void> clearTasks() async {
    await _sp.remove('tasks');
    await _sp.remove('frozen');
  }
}

final store = Storage();