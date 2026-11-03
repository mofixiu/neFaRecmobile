import 'package:flutter_test/flutter_test.dart';
import 'package:nefarec/core/db/database.dart';
import 'package:nefarec/core/models/training.dart';
import 'package:nefarec/features/workout/domain/progression.dart';
import 'package:nefarec/features/workout/domain/session_models.dart';

SetLog _set(int i, {double? w, int? reps, int? secs, bool done = true}) => SetLog(
  id: i,
  sessionExerciseId: 1,
  position: i,
  kind: secs != null ? TargetKind.duration : TargetKind.reps,
  unit: WeightUnit.kg,
  weight: w,
  reps: reps,
  durationSeconds: secs,
  completedAt: done ? DateTime(2026, 10, 1) : null,
);

PreviousPerformance _prev(List<SetLog> sets) =>
    PreviousPerformance(date: DateTime(2026, 10, 1), sets: sets);

void main() {
  test('top of the range on every set adds load and resets reps', () {
    final s = suggestNext(
      previous: _prev([
        _set(0, w: 20, reps: 12),
        _set(1, w: 20, reps: 12),
        _set(2, w: 20, reps: 12),
      ]),
      target: const SetTarget.range(8, 12),
      plannedSets: 3,
      equipment: 'barbell',
    )!;
    expect(s.weight, 22.5);
    expect(s.reps, 8);
  });

  test('dumbbells move in 2 kg steps', () {
    final s = suggestNext(
      previous: _prev([_set(0, w: 12, reps: 10), _set(1, w: 12, reps: 10)]),
      target: const SetTarget.reps(10),
      plannedSets: 2,
      equipment: 'dumbbell',
    )!;
    expect(s.weight, 14);
  });

  test('missed reps keep the load and ask for one more', () {
    final s = suggestNext(
      previous: _prev([_set(0, w: 20, reps: 10), _set(1, w: 20, reps: 8), _set(2, w: 20, reps: 7)]),
      target: const SetTarget.range(8, 12),
      plannedSets: 3,
    )!;
    expect(s.weight, 20);
    expect(s.reps, 8);
    expect(s.addsLoad, isTrue);
  });

  test('holds add five seconds once every set reached the target', () {
    final s = suggestNext(
      previous: _prev([_set(0, secs: 46), _set(1, secs: 45)]),
      target: const SetTarget.duration(45),
      plannedSets: 2,
    )!;
    expect(s.seconds, 50);
  });

  test('bodyweight progresses by reps', () {
    final s = suggestNext(
      previous: _prev([_set(0, reps: 15), _set(1, reps: 15)]),
      target: const SetTarget.reps(15),
      plannedSets: 2,
    )!;
    expect(s.weight, isNull);
    expect(s.reps, 16);
  });

  test('too little data means no suggestion', () {
    expect(
      suggestNext(
        previous: _prev([_set(0, w: 20, reps: 10)]),
        target: const SetTarget.reps(10),
        plannedSets: 4,
      ),
      isNull,
    );
    expect(suggestNext(previous: null, target: const SetTarget.reps(10), plannedSets: 3), isNull);
  });
}
