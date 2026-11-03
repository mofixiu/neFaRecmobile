import 'package:flutter_test/flutter_test.dart';
import 'package:nefarec/core/db/database.dart';
import 'package:nefarec/core/models/training.dart';
import 'package:nefarec/features/history/domain/analytics.dart';
import 'package:nefarec/features/workout/domain/session_models.dart';

LoggedSet _s(
  int session,
  DateTime d, {
  String id = 'Barbell_Squat',
  double w = 100,
  int reps = 5,
}) => LoggedSet(
  sessionId: session,
  date: d,
  exercise: SessionExercise(
    id: session,
    sessionId: session,
    exerciseId: id,
    name: id,
    position: 0,
    perSide: false,
    timed: false,
    skipped: false,
  ),
  set: SetLog(
    id: session * 10,
    sessionExerciseId: session,
    position: 0,
    kind: TargetKind.reps,
    unit: WeightUnit.kg,
    weight: w,
    reps: reps,
    completedAt: d,
  ),
);

void main() {
  final now = DateTime(2026, 11, 4); // a Wednesday

  test('weekly totals include empty weeks and sum volume', () {
    final weeks = weeklyTotals([
      _s(1, DateTime(2026, 11, 2)),
      _s(2, DateTime(2026, 10, 20)),
    ], now: now);
    expect(weeks, hasLength(8));
    expect(weeks.last.volumeKg, 500);
    expect(weeks.last.sessions, 1);
    expect(weeks[weeks.length - 2].volumeKg, 0);
  });

  test('streak counts back from this or last week', () {
    final sets = [_s(1, DateTime(2026, 10, 27)), _s(2, DateTime(2026, 10, 21))];
    expect(weekStreak(sets, now: now), 2);
    expect(weekStreak([_s(1, DateTime(2026, 9, 1))], now: now), 0);
  });

  test('trend gives best estimated 1RM per session', () {
    final t = trendFor([
      _s(1, DateTime(2026, 10, 1), w: 100, reps: 5),
      _s(2, DateTime(2026, 10, 8), w: 105, reps: 5),
    ], 'Barbell_Squat')!;
    expect(t.points, hasLength(2));
    expect(t.points.last.value, greaterThan(t.points.first.value));
  });
}
