import '../../../core/models/training.dart';
import 'progression.dart';

/// Short names for the effort buttons.
String effortLabel(Effort e) => switch (e) {
  Effort.easy => 'Easy',
  Effort.good => 'Good',
  Effort.hard => 'Hard',
  Effort.tooHeavy => 'Too heavy',
};

/// What each one means, for people who've never heard of "reps in reserve".
String effortHint(Effort e) => switch (e) {
  Effort.easy => '4+ more in you',
  Effort.good => '2–3 more',
  Effort.hard => '1 more, or none',
  Effort.tooHeavy => 'couldn’t finish',
};

/// The weight for your next set, from how the last one felt.
class NextWeight {
  const NextWeight(this.weight, this.reason);
  final double weight;

  /// Plain-language "because".
  final String reason;
}

/// Adjusts the load after a set you just finished at [weight].
///
/// Easy: add about 5% (at least one realistic jump). Good: stay. Hard: stay,
/// unless you missed the bottom of the rep range. Too heavy: drop about 10%.
/// Returns null for unloaded sets.
NextWeight? nextWeightAfter({
  required Effort effort,
  required double weight,
  required int? reps,
  required SetTarget target,
  required WeightUnit unit,
  String? equipment,
}) {
  if (weight <= 0) return null;
  final step = loadStep(equipment, unit);
  double jump(double share) {
    final n = (weight * share / step).round();
    return (n < 1 ? 1 : n) * step;
  }

  final missed = reps != null && target.repsMin != null && reps < target.repsMin!;
  final w = formatWeight(weight, unit);
  switch (effort) {
    case Effort.easy:
      if (missed) {
        return NextWeight(weight, 'Felt easy, but short of ${target.repsMin} reps. Stay at $w.');
      }
      final next = weight + jump(.05);
      return NextWeight(next, 'Felt easy, so go up to ${formatWeight(next, unit)}.');
    case Effort.good:
      return NextWeight(weight, 'Right weight. Stay at $w.');
    case Effort.hard:
      if (missed) {
        final next = (weight - step).clamp(0, weight).toDouble();
        return NextWeight(
          next,
          'Hard and short of ${target.repsMin} reps. Drop to ${formatWeight(next, unit)}.',
        );
      }
      return NextWeight(weight, 'Hard but done. Stay at $w and keep your form.');
    case Effort.tooHeavy:
      final next = (weight - jump(.10)).clamp(0, weight).toDouble();
      return NextWeight(next, 'Too heavy. Drop to ${formatWeight(next, unit)}.');
  }
}

/// A first-timer's starting point, by equipment.
String startingWeightTip(String? equipment, WeightUnit unit) {
  final kg = unit == WeightUnit.kg;
  return switch (equipment) {
    'barbell' => 'Start with the empty bar (${kg ? '20 kg' : '45 lb'}) and add from there.',
    'e-z curl bar' => 'Start with just the bar. Curls need less than you think.',
    'dumbbell' =>
      'Pick a pair you could lift 15 times. For most beginners that’s ${kg ? '4–8 kg' : '10–15 lb'}.',
    'kettlebells' => 'Start with a light bell, ${kg ? '8–12 kg' : '15–25 lb'}.',
    'machine' || 'cable' => 'Put the pin in one of the lightest plates on the stack.',
    _ => 'Start light enough to do every rep with good form.',
  };
}
