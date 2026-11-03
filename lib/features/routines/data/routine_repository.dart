import 'package:drift/drift.dart';

import '../../../core/db/database.dart';
import '../../../core/models/training.dart';
import '../../import/domain/exercise_index.dart';
import '../../workout/data/session_repository.dart' show reloadOn;
import '../domain/routine_draft.dart';

class RoutineSummary {
  const RoutineSummary({
    required this.routine,
    required this.dayCount,
    required this.exerciseCount,
    this.lastPerformed,
  });
  final Routine routine;
  final int dayCount;
  final int exerciseCount;
  final DateTime? lastPerformed;
}

class ExercisePlan {
  const ExercisePlan(this.exercise, this.sets);
  final RoutineExercise exercise;
  final List<RoutineSet> sets;

  SetTarget get target => sets.isEmpty
      ? const SetTarget.reps(10)
      : SetTarget.fromParts(
          kind: sets.first.kind,
          repsMin: sets.first.repsMin,
          repsMax: sets.first.repsMax,
          durationSeconds: sets.first.durationSeconds,
        );
}

class DayPlan {
  const DayPlan(this.day, this.exercises);
  final RoutineDay day;
  final List<ExercisePlan> exercises;

  int get setCount => exercises.fold(0, (n, e) => n + e.sets.length);
}

class RoutineDetail {
  const RoutineDetail(this.routine, this.days);
  final Routine routine;
  final List<DayPlan> days;

  RoutineDraft toDraft() => RoutineDraft(
    routineId: routine.id,
    name: routine.name,
    notes: routine.notes,
    sourceText: routine.sourceText,
    days: [
      for (final d in days)
        DayDraft(
          name: d.day.name,
          weekdays: d.day.weekdays,
          exercises: [
            for (final e in d.exercises)
              ExerciseDraft(
                name: e.exercise.name,
                exerciseId: e.exercise.exerciseId,
                sets: e.sets.length,
                target: e.target,
                perSetReps: _perSet(e.sets),
                weight: e.sets.isEmpty ? null : e.sets.first.weight,
                unit: e.sets.isEmpty ? WeightUnit.kg : e.sets.first.unit,
                restSeconds: e.exercise.restSeconds,
                tempo: e.exercise.tempo,
                group: e.exercise.groupLabel,
                notes: e.exercise.notes,
                perSide: e.exercise.perSide,
                timed: e.exercise.timed,
                variant: e.exercise.variant,
              ),
          ],
        ),
    ],
  );

  static List<int>? _perSet(List<RoutineSet> sets) {
    if (sets.length < 2) return null;
    final reps = sets.map((s) => s.repsMin).toList();
    if (reps.any((r) => r == null) || reps.toSet().length == 1) return null;
    if (sets.any((s) => s.repsMin != s.repsMax)) return null;
    return reps.cast<int>();
  }
}

class RoutineRepository {
  RoutineRepository(this.db);
  final NefaDatabase db;

  Stream<List<RoutineSummary>> watchRoutines() {
    return db
        .customSelect(
          '''
SELECT r.*,
  (SELECT COUNT(*) FROM routine_days d WHERE d.routine_id = r.id) AS day_count,
  (SELECT COUNT(*) FROM routine_exercises e
     JOIN routine_days d ON e.day_id = d.id WHERE d.routine_id = r.id) AS exercise_count,
  (SELECT MAX(s.started_at) FROM workout_sessions s
     WHERE s.routine_id = r.id AND s.status = 'completed') AS last_performed
FROM routines r
WHERE r.archived = 0
ORDER BY r.updated_at DESC
''',
          readsFrom: {db.routines, db.routineDays, db.routineExercises, db.workoutSessions},
        )
        .watch()
        .map(
          (rows) => [
            for (final row in rows)
              RoutineSummary(
                routine: db.routines.map(row.data),
                dayCount: row.read<int>('day_count'),
                exerciseCount: row.read<int>('exercise_count'),
                lastPerformed: row.readNullable<DateTime>('last_performed'),
              ),
          ],
        );
  }

  Stream<RoutineDetail?> watchRoutine(int id) {
    return reloadOn(db, [
      db.routines,
      db.routineDays,
      db.routineExercises,
      db.routineSets,
    ], () => load(id));
  }

  Future<RoutineDetail?> load(int id) async {
    final routine = await (db.select(db.routines)..where((r) => r.id.equals(id))).getSingleOrNull();
    if (routine == null) return null;
    final days =
        await (db.select(db.routineDays)
              ..where((d) => d.routineId.equals(id))
              ..orderBy([(d) => OrderingTerm(expression: d.position)]))
            .get();
    final plans = <DayPlan>[];
    for (final day in days) {
      final exercises =
          await (db.select(db.routineExercises)
                ..where((e) => e.dayId.equals(day.id))
                ..orderBy([(e) => OrderingTerm(expression: e.position)]))
              .get();
      final ids = exercises.map((e) => e.id).toList();
      final sets = ids.isEmpty
          ? <RoutineSet>[]
          : await (db.select(db.routineSets)
                  ..where((s) => s.routineExerciseId.isIn(ids))
                  ..orderBy([(s) => OrderingTerm(expression: s.position)]))
                .get();
      plans.add(
        DayPlan(day, [
          for (final e in exercises)
            ExercisePlan(e, sets.where((s) => s.routineExerciseId == e.id).toList()),
        ]),
      );
    }
    return RoutineDetail(routine, plans);
  }

  /// Saves a reviewed import or an edited routine. Past sessions are untouched:
  /// they hold their own copy of the targets.
  Future<int> save(RoutineDraft draft, {DateTime? now}) {
    final at = now ?? DateTime.now();
    return db.transaction(() async {
      final int routineId;
      if (draft.routineId == null) {
        routineId = await db
            .into(db.routines)
            .insert(
              RoutinesCompanion.insert(
                name: draft.name.trim().isEmpty ? 'New routine' : draft.name.trim(),
                notes: Value(draft.notes),
                sourceText: Value(draft.sourceText),
                createdAt: at,
                updatedAt: at,
              ),
            );
      } else {
        routineId = draft.routineId!;
        await (db.update(db.routines)..where((r) => r.id.equals(routineId))).write(
          RoutinesCompanion(
            name: Value(draft.name.trim()),
            notes: Value(draft.notes),
            updatedAt: Value(at),
          ),
        );
        await (db.delete(db.routineDays)..where((d) => d.routineId.equals(routineId))).go();
      }

      for (final (dayIndex, day) in draft.days.indexed) {
        final dayId = await db
            .into(db.routineDays)
            .insert(
              RoutineDaysCompanion.insert(
                routineId: routineId,
                name: day.name,
                position: dayIndex,
                weekdays: Value(day.weekdays),
              ),
            );
        for (final (exIndex, ex) in day.exercises.indexed) {
          final exerciseId = ex.exerciseId ?? await _ensureCustom(ex, at);
          if (ex.typedName != null && ex.status != null && ex.status != MatchStatus.exact) {
            await db
                .into(db.learnedAliases)
                .insertOnConflictUpdate(
                  LearnedAlias(alias: normalizeName(ex.typedName!), exerciseId: exerciseId),
                );
          }
          final reId = await db
              .into(db.routineExercises)
              .insert(
                RoutineExercisesCompanion.insert(
                  dayId: dayId,
                  exerciseId: Value(exerciseId),
                  name: ex.name,
                  position: exIndex,
                  groupLabel: Value(ex.group),
                  restSeconds: Value(ex.restSeconds),
                  restFrom: Value(ex.restFrom),
                  tempo: Value(ex.tempo),
                  notes: Value(ex.notes),
                  perSide: Value(ex.perSide),
                  timed: Value(ex.target.isTimed),
                  variant: Value(ex.variant?.trim().isEmpty ?? true ? null : ex.variant!.trim()),
                ),
              );
          for (var i = 0; i < ex.sets; i++) {
            final perSet = ex.perSetReps;
            final reps = perSet != null && i < perSet.length ? perSet[i] : null;
            await db
                .into(db.routineSets)
                .insert(
                  RoutineSetsCompanion.insert(
                    routineExerciseId: reId,
                    position: i,
                    kind: reps != null ? TargetKind.reps : ex.target.kind,
                    repsMin: Value(reps ?? ex.target.repsMin),
                    repsMax: Value(reps ?? ex.target.repsMax),
                    durationSeconds: Value(ex.target.durationSeconds),
                    weight: Value(ex.weight),
                    unit: Value(ex.unit),
                    setsFrom: Value(ex.setsFrom),
                    targetFrom: Value(ex.targetFrom),
                  ),
                );
          }
        }
      }
      return routineId;
    });
  }

  Future<String> _ensureCustom(ExerciseDraft ex, DateTime at) async {
    final slug = normalizeName(ex.name).replaceAll(' ', '_');
    final id = 'custom_${slug.isEmpty ? 'exercise' : slug}';
    await db
        .into(db.customExercises)
        .insertOnConflictUpdate(
          CustomExercise(id: id, name: ex.name, timed: ex.target.isTimed, createdAt: at),
        );
    return id;
  }

  Future<void> rename(int id, String name) =>
      (db.update(db.routines)..where((r) => r.id.equals(id))).write(
        RoutinesCompanion(name: Value(name), updatedAt: Value(DateTime.now())),
      );

  /// Plans a routine day on weekdays (bit 0 = Monday).
  Future<void> setWeekdays(int dayId, int weekdays) => (db.update(
    db.routineDays,
  )..where((d) => d.id.equals(dayId))).write(RoutineDaysCompanion(weekdays: Value(weekdays)));

  Future<void> delete(int id) => (db.delete(db.routines)..where((r) => r.id.equals(id))).go();

  Future<List<CustomExercise>> customExercises() => db.select(db.customExercises).get();

  Future<Map<String, String>> learnedAliases() async => {
    for (final a in await db.select(db.learnedAliases).get()) a.alias: a.exerciseId,
  };
}
