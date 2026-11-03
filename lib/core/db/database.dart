import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../models/training.dart';

part 'database.g.dart';

/// Movements you added that the bundled library does not have.
class CustomExercises extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get equipment => text().nullable()();
  BoolColumn get timed => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Names you confirmed during an import, so the next paste matches them.
@DataClassName('LearnedAlias')
class LearnedAliases extends Table {
  TextColumn get alias => text()();
  TextColumn get exerciseId => text()();

  @override
  Set<Column> get primaryKey => {alias};
}

class Routines extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get notes => text().nullable()();

  /// The text you pasted, kept for reference.
  TextColumn get sourceText => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
}

class RoutineDays extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get routineId => integer().references(Routines, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  IntColumn get position => integer()();

  /// Days of the week this day is planned for: bit 0 = Monday … bit 6 = Sunday.
  IntColumn get weekdays => integer().withDefault(const Constant(0))();
}

class RoutineExercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get dayId => integer().references(RoutineDays, #id, onDelete: KeyAction.cascade)();

  /// Library or custom id. Null while an imported name is still unresolved.
  TextColumn get exerciseId => text().nullable()();
  TextColumn get name => text()();
  IntColumn get position => integer()();
  TextColumn get groupLabel => text().nullable()();
  IntColumn get restSeconds => integer().nullable()();
  IntColumn get restFrom => intEnum<Provenance>().withDefault(const Constant(0))();
  TextColumn get tempo => text().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get perSide => boolean().withDefault(const Constant(false))();
  BoolColumn get timed => boolean().withDefault(const Constant(false))();

  /// The specific machine or setup ("Gym A cable, 2:1 pulley"). Loads are only
  /// compared between sets with the same variant.
  TextColumn get variant => text().nullable()();
}

/// One prescribed set.
class RoutineSets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get routineExerciseId =>
      integer().references(RoutineExercises, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();
  IntColumn get kind => intEnum<TargetKind>()();
  IntColumn get repsMin => integer().nullable()();
  IntColumn get repsMax => integer().nullable()();
  IntColumn get durationSeconds => integer().nullable()();
  RealColumn get weight => real().nullable()();
  IntColumn get unit => intEnum<WeightUnit>().withDefault(const Constant(0))();
  IntColumn get setsFrom => intEnum<Provenance>().withDefault(const Constant(0))();
  IntColumn get targetFrom => intEnum<Provenance>().withDefault(const Constant(0))();
}

/// One attempt at a routine day. Targets are copied in when it starts, so
/// editing the routine later never rewrites what you did.
class WorkoutSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get routineId => integer().nullable()();
  IntColumn get dayId => integer().nullable()();
  TextColumn get title => text()();
  TextColumn get routineName => text().nullable()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();

  /// active, completed or discarded.
  TextColumn get status => text().withDefault(const Constant('active'))();
  TextColumn get notes => text().nullable()();
}

class SessionExercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId =>
      integer().references(WorkoutSessions, #id, onDelete: KeyAction.cascade)();
  TextColumn get exerciseId => text().nullable()();
  TextColumn get name => text()();
  IntColumn get position => integer()();
  TextColumn get groupLabel => text().nullable()();
  IntColumn get restSeconds => integer().nullable()();
  TextColumn get tempo => text().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get perSide => boolean().withDefault(const Constant(false))();
  BoolColumn get timed => boolean().withDefault(const Constant(false))();

  /// The specific machine or setup ("Gym A cable, 2:1 pulley"). Loads are only
  /// compared between sets with the same variant.
  TextColumn get variant => text().nullable()();
  BoolColumn get skipped => boolean().withDefault(const Constant(false))();
}

/// What actually happened in one set, next to what was prescribed.
class SetLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionExerciseId =>
      integer().references(SessionExercises, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();
  IntColumn get kind => intEnum<TargetKind>()();
  IntColumn get targetRepsMin => integer().nullable()();
  IntColumn get targetRepsMax => integer().nullable()();
  IntColumn get targetDurationSeconds => integer().nullable()();
  RealColumn get targetWeight => real().nullable()();
  IntColumn get unit => intEnum<WeightUnit>().withDefault(const Constant(0))();
  IntColumn get reps => integer().nullable()();
  RealColumn get weight => real().nullable()();
  IntColumn get durationSeconds => integer().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
}

/// The single running timer, stored as [WorkoutTimer] JSON.
class ActiveTimers extends Table {
  IntColumn get id => integer()();
  IntColumn get sessionId => integer()();
  TextColumn get payload => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class Preferences extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(
  tables: [
    CustomExercises,
    LearnedAliases,
    Routines,
    RoutineDays,
    RoutineExercises,
    RoutineSets,
    WorkoutSessions,
    SessionExercises,
    SetLogs,
    ActiveTimers,
    Preferences,
  ],
)
class NefaDatabase extends _$NefaDatabase {
  NefaDatabase([QueryExecutor? executor]) : super(executor ?? driftDatabase(name: 'nefarec'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(routineDays, routineDays.weekdays);
        await m.addColumn(routineExercises, routineExercises.variant);
        await m.addColumn(sessionExercises, sessionExercises.variant);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
