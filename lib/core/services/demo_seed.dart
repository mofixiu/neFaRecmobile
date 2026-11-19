import 'package:drift/drift.dart' show Value;

import '../../features/import/domain/exercise_index.dart';
import '../../features/import/domain/routine_parser.dart';
import '../../features/routines/data/routine_repository.dart';
import '../../features/routines/domain/routine_draft.dart';
import '../../features/workout/data/session_repository.dart';
import '../db/database.dart';
import '../models/training.dart';

/// A few weeks of made-up training so History has something to show in a demo
/// recording. Only runs in a build made with
/// `--dart-define=NEFAREC_DEMO_SEED=true`, and only on an empty install.
class DemoSeed {
  static const enabled = bool.fromEnvironment('NEFAREC_DEMO_SEED');

  static const _routine = '''Monday — Push
Bench Press 4 x 6-8, rest 2 min
Incline DB Press 3 x 10
Lateral Raises 3 x 15
Tricep Pushdown 3 x 12
Wednesday — Pull
Deadlift 3 x 5, rest 3 min
Pull-ups 3 x 8
Barbell Row 3 x 10
Bicep Curl 3 x 12
Friday — Legs
Squat 4 x 6, rest 2 min
Romanian Deadlift 3 x 10
Leg Press 3 x 12
Plank 3 x 45 sec''';

  /// Starting weight in kg for each exercise, matched on the name's start.
  static const _start = {
    'bench': 60.0,
    'incline': 20.0,
    'lateral': 8.0,
    'tricep': 25.0,
    'deadlift': 100.0,
    'pull': 0.0,
    'row': 50.0,
    'curl': 12.0,
    'squat': 80.0,
    'romanian': 60.0,
    'leg press': 120.0,
  };

  static Future<void> run(NefaDatabase db, ExerciseIndex index) async {
    if ((await db.select(db.workoutSessions).get()).isNotEmpty) return;

    final routines = RoutineRepository(db);
    final sessions = SessionRepository(db);
    final parsed = RoutineParser(index).parse(_routine);
    final routineId = await routines.save(RoutineDraft.fromParsed(parsed, _routine));
    final routine = (await routines.load(routineId))!;

    final today = DateTime.now();
    final monday = DateTime(today.year, today.month, today.day - (today.weekday - 1));
    for (var week = 6; week >= 0; week--) {
      for (var i = 0; i < routine.days.length && i < 3; i++) {
        final day = routine.days[i];
        final date = monday.subtract(Duration(days: week * 7 - i * 2));
        if (!date.isBefore(DateTime(today.year, today.month, today.day))) continue;
        final start = DateTime(date.year, date.month, date.day, 18, 5 + week * 3);
        final id = await sessions.start(routine, day, now: start);
        final detail = (await sessions.load(id))!;
        var t = start.add(const Duration(minutes: 4));
        final progress = (7 - week) ~/ 2;
        for (final ex in detail.exercises) {
          final base = _baseFor(ex.exercise.name);
          for (final set in ex.sets) {
            if (set.kind != TargetKind.duration && base != null && base > 0) {
              final step = base >= 60 ? 5.0 : (base >= 20 ? 2.5 : 1.0);
              await sessions.updateSet(set.id, weight: base + step * progress);
            }
            t = t.add(Duration(minutes: 2, seconds: 20 + (set.position * 7) % 40));
            final fresh = await (db.select(db.setLogs)..where((s) => s.id.equals(set.id))).getSingle();
            await sessions.completeSet(fresh, at: t);
          }
        }
        await sessions.finish(id, at: t.add(const Duration(minutes: 3)));
        await (db.update(db.workoutSessions)..where((s) => s.id.equals(id)))
            .write(WorkoutSessionsCompanion(startedAt: Value(start)));
      }
    }
  }

  static double? _baseFor(String name) {
    final n = name.toLowerCase();
    if (n.contains('romanian')) return _start['romanian'];
    if (n.contains('leg press')) return _start['leg press'];
    for (final e in _start.entries) {
      if (n.contains(e.key)) return e.value;
    }
    return null;
  }
}
