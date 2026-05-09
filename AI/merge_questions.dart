import 'dart:convert';
import 'dart:io';

void main() async {
  final base = 'AI';

  // ── load helpers ──────────────────────────────────────────────────────────
  List<dynamic> loadJson(String path) {
    final f = File(path);
    if (!f.existsSync()) {
      print('ERROR: $path not found');
      exit(1);
    }
    return jsonDecode(f.readAsStringSync()) as List<dynamic>;
  }

  // ── fix geography.json (Python code + JSON output mixed) ──────────────────
  List<dynamic> fixGeography() {
    final raw = File('$base/geography.json').readAsStringSync();
    // Find the LAST occurrence of a JSON array starting with {"id":
    final pattern = RegExp(r'\[\s*\{[^}]*"id"\s*:');
    final matches = pattern.allMatches(raw).toList();
    if (matches.isEmpty) {
      print('ERROR: No valid JSON found in geography.json');
      exit(1);
    }
    final start = matches.last.start;
    final jsonStr = raw.substring(start);
    // Find matching closing bracket
    int depth = 0, end = 0;
    for (int i = 0; i < jsonStr.length; i++) {
      if (jsonStr[i] == '[') depth++;
      else if (jsonStr[i] == ']') {
        depth--;
        if (depth == 0) { end = i + 1; break; }
      }
    }
    final questions = jsonDecode(jsonStr.substring(0, end)) as List<dynamic>;
    print('  Geography       : ${questions.length} questions (extracted from mixed file)');
    return questions;
  }

  // ── fix current_affairs.json (has difficulty field, some 3-option Qs) ────
  List<dynamic> fixCurrentAffairs() {
    final data = loadJson('$base/current_affairs.json');
    final fixed = <dynamic>[];
    int skipped = 0;
    for (final q in data) {
      final m = q as Map<String, dynamic>;
      m.remove('difficulty');
      final opts = m['options'] as List?;
      if (opts == null || opts.length != 4) { skipped++; continue; }
      if (m['question'] == null) { skipped++; continue; }
      fixed.add(m);
    }
    print('  Current Affairs : ${fixed.length} questions ($skipped skipped)');
    return fixed;
  }

  // ── validate ──────────────────────────────────────────────────────────────
  List<dynamic> validate(List<dynamic> qs, String label) {
    final out = <dynamic>[];
    int bad = 0;
    for (final q in qs) {
      final m = q as Map<String, dynamic>;
      final opts = m['options'] as List?;
      final ci = m['correctIndex'];
      if (opts == null || opts.length != 4) { bad++; continue; }
      if (ci == null || ci < 0 || ci > 3)  { bad++; continue; }
      if (m['question'] == null || m['category'] == null) { bad++; continue; }
      out.add(m);
    }
    if (bad > 0) print('  ⚠  $label: $bad questions removed (bad format)');
    return out;
  }

  // ── load all ──────────────────────────────────────────────────────────────
  print('Loading category files …');

  List<dynamic> simple(String file, String label) {
    final d = loadJson('$base/$file');
    print('  ${label.padRight(16)}: ${d.length} questions');
    return d;
  }

  var science        = validate(simple('science_data.json',     'Science'),         'Science');
  var history        = validate(simple('history_quiz_200.json', 'History'),         'History');
  var geography      = validate(fixGeography(),                                     'Geography');
  var currentAffairs = validate(fixCurrentAffairs(),                                'Current Affairs');
  var sports         = validate(simple('sports_data.json',      'Sports'),          'Sports');

  // ── merge + reassign IDs ─────────────────────────────────────────────────
  final all = <Map<String, dynamic>>[];
  int newId = 1;
  for (final bucket in [science, history, geography, currentAffairs, sports]) {
    for (final q in bucket) {
      final m = q as Map<String, dynamic>;
      m['id'] = newId++;
      all.add(m);
    }
  }

  print('\nMerge summary:');
  for (final cat in ['Science', 'History', 'Geography', 'Current Affairs', 'Sports']) {
    final n = all.where((q) => q['category'] == cat).length;
    print('  ${cat.padRight(18)}: $n');
  }
  print('  ${'TOTAL'.padRight(18)}: ${all.length}');

  // ── save ──────────────────────────────────────────────────────────────────
  const outPath = 'assets/data/questions.json';
  final encoder = JsonEncoder.withIndent('  ');
  File(outPath).writeAsStringSync(encoder.convert(all));
  print('\n✅  Saved → $outPath');
}
