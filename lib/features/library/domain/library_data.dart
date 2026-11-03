import 'dart:convert';

import '../../import/domain/exercise_index.dart';

/// One record from `assets/exercises/library.json`.
class LibraryRecord {
  const LibraryRecord({
    required this.id,
    required this.name,
    required this.category,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    required this.instructions,
    required this.images,
    required this.timed,
    required this.curated,
    this.equipment,
    this.level,
    this.mechanic,
    this.force,
  });

  factory LibraryRecord.fromJson(Map<String, dynamic> j) => LibraryRecord(
    id: j['id'] as String,
    name: j['name'] as String,
    category: j['category'] as String? ?? 'strength',
    equipment: j['equipment'] as String?,
    level: j['level'] as String?,
    mechanic: j['mechanic'] as String?,
    force: j['force'] as String?,
    primaryMuscles: List<String>.from(j['primaryMuscles'] as List? ?? []),
    secondaryMuscles: List<String>.from(j['secondaryMuscles'] as List? ?? []),
    instructions: List<String>.from(j['instructions'] as List? ?? []),
    images: List<String>.from(j['images'] as List? ?? []),
    timed: j['tracking'] == 'duration',
    curated: j['curated'] == true,
  );

  final String id;
  final String name;
  final String category;
  final String? equipment;
  final String? level;
  final String? mechanic;
  final String? force;
  final List<String> primaryMuscles;
  final List<String> secondaryMuscles;
  final List<String> instructions;
  final List<String> images;
  final bool timed;
  final bool curated;

  IndexedExercise toIndexed() =>
      IndexedExercise(id: id, name: name, equipment: equipment, curated: curated, timed: timed);
}

class LibraryData {
  const LibraryData(this.records, this.aliases);

  factory LibraryData.parse(String source) {
    final json = jsonDecode(source) as Map<String, dynamic>;
    final records = [
      for (final e in json['exercises'] as List) LibraryRecord.fromJson(e as Map<String, dynamic>),
    ];
    return LibraryData(records, Map<String, String>.from(json['aliases'] as Map));
  }

  final List<LibraryRecord> records;
  final Map<String, String> aliases;

  ExerciseIndex buildIndex() =>
      ExerciseIndex(exercises: records.map((r) => r.toIndexed()), aliases: aliases);
}

/// Bundled demo frames live flat as `assets/exercises/demos/<id>__<n>.jpg`.
/// Only curated lifts ship images; others fall back to a cue card.
String? bundledDemoAsset(String exerciseId, int frame, {required bool curated}) {
  if (!curated || exerciseId.startsWith('nefa_')) return null;
  return 'assets/exercises/demos/${exerciseId}__$frame.jpg';
}
