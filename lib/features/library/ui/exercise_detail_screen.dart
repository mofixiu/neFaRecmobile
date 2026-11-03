import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/training.dart';
import '../../../core/providers.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/controls.dart';
import '../../../shared/widgets/surfaces.dart';
import '../../settings/settings_controller.dart';
import '../../workout/domain/session_models.dart';
import '../../../shared/widgets/charts.dart';
import '../../formcheck/form_check_screen.dart';
import '../../history/domain/analytics.dart';
import 'exercise_demo.dart';
import '../../../shared/widgets/motion.dart';

class ExerciseDetailScreen extends ConsumerWidget {
  const ExerciseDetailScreen({super.key, required this.exerciseId});
  final String exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.nefa;
    final record = ref.watch(libraryByIdProvider).valueOrNull?[exerciseId];
    final history = ref.watch(exerciseHistoryProvider(exerciseId)).valueOrNull ?? const [];
    final unit = ref.watch(settingsProvider).unit;
    if (record == null) return const PaperScaffold(body: PageBar());

    final done = history.map((h) => h.$2).toList();
    final heaviest = done
        .where((s) => s.weight != null && s.weight! > 0)
        .fold<double>(0, (m, s) => toKg(s.weight!, s.unit) > m ? toKg(s.weight!, s.unit) : m);
    final e1rm = done.fold<double>(0, (m, s) => (s.e1rmKg ?? 0) > m ? s.e1rmKg! : m);
    final longest = done.fold<int>(
      0,
      (m, s) => (s.durationSeconds ?? 0) > m ? s.durationSeconds! : m,
    );
    final sessions = history.map((h) => h.$1).toSet().length;
    final logged = ref.watch(loggedSetsProvider).valueOrNull ?? const [];
    final trend = trendFor(logged, exerciseId);
    final trendKg = trend?.metric.contains('1RM') ?? false;
    final trendValues = [
      for (final p in trend?.points ?? const <TrendPoint>[])
        trendKg ? fromKg(p.value, unit) : p.value,
    ];
    final trendLabel = trendKg
        ? 'Best estimated 1RM per session (${unit.name}). An estimate, not a tested max.'
        : trend?.metric ?? '';

    return PaperScaffold(
      body: Column(
        children: [
          const PageBar(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                NefaSpace.gutter,
                0,
                NefaSpace.gutter,
                MediaQuery.paddingOf(context).bottom + 24,
              ),
              children: [
                ExerciseDemo(exerciseId: record.id, name: record.name, height: 240),
                const SizedBox(height: 20),
                Eyebrow([record.category, if (record.level != null) record.level!].join(' · ')),
                const SizedBox(height: 8),
                Text(record.name, style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (record.equipment != null)
                      Pill(
                        label: record.equipment!,
                        icon: Icons.fitness_center_rounded,
                        background: c.sheet,
                      ),
                    for (final m in record.primaryMuscles) Pill(label: m, selected: true),
                    for (final m in record.secondaryMuscles) Pill(label: m, background: c.sheet),
                  ],
                ),
                if (done.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  BoardCard(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                    child: Row(
                      children: [
                        _Stat(value: '$sessions', label: 'sessions'),
                        if (longest > 0 && heaviest == 0)
                          _Stat(
                            value: formatClock(Duration(seconds: longest)),
                            label: 'longest',
                          )
                        else ...[
                          _Stat(
                            value: heaviest == 0
                                ? '—'
                                : fromKg(heaviest, unit).toStringAsFixed(heaviest % 1 == 0 ? 0 : 1),
                            label: 'best ${unit.name}',
                          ),
                          _Stat(
                            value: e1rm == 0 ? '—' : fromKg(e1rm, unit).round().toString(),
                            label: 'est. 1RM',
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                if (formCheckSupported(record.id)) ...[
                  const SizedBox(height: 16),
                  NefaButton(
                    label: 'Form check (beta)',
                    icon: Icons.videocam_outlined,
                    tone: ButtonTone.ghost,
                    onPressed: () => openFormCheck(context, exerciseName: record.name),
                  ),
                ],
                if (trend != null && trend.points.length >= 2) ...[
                  const SizedBox(height: 26),
                  Text('Trend', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 4),
                  Text(trendLabel, style: NefaType.style(12.5, 500, color: c.muted)),
                  const SizedBox(height: 12),
                  SheetCard(
                    child: TrendChart(
                      values: trendValues,
                      readout: (i) {
                        final p = trend.points[i];
                        return '${p.date.day}/${p.date.month}/${p.date.year} · '
                            '${trendValues[i].toStringAsFixed(trendKg ? 1 : 0)}${trendKg ? ' ${unit.name}' : ''}';
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 26),
                Text('How to do it', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 14),
                for (final (i, step) in record.instructions.indexed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: c.board, shape: BoxShape.circle),
                          child: Text('${i + 1}', style: NefaType.style(12, 900, color: c.onBoard)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            step,
                            style: NefaType.style(14.5, 500, height: 1.55, color: c.ink),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 6),
                Notice(
                  text:
                      'General cues, not the one correct form for every body. Stop if something hurts.',
                ),
                const SizedBox(height: 18),
                Text(
                  'Exercise data: free-exercise-db (public domain).',
                  style: NefaType.style(11.5, 500, color: c.faint),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CountText(value, style: NefaType.value(26, color: c.onBoard)),
          const SizedBox(height: 4),
          Text(label.toUpperCase(), style: NefaType.eyebrow(color: c.boardMuted, size: 9.5)),
        ],
      ),
    );
  }
}
