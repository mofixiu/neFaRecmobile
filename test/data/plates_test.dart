import 'package:flutter_test/flutter_test.dart';
import 'package:nefarec/core/models/training.dart';
import 'package:nefarec/features/tools/plates.dart';

void main() {
  test('60 kg on an Olympic bar is a 20 each side', () {
    final l = loadBar(60, bar: 20, unit: WeightUnit.kg);
    expect(l.perSide, [20]);
    expect(l.exact, isTrue);
    expect(l.total, 60);
  });

  test('uses the fewest plates, heaviest first', () {
    expect(loadBar(100, bar: 20, unit: WeightUnit.kg).perSide, [25, 15]);
    expect(loadBar(72.5, bar: 20, unit: WeightUnit.kg).perSide, [25, 1.25]);
    expect(loadBar(142.5, bar: 20, unit: WeightUnit.kg).perSide, [25, 25, 10, 1.25]);
  });

  test('pounds use pound plates', () {
    expect(loadBar(135, bar: 45, unit: WeightUnit.lb).perSide, [45]);
    expect(loadBar(185, bar: 45, unit: WeightUnit.lb).perSide, [45, 25]);
  });

  test('plate-loaded machines count plates only', () {
    final l = loadBar(100, bar: 0, unit: WeightUnit.kg);
    expect(l.perSide, [25, 25]);
    expect(l.total, 100);
  });

  test('a weight that cannot be made offers the nearest either side', () {
    final l = loadBar(61, bar: 20, unit: WeightUnit.kg);
    expect(l.exact, isFalse);
    expect(l.total, 60);
    expect(l.above!.total, 62.5);
    expect(l.above!.perSide, [20, 1.25]);
  });

  test('less than the bar loads nothing', () {
    final l = loadBar(15, bar: 20, unit: WeightUnit.kg);
    expect(l.belowBar, isTrue);
    expect(l.perSide, isEmpty);
    expect(loadBar(20, bar: 20, unit: WeightUnit.kg).exact, isTrue);
  });

  test('default bars by equipment', () {
    expect(defaultBar('barbell', WeightUnit.kg), 20);
    expect(defaultBar('barbell', WeightUnit.lb), 45);
    expect(defaultBar('e-z curl bar', WeightUnit.kg), 10);
    expect(defaultBar('dumbbell', WeightUnit.kg), isNull);
    expect(defaultBar('machine', WeightUnit.kg, plateLoaded: true), 0);
  });
}
