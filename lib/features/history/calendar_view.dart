import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/training.dart';
import '../../core/providers.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/controls.dart';
import '../../shared/widgets/surfaces.dart';
import '../app/navigation.dart';
import '../routines/data/routine_repository.dart';
import 'session_detail_screen.dart';

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

/// Every saved routine with its days, for scheduling.
final allRoutineDetailsProvider = FutureProvider<List<RoutineDetail>>((ref) async {
  final summaries = await ref.watch(routinesProvider.future);
  final repo = ref.watch(routineRepositoryProvider);
  final out = <RoutineDetail>[];
  for (final s in summaries) {
    final d = await repo.load(s.routine.id);
    if (d != null) out.add(d);
  }
  return out;
});

bool plannedOn(int weekdays, DateTime day) => weekdays & (1 << (day.weekday - 1)) != 0;

/// A month of training: filled = trained, ring = planned.
class CalendarView extends ConsumerStatefulWidget {
  const CalendarView({super.key});

  @override
  ConsumerState<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends ConsumerState<CalendarView> {
  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  late DateTime _day = DateUtils.dateOnly(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    final history = ref.watch(historyProvider).valueOrNull ?? const [];
    final routines = ref.watch(allRoutineDetailsProvider).valueOrNull ?? const [];
    final today = DateUtils.dateOnly(DateTime.now());
    final bottom = MediaQuery.paddingOf(context).bottom + 120;

    final trained = <DateTime>{for (final h in history) DateUtils.dateOnly(h.session.startedAt)};
    List<(RoutineDetail, DayPlan)> plannedFor(DateTime d) => [
      for (final r in routines)
        for (final day in r.days)
          if (plannedOn(day.day.weekdays, d)) (r, day),
    ];

    final first = DateTime(_month.year, _month.month);
    final daysInMonth = DateUtils.getDaysInMonth(_month.year, _month.month);
    final lead = first.weekday - 1;
    final cells = lead + daysInMonth;
    final sessionsToday = history
        .where((h) => DateUtils.isSameDay(h.session.startedAt, _day))
        .toList();
    final planned = plannedFor(_day);
    final anyPlan = routines.any((r) => r.days.any((d) => d.day.weekdays != 0));

    return Padding(
      padding: EdgeInsets.fromLTRB(NefaSpace.gutter, 22, NefaSpace.gutter, bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SheetCard(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
            child: Column(
              children: [
                Row(
                  children: [
                    RoundIconButton(
                      icon: Icons.chevron_left_rounded,
                      label: 'Previous month',
                      onPressed: () =>
                          setState(() => _month = DateTime(_month.year, _month.month - 1)),
                    ),
                    Expanded(
                      child: Text(
                        '${_months[_month.month - 1]} ${_month.year}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    RoundIconButton(
                      icon: Icons.chevron_right_rounded,
                      label: 'Next month',
                      onPressed: () =>
                          setState(() => _month = DateTime(_month.year, _month.month + 1)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    for (final d in 'MTWTFSS'.split(''))
                      Expanded(
                        child: Center(
                          child: Text(d, style: NefaType.style(11, 800, color: c.faint)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
                  itemCount: (cells / 7).ceil() * 7,
                  itemBuilder: (context, i) {
                    final dayNum = i - lead + 1;
                    if (dayNum < 1 || dayNum > daysInMonth) return const SizedBox();
                    final d = DateTime(_month.year, _month.month, dayNum);
                    final did = trained.contains(d);
                    final plan = !did && !d.isBefore(today) && plannedFor(d).isNotEmpty;
                    final sel = DateUtils.isSameDay(d, _day);
                    return GestureDetector(
                      onTap: () => setState(() => _day = d),
                      child: Semantics(
                        button: true,
                        selected: sel,
                        label:
                            '$dayNum ${_months[d.month - 1]}${did
                                ? ', trained'
                                : plan
                                ? ', planned'
                                : ''}',
                        child: Center(
                          child: AnimatedContainer(
                            duration: NefaMotion.small,
                            width: 38,
                            height: 38,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: did
                                  ? c.accent
                                  : sel
                                  ? c.recessed
                                  : Colors.transparent,
                              border: Border.all(
                                color: sel
                                    ? c.ink
                                    : plan
                                    ? c.accent
                                    : DateUtils.isSameDay(d, today)
                                    ? c.faint
                                    : Colors.transparent,
                                width: sel || plan ? 1.6 : 1,
                              ),
                            ),
                            child: Text(
                              '$dayNum',
                              style: NefaType.style(
                                13,
                                did || sel ? 800 : 600,
                                color: did ? c.onAccent : c.ink,
                                tabular: true,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Key(fill: c.accent, label: 'Trained'),
                    const SizedBox(width: 18),
                    _Key(ring: c.accent, label: 'Planned'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text(
            '${_day.day} ${_months[_day.month - 1]}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          for (final h in sessionsToday) ...[
            SheetCard(
              onTap: () => push(context, SessionDetailScreen(sessionId: h.session.id)),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: c.accent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(h.session.title, style: Theme.of(context).textTheme.titleMedium),
                  ),
                  Text(
                    '${formatClock(h.duration)} · ${h.doneSets} sets',
                    style: NefaType.style(12.5, 600, color: c.muted, tabular: true),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
          if (!_day.isBefore(today))
            for (final (r, day) in planned) ...[
              SheetCard(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Icon(Icons.event_rounded, color: c.accentInk),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(day.day.name, style: Theme.of(context).textTheme.titleMedium),
                          Text(r.routine.name, style: NefaType.style(12.5, 600, color: c.muted)),
                        ],
                      ),
                    ),
                    if (DateUtils.isSameDay(_day, today))
                      Pill(
                        label: 'Start',
                        icon: Icons.play_arrow_rounded,
                        selected: true,
                        onTap: () => startWorkout(context, ref, r, day),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          if (sessionsToday.isEmpty && (planned.isEmpty || _day.isBefore(today)))
            Text(
              anyPlan
                  ? 'Nothing logged or planned for this day.'
                  : 'Nothing logged. Plan days from a routine: open it and tap “Plan days”.',
              style: NefaType.style(13.5, 500, color: c.muted, height: 1.45),
            ),
        ],
      ),
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({this.fill, this.ring, required this.label});
  final Color? fill;
  final Color? ring;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: fill,
            border: ring == null ? null : Border.all(color: ring!, width: 1.6),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: NefaType.style(12, 700, color: c.muted)),
      ],
    );
  }
}
