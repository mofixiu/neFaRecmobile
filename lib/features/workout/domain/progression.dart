import '../../../core/db/database.dart';
import '../../../core/models/training.dart';
import 'session_models.dart';

/// A rule-based nudge for today's sets, from what you did last time.
///
/// Double progression: earn every rep in the range first, then add load and
/// drop back to the bottom of the range. Never suggests a change when the
/// last session is too thin to judge.
class Suggestion {
  const Suggestion({required this.reason, this.weight, this.reps, this.seconds});

  final double? weight;
  final int? reps;
  final int? seconds;

  /// Plain-language "because": shown under the suggestion.
  final String reason;

  bool get addsLoad => weight != null;

  String label(WeightUnit unit) {
    if (seconds != null) return formatClock(Duration(seconds: seconds!));
    final r = reps == null ? '' : ' × $reps';
    if (weight != null) return '${formatWeight(weight, unit)}$r';
    return '${reps ?? '?'} reps';
  }
}

/// Load jumps that are realistic for the kit you are using.
double loadStep(String? equipment, WeightUnit unit) {
  final kg = unit == WeightUnit.kg;
  return switch (equipment) {
    'dumbbell' => kg ? 2 : 5,
    'kettlebells' => kg ? 4 : 8,
    'barbell' || 'e-z curl bar' => kg ? 2.5 : 5,
    'cable' || 'machine' => kg ? 2.5 : 5,
    _ => kg ? 2.5 : 5,
  };
}

Suggestion? suggestNext({
  required PreviousPerformance? previous,
  required SetTarget target,
  required int plannedSets,
  String? equipment,
}) {
  final prev = previous?.sets.where((s) => s.isDone).toList() ?? const <SetLog>[];
  // Fewer than half the planned sets last time: not enough to judge.
  if (prev.isEmpty || prev.length * 2 < plannedSets) return null;

  if (target.isTimed) {
    final goal = target.durationSeconds!;
    final held = prev.map((s) => s.durationSeconds ?? 0).toList();
    if (held.every((h) => h >= goal)) {
      return Suggestion(
        seconds: goal + 5,
        reason:
            'You held ${formatClock(Duration(seconds: goal))} on every set last time. Try 5 seconds more.',
      );
    }
    return null;
  }

  final weights = prev.map((s) => s.weight ?? 0).toList();
  final top = weights.reduce((a, b) => a > b ? a : b);
  final unit = prev.first.unit;
  final reps = prev.map((s) => s.reps ?? 0).toList();
  final minReps = reps.reduce((a, b) => a < b ? a : b);
  final best = reps.reduce((a, b) => a > b ? a : b);

  if (target.kind == TargetKind.failure) {
    return Suggestion(
      weight: top > 0 ? top : null,
      reps: best + 1,
      reason: 'Your best set last time was $best. Beat it by one.',
    );
  }

  final low = target.repsMin ?? 1;
  final high = target.repsMax ?? low;
  final allAtTop = reps.every((r) => r >= high);

  if (top <= 0) {
    // Bodyweight: progress by reps only.
    if (allAtTop) {
      return Suggestion(reps: high + 1, reason: 'Every set reached $high last time. Add a rep.');
    }
    return Suggestion(
      reps: (minReps + 1).clamp(low, high),
      reason: 'Lowest set last time was $minReps. Bring it up by one.',
    );
  }

  final atTopWeight = prev.where((s) => (s.weight ?? 0) == top).toList();
  final topRepsOk = atTopWeight.every((s) => (s.reps ?? 0) >= high);
  if (allAtTop || (topRepsOk && atTopWeight.length * 2 >= plannedSets)) {
    final next = top + loadStep(equipment, unit);
    return Suggestion(
      weight: next,
      reps: low,
      reason:
          'You hit $high reps on every set at ${formatWeight(top, unit)}. '
          'Add load and start again at $low.',
    );
  }
  return Suggestion(
    weight: top,
    reps: (minReps + 1).clamp(low, high),
    reason:
        'Same load as last time. Your lowest set was $minReps; '
        'aim for ${(minReps + 1).clamp(low, high)} before adding weight.',
  );
}
