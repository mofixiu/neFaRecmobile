import 'dart:convert';

/// One bundled demo video from `assets/exercises/videos/videos.json`.
/// The clips come from wger.de under CC BY-SA 4.0, so each carries its credit.
class VideoClip {
  const VideoClip({
    required this.file,
    required this.ids,
    required this.title,
    required this.author,
    required this.license,
    required this.licenseUrl,
    required this.source,
    required this.changes,
  });

  factory VideoClip.fromJson(Map<String, dynamic> j) => VideoClip(
    file: j['file'] as String,
    ids: List<String>.from(j['ids'] as List),
    title: j['title'] as String? ?? '',
    author: j['author'] as String,
    license: j['license'] as String,
    licenseUrl: j['licenseUrl'] as String,
    source: j['source'] as String,
    changes: j['changes'] as String? ?? '',
  );

  final String file;

  /// The library exercises this clip demonstrates.
  final List<String> ids;
  final String title;
  final String author;
  final String license;
  final String licenseUrl;
  final String source;
  final String changes;

  String get asset => 'assets/exercises/videos/$file';

  /// The short credit shown on the video itself.
  String get credit => '$author · $license';
}

class ExerciseVideos {
  const ExerciseVideos(this.clips);

  factory ExerciseVideos.parse(String source) {
    final json = jsonDecode(source) as Map<String, dynamic>;
    return ExerciseVideos([
      for (final c in json['clips'] as List) VideoClip.fromJson(c as Map<String, dynamic>),
    ]);
  }

  static const empty = ExerciseVideos([]);

  final List<VideoClip> clips;

  /// Library id to its clip.
  Map<String, VideoClip> get byExercise => {
    for (final c in clips)
      for (final id in c.ids) id: c,
  };
}
