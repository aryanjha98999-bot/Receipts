class Task {
  String id, title;
  bool done;
  int attempts;
  String? verdict, reason, roast, source;
  Task(this.id, this.title, {this.done = false, this.attempts = 0, this.verdict, this.reason, this.roast, this.source});

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'done': done, 'attempts': attempts, 'verdict': verdict, 'reason': reason, 'roast': roast, 'source': source};
  factory Task.fromJson(Map<String, dynamic> j) => Task(j['id'], j['title'], done: j['done'] ?? false, attempts: j['attempts'] ?? 0, verdict: j['verdict'], reason: j['reason'], roast: j['roast'], source: j['source']);
}

class Verdict {
  final bool ok;
  final String reason, roast, source;
  Verdict(this.ok, this.reason, this.roast, this.source);
}