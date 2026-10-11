class Task {
  String id;
  String title;
  bool done;
  int attempts;
  String? verdict, reason, roast, source, stake;
  DateTime? deadline, createdAt;

  Task({
    required this.id,
    required this.title,
    this.done = false,
    this.attempts = 0,
    this.verdict,
    this.reason,
    this.roast,
    this.source,
    this.stake,
    this.deadline,
    this.createdAt,
  });

  factory Task.fromJson(Map<String, dynamic> j) => Task(
        id: j['id'].toString(),
        title: (j['title'] ?? '').toString(),
        done: j['done'] == true,
        attempts: (j['attempts'] as num?)?.toInt() ?? 0,
        verdict: j['verdict'] as String?,
        reason: j['reason'] as String?,
        roast: j['roast'] as String?,
        source: j['source'] as String?,
        stake: j['stake'] as String?,
        deadline: j['deadline'] == null ? null : DateTime.tryParse(j['deadline'].toString())?.toLocal(),
        createdAt: j['created_at'] == null ? null : DateTime.tryParse(j['created_at'].toString()),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'done': done,
        'attempts': attempts,
        'verdict': verdict,
        'reason': reason,
        'roast': roast,
        'source': source,
        'stake': stake,
        'deadline': deadline?.toUtc().toIso8601String(),
      };
}

class Verdict {
  final bool ok;
  final String reason, roast, source;
  const Verdict(this.ok, this.reason, this.roast, this.source);
}