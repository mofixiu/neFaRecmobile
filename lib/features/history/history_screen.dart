import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/training.dart';
import '../../core/providers.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/controls.dart';
import '../../shared/widgets/surfaces.dart';
import '../app/navigation.dart';
import '../settings/settings_controller.dart';
import '../workout/domain/session_models.dart';
import 'calendar_view.dart';
import 'progress_view.dart';
import 'session_detail_screen.dart';
import '../../shared/widgets/motion.dart';

const _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

enum HistoryView { sessions, progress, calendar }

final historyViewProvider = StateProvider<HistoryView>((_) => HistoryView.sessions);

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(historyViewProvider);
    final history = ref.watch(historyProvider).valueOrNull ?? const [];
    final unit = ref.watch(settingsProvider).unit;
    final bottom = MediaQuery.paddingOf(context).bottom + 120;

    final groups = <String, List<SessionSummary>>{};
    for (final h in history) {
      final d = h.session.startedAt;
      groups.putIfAbsent('${_months[d.month - 1]} ${d.year}', () => []).add(h);
    }
    final totalSets = history.fold(0, (n, h) => n + h.doneSets);
    final totalVolume = history.fold(0.0, (v, h) => v + h.volumeKg);

    return CustomScrollView(
      slivers: [
        SliverSafeArea(
          bottom: false,
          sliver: SliverPadding(
            padding: const EdgeInsets.fromLTRB(NefaSpace.gutter, 24, NefaSpace.gutter, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const PageTitle('History', subtitle: 'Every session, as it happened.'),
                  const SizedBox(height: 20),
                  Segmented<HistoryView>(
                    values: HistoryView.values,
                    value: view,
                    labelOf: (v) => switch (v) {
                      HistoryView.sessions => 'Sessions',
                      HistoryView.progress => 'Progress',
                      HistoryView.calendar => 'Calendar',
                    },
                    onChanged: (v) => ref.read(historyViewProvider.notifier).state = v,
                  ),
                  if (history.isNotEmpty && view == HistoryView.sessions) ...[
                    const SizedBox(height: 22),
                    BoardCard(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                      child: Row(
                        children: [
                          _Stat(value: '${history.length}', label: 'sessions'),
                          _Stat(value: '$totalSets', label: 'sets'),
                          _Stat(
                            value: fromKg(totalVolume, unit) >= 10000
                                ? '${(fromKg(totalVolume, unit) / 1000).toStringAsFixed(1)}k'
                                : '${fromKg(totalVolume, unit).round()}',
                            label: '${unit.name} moved',
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        if (view == HistoryView.progress)
          const SliverToBoxAdapter(child: ProgressView())
        else if (view == HistoryView.calendar)
          const SliverToBoxAdapter(child: CalendarView())
        else if (history.isEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(NefaSpace.gutter, 26, NefaSpace.gutter, 0),
            sliver: SliverToBoxAdapter(
              child: EmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'Nothing logged yet',
                body: 'Finish a workout and it prints here as a receipt, with every set you did.',
                action: 'Paste a routine',
                onAction: () => openPaste(context),
              ),
            ),
          ),
        if (view == HistoryView.sessions)
          for (final entry in groups.entries) ...[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(NefaSpace.gutter, 28, NefaSpace.gutter, 10),
              sliver: SliverToBoxAdapter(
                child: Text(entry.key, style: Theme.of(context).textTheme.headlineSmall),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: NefaSpace.gutter),
              sliver: SliverList.separated(
                itemCount: entry.value.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) => Rise(
                  index: i,
                  child: _SessionRow(summary: entry.value[i], unit: unit),
                ),
              ),
            ),
          ],
        SliverToBoxAdapter(child: SizedBox(height: bottom)),
      ],
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

class _SessionRow extends StatelessWidget {
  const _SessionRow({required this.summary, required this.unit});
  final SessionSummary summary;
  final WeightUnit unit;

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    final s = summary.session;
    const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    final volume = fromKg(summary.volumeKg, unit);
    return SheetCard(
      onTap: () => push(context, SessionDetailScreen(sessionId: s.id)),
      semanticLabel: 'Open ${s.title}',
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 56,
            decoration: BoxDecoration(
              color: c.recessed,
              borderRadius: BorderRadius.circular(NefaRadii.md - 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  days[s.startedAt.weekday - 1],
                  style: NefaType.eyebrow(color: c.accentInk, size: 9),
                ),
                const SizedBox(height: 2),
                Text('${s.startedAt.day}', style: NefaType.value(21, color: c.ink)),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  [
                    formatClock(summary.duration),
                    '${summary.exerciseCount} exercises',
                    '${summary.doneSets} sets',
                    if (volume > 0) '${volume.round()} ${unit.name}',
                  ].join(' · '),
                  style: NefaType.style(12.5, 600, color: c.muted, tabular: true),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: c.muted),
        ],
      ),
    );
  }
}
