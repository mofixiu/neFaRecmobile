import 'library_data.dart';

/// Equipment groups you can tell neFaRec you have.
const equipmentGroups = <String, List<String?>>{
  'Bodyweight': ['body only', null],
  'Dumbbells': ['dumbbell'],
  'Barbell': ['barbell', 'e-z curl bar'],
  'Cables': ['cable'],
  'Machines': ['machine'],
  'Kettlebells': ['kettlebells'],
  'Bands': ['bands'],
  'Other': ['other', 'medicine ball', 'exercise ball', 'foam roll'],
};

bool _available(LibraryRecord r, Set<String> groups) {
  if (groups.isEmpty) return true;
  for (final g in groups) {
    if (equipmentGroups[g]?.contains(r.equipment) ?? false) return true;
  }
  return false;
}

/// Movements that train the same thing as [original] with the equipment you
/// have. Ranked by how closely they match: same primary muscle first, then
/// the same push/pull pattern, compound vs isolation, category and level.
List<LibraryRecord> alternativesFor(
  LibraryRecord original,
  Iterable<LibraryRecord> library, {
  Set<String> equipment = const {},
  int limit = 20,
}) {
  final primary = original.primaryMuscles.toSet();
  if (primary.isEmpty) return const [];
  final scored = <(LibraryRecord, double)>[];
  for (final r in library) {
    if (r.id == original.id) continue;
    if (r.category == 'stretching' ||
        r.category != original.category && original.category != 'strength') {
      continue;
    }
    if (!r.primaryMuscles.any(primary.contains)) continue;
    if (!_available(r, equipment)) continue;
    var score = 3.0;
    if (r.primaryMuscles.first == original.primaryMuscles.first) score += 2;
    if (r.force != null && r.force == original.force) score += 1.5;
    if (r.mechanic != null && r.mechanic == original.mechanic) score += 1;
    if (r.category == original.category) score += .5;
    if (r.level == original.level) score += .3;
    if (r.curated) score += .8;
    if (r.timed == original.timed) score += 1;
    final shared = r.secondaryMuscles
        .toSet()
        .intersection(original.secondaryMuscles.toSet())
        .length;
    score += shared * .2;
    scored.add((r, score));
  }
  scored.sort((a, b) => b.$2.compareTo(a.$2));
  return scored.take(limit).map((e) => e.$1).toList();
}
