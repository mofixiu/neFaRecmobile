import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../import/ui/paste_screen.dart';
import '../library/ui/exercise_detail_screen.dart';
import '../routines/data/routine_repository.dart';
import '../routines/ui/routine_detail_screen.dart';
import '../workout/ui/workout_screen.dart';
import '../../shared/widgets/dialog.dart';

/// The selected root tab.
final shellTabProvider = StateProvider<int>((_) => 0);

Future<T?> push<T>(BuildContext context, Widget screen, {bool fullscreen = false}) => Navigator.of(
  context,
).push<T>(MaterialPageRoute(builder: (_) => screen, fullscreenDialog: fullscreen));

void openPaste(BuildContext context) => push(context, const PasteScreen(), fullscreen: true);

void openRoutine(BuildContext context, int id) => push(context, RoutineDetailScreen(routineId: id));

void openExercise(BuildContext context, String id) =>
    push(context, ExerciseDetailScreen(exerciseId: id));

void openWorkout(BuildContext context, int sessionId) =>
    push(context, WorkoutScreen(sessionId: sessionId), fullscreen: true);

/// Starts (or resumes) a session for a day and opens it.
Future<void> startWorkout(
  BuildContext context,
  WidgetRef ref,
  RoutineDetail routine,
  DayPlan day,
) async {
  final active = ref.read(activeSessionProvider).valueOrNull;
  if (active != null && active.dayId != day.day.id) {
    final go = await showConfirm(
      context,
      title: 'A workout is already running',
      body:
          'Finish or discard “${active.title}” before starting another. Your sets so far are saved.',
      confirm: 'Open ${active.title}',
      cancel: 'Not now',
      icon: Icons.fitness_center_rounded,
    );
    if (go && context.mounted) openWorkout(context, active.id);
    return;
  }
  final id = await ref.read(sessionRepositoryProvider).start(routine, day);
  if (context.mounted) openWorkout(context, id);
}
