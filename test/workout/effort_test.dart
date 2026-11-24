import 'package:flutter_test/flutter_test.dart';
import 'package:nefarec/core/db/database.dart';
import 'package:nefarec/core/models/training.dart';
import 'package:nefarec/features/workout/domain/effort.dart';
import 'package:nefarec/features/workout/domain/progression.dart';
import 'package:nefarec/features/workout/domain/session_models.dart';

SetLog _set(int i, double w, int reps, {Effort? effort}) => SetLog(
  id: i,
  sessionExerciseId: 1,
  position: i,
  kind: TargetKind.range,
  targetRepsMin: 8,
  targetRepsMax: 12,
  unit: WeightUnit.kg,
  weight: w,
  reps: reps,
  completedAt: DateTime(2026, 11, 1),
  effort: effort,
);

NextWeight _after(Effort e, double w, {int reps = 10, String? kit = 'barbell'}) => nextWeightAfter(
  effort: e,
  weight: w,
  reps: reps,
  target: const SetTarget.range(8, 12),
  unit: WeightUnit.kg,
  equipment: kit,
)!;

void main() {
  group('next set', () {
    test('easy adds about 5%, at least one realistic jump', () {
      expect(_after(Effort.easy, 40).weight, 42.5);
      expect(_after(Effort.easy, 100).weight, 105);
      expect(_after(Effort.easy, 10, kit: 'dumbbell').weight, 12);
    });

    test('good and hard stay put', () {
      expect(_after(Effort.good, 40).weight, 40);
      expect(_after(Effort.hard, 40).weight, 40);
    });

    test('hard and short of the range drops one step', () {
      expect(_after(Effort.hard, 40, reps: 6).weight, 37.5);
    });

    test('too heavy drops about 10%', () {
      expect(_after(Effort.tooHeavy, 40).weight, 35);
      expect(_after(Effort.tooHeavy, 100).weight, 90);
      expect(_after(Effort.tooHeavy, 2, kit: 'dumbbell').weight, 0);
    });

    test('easy but short of the range does not add weight', () {
      expect(_after(Effort.easy, 40, reps: 5).weight, 40);
    });

    test('unloaded sets get no weight', () {
      expect(
        nextWeightAfter(
          effort: Effort.easy,
          weight: 0,
          reps: 10,
          target: const SetTarget.reps(10),
          unit: WeightUnit.kg,
        ),
        isNull,
      );
    });

    test('reasons say what to do', () {
      expect(_after(Effort.easy, 40).reason, contains('42.5'));
      expect(_after(Effort.tooHeavy, 40).reason, startsWith('Too heavy'));
    });
  });

  group('next session', () {
    PreviousPerformance prev(List<SetLog> s) =>
        PreviousPerformance(date: DateTime(2026, 11, 1), sets: s);

    test('every set easy adds load before the top of the range', () {
      final s = suggestNext(
        previous: prev([for (var i = 0; i < 3; i++) _set(i, 40, 9, effort: Effort.easy)]),
        target: const SetTarget.range(8, 12),
        plannedSets: 3,
        equipment: 'barbell',
      )!;
      expect(s.weight, 42.5);
      expect(s.reason, contains('easy'));
    });

    test('too heavy last time starts lower', () {
      final s = suggestNext(
        previous: prev([
          _set(0, 40, 8, effort: Effort.good),
          _set(1, 40, 6, effort: Effort.tooHeavy),
        ]),
        target: const SetTarget.range(8, 12),
        plannedSets: 2,
        equipment: 'barbell',
      )!;
      expect(s.weight, 37.5);
    });

    test('no effort recorded keeps the old rules', () {
      final s = suggestNext(
        previous: prev([for (var i = 0; i < 3; i++) _set(i, 40, 9)]),
        target: const SetTarget.range(8, 12),
        plannedSets: 3,
        equipment: 'barbell',
      )!;
      expect(s.weight, 40);
    });
  });

  test('starting tips by equipment', () {
    expect(startingWeightTip('barbell', WeightUnit.kg), contains('20 kg'));
    expect(startingWeightTip('machine', WeightUnit.kg), contains('lightest'));
  });
}
