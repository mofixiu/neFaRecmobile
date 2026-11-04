import 'package:flutter_test/flutter_test.dart';
import 'package:nefarec/core/models/training.dart';

void main() {
  test('counts read naturally', () {
    expect(plural(1, 'set'), '1 set');
    expect(plural(0, 'set'), '0 sets');
    expect(plural(3, 'exercise'), '3 exercises');
    expect(plural(2, 'person', 'people'), '2 people');
  });
}
