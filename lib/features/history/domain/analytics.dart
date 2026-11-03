import '../../library/domain/library_data.dart';
import '../../workout/domain/session_models.dart';

DateTime weekStart(DateTime d) {
  final day = DateTime(d.year, d.month, d.day);
  return day.subtract(Duration(days: day.weekday - 1));
}

class WeekPoint {
  const WeekPoint(this.start, this.volumeKg, this.sessions, this.sets);
  final DateTime start;
  final double volumeKg;
  final int sessions;
  final int sets;
}

/// The last [weeks] weeks, oldest first, including empty ones.
List<WeekPoint> weeklyTotals(List<LoggedSet> sets, {required DateTime now, int weeks = 8}) {
  final first = weekStart(now).subtract(Duration(days: 7 * (weeks - 1)));
  return [
    for (var i = 0; i < weeks; i++)
      () {
        final start = first.add(Duration(days: 7 * i));
        final end = start.add(const Duration(days: 7));
        final inWeek = sets.where((s) => !s.date.isBefore(start) && s.date.isBefore(end)).toList();
        return WeekPoint(
          start,
          inWeek.fold(0.0, (v, s) => v + s.set.volumeKg),
          inWeek.map((s) => s.sessionId).toSet().length,
          inWeek.length,
        );
      }(),
  ];
}

/// Consecutive weeks, ending this week or last, with at least one session.
int weekStreak(List<LoggedSet> sets, {required DateTime now}) {
  final weeks = sets.map((s) => weekStart(s.date)).toSet();
  var cursor = weekStart(now);
  if (!weeks.contains(cursor)) cursor = cursor.subtract(const Duration(days: 7));
  var n = 0;
  while (weeks.contains(cursor)) {
    n++;
    cursor = cursor.subtract(const Duration(days: 7));
  }
  return n;
}

/// Completed sets per primary muscle since [since], most first.
List<(String, int)> setsPerMuscle(
  List<LoggedSet> sets,
  Map<String, LibraryRecord> library, {
  required DateTime since,
}) {
  final counts = <String, int>{};
  for (final s in sets.where((s) => !s.date.isBefore(since))) {
    final muscle = library[s.exercise.exerciseId]?.primaryMuscles.firstOrNull ?? 'other';
    counts[muscle] = (counts[muscle] ?? 0) + 1;
  }
  final list = counts.entries.map((e) => (e.key, e.value)).toList()
    ..sort((a, b) => b.$2.compareTo(a.$2));
  return list;
}

class TrendPoint {
  const TrendPoint(this.date, this.value, this.label);
  final DateTime date;
  final double value;
  final String label;
}

/// Best value per session for one exercise: estimated 1RM for loaded sets,
/// longest hold for timed ones, most reps for bodyweight.
class ExerciseTrend {
  const ExerciseTrend({required this.metric, required this.points});
  final String metric;
  final List<TrendPoint> points;
}

ExerciseTrend? trendFor(List<LoggedSet> sets, String exerciseId) {
  final mine = sets.where((s) => s.exercise.exerciseId == exerciseId).toList();
  if (mine.isEmpty) return null;
  final bySession = <int, List<LoggedSet>>{};
  for (final s in mine) {
    bySession.putIfAbsent(s.sessionId, () => []).add(s);
  }
  final timed = mine.first.exercise.timed;
  final loaded = mine.any((s) => (s.set.weight ?? 0) > 0);
  final metric = timed
      ? 'Longest hold (s)'
      : loaded
      ? 'Estimated 1RM (kg)'
      : 'Most reps';
  final points = <TrendPoint>[];
  for (final group in bySession.values) {
    double best = 0;
    for (final s in group) {
      final v = timed
          ? (s.set.durationSeconds ?? 0).toDouble()
          : loaded
          ? (s.set.e1rmKg ?? 0)
          : (s.set.reps ?? 0).toDouble();
      if (v > best) best = v;
    }
    if (best > 0) {
      points.add(TrendPoint(group.first.date, best, best.toStringAsFixed(timed ? 0 : 1)));
    }
  }
  points.sort((a, b) => a.date.compareTo(b.date));
  return ExerciseTrend(metric: metric, points: points);
}

/// Exercises you have logged most often, with their names.
List<(String, String, int)> mostTrained(List<LoggedSet> sets, {int limit = 6}) {
  final sessions = <String, Set<int>>{};
  final names = <String, String>{};
  for (final s in sets) {
    final id = s.exercise.exerciseId;
    if (id == null) continue;
    sessions.putIfAbsent(id, () => {}).add(s.sessionId);
    names[id] = s.exercise.name;
  }
  final list = sessions.entries.map((e) => (e.key, names[e.key]!, e.value.length)).toList()
    ..sort((a, b) => b.$3.compareTo(a.$3));
  return list.take(limit).toList();
}
