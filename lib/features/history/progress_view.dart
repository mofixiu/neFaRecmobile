import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/training.dart';
import '../../core/providers.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/charts.dart';
import '../../shared/widgets/surfaces.dart';
import '../app/navigation.dart';
import '../settings/settings_controller.dart';
import '../workout/domain/session_models.dart';
import 'domain/analytics.dart';
import '../../shared/widgets/motion.dart';

const _monthShort = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// Training analytics from your logged sets: volume, consistency, where the
/// work went and how each main lift is moving.
class ProgressView extends ConsumerWidget {
  const ProgressView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.nefa;
    final sets = ref.watch(loggedSetsProvider).valueOrNull;
    final library = ref.watch(libraryByIdProvider).valueOrNull ?? const {};
    final unit = ref.watch(settingsProvider).unit;
    final bottom = MediaQuery.paddingOf(context).bottom + 120;
    final now = DateTime.now();

    if (sets == null) return const SizedBox(height: 200);
    if (sets.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(NefaSpace.gutter, 26, NefaSpace.gutter, 0),
        child: EmptyState(
          icon: Icons.insights_outlined,
          title: 'No progress to chart yet',
          body: 'Log a couple of workouts and your volume, consistency and best lifts appear here.',
          action: 'Paste a routine',
          onAction: () => openPaste(context),
        ),
      );
    }

    final weeks = weeklyTotals(sets, now: now);
    final streak = weekStreak(sets, now: now);
    final muscles = setsPerMuscle(
      sets,
      library,
      since: weekStart(now).subtract(const Duration(days: 21)),
    );
    final top = mostTrained(sets);
    String wk(DateTime d) => '${d.day} ${_monthShort[d.month - 1]}';

    return Padding(
      padding: EdgeInsets.fromLTRB(NefaSpace.gutter, 22, NefaSpace.gutter, bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BoardCard(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: Row(
              children: [
                _Stat(value: '$streak', label: streak == 1 ? 'week streak' : 'weeks streak'),
                _Stat(value: '${weeks.last.sessions}', label: 'this week'),
                _Stat(value: '${weeks.last.sets}', label: 'sets this week'),
              ],
            ),
          ),
          const SizedBox(height: NefaSpace.section),
          Text('Weekly volume', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            'Load × reps on completed sets, last 8 weeks. Tap a week.',
            style: NefaType.style(12.5, 500, color: c.muted),
          ),
          const SizedBox(height: 14),
          SheetCard(
            child: ColumnChart(
              values: [for (final w in weeks) fromKg(w.volumeKg, unit)],
              labels: [for (final w in weeks) '${w.start.day}/${w.start.month}'],
              format: (i) {
                final w = weeks[i];
                return 'Week of ${wk(w.start)} · ${fromKg(w.volumeKg, unit).round()} ${unit.name} · '
                    '${w.sessions} session${w.sessions == 1 ? '' : 's'}';
              },
            ),
          ),
          if (muscles.isNotEmpty) ...[
            const SizedBox(height: NefaSpace.section),
            Text('Where the work went', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(
              'Completed sets by main muscle, last 4 weeks.',
              style: NefaType.style(12.5, 500, color: c.muted),
            ),
            const SizedBox(height: 14),
            SheetCard(child: BarList(rows: muscles.take(8).toList())),
          ],
          if (top.isNotEmpty) ...[
            const SizedBox(height: NefaSpace.section),
            Text('Your main lifts', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 14),
            for (final (i, (id, name, count)) in top.indexed) ...[
              Rise(
                index: i,
                child: _LiftCard(id: id, name: name, sessions: count, sets: sets, unit: unit),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ],
      ),
    );
  }
}

class _LiftCard extends StatelessWidget {
  const _LiftCard({
    required this.id,
    required this.name,
    required this.sessions,
    required this.sets,
    required this.unit,
  });
  final String id;
  final String name;
  final int sessions;
  final List<LoggedSet> sets;
  final WeightUnit unit;

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    final trend = trendFor(sets, id);
    final kg = trend?.metric.contains('1RM') ?? false;
    final values = [
      for (final p in trend?.points ?? const <TrendPoint>[]) kg ? fromKg(p.value, unit) : p.value,
    ];
    final metric = kg ? 'Estimated 1RM (${unit.name})' : trend?.metric ?? '';
    return SheetCard(
      onTap: id.startsWith('custom_') ? null : () => openExercise(context, id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(name, style: Theme.of(context).textTheme.titleMedium)),
              Text(
                '$sessions session${sessions == 1 ? '' : 's'}',
                style: NefaType.style(12, 700, color: c.muted),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(metric.toUpperCase(), style: NefaType.eyebrow(color: c.muted, size: 9.5)),
          const SizedBox(height: 10),
          if (values.length < 2)
            Text(
              'One session so far. The trend appears after your next one.',
              style: NefaType.style(13, 500, color: c.muted),
            )
          else
            TrendChart(
              values: values,
              height: 90,
              readout: (i) {
                final p = trend!.points[i];
                return '${p.date.day} ${_monthShort[p.date.month - 1]} · ${values[i].toStringAsFixed(kg ? 1 : 0)}'
                    '${kg ? ' ${unit.name} (estimate)' : ''}';
              },
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
          CountText(value, style: NefaType.value(28, color: c.onBoard)),
          const SizedBox(height: 4),
          Text(label.toUpperCase(), style: NefaType.eyebrow(color: c.boardMuted, size: 9.5)),
        ],
      ),
    );
  }
}
