import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/import/domain/exercise_index.dart';
import '../features/library/domain/exercise_videos.dart';
import '../features/library/domain/library_data.dart';
import '../features/routines/data/routine_repository.dart';
import '../features/workout/data/session_repository.dart';
import '../features/workout/domain/session_models.dart';
import 'db/database.dart';
import 'services/alerts.dart';

/// Overridden in main and in tests.
final databaseProvider = Provider<NefaDatabase>((_) => throw UnimplementedError());
final alertsProvider = Provider<AlertService>((_) => AlertService());

/// The clock, so tests can move time.
final clockProvider = Provider<DateTime Function()>((_) => DateTime.now);

final routineRepositoryProvider = Provider((ref) => RoutineRepository(ref.watch(databaseProvider)));
final sessionRepositoryProvider = Provider((ref) => SessionRepository(ref.watch(databaseProvider)));

final libraryDataProvider = FutureProvider<LibraryData>((ref) async {
  final source = await rootBundle.loadString('assets/exercises/library.json');
  return LibraryData.parse(source);
});

final libraryByIdProvider = FutureProvider<Map<String, LibraryRecord>>((ref) async {
  final data = await ref.watch(libraryDataProvider.future);
  return {for (final r in data.records) r.id: r};
});

/// Bundled demo videos. Empty when the manifest is missing, so photos still work.
final exerciseVideosProvider = FutureProvider<ExerciseVideos>((ref) async {
  try {
    return ExerciseVideos.parse(await rootBundle.loadString('assets/exercises/videos/videos.json'));
  } catch (_) {
    return ExerciseVideos.empty;
  }
});

final videoByExerciseProvider = FutureProvider<Map<String, VideoClip>>((ref) async {
  return (await ref.watch(exerciseVideosProvider.future)).byExercise;
});

/// The bundled library, plus your custom exercises and the names you have
/// confirmed in earlier imports.
final exerciseIndexProvider = FutureProvider<ExerciseIndex>((ref) async {
  final data = await ref.watch(libraryDataProvider.future);
  final repo = ref.watch(routineRepositoryProvider);
  final custom = await repo.customExercises();
  final learned = await repo.learnedAliases();
  return ExerciseIndex(
    exercises: [
      ...data.records.map((r) => r.toIndexed()),
      for (final c in custom)
        IndexedExercise(id: c.id, name: c.name, equipment: c.equipment, timed: c.timed),
    ],
    aliases: {...data.aliases, ...learned},
  );
});

final routinesProvider = StreamProvider<List<RoutineSummary>>(
  (ref) => ref.watch(routineRepositoryProvider).watchRoutines(),
);

final routineProvider = StreamProvider.family<RoutineDetail?, int>(
  (ref, id) => ref.watch(routineRepositoryProvider).watchRoutine(id),
);

final activeSessionProvider = StreamProvider(
  (ref) => ref.watch(sessionRepositoryProvider).watchActive(),
);

final sessionProvider = StreamProvider.family<SessionDetail?, int>(
  (ref, id) => ref.watch(sessionRepositoryProvider).watchSession(id),
);

final historyProvider = StreamProvider<List<SessionSummary>>(
  (ref) => ref.watch(sessionRepositoryProvider).watchHistory(),
);

/// Last time's sets for an exercise, ignoring the session you are in.
/// Keyed by (exercise id, session to ignore, variant).
final previousProvider = FutureProvider.family<PreviousPerformance?, (String, int?, String?)>((
  ref,
  key,
) {
  // Re-read when history changes, e.g. after finishing a workout.
  ref.watch(historyProvider);
  return ref
      .watch(sessionRepositoryProvider)
      .previous(key.$1, excludeSession: key.$2, variant: key.$3);
});

/// Every completed set, for the Progress tab.
final loggedSetsProvider = FutureProvider<List<LoggedSet>>((ref) {
  ref.watch(historyProvider);
  return ref.watch(sessionRepositoryProvider).allLoggedSets();
});

final exerciseHistoryProvider = FutureProvider.family<List<(DateTime, SetLog)>, String>((ref, id) {
  ref.watch(historyProvider);
  return ref.watch(sessionRepositoryProvider).history(id);
});
