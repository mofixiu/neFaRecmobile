import 'package:drift/drift.dart';

import '../../../core/db/database.dart';

class BackupSummary {
  const BackupSummary(this.routines, this.sessions, this.sets);
  final int routines;
  final int sessions;
  final int sets;

  Map<String, int> toJson() => {'routines': routines, 'sessions': sessions, 'sets': sets};
}

class BackupSnapshot {
  const BackupSnapshot({required this.schemaVersion, required this.summary, required this.payload});
  final int schemaVersion;
  final BackupSummary summary;
  final Map<String, Object?> payload;
}

/// Turns the whole local database into JSON and back. The running timer is
/// left out: it belongs to this phone, right now.
class BackupCodec {
  BackupCodec(this.db);
  final NefaDatabase db;

  Future<BackupSnapshot> export() async {
    List<Map<String, dynamic>> rows<T extends Table, D extends DataClass>(
      TableInfo<T, D> t,
      List<D> data,
    ) => [for (final d in data) d.toJson()];
    final routines = await db.select(db.routines).get();
    final sessions = await db.select(db.workoutSessions).get();
    final sets = await db.select(db.setLogs).get();
    final payload = <String, Object?>{
      'customExercises': rows(db.customExercises, await db.select(db.customExercises).get()),
      'learnedAliases': rows(db.learnedAliases, await db.select(db.learnedAliases).get()),
      'routines': rows(db.routines, routines),
      'routineDays': rows(db.routineDays, await db.select(db.routineDays).get()),
      'routineExercises': rows(db.routineExercises, await db.select(db.routineExercises).get()),
      'routineSets': rows(db.routineSets, await db.select(db.routineSets).get()),
      'workoutSessions': rows(db.workoutSessions, sessions),
      'sessionExercises': rows(db.sessionExercises, await db.select(db.sessionExercises).get()),
      'setLogs': rows(db.setLogs, sets),
      'preferences': rows(db.preferences, await db.select(db.preferences).get()),
    };
    return BackupSnapshot(
      schemaVersion: db.schemaVersion,
      summary: BackupSummary(
        routines.where((r) => !r.archived).length,
        sessions.where((s) => s.status == 'completed').length,
        sets.where((s) => s.completedAt != null).length,
      ),
      payload: payload,
    );
  }

  /// Replaces everything on this phone with [payload]. Refuses a backup made
  /// by a newer version of the app.
  Future<void> restore(Map<String, dynamic> payload, {required int schemaVersion}) async {
    if (schemaVersion > db.schemaVersion) {
      throw StateError('This backup is from a newer version of neFaRec. Update the app first.');
    }
    List<Map<String, dynamic>> list(String key) => [
      for (final r in (payload[key] as List? ?? const [])) Map<String, dynamic>.from(r as Map),
    ];

    await db.transaction(() async {
      // Children first, then parents.
      for (final t in <TableInfo>[
        db.activeTimers,
        db.setLogs,
        db.sessionExercises,
        db.workoutSessions,
        db.routineSets,
        db.routineExercises,
        db.routineDays,
        db.routines,
        db.learnedAliases,
        db.customExercises,
        db.preferences,
      ]) {
        await db.delete(t).go();
      }
      await db.batch((b) {
        b.insertAll(db.customExercises, list('customExercises').map(CustomExercise.fromJson));
        b.insertAll(db.learnedAliases, list('learnedAliases').map(LearnedAlias.fromJson));
        b.insertAll(db.routines, list('routines').map(Routine.fromJson));
        // Backups from schema 1 predate planned weekdays.
        b.insertAll(
          db.routineDays,
          list('routineDays').map((r) => RoutineDay.fromJson({'weekdays': 0, ...r})),
        );
        b.insertAll(db.routineExercises, list('routineExercises').map(RoutineExercise.fromJson));
        b.insertAll(db.routineSets, list('routineSets').map(RoutineSet.fromJson));
        b.insertAll(db.workoutSessions, list('workoutSessions').map(WorkoutSession.fromJson));
        b.insertAll(db.sessionExercises, list('sessionExercises').map(SessionExercise.fromJson));
        b.insertAll(db.setLogs, list('setLogs').map(SetLog.fromJson));
        b.insertAll(db.preferences, list('preferences').map(Preference.fromJson));
      });
    });
  }
}
