import 'dart:math' as math;

/// A canonical exercise as far as matching is concerned.
class IndexedExercise {
  const IndexedExercise({
    required this.id,
    required this.name,
    this.equipment,
    this.curated = false,
    this.timed = false,
  });

  final String id;
  final String name;
  final String? equipment;
  final bool curated;

  /// Usually prescribed as a hold rather than reps (planks, wall sits).
  final bool timed;
}

enum MatchStatus {
  /// The text is a known name or alias.
  exact,

  /// Close enough to trust, but not word for word.
  fuzzy,

  /// Several exercises fit. The review screen asks you to confirm.
  uncertain,

  /// Nothing in the library fits. It is kept as a custom exercise.
  unmatched,
}

class MatchCandidate {
  const MatchCandidate(this.exercise, this.score);
  final IndexedExercise exercise;
  final double score;
}

class ExerciseMatch {
  const ExerciseMatch({
    required this.status,
    required this.query,
    this.exercise,
    this.score = 0,
    this.candidates = const [],
  });

  final MatchStatus status;

  /// What you wrote, untouched.
  final String query;
  final IndexedExercise? exercise;
  final double score;

  /// Best alternatives, highest first, never including [exercise].
  final List<MatchCandidate> candidates;

  bool get needsReview => status == MatchStatus.uncertain || status == MatchStatus.unmatched;
}

/// Shorthand that people write in routines.
const _abbreviations = {
  'db': 'dumbbell',
  'dbs': 'dumbbell',
  'bb': 'barbell',
  'kb': 'kettlebell',
  'kbs': 'kettlebell',
  'ez': 'ez bar',
  'sm': 'smith machine',
  'bw': 'bodyweight',
  'ext': 'extension',
  'exts': 'extensions',
  'lat': 'lat',
  'tri': 'tricep',
  'tris': 'triceps',
  'bi': 'bicep',
  'bis': 'biceps',
  'sl': 'single leg',
  'sa': 'single arm',
  'oh': 'overhead',
  'inc': 'incline',
  'dec': 'decline',
  'w': 'with',
  'alt': 'alternating',
};

/// Real aliases that still name more than one movement. They resolve to the
/// most common variation but ask you to confirm it.
const _ambiguousAliases = {
  'dumbbell press',
  'db press',
  'press',
  'row',
  'rows',
  'raises',
  'fly',
  'flyes',
  'flys',
  'extension',
  'extensions',
};

const _equipmentWords = {
  'dumbbell',
  'barbell',
  'cable',
  'machine',
  'kettlebell',
  'band',
  'bands',
  'smith',
  'ez',
  'bodyweight',
  'leverage',
};

/// Lowercase, ASCII-ish, single spaces, hyphens as spaces.
String normalizeName(String input) {
  var s = input.toLowerCase();
  s = s.replaceAll(RegExp(r'[’‘`]'), "'");
  s = s.replaceAll(RegExp(r'[-_/–—]'), ' ');
  s = s.replaceAll(RegExp(r"[^a-z0-9' ]"), ' ');
  s = s.replaceAll(RegExp(r"'s\b"), 's');
  s = s.replaceAll("'", '');
  return s.replaceAll(RegExp(r'\s+'), ' ').trim();
}

String _expand(String normalized) =>
    normalized.split(' ').map((w) => _abbreviations[w] ?? w).join(' ');

String _singular(String normalized) => normalized
    .split(' ')
    .map(
      (w) =>
          w.length > 3 && w.endsWith('s') && !w.endsWith('ss') ? w.substring(0, w.length - 1) : w,
    )
    .join(' ');

/// Looks up exercises by alias, then by fuzzy similarity.
class ExerciseIndex {
  ExerciseIndex({
    required Iterable<IndexedExercise> exercises,
    required Map<String, String> aliases,
  }) {
    for (final e in exercises) {
      _byId[e.id] = e;
    }
    aliases.forEach((alias, id) {
      if (_byId.containsKey(id)) _aliases[normalizeName(alias)] = id;
    });
    for (final e in _byId.values) {
      _aliases.putIfAbsent(normalizeName(e.name), () => e.id);
    }
    _singularAliases = {for (final entry in _aliases.entries) _singular(entry.key): entry.value};
    _keys = _aliases.keys.toList(growable: false);
  }

  final _byId = <String, IndexedExercise>{};
  final _aliases = <String, String>{};
  late final Map<String, String> _singularAliases;
  late final List<String> _keys;

  IndexedExercise? byId(String id) => _byId[id];
  Iterable<IndexedExercise> get all => _byId.values;

  /// Confident above this, uncertain between it and [_floor], unmatched below.
  static const _confident = .93;
  static const _floor = .72;

  ExerciseMatch match(String query) {
    final normalized = normalizeName(query);
    if (normalized.isEmpty) {
      return ExerciseMatch(status: MatchStatus.unmatched, query: query);
    }
    final expanded = _expand(normalized);
    for (final key in [normalized, expanded]) {
      final id = _aliases[key] ?? _singularAliases[_singular(key)];
      if (id != null) {
        final ambiguous = _ambiguousAliases.contains(normalized) || _ambiguousAliases.contains(key);
        return ExerciseMatch(
          status: ambiguous ? MatchStatus.uncertain : MatchStatus.exact,
          query: query,
          exercise: _byId[id],
          score: 1,
          candidates: _ranked(expanded, exclude: id).take(3).toList(),
        );
      }
    }

    final ranked = _ranked(expanded).toList();
    if (ranked.isEmpty || ranked.first.score < _floor) {
      return ExerciseMatch(
        status: MatchStatus.unmatched,
        query: query,
        candidates: ranked.where((c) => c.score >= .5).take(3).toList(),
      );
    }
    final best = ranked.first;
    final runnerUp = ranked.length > 1 ? ranked[1].score : 0.0;
    // A clear winner well above the next option is safe to accept.
    final confident = best.score >= _confident && best.score - runnerUp > .03;
    return ExerciseMatch(
      status: confident ? MatchStatus.fuzzy : MatchStatus.uncertain,
      query: query,
      exercise: best.exercise,
      score: best.score,
      candidates: ranked.skip(1).take(3).toList(),
    );
  }

  /// Free-text search for the library and the "pick another" sheet.
  List<IndexedExercise> search(String query, {int limit = 30}) {
    final q = _expand(normalizeName(query));
    if (q.isEmpty) return const [];
    return _ranked(
      q,
      substringBoost: true,
    ).where((c) => c.score > .55).take(limit).map((c) => c.exercise).toList();
  }

  Iterable<MatchCandidate> _ranked(String query, {String? exclude, bool substringBoost = false}) {
    final best = <String, double>{};
    final queryTokens = query.split(' ').toSet();
    final queryEquipment = queryTokens.intersection(_equipmentWords);
    for (final key in _keys) {
      final id = _aliases[key]!;
      if (id == exclude) continue;
      var score = similarity(query, key);
      if (substringBoost && key.contains(query)) score = math.max(score, .9);
      final keyTokens = key.split(' ').toSet();
      final keyEquipment = keyTokens.intersection(_equipmentWords);
      // "dumbbell press" must not quietly become a barbell lift.
      if (queryEquipment.isNotEmpty &&
          keyEquipment.isNotEmpty &&
          queryEquipment.intersection(keyEquipment).isEmpty) {
        score *= .78;
      }
      if (_byId[id]!.curated) score += .015;
      if (score > (best[id] ?? 0)) best[id] = score;
    }
    final list =
        best.entries.map((e) => MatchCandidate(_byId[e.key]!, math.min(e.value, 1))).toList()
          ..sort((a, b) => b.score.compareTo(a.score));
    return list;
  }
}

/// Blend of whole-string Jaro-Winkler and a soft token overlap, in 0..1.
double similarity(String a, String b) {
  if (a == b) return 1;
  final whole = jaroWinkler(a, b);
  final ta = a.split(' ').map(_singular).toList();
  final tb = b.split(' ').map(_singular).toList();
  double soft(List<String> from, List<String> to) {
    var sum = 0.0;
    for (final t in from) {
      var m = 0.0;
      for (final u in to) {
        final s = t == u ? 1.0 : jaroWinkler(t, u);
        if (s > m) m = s;
      }
      // Near misses on short words ("row" vs "raw") count for little.
      sum += m >= .88 ? m : m * .4;
    }
    return from.isEmpty ? 0 : sum / from.length;
  }

  final forward = soft(ta, tb);
  final backward = soft(tb, ta);
  final tokens = (forward * .55 + backward * .45);
  return whole * .35 + tokens * .65;
}

double jaroWinkler(String s1, String s2) {
  if (s1 == s2) return 1;
  if (s1.isEmpty || s2.isEmpty) return 0;
  final range = math.max(0, math.max(s1.length, s2.length) ~/ 2 - 1);
  final m1 = List<bool>.filled(s1.length, false);
  final m2 = List<bool>.filled(s2.length, false);
  var matches = 0;
  for (var i = 0; i < s1.length; i++) {
    final start = math.max(0, i - range);
    final end = math.min(i + range + 1, s2.length);
    for (var j = start; j < end; j++) {
      if (m2[j] || s1[i] != s2[j]) continue;
      m1[i] = m2[j] = true;
      matches++;
      break;
    }
  }
  if (matches == 0) return 0;
  var t = 0;
  var k = 0;
  for (var i = 0; i < s1.length; i++) {
    if (!m1[i]) continue;
    while (!m2[k]) {
      k++;
    }
    if (s1[i] != s2[k]) t++;
    k++;
  }
  final m = matches.toDouble();
  final jaro = (m / s1.length + m / s2.length + (m - t / 2) / m) / 3;
  var prefix = 0;
  for (var i = 0; i < math.min(4, math.min(s1.length, s2.length)); i++) {
    if (s1[i] != s2[i]) break;
    prefix++;
  }
  return jaro + prefix * .1 * (1 - jaro);
}
