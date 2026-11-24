import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nefarec/features/equipment/equipment_guide.dart';
import 'package:nefarec/features/library/domain/library_data.dart';

void main() {
  final guide = EquipmentGuide.parse(File('assets/equipment/equipment.json').readAsStringSync());
  final library = LibraryData.parse(File('assets/exercises/library.json').readAsStringSync());
  final libraryIds = {for (final r in library.records) r.id};
  final muscles = {
    for (final r in library.records) ...[...r.primaryMuscles, ...r.secondaryMuscles],
  };

  group('guide', () {
    test('every entry is complete and links to real exercises', () {
      final ids = <String>{};
      for (final e in guide.items) {
        expect(ids.add(e.id), isTrue, reason: 'duplicate id ${e.id}');
        expect(equipmentKinds, contains(e.kind), reason: e.id);
        expect(e.setup.length, greaterThanOrEqualTo(3), reason: e.id);
        expect(e.what, isNotEmpty);
        expect(e.tip, isNotEmpty);
        expect(e.mistake, isNotEmpty);
        expect(e.exercises, isNotEmpty, reason: e.id);
        expect(File(e.image).existsSync(), isTrue, reason: '${e.id} photo ${e.image}');
        for (final x in e.exercises) {
          expect(libraryIds, contains(x), reason: '${e.id} links to $x');
        }
        for (final m in e.trains) {
          // Muscle names come from the library, apart from the hip machine's
          // own two.
          if (m == 'abductors' || m == 'adductors') continue;
          expect(muscles, contains(m), reason: '${e.id} trains $m');
        }
      }
    });

    test('covers every label the on-device models can return', () {
      final labels = File(
        'android/app/src/main/assets/equipment_labels.txt',
      ).readAsLinesSync().where((l) => l.trim().isNotEmpty);
      expect(labels, hasLength(guide.items.length));
      for (final l in labels) {
        expect(guide.byId(l), isNotNull, reason: l);
      }
    });

    test('finds the machine an exercise is done on', () {
      expect(guide.forExercise('Leg_Press').map((e) => e.id), ['leg_press']);
      expect(guide.forExercise('Leg_Extensions').first.id, 'leg_extension');
      expect(guide.forExercise('Plank'), isEmpty);
    });
  });

  group('machine taken', () {
    LibraryRecord r(String id) => library.records.firstWhere((x) => x.id == id);

    test('leg press taken rules out every leg press', () {
      final lp = r('Leg_Press');
      expect(usesSameStation(lp, r('Narrow_Stance_Leg_Press'), guide), isTrue);
      expect(usesSameStation(lp, r('Smith_Machine_Leg_Press'), guide), isTrue);
      expect(usesSameStation(lp, r('Hack_Squat'), guide), isFalse);
      expect(usesSameStation(lp, r('Goblet_Squat'), guide), isFalse);
    });

    test('a bar or cable column taken rules out the same kit', () {
      expect(usesSameStation(r('Barbell_Squat'), r('Front_Barbell_Squat'), guide), isTrue);
      expect(usesSameStation(r('Barbell_Squat'), r('Leg_Press'), guide), isFalse);
      expect(usesSameStation(r('Triceps_Pushdown'), r('Cable_Crossover'), guide), isTrue);
      expect(usesSameStation(r('Triceps_Pushdown'), r('Bench_Dips'), guide), isFalse);
    });

    test('dumbbells are never all taken', () {
      expect(
        usesSameStation(r('Dumbbell_Bench_Press'), r('Dumbbell_Shoulder_Press'), guide),
        isFalse,
      );
    });
  });

  group('reading the machine', () {
    test('a specific label on the machine names it', () {
      expect(
        equipmentFromText('HAMMER STRENGTH\nLEG EXTENSION\nAdjust seat', guide)?.$1.id,
        'leg_extension',
      );
      expect(equipmentFromText('Lat Pulldown / Low Row', guide)?.$1.id, 'lat_pulldown');
      expect(equipmentFromText('TREADMILL T5', guide)?.$1.id, 'treadmill');
    });

    test('the longest label wins', () {
      expect(equipmentFromText('TRICEPS PRESS', guide)?.$1.id, 'dip_machine');
      expect(equipmentFromText('SEATED LEG CURL', guide)?.$1.id, 'leg_curl');
    });

    test('short or partial words alone do not name a machine', () {
      expect(equipmentFromText('ROW', guide), isNull);
      expect(
        equipmentFromText('Narrow grip', guide, strongOnly: false)?.$1.id,
        isNot('seated_row'),
      );
      expect(equipmentFromText('', guide), isNull);
    });
  });

  group('ranking', () {
    test('the model alone, best first', () {
      final scan = rankEquipment(
        [('leg_press', .82), ('hack_squat', .1), ('leg_curl', .05)],
        '',
        guide,
      );
      expect(scan.best!.equipment.id, 'leg_press');
      expect(scan.best!.readLabel, isNull);
      expect(scan.confident, isTrue);
      expect(scan.guesses.map((g) => g.equipment.id), ['leg_press', 'hack_squat', 'leg_curl']);
    });

    test('a printed name beats the model', () {
      final scan = rankEquipment([('leg_curl', .6), ('leg_extension', .3)], 'LEG EXTENSION', guide);
      expect(scan.best!.equipment.id, 'leg_extension');
      expect(scan.best!.readLabel, 'leg extension');
      expect(scan.confident, isTrue);
      expect(scan.guesses.map((g) => g.equipment.id), ['leg_extension', 'leg_curl']);
    });

    test('a short word only lifts a guess the model already made', () {
      var scan = rankEquipment([('lat_pulldown', .5), ('seated_row', .3)], 'ROW', guide);
      expect(scan.best!.equipment.id, 'seated_row');
      scan = rankEquipment([('lat_pulldown', .5), ('pec_deck', .3)], 'ROW', guide);
      expect(scan.best!.equipment.id, 'lat_pulldown');
      expect(scan.best!.readLabel, isNull);
    });

    test('a routine screenshot does not become the machine it mentions', () {
      const chat =
          'Coach Tobi online Today Push day Bench press 4x6-8, rest 2 min Incline DB press 3x10 '
          'Lateral raises 3x15 Tricep pushdown 3x12 Plank 3 x 45 sec';
      var scan = rankEquipment([('barbell', .52), ('bench', .13)], chat, guide);
      expect(scan.best!.equipment.id, 'barbell');
      expect(scan.best!.readLabel, isNull);
      // A label in long text still lifts a guess the model already made.
      scan = rankEquipment([('barbell', .52), ('chest_press', .2)], chat, guide);
      expect(scan.best!.equipment.id, 'chest_press');
    });

    test('low confidence is not presented as an answer', () {
      final unsure = rankEquipment([('bench', .15), ('plates', .1)], '', guide);
      expect(unsure.unsure, isTrue);
      final maybe = rankEquipment([('bench', .35), ('plates', .3)], '', guide);
      expect(maybe.unsure, isFalse);
      expect(maybe.confident, isFalse);
      expect(rankEquipment(const [], '', guide).unsure, isTrue);
    });

    test('ignores labels the guide does not know', () {
      final scan = rankEquipment([('spaceship', .9), ('treadmill', .05)], '', guide);
      expect(scan.best!.equipment.id, 'treadmill');
    });
  });
}
