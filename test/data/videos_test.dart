import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nefarec/features/library/domain/exercise_videos.dart';
import 'package:nefarec/features/library/domain/library_data.dart';

void main() {
  final videos = ExerciseVideos.parse(
    File('assets/exercises/videos/videos.json').readAsStringSync(),
  );
  final library = LibraryData.parse(File('assets/exercises/library.json').readAsStringSync());
  final ids = {for (final r in library.records) r.id};

  test('every clip is bundled, credited and points at real exercises', () {
    expect(videos.clips, isNotEmpty);
    for (final clip in videos.clips) {
      expect(File(clip.asset).existsSync(), isTrue, reason: clip.file);
      expect(clip.author, isNotEmpty, reason: clip.file);
      expect(clip.license, 'CC BY-SA 4.0');
      expect(clip.source, startsWith('https://wger.de/'));
      for (final id in clip.ids) {
        expect(ids, contains(id), reason: '${clip.file} -> $id');
      }
    }
  });

  test('no exercise gets two clips', () {
    final all = [for (final c in videos.clips) ...c.ids];
    expect(all.toSet().length, all.length);
    expect(videos.byExercise['Barbell_Bench_Press_-_Medium_Grip']?.file, 'wger_73.mp4');
  });

  test('bundled clips stay small', () {
    final total = videos.clips.fold<int>(0, (n, c) => n + File(c.asset).lengthSync());
    expect(total, lessThan(30 * 1024 * 1024));
  });
}
