import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/db/database.dart';
import '../../../core/models/training.dart';
import '../../routines/data/routine_repository.dart';
import '../domain/session_models.dart';
import '../domain/timer_machine.dart';

/// Emits [read] now and again after every write to [tables].
Stream<T> reloadOn<T>(GeneratedDatabase db, List<TableInfo> tables, Future<T> Function() read) {
  StreamSubscription<void>? updates;
  late final StreamController<T> controller;
  controller = StreamController<T>(
    onListen: () {
      read().then(controller.add, onError: controller.addError);
      updates = db
          .tableUpdates(TableUpdateQuery.onAllTables(tables))
          .asyncMap((_) => read())
          .listen(controller.add, onError: controller.addError);
    },
    onCancel: () => updates?.cancel(),
  );
  return controller.stream;
}

class StoredTimer {
  const StoredTimer({required this.sessionId, required this.timer, required this.label});
  final int sessionId;
  final WorkoutTimer timer;
  final String label;
}

class SessionRepository {
  SessionRepository(this.db);
  final NefaDatabase db;

  Stream<WorkoutSession?> watchActive() =>
      (db.select(db.workoutSessions)
            ..where((s) => s.status.equals('active'))
            ..orderBy([(s) => OrderingTerm.desc(s.startedAt)])
            ..limit(1))
          .watchSingleOrNull();

  /// Copies the day's targets into a new session. If one is already running it
  /// is returned instead, so a workout is never lost by tapping start twice.
  Future<int> start(RoutineDetail routine, DayPlan day, {DateTime? now}) {
    return db.transaction(() async {
      final active = await (db.select(
        db.workoutSessions,
      )..where((s) => s.status.equals('active'))).get();
      if (active.isNotEmpty) return active.first.id;

      final sessionId = await db
          .into(db.workoutSessions)
          .insert(
            WorkoutSessionsCompanion.insert(
              routineId: Value(routine.routine.id),
              dayId: Value(day.day.id),
              title: day.day.name,
              routineName: Value(routine.routine.name),
              startedAt: now ?? DateTime.now(),
            ),
          );
      for (final (i, plan) in day.exercises.indexed) {
        final e = plan.exercise;
        final seId = await db
            .into(db.sessionExercises)
            .insert(
              SessionExercisesCompanion.insert(
                sessionId: sessionId,
                exerciseId: Value(e.exerciseId),
                name: e.name,
                position: i,
                groupLabel: Value(e.groupLabel),
                restSeconds: Value(e.restSeconds),
                tempo: Value(e.tempo),
                notes: Value(e.notes),
                perSide: Value(e.perSide),
                timed: Value(e.timed),
                variant: Value(e.variant),
              ),
            );
        for (final s in plan.sets) {
          await db
              .into(db.setLogs)
              .insert(
                SetLogsCompanion.insert(
                  sessionExerciseId: seId,
                  position: s.position,
                  kind: s.kind,
                  targetRepsMin: Value(s.repsMin),
                  targetRepsMax: Value(s.repsMax),
                  targetDurationSeconds: Value(s.durationSeconds),
                  targetWeight: Value(s.weight),
                  unit: Value(s.unit),
                  weight: Value(s.weight),
                ),
              );
        }
      }
      return sessionId;
    });
  }

  /// Re-reads the whole session on every write to its tables. (A constant
  /// trigger query would be de-duplicated by drift and never fire again.)
  Stream<SessionDetail?> watchSession(int id) =>
      reloadOn(db, [db.workoutSessions, db.sessionExercises, db.setLogs], () => load(id));

  Future<SessionDetail?> load(int id) async {
    final session = await (db.select(
      db.workoutSessions,
    )..where((s) => s.id.equals(id))).getSingleOrNull();
    if (session == null) return null;
    final exercises =
        await (db.select(db.sessionExercises)
              ..where((e) => e.sessionId.equals(id))
              ..orderBy([(e) => OrderingTerm(expression: e.position)]))
            .get();
    final ids = exercises.map((e) => e.id).toList();
    final sets = ids.isEmpty
        ? <SetLog>[]
        : await (db.select(db.setLogs)
                ..where((s) => s.sessionExerciseId.isIn(ids))
                ..orderBy([(s) => OrderingTerm(expression: s.position)]))
              .get();
    return SessionDetail(session, [
      for (final e in exercises)
        SessionExerciseDetail(e, sets.where((s) => s.sessionExerciseId == e.id).toList()),
    ]);
  }

  Future<void> updateSet(
    int setId, {
    int? reps,
    bool clearReps = false,
    double? weight,
    bool clearWeight = false,
    int? durationSeconds,
    WeightUnit? unit,
  }) {
    return (db.update(db.setLogs)..where((s) => s.id.equals(setId))).write(
      SetLogsCompanion(
        reps: clearReps ? const Value(null) : Value.absentIfNull(reps),
        weight: clearWeight ? const Value(null) : Value.absentIfNull(weight),
        durationSeconds: Value.absentIfNull(durationSeconds),
        unit: Value.absentIfNull(unit),
      ),
    );
  }

  /// Marks a set done. Missing reps fall back to the target so one tap logs a
  /// set that went to plan.
  Future<void> completeSet(SetLog set, {DateTime? at}) {
    final reps =
        set.reps ??
        (set.kind == TargetKind.duration ? null : set.targetRepsMax ?? set.targetRepsMin);
    return (db.update(db.setLogs)..where((s) => s.id.equals(set.id))).write(
      SetLogsCompanion(
        completedAt: Value(at ?? DateTime.now()),
        reps: Value(reps),
        durationSeconds: Value(
          set.durationSeconds ??
              (set.kind == TargetKind.duration ? set.targetDurationSeconds : null),
        ),
      ),
    );
  }

  Future<void> uncompleteSet(int setId) => (db.update(
    db.setLogs,
  )..where((s) => s.id.equals(setId))).write(const SetLogsCompanion(completedAt: Value(null)));

  Future<void> addSet(SessionExerciseDetail detail) {
    final last = detail.sets.isEmpty ? null : detail.sets.last;
    return db
        .into(db.setLogs)
        .insert(
          SetLogsCompanion.insert(
            sessionExerciseId: detail.exercise.id,
            position: (last?.position ?? -1) + 1,
            kind: last?.kind ?? TargetKind.reps,
            targetRepsMin: Value(last?.targetRepsMin ?? 10),
            targetRepsMax: Value(last?.targetRepsMax ?? 10),
            targetDurationSeconds: Value(last?.targetDurationSeconds),
            targetWeight: Value(last?.targetWeight),
            unit: Value(last?.unit ?? WeightUnit.kg),
            weight: Value(last?.weight ?? last?.targetWeight),
          ),
        );
  }

  /// Completed sets are never removed by editing.
  Future<bool> removeSet(SetLog set) async {
    if (set.isDone) return false;
    await (db.delete(db.setLogs)..where((s) => s.id.equals(set.id))).go();
    return true;
  }

  /// Fills today's load (or hold target) on sets not yet done.
  Future<void> applySuggestion(SessionExerciseDetail ex, {double? weight, int? seconds}) {
    return db.transaction(() async {
      for (final set in ex.sets.where((s) => s.completedAt == null)) {
        await (db.update(db.setLogs)..where((s) => s.id.equals(set.id))).write(
          SetLogsCompanion(
            weight: weight == null ? const Value.absent() : Value(weight),
            targetDurationSeconds: seconds == null ? const Value.absent() : Value(seconds),
          ),
        );
      }
    });
  }

  Future<void> setVariant(int sessionExerciseId, String? variant) =>
      (db.update(db.sessionExercises)..where((e) => e.id.equals(sessionExerciseId))).write(
        SessionExercisesCompanion(
          variant: Value(variant == null || variant.trim().isEmpty ? null : variant.trim()),
        ),
      );

  /// Swaps the movement in a running session. Targets stay; loads on sets not
  /// yet done are cleared, because different equipment loads differently.
  Future<void> swapExercise(
    SessionExerciseDetail ex, {
    required String exerciseId,
    required String name,
    required bool timed,
  }) {
    return db.transaction(() async {
      await (db.update(db.sessionExercises)..where((e) => e.id.equals(ex.exercise.id))).write(
        SessionExercisesCompanion(
          exerciseId: Value(exerciseId),
          name: Value(name),
          timed: Value(timed),
          variant: const Value(null),
          notes: Value(
            [
              'Swapped from ${ex.exercise.name}',
              if (ex.exercise.notes?.isNotEmpty ?? false) ex.exercise.notes!,
            ].join(' · '),
          ),
        ),
      );
      for (final set in ex.sets.where((s) => s.completedAt == null)) {
        await (db.update(db.setLogs)..where((s) => s.id.equals(set.id))).write(
          SetLogsCompanion(
            weight: const Value(null),
            targetWeight: const Value(null),
            kind: timed && set.kind != TargetKind.duration
                ? const Value(TargetKind.duration)
                : const Value.absent(),
            targetDurationSeconds: timed && set.targetDurationSeconds == null
                ? const Value(30)
                : const Value.absent(),
          ),
        );
      }
    });
  }

  /// Every completed set with its session date and exercise, oldest first.
  /// Feeds the Progress charts.
  Future<List<LoggedSet>> allLoggedSets() async {
    final rows =
        await (db.select(db.setLogs).join([
                innerJoin(
                  db.sessionExercises,
                  db.sessionExercises.id.equalsExp(db.setLogs.sessionExerciseId),
                ),
                innerJoin(
                  db.workoutSessions,
                  db.workoutSessions.id.equalsExp(db.sessionExercises.sessionId),
                ),
              ])
              ..where(
                db.workoutSessions.status.equals('completed') & db.setLogs.completedAt.isNotNull(),
              )
              ..orderBy([OrderingTerm.asc(db.workoutSessions.startedAt)]))
            .get();
    return [
      for (final r in rows)
        LoggedSet(
          sessionId: r.readTable(db.workoutSessions).id,
          date: r.readTable(db.workoutSessions).startedAt,
          exercise: r.readTable(db.sessionExercises),
          set: r.readTable(db.setLogs),
        ),
    ];
  }

  Future<void> setSkipped(int sessionExerciseId, bool skipped) =>
      (db.update(db.sessionExercises)..where((e) => e.id.equals(sessionExerciseId))).write(
        SessionExercisesCompanion(skipped: Value(skipped)),
      );

  /// Moves an exercise to a new position, shifting the others.
  Future<void> moveExercise(SessionDetail detail, int from, int to) {
    final order = detail.exercises.map((e) => e.exercise.id).toList();
    final id = order.removeAt(from);
    order.insert(to.clamp(0, order.length), id);
    return db.transaction(() async {
      for (final (i, eid) in order.indexed) {
        await (db.update(
          db.sessionExercises,
        )..where((e) => e.id.equals(eid))).write(SessionExercisesCompanion(position: Value(i)));
      }
    });
  }

  Future<void> finish(int sessionId, {DateTime? at}) async {
    await (db.update(db.workoutSessions)..where((s) => s.id.equals(sessionId))).write(
      WorkoutSessionsCompanion(
        status: const Value('completed'),
        endedAt: Value(at ?? DateTime.now()),
      ),
    );
    await clearTimer();
  }

  Future<void> discard(int sessionId) async {
    await (db.delete(db.workoutSessions)..where((s) => s.id.equals(sessionId))).go();
    await clearTimer();
  }

  /// The most recent completed session's sets for [exerciseId] on the same
  /// [variant] (machine or setup): loads on different equipment never compare.
  Future<PreviousPerformance?> previous(
    String exerciseId, {
    int? excludeSession,
    String? variant,
  }) async {
    final query =
        db.select(db.setLogs).join([
            innerJoin(
              db.sessionExercises,
              db.sessionExercises.id.equalsExp(db.setLogs.sessionExerciseId),
            ),
            innerJoin(
              db.workoutSessions,
              db.workoutSessions.id.equalsExp(db.sessionExercises.sessionId),
            ),
          ])
          ..where(
            db.sessionExercises.exerciseId.equals(exerciseId) &
                (variant == null
                    ? db.sessionExercises.variant.isNull()
                    : db.sessionExercises.variant.equals(variant)) &
                db.workoutSessions.status.equals('completed') &
                db.setLogs.completedAt.isNotNull() &
                (excludeSession == null
                    ? const Constant(true)
                    : db.workoutSessions.id.equals(excludeSession).not()),
          )
          ..orderBy([
            OrderingTerm.desc(db.workoutSessions.startedAt),
            OrderingTerm.asc(db.setLogs.position),
          ]);
    final rows = await query.get();
    if (rows.isEmpty) return null;
    final latest = rows.first.readTable(db.workoutSessions);
    final sets = rows
        .where((r) => r.readTable(db.workoutSessions).id == latest.id)
        .map((r) => r.readTable(db.setLogs))
        .toList();
    return PreviousPerformance(date: latest.startedAt, sets: sets);
  }

  /// All completed sets for an exercise, oldest first, with their session date.
  Future<List<(DateTime, SetLog)>> history(String exerciseId) async {
    final rows =
        await (db.select(db.setLogs).join([
                innerJoin(
                  db.sessionExercises,
                  db.sessionExercises.id.equalsExp(db.setLogs.sessionExerciseId),
                ),
                innerJoin(
                  db.workoutSessions,
                  db.workoutSessions.id.equalsExp(db.sessionExercises.sessionId),
                ),
              ])
              ..where(
                db.sessionExercises.exerciseId.equals(exerciseId) &
                    db.workoutSessions.status.equals('completed') &
                    db.setLogs.completedAt.isNotNull(),
              )
              ..orderBy([OrderingTerm.asc(db.workoutSessions.startedAt)]))
            .get();
    return [
      for (final r in rows) (r.readTable(db.workoutSessions).startedAt, r.readTable(db.setLogs)),
    ];
  }

  /// Records this session set compared with every earlier completed session.
  Future<List<PersonalRecord>> recordsFor(SessionDetail detail) async {
    final records = <PersonalRecord>[];
    for (final ex in detail.exercises) {
      final id = ex.exercise.exerciseId;
      final done = ex.sets.where((s) => s.isDone).toList();
      if (id == null || done.isEmpty) continue;
      final past = (await history(
        id,
      )).where((h) => h.$1.isBefore(detail.session.startedAt)).map((h) => h.$2).toList();
      if (past.isEmpty) continue; // A first time is a baseline, not a record.

      if (ex.exercise.timed) {
        final best = _max(past.map((s) => (s.durationSeconds ?? 0).toDouble()));
        final now = _max(done.map((s) => (s.durationSeconds ?? 0).toDouble()));
        if (now > best && now > 0) {
          records.add(
            PersonalRecord(
              exerciseName: ex.exercise.name,
              kind: RecordKind.longestHold,
              value: now,
              label: 'Longest hold · ${formatClock(Duration(seconds: now.round()))}',
            ),
          );
        }
        continue;
      }
      final bestWeight = _max(past.map((s) => s.weight == null ? 0 : toKg(s.weight!, s.unit)));
      final heaviest = done
          .where((s) => s.weight != null)
          .fold<SetLog?>(
            null,
            (m, s) => m == null || toKg(s.weight!, s.unit) > toKg(m.weight!, m.unit) ? s : m,
          );
      if (heaviest != null &&
          toKg(heaviest.weight!, heaviest.unit) > bestWeight &&
          bestWeight > 0) {
        records.add(
          PersonalRecord(
            exerciseName: ex.exercise.name,
            kind: RecordKind.heaviest,
            value: heaviest.weight!,
            label:
                'Heaviest · ${formatWeight(heaviest.weight, heaviest.unit)} × ${heaviest.reps ?? 0}',
          ),
        );
        continue;
      }
      final bestE1rm = _max(past.map((s) => s.e1rmKg ?? 0));
      final topE1rm = _max(done.map((s) => s.e1rmKg ?? 0));
      if (topE1rm > bestE1rm && bestE1rm > 0) {
        final unit = done.first.unit;
        records.add(
          PersonalRecord(
            exerciseName: ex.exercise.name,
            kind: RecordKind.estimatedMax,
            value: topE1rm,
            label: 'Est. 1RM · ${formatWeight(fromKg(topE1rm, unit).roundToDouble(), unit)}',
          ),
        );
        continue;
      }
      final bodyweight = done.every((s) => s.weight == null || s.weight == 0);
      if (bodyweight) {
        final bestReps = _max(past.map((s) => (s.reps ?? 0).toDouble()));
        final topReps = _max(done.map((s) => (s.reps ?? 0).toDouble()));
        if (topReps > bestReps && bestReps > 0) {
          records.add(
            PersonalRecord(
              exerciseName: ex.exercise.name,
              kind: RecordKind.mostReps,
              value: topReps,
              label: 'Most reps · ${topReps.round()}',
            ),
          );
        }
      }
    }
    return records;
  }

  static double _max(Iterable<double> v) => v.fold(0, (a, b) => b > a ? b : a);

  Stream<List<SessionSummary>> watchHistory() {
    return db
        .customSelect(
          '''
SELECT s.*,
  (SELECT COUNT(*) FROM session_exercises e WHERE e.session_id = s.id AND e.skipped = 0) AS exercise_count,
  (SELECT COUNT(*) FROM set_logs l JOIN session_exercises e ON l.session_exercise_id = e.id
     WHERE e.session_id = s.id AND l.completed_at IS NOT NULL) AS done_sets,
  (SELECT COALESCE(SUM(
      CASE WHEN l.weight IS NULL OR l.reps IS NULL THEN 0
           WHEN l.unit = 1 THEN l.weight * 0.45359237 * l.reps
           ELSE l.weight * l.reps END), 0)
     FROM set_logs l JOIN session_exercises e ON l.session_exercise_id = e.id
     WHERE e.session_id = s.id AND l.completed_at IS NOT NULL) AS volume
FROM workout_sessions s
WHERE s.status = 'completed'
ORDER BY s.started_at DESC
''',
          readsFrom: {db.workoutSessions, db.sessionExercises, db.setLogs},
        )
        .watch()
        .map(
          (rows) => [
            for (final row in rows)
              SessionSummary(
                session: db.workoutSessions.map(row.data),
                exerciseCount: row.read<int>('exercise_count'),
                doneSets: row.read<int>('done_sets'),
                volumeKg: row.read<double>('volume'),
              ),
          ],
        );
  }

  Future<void> deleteSession(int id) =>
      (db.delete(db.workoutSessions)..where((s) => s.id.equals(id))).go();

  // Timer persistence: one row, so a restart always finds the same timer.

  Future<void> saveTimer(int sessionId, WorkoutTimer timer, {String label = ''}) => db
      .into(db.activeTimers)
      .insertOnConflictUpdate(
        ActiveTimer(
          id: 1,
          sessionId: sessionId,
          payload: jsonEncode({'timer': timer.toJson(), 'label': label}),
        ),
      );

  Future<StoredTimer?> loadTimer() async {
    final row = await (db.select(db.activeTimers)..where((t) => t.id.equals(1))).getSingleOrNull();
    if (row == null) return null;
    try {
      final json = jsonDecode(row.payload) as Map<String, Object?>;
      return StoredTimer(
        sessionId: row.sessionId,
        timer: WorkoutTimer.fromJson(json['timer'] as Map<String, Object?>),
        label: json['label'] as String? ?? '',
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> clearTimer() => (db.delete(db.activeTimers)..where((t) => t.id.equals(1))).go();
}
