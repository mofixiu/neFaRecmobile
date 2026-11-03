import '../../../core/models/training.dart';
import '../../import/domain/exercise_index.dart';
import '../../import/domain/parsed_routine.dart';

int _keySeed = 0;
int _nextKey() => ++_keySeed;

/// An exercise as it is being reviewed or edited, before it is saved.
class ExerciseDraft {
  ExerciseDraft({
    int? key,
    required this.name,
    this.exerciseId,
    this.typedName,
    this.status,
    this.candidates = const [],
    this.sets = 3,
    this.setsFrom = Provenance.explicit,
    this.target = const SetTarget.reps(10),
    this.targetFrom = Provenance.explicit,
    this.perSetReps,
    this.weight,
    this.unit = WeightUnit.kg,
    this.restSeconds,
    this.restFrom = Provenance.explicit,
    this.tempo,
    this.group,
    this.notes,
    this.perSide = false,
    this.timed = false,
    this.sourceLine,
    this.variant,
  }) : key = key ?? _nextKey();

  factory ExerciseDraft.fromParsed(ParsedExercise p) {
    final m = p.match;
    return ExerciseDraft(
      name: p.displayName,
      exerciseId: m.status == MatchStatus.unmatched ? null : m.exercise?.id,
      typedName: p.typedName,
      status: m.status,
      candidates: [
        if (m.status == MatchStatus.uncertain && m.exercise != null) m.exercise!,
        ...m.candidates.map((c) => c.exercise),
      ],
      sets: p.sets,
      setsFrom: p.setsFrom,
      target: p.target,
      targetFrom: p.targetFrom,
      perSetReps: p.perSetReps,
      weight: p.weight,
      unit: p.unit,
      restSeconds: p.restSeconds,
      restFrom: p.restFrom,
      tempo: p.tempo,
      group: p.group,
      notes: p.notes,
      perSide: p.perSide,
      timed: p.target.isTimed,
      sourceLine: p.line,
    );
  }

  final int key;
  final String name;
  final String? exerciseId;

  /// What the paste said, when this came from an import.
  final String? typedName;
  final MatchStatus? status;
  final List<IndexedExercise> candidates;
  final int sets;
  final Provenance setsFrom;
  final SetTarget target;
  final Provenance targetFrom;
  final List<int>? perSetReps;
  final double? weight;
  final WeightUnit unit;
  final int? restSeconds;
  final Provenance restFrom;
  final String? tempo;
  final String? group;
  final String? notes;
  final bool perSide;
  final bool timed;
  final String? sourceLine;

  /// Machine or setup, e.g. "Hammer Strength" or "Gym A cable".
  final String? variant;

  /// Still waiting for you to confirm which exercise this is.
  bool get needsMatch => status == MatchStatus.uncertain || status == MatchStatus.unmatched;

  bool get hasSuggestions =>
      setsFrom != Provenance.explicit ||
      targetFrom != Provenance.explicit ||
      restFrom != Provenance.explicit;

  ExerciseDraft copyWith({
    String? name,
    String? exerciseId,
    bool clearExercise = false,
    MatchStatus? status,
    int? sets,
    Provenance? setsFrom,
    SetTarget? target,
    Provenance? targetFrom,
    List<int>? perSetReps,
    bool clearPerSet = false,
    double? weight,
    bool clearWeight = false,
    WeightUnit? unit,
    int? restSeconds,
    bool clearRest = false,
    Provenance? restFrom,
    String? tempo,
    String? group,
    bool clearGroup = false,
    String? notes,
    bool? perSide,
    bool? timed,
    String? variant,
    bool clearVariant = false,
  }) {
    return ExerciseDraft(
      key: key,
      name: name ?? this.name,
      exerciseId: clearExercise ? null : exerciseId ?? this.exerciseId,
      typedName: typedName,
      status: status ?? this.status,
      candidates: candidates,
      sets: sets ?? this.sets,
      setsFrom: setsFrom ?? this.setsFrom,
      target: target ?? this.target,
      targetFrom: targetFrom ?? this.targetFrom,
      perSetReps: clearPerSet ? null : perSetReps ?? this.perSetReps,
      weight: clearWeight ? null : weight ?? this.weight,
      unit: unit ?? this.unit,
      restSeconds: clearRest ? null : restSeconds ?? this.restSeconds,
      restFrom: restFrom ?? this.restFrom,
      tempo: tempo ?? this.tempo,
      group: clearGroup ? null : group ?? this.group,
      notes: notes ?? this.notes,
      perSide: perSide ?? this.perSide,
      timed: timed ?? this.timed,
      sourceLine: sourceLine,
      variant: clearVariant ? null : variant ?? this.variant,
    );
  }
}

class DayDraft {
  DayDraft({int? key, required this.name, required this.exercises, this.weekdays = 0})
    : key = key ?? _nextKey();

  final int key;
  final String name;
  final List<ExerciseDraft> exercises;

  /// Bit 0 = Monday … bit 6 = Sunday.
  final int weekdays;

  DayDraft copyWith({String? name, List<ExerciseDraft>? exercises, int? weekdays}) => DayDraft(
    key: key,
    name: name ?? this.name,
    exercises: exercises ?? this.exercises,
    weekdays: weekdays ?? this.weekdays,
  );
}

class RoutineDraft {
  const RoutineDraft({
    this.routineId,
    required this.name,
    required this.days,
    this.notes,
    this.sourceText,
    this.issues = const [],
  });

  factory RoutineDraft.fromParsed(ParsedRoutine parsed, String sourceText) {
    final days = parsed.days
        .map(
          (d) =>
              DayDraft(name: d.name, exercises: d.exercises.map(ExerciseDraft.fromParsed).toList()),
        )
        .toList();
    final first = days.isEmpty ? null : days.first.name;
    return RoutineDraft(
      name: days.length == 1 && first != 'Workout'
          ? first!
          : days.length > 1
          ? '${days.length}-day routine'
          : 'New routine',
      days: days,
      notes: parsed.notes.isEmpty ? null : parsed.notes.join('\n'),
      sourceText: sourceText,
      issues: parsed.issues,
    );
  }

  final int? routineId;
  final String name;
  final String? notes;
  final String? sourceText;
  final List<DayDraft> days;
  final List<ParseIssue> issues;

  Iterable<ExerciseDraft> get exercises => days.expand((d) => d.exercises);
  int get toConfirm => exercises.where((e) => e.needsMatch).length;
  int get suggested => exercises.where((e) => e.hasSuggestions).length;

  RoutineDraft copyWith({
    String? name,
    String? notes,
    List<DayDraft>? days,
    List<ParseIssue>? issues,
  }) => RoutineDraft(
    routineId: routineId,
    name: name ?? this.name,
    notes: notes ?? this.notes,
    sourceText: sourceText,
    days: days ?? this.days,
    issues: issues ?? this.issues,
  );
}
