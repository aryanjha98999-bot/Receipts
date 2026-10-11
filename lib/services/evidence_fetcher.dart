import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';

/// Either hard `failure` (proof is plainly invalid) or `context` (real content for the AI to judge).
class Evidence {
  final String? context, failure;
  Evidence.ok(this.context) : failure = null;
  Evidence.fail(this.failure) : context = null;
}

String _cut(String s, int n) => s.length > n ? '${s.substring(0, n)}...' : s;

Future<Evidence> gatherEvidence(Task t, String type, String text) async {
  if (type == 'Link') return _link(text);
  if (type == 'Commit') return _commit(t, text);
  return Evidence.ok(text);
}

Future<Evidence> _link(String text) async {
  final m = RegExp(r'https?://\S+').firstMatch(text);
  final url = m == null ? null : Uri.tryParse(m.group(0)!);
  if (url == null) return Evidence.fail("🔗 That isn't a link. Paste a full URL starting with https://");
  try {
    final r = await http.get(url, headers: {'User-Agent': 'Mozilla/5.0 (compatible; ReceiptsBot)'}).timeout(const Duration(seconds: 15));
    final code = r.statusCode;
    if (code == 404 || code == 410) return Evidence.fail('🕳️ That link returns a 404. The page does not exist.');
    if (code == 401 || code == 403) return Evidence.fail('🔒 That link is private or blocked. Make it public and try again.');
    if (code >= 400) return Evidence.fail('💥 That link returned error $code.');
    final html = r.body;
    final title = RegExp(r'<title[^>]*>([\s\S]*?)</title>', caseSensitive: false).firstMatch(html)?.group(1)?.trim() ?? '';
    final desc = RegExp(r'''<meta[^>]+name=["']description["'][^>]+content=["']([\s\S]*?)["']''', caseSensitive: false).firstMatch(html)?.group(1) ?? '';
    final body = _cut(html.replaceAll(RegExp(r'<(script|style)[\s\S]*?</\1>', caseSensitive: false), ' ').replaceAll(RegExp(r'<[^>]+>'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim(), 3000);
    final wall = RegExp(r'sign in|log in|login', caseSensitive: false).hasMatch(title) && body.length < 800;
    return Evidence.ok('URL: $url\nHTTP status: $code\nPage title: $title\nDescription: $desc\nPage text excerpt: $body${wall ? '\nNOTE: this looks like a login wall, so the real content is not visible.' : ''}');
  } catch (_) {
    return Evidence.ok('URL: $url\nThe page could not be fetched from the app. Judge only whether the URL looks plausible and relevant to the task, and say so.');
  }
}

Future<Evidence> _commit(Task t, String text) async {
  final m = RegExp(r'github\.com/([\w.-]+)/([\w.-]+)/commit/([0-9a-fA-F]{7,40})').firstMatch(text) ?? RegExp(r'([\w.-]+)/([\w.-]+)[@\s:]+([0-9a-fA-F]{7,40})').firstMatch(text);
  if (m == null) return Evidence.fail('🕵️ I need the repo to check a commit. Paste the GitHub commit URL, like github.com/you/repo/commit/abc1234.');
  final api = Uri.parse('https://api.github.com/repos/${m.group(1)}/${m.group(2)}/commits/${m.group(3)}');
  try {
    final r = await http.get(api, headers: {'Accept': 'application/vnd.github+json', 'User-Agent': 'receipts-app'}).timeout(const Duration(seconds: 15));
    if (r.statusCode == 404 || r.statusCode == 422) return Evidence.fail('🤷 GitHub cannot find that commit. Wrong hash, or the repo is private.');
    if (r.statusCode == 403 || r.statusCode == 429) return Evidence.fail('🐌 GitHub is rate-limiting checks right now. Try again in a few minutes.');
    if (r.statusCode != 200) return Evidence.fail('💥 GitHub returned error ${r.statusCode}.');
    final j = jsonDecode(r.body);
    final date = DateTime.tryParse(j['commit']['author']['date'] ?? '');
    if (t.createdAt != null && date != null && date.isBefore(t.createdAt!)) {
      return Evidence.fail('♻️ That commit is older than this task. Recycled receipts do not count.');
    }
    final files = (j['files'] as List? ?? []).take(6).map((f) => '${f['filename']} (${f['status']}, +${f['additions']}/-${f['deletions']})\n${_cut(f['patch'] ?? '', 500)}').join('\n---\n');
    return Evidence.ok('Real commit fetched from GitHub.\nRepo: ${m.group(1)}/${m.group(2)}\nAuthor: ${j['commit']['author']['name']}\nDate: $date\nMessage: ${j['commit']['message']}\nTotal changes: +${j['stats']?['additions']}/-${j['stats']?['deletions']}\nFiles:\n$files');
  } catch (_) {
    return Evidence.ok('Commit input: $text\nGitHub could not be reached, so judge only whether this looks like a plausible commit reference for the task.');
  }
}