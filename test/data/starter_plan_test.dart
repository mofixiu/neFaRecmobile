import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nefarec/features/library/domain/library_data.dart';
import 'package:nefarec/features/plans/starter_plan.dart';

void main() {
  final data = LibraryData.parse(File('assets/exercises/library.json').readAsStringSync());
  final library = {for (final r in data.records) r.id: r};

  test('every exercise a plan can use is in the library', () {
    for (final id in starterExerciseIds) {
      expect(library, contains(id), reason: id);
    }
  });

  test('3 days with machines and dumbbells: full body, five moves, no repeats in a day', () {
    final plan = buildStarterPlan(
      days: 3,
      kits: {Kit.machines, Kit.dumbbells},
      brandNew: true,
      library: library,
    );
    expect(plan.days.map((d) => d.name), ['Full body A', 'Full body B', 'Full body C']);
    for (final d in plan.days) {
      expect(d.exercises, hasLength(5));
      final ids = d.exercises.map((e) => e.exerciseId).toList();
      expect(ids.toSet(), hasLength(ids.length));
      expect(d.exercises.every((e) => e.sets == 2), isTrue);
    }
    // Machines first, and day C varies day A's squat.
    expect(plan.days[0].exercises.first.exerciseId, 'Leg_Press');
    expect(plan.days[2].exercises.first.exerciseId, 'Hack_Squat');
    // Mon, Wed, Fri.
    expect(plan.days.map((d) => d.weekdays), [1, 4, 16]);
  });

  test('bodyweight only never asks for equipment', () {
    final plan = buildStarterPlan(
      days: 2,
      kits: {Kit.bodyweight},
      brandNew: false,
      library: library,
    );
    for (final e in plan.days.expand((d) => d.exercises)) {
      expect(library[e.exerciseId]!.equipment, anyOf(isNull, 'body only', 'other'), reason: e.name);
      expect(e.sets, 3);
    }
  });

  test('a barbell gym still covers every movement', () {
    final plan = buildStarterPlan(days: 4, kits: {Kit.barbell}, brandNew: false, library: library);
    expect(plan.days.map((d) => d.name), ['Upper A', 'Lower A', 'Upper B', 'Lower B']);
    expect(plan.days[1].exercises.first.exerciseId, 'Barbell_Squat');
    expect(plan.days.every((d) => d.exercises.length >= 4), isTrue);
  });

  test('timed holds and one-sided moves are set up right', () {
    final plan = buildStarterPlan(days: 2, kits: {Kit.dumbbells}, brandNew: true, library: library);
    final all = plan.days.expand((d) => d.exercises).toList();
    final plank = all.firstWhere((e) => e.exerciseId == 'Plank');
    expect(plank.timed, isTrue);
    expect(plank.target.durationSeconds, 20);
    expect(all.firstWhere((e) => e.exerciseId == 'One-Arm_Dumbbell_Row').perSide, isTrue);
  });
}
