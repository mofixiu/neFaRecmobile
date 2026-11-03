import '../../../core/db/database.dart';
import '../../../core/models/training.dart';

const _lbToKg = 0.45359237;

double toKg(double weight, WeightUnit unit) => unit == WeightUnit.kg ? weight : weight * _lbToKg;

double fromKg(double kg, WeightUnit unit) => unit == WeightUnit.kg ? kg : kg / _lbToKg;

extension SetLogX on SetLog {
  bool get isDone => completedAt != null;

  SetTarget get target => SetTarget.fromParts(
    kind: kind,
    repsMin: targetRepsMin,
    repsMax: targetRepsMax,
    durationSeconds: targetDurationSeconds,
  );

  /// Weight × reps in kilograms. Volume = Σ(load × reps) over completed sets
  /// that have both; timed and bodyweight sets add nothing.
  double get volumeKg {
    final w = weight;
    final r = reps;
    if (!isDone || w == null || r == null || w <= 0) return 0;
    return toKg(w, unit) * r;
  }

  double? get e1rmKg {
    final w = weight;
    final r = reps;
    if (!isDone || w == null || r == null) return null;
    return estimatedOneRepMax(toKg(w, unit), r);
  }
}

class SessionExerciseDetail {
  const SessionExerciseDetail(this.exercise, this.sets);
  final SessionExercise exercise;
  final List<SetLog> sets;

  int get done => sets.where((s) => s.isDone).length;
  bool get isComplete => sets.isNotEmpty && done == sets.length;
  bool get isFinished => exercise.skipped || isComplete;
  double get volumeKg => sets.fold(0, (v, s) => v + s.volumeKg);
}

class SessionDetail {
  const SessionDetail(this.session, this.exercises);
  final WorkoutSession session;
  final List<SessionExerciseDetail> exercises;

  int get totalSets => exercises.fold(0, (n, e) => n + e.sets.length);
  int get doneSets => exercises.fold(0, (n, e) => n + e.done);
  double get volumeKg => exercises.fold(0, (v, e) => v + e.volumeKg);
  double get progress => totalSets == 0 ? 0 : doneSets / totalSets;

  /// First exercise with work left, or the last one.
  int get currentIndex {
    final i = exercises.indexWhere((e) => !e.isFinished);
    return i < 0 ? exercises.length - 1 : i;
  }

  Duration elapsed(DateTime now) => (session.endedAt ?? now).difference(session.startedAt);
}

/// What you did last time for a movement, set by set.
class PreviousPerformance {
  const PreviousPerformance({required this.date, required this.sets});
  final DateTime date;
  final List<SetLog> sets;

  SetLog? forPosition(int position) {
    if (sets.isEmpty) return null;
    return position < sets.length ? sets[position] : sets.last;
  }
}

enum RecordKind { heaviest, estimatedMax, mostReps, longestHold, volume }

class PersonalRecord {
  const PersonalRecord({
    required this.exerciseName,
    required this.kind,
    required this.value,
    required this.label,
  });
  final String exerciseName;
  final RecordKind kind;
  final double value;
  final String label;
}

class SessionSummary {
  const SessionSummary({
    required this.session,
    required this.exerciseCount,
    required this.doneSets,
    required this.volumeKg,
  });
  final WorkoutSession session;
  final int exerciseCount;
  final int doneSets;
  final double volumeKg;

  Duration get duration => (session.endedAt ?? session.startedAt).difference(session.startedAt);
}

/// One completed set, with where and when it happened.
class LoggedSet {
  const LoggedSet({
    required this.sessionId,
    required this.date,
    required this.exercise,
    required this.set,
  });
  final int sessionId;
  final DateTime date;
  final SessionExercise exercise;
  final SetLog set;
}
