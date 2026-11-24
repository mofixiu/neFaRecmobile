import '../../core/models/training.dart';

/// Plates most gyms have, heaviest first.
const kgPlates = <double>[25, 20, 15, 10, 5, 2.5, 1.25];
const lbPlates = <double>[45, 35, 25, 10, 5, 2.5];

/// Bars to load, by unit. 0 is a plate-loaded machine: plates only.
const kgBars = <double>[20, 15, 10, 0];
const lbBars = <double>[45, 35, 25, 0];

List<double> platesFor(WeightUnit unit) => unit == WeightUnit.kg ? kgPlates : lbPlates;
List<double> barsFor(WeightUnit unit) => unit == WeightUnit.kg ? kgBars : lbBars;

const _eps = 1e-6;

/// What to put on each side of the bar for a weight.
class BarLoad {
  const BarLoad({
    required this.target,
    required this.bar,
    required this.unit,
    required this.perSide,
    this.above,
  });

  /// The weight you asked for.
  final double target;
  final double bar;
  final WeightUnit unit;

  /// Plates for one side, heaviest first (load them in this order).
  final List<double> perSide;

  /// When [target] can't be made exactly: the nearest loadable weight above
  /// it. [total] is then the nearest one below.
  final BarLoad? above;

  double get side => perSide.fold(0.0, (a, b) => a + b);
  double get total => bar + 2 * side;
  bool get exact => (total - target).abs() < _eps;

  /// Asked for less than the bar weighs.
  bool get belowBar => target < bar - _eps;
}

/// Loads [target] onto a bar weighing [bar] with standard plates, one
/// matching set per side. If it can't be made exactly, loads the nearest
/// weight below and offers the nearest above.
BarLoad loadBar(double target, {required double bar, required WeightUnit unit}) {
  final plates = platesFor(unit);
  final perSide = _greedy((target - bar) / 2, plates);
  final load = BarLoad(target: target, bar: bar, unit: unit, perSide: perSide);
  if (load.exact || load.belowBar) return load;
  // The next weight up: one more of the smallest plate on each side,
  // re-packed into the fewest plates.
  final up = _greedy(load.side + plates.last, plates);
  return BarLoad(
    target: target,
    bar: bar,
    unit: unit,
    perSide: perSide,
    above: BarLoad(
      target: bar + 2 * up.fold(0.0, (a, b) => a + b),
      bar: bar,
      unit: unit,
      perSide: up,
    ),
  );
}

/// Fewest plates that add up to at most [side]. Standard plate sets are
/// canonical, so taking the heaviest that fits each time is optimal.
List<double> _greedy(double side, List<double> plates) {
  final out = <double>[];
  var left = side;
  for (final p in plates) {
    while (left + _eps >= p) {
      out.add(p);
      left -= p;
    }
  }
  return out;
}

/// The bar a lift usually uses, from its library equipment, or null when
/// plates don't apply.
double? defaultBar(String? equipment, WeightUnit unit, {bool plateLoaded = false}) {
  final kg = unit == WeightUnit.kg;
  if (plateLoaded) return 0;
  return switch (equipment) {
    'barbell' => kg ? 20 : 45,
    'e-z curl bar' => kg ? 10 : 25,
    _ => null,
  };
}

/// Equipment guide ids that you load with plates.
const plateLoadedMachines = {'leg_press', 'hack_squat', 'smith_machine'};

String plateLabel(double p) => p == p.roundToDouble() ? p.toStringAsFixed(0) : '$p';
