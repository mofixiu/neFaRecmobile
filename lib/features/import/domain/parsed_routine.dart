import '../../../core/models/training.dart';
import 'exercise_index.dart';

/// The parser's best reading of a pasted routine, before you confirm it.
class ParsedRoutine {
  const ParsedRoutine({required this.days, this.notes = const [], this.issues = const []});

  final List<ParsedDay> days;

  /// Lines that read like general advice rather than exercises.
  final List<String> notes;

  /// Lines nefaRec could not read.
  final List<ParseIssue> issues;

  Iterable<ParsedExercise> get exercises => days.expand((d) => d.exercises);
  bool get isEmpty => exercises.isEmpty;
  int get flaggedCount => exercises.where((e) => e.match.needsReview || e.hasSuggestions).length;
}

class ParsedDay {
  const ParsedDay({required this.name, required this.exercises});

  /// Your day heading, or "Workout" when the paste had none.
  final String name;
  final List<ParsedExercise> exercises;
}

class ParsedExercise {
  const ParsedExercise({
    required this.line,
    required this.typedName,
    required this.match,
    required this.sets,
    required this.setsFrom,
    required this.target,
    required this.targetFrom,
    this.perSetReps,
    this.weight,
    this.unit = WeightUnit.kg,
    this.restSeconds,
    this.restFrom = Provenance.defaulted,
    this.tempo,
    this.group,
    this.perSide = false,
    this.notes,
  });

  /// The original line, kept so the review can show what was read.
  final String line;
  final String typedName;
  final ExerciseMatch match;

  final int sets;
  final Provenance setsFrom;
  final SetTarget target;
  final Provenance targetFrom;

  /// "4 × 12, 10, 8, 6": one target per set when they differ.
  final List<int>? perSetReps;
  final double? weight;
  final WeightUnit unit;
  final int? restSeconds;
  final Provenance restFrom;
  final String? tempo;

  /// Superset label shared by grouped exercises ("A").
  final String? group;
  final bool perSide;
  final String? notes;

  bool get hasSuggestions => setsFrom != Provenance.explicit || targetFrom != Provenance.explicit;

  String get displayName => match.exercise?.name ?? typedName;

  ParsedExercise copyWith({String? notes, int? restSeconds, Provenance? restFrom, String? group}) {
    return ParsedExercise(
      line: line,
      typedName: typedName,
      match: match,
      sets: sets,
      setsFrom: setsFrom,
      target: target,
      targetFrom: targetFrom,
      perSetReps: perSetReps,
      weight: weight,
      unit: unit,
      restSeconds: restSeconds ?? this.restSeconds,
      restFrom: restFrom ?? this.restFrom,
      tempo: tempo,
      group: group ?? this.group,
      perSide: perSide,
      notes: notes ?? this.notes,
    );
  }
}

class ParseIssue {
  const ParseIssue({required this.line, required this.message});
  final String line;
  final String message;
}
