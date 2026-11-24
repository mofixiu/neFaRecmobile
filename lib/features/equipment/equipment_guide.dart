import 'dart:convert';

/// One kind of gym equipment from `assets/equipment/equipment.json`.
class Equipment {
  const Equipment({
    required this.id,
    required this.name,
    required this.also,
    required this.kind,
    required this.image,
    required this.trains,
    required this.what,
    required this.setup,
    required this.tip,
    required this.mistake,
    required this.labels,
    required this.exercises,
  });

  factory Equipment.fromJson(Map<String, dynamic> j) => Equipment(
    id: j['id'] as String,
    name: j['name'] as String,
    also: List<String>.from(j['also'] as List? ?? const []),
    kind: j['kind'] as String,
    image: j['image'] as String,
    trains: List<String>.from(j['trains'] as List? ?? const []),
    what: j['what'] as String,
    setup: List<String>.from(j['setup'] as List? ?? const []),
    tip: j['tip'] as String,
    mistake: j['mistake'] as String,
    labels: List<String>.from(j['labels'] as List? ?? const []),
    exercises: List<String>.from(j['exercises'] as List? ?? const []),
  );

  /// Matches the on-device model's labels.
  final String id;
  final String name;

  /// Other names people use for it.
  final List<String> also;

  /// machine, cable, free weight, bodyweight or cardio.
  final String kind;

  /// Asset path of a public-domain photo (free-exercise-db) of someone using it.
  final String image;

  /// Library muscle names, main one first.
  final List<String> trains;
  final String what;
  final List<String> setup;
  final String tip;
  final String mistake;

  /// Words printed on the machine itself, lowercase.
  final List<String> labels;

  /// Library exercise ids, most useful first.
  final List<String> exercises;
}

/// The order kinds appear in when you browse.
const equipmentKinds = ['machine', 'cable', 'free weight', 'bodyweight', 'cardio'];

String kindTitle(String kind) => switch (kind) {
  'machine' => 'Machines',
  'cable' => 'Cables',
  'free weight' => 'Free weights',
  'bodyweight' => 'Bodyweight',
  'cardio' => 'Cardio',
  _ => 'Other',
};

class EquipmentGuide {
  const EquipmentGuide(this.items);

  factory EquipmentGuide.parse(String source) {
    final json = jsonDecode(source) as Map<String, dynamic>;
    return EquipmentGuide([
      for (final e in json['equipment'] as List) Equipment.fromJson(e as Map<String, dynamic>),
    ]);
  }

  final List<Equipment> items;

  Equipment? byId(String id) {
    for (final e in items) {
      if (e.id == id) return e;
    }
    return null;
  }

  /// Every kind of equipment that uses [exerciseId], best match first.
  List<Equipment> forExercise(String exerciseId) => [
    for (final e in items)
      if (e.exercises.contains(exerciseId)) e,
  ]..sort((a, b) => a.exercises.indexOf(exerciseId).compareTo(b.exercises.indexOf(exerciseId)));
}

/// One possible answer to "what is this?".
class EquipmentGuess {
  const EquipmentGuess(this.equipment, this.confidence, {this.readLabel});
  final Equipment equipment;

  /// The model's confidence, 0 to 1.
  final double confidence;

  /// The words on the machine that named it, when the photo had them.
  final String? readLabel;
}

/// What the scanner thinks a photo shows.
class EquipmentScan {
  const EquipmentScan(this.guesses);
  final List<EquipmentGuess> guesses;

  EquipmentGuess? get best => guesses.isEmpty ? null : guesses.first;

  /// The machine named itself, or the model is fairly sure.
  bool get confident {
    final b = best;
    return b != null && (b.readLabel != null || b.confidence >= .5);
  }

  /// Too unsure to suggest anything.
  bool get unsure {
    final b = best;
    return b == null || (b.readLabel == null && b.confidence < .2);
  }
}

String _normalise(String text) =>
    ' ${text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9/]+'), ' ').trim()} ';

/// A label is specific enough to trust on its own when it's more than one
/// word or a long single word ("treadmill", "pulldown"). Short words like
/// "row" or "dip" only back up a guess the model already made.
bool _strong(String label) => label.contains(' ') || label.length >= 7;

/// The equipment named by the words on a machine, and the words that did it.
/// Longer, more specific labels win: "triceps press" beats "triceps".
(Equipment, String)? equipmentFromText(String text, EquipmentGuide guide, {bool strongOnly = true}) {
  final hay = _normalise(text);
  if (hay.trim().isEmpty) return null;
  (Equipment, String)? found;
  for (final e in guide.items) {
    for (final label in e.labels) {
      if (strongOnly && !_strong(label)) continue;
      final needle = _normalise(label);
      if (needle.trim().isEmpty || !hay.contains(needle)) continue;
      if (found == null || label.length > found.$2.length) found = (e, label);
    }
  }
  return found;
}

/// Text with more words than this is a document or a screen, not the name
/// plate on a machine.
const _plateWords = 15;

/// Combines the model's guesses with any text read from the photo.
/// A specific label on a name plate goes first. A short label, or any label
/// in a longer block of text (a chat, a poster), only lifts a guess the model
/// already has. Returns at most [limit] guesses, best first.
EquipmentScan rankEquipment(
  List<(String, double)> model,
  String text,
  EquipmentGuide guide, {
  int limit = 4,
}) {
  final guesses = <EquipmentGuess>[];
  for (final (id, p) in model) {
    final e = guide.byId(id);
    if (e != null && guesses.every((g) => g.equipment.id != id)) guesses.add(EquipmentGuess(e, p));
  }
  final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  final plate = words <= _plateWords;
  final strong = plate ? equipmentFromText(text, guide) : null;
  if (strong != null) {
    final (e, label) = strong;
    final p = guesses.where((g) => g.equipment.id == e.id).firstOrNull?.confidence ?? 0;
    guesses
      ..removeWhere((g) => g.equipment.id == e.id)
      ..insert(0, EquipmentGuess(e, p, readLabel: label));
  } else {
    final weak = equipmentFromText(text, guide, strongOnly: false);
    if (weak != null) {
      final i = guesses.indexWhere((g) => g.equipment.id == weak.$1.id);
      if (i > 0) {
        final g = guesses.removeAt(i);
        guesses.insert(0, EquipmentGuess(g.equipment, g.confidence, readLabel: weak.$2));
      } else if (i == 0) {
        guesses[0] = EquipmentGuess(guesses[0].equipment, guesses[0].confidence, readLabel: weak.$2);
      }
    }
  }
  return EquipmentScan(guesses.take(limit).toList());
}
