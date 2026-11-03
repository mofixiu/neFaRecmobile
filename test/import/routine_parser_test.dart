import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nefarec/core/models/training.dart';
import 'package:nefarec/features/import/domain/exercise_index.dart';
import 'package:nefarec/features/import/domain/routine_parser.dart';
import 'package:nefarec/features/library/domain/library_data.dart';

import 'fixtures.dart';

void main() {
  late ExerciseIndex index;
  late RoutineParser parser;

  setUpAll(() {
    final data = LibraryData.parse(File('assets/exercises/library.json').readAsStringSync());
    index = data.buildIndex();
    parser = RoutineParser(index);
  });

  String? confidentId(ExerciseMatch m) =>
      m.status == MatchStatus.exact || m.status == MatchStatus.fuzzy ? m.exercise?.id : null;

  test('spec example parses exactly, with suggestions marked', () {
    final r = parser.parse(fixtures.first.text);
    expect(r.days.single.name, 'Monday — Push');
    final ex = r.exercises.toList();
    expect(ex, hasLength(4));
    expect(ex[0].restSeconds, 90);
    expect(ex[0].restFrom, Provenance.explicit);
    expect(ex[1].restFrom, Provenance.defaulted);
    expect(ex[2].target, const SetTarget.duration(45));
    expect(ex[3].target, const SetTarget.failure());
    expect(ex.every((e) => e.setsFrom == Provenance.explicit), isTrue);
  });

  test('reps without sets suggest a set count rather than inventing one', () {
    final e = parser.parse('Push ups 20 reps').exercises.single;
    expect(e.sets, 3);
    expect(e.setsFrom, Provenance.suggested);
    expect(e.targetFrom, Provenance.explicit);
  });

  test('order is preserved and nothing is silently replaced', () {
    final r = parser.parse('Landmine press 3x10\nSquat 3x5');
    final ex = r.exercises.toList();
    expect(ex.first.typedName, 'Landmine press');
    expect(ex.first.match.needsReview, isTrue);
    expect(ex.last.match.exercise?.id, 'Barbell_Squat');
  });

  test('unreadable lines become issues, not exercises', () {
    final r = parser.parse('Squat 3x5\nfoo bar baz');
    expect(r.exercises, hasLength(1));
    expect(r.issues.single.line, 'foo bar baz');
  });

  test('dumbbell shorthand never turns into a barbell lift', () {
    final m = index.match('DB press');
    expect(m.exercise?.equipment, 'dumbbell');
  });

  test('fixture accuracy', () {
    var fields = 0;
    var correct = 0;
    var names = 0;
    var namesCorrect = 0;
    final misses = <String>[];

    void check(String fixture, String field, Object? want, Object? got) {
      fields++;
      if (want == got) {
        correct++;
      } else {
        misses.add('$fixture · $field: want $want, got $got');
      }
    }

    for (final f in fixtures) {
      final r = parser.parse(f.text);
      check(f.name, 'days', f.days.join(' / '), r.days.map((d) => d.name).join(' / '));
      final got = r.exercises.toList();
      check(f.name, 'count', f.exercises.length, got.length);
      for (var i = 0; i < f.exercises.length && i < got.length; i++) {
        final want = f.exercises[i];
        final g = got[i];
        final label = '${f.name}[$i] ${g.typedName}';
        names++;
        if (want.id == confidentId(g.match)) {
          namesCorrect++;
        } else {
          misses.add(
            '$label · id: want ${want.id}, got ${g.match.status.name} '
            '${g.match.exercise?.id} (${g.match.score.toStringAsFixed(2)})',
          );
        }
        check(label, 'sets', want.sets, g.sets);
        check(label, 'target', want.target, g.target.label);
        check(label, 'rest', want.rest, g.restFrom == Provenance.explicit ? g.restSeconds : null);
        check(label, 'weight', want.weight, g.weight);
        check(label, 'group', want.group, g.group);
        if (want.tempo != null) check(label, 'tempo', want.tempo, g.tempo);
      }
    }

    final fieldAcc = correct / fields;
    final nameAcc = namesCorrect / names;
    // ignore: avoid_print
    print(
      'field accuracy ${(fieldAcc * 100).toStringAsFixed(1)}% '
      '($correct/$fields) · exercise match ${(nameAcc * 100).toStringAsFixed(1)}% '
      '($namesCorrect/$names)\n${misses.join('\n')}',
    );
    expect(fieldAcc, greaterThanOrEqualTo(.9));
    expect(nameAcc, greaterThanOrEqualTo(.9));
  });
}
