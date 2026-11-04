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

const _weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

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

/// A month of training: solid orange = trained (streaks joined), a small
/// dot = planned, ink = today.
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
    final rows = ((lead + daysInMonth) / 7).ceil();
    // The grid starts on the Monday before the 1st, so the edges show the
    // neighbouring months' days, faint, instead of blank squares.
    final gridStart = first.subtract(Duration(days: lead));
    final sessionsToday = history
        .where((h) => DateUtils.isSameDay(h.session.startedAt, _day))
        .toList();
    final planned = plannedFor(_day);
    final anyPlan = routines.any((r) => r.days.any((d) => d.day.weekdays != 0));

    bool inMonth(DateTime d) => d.month == _month.month && d.year == _month.year;
    final trainedThisMonth = history.where((h) => inMonth(h.session.startedAt)).length;
    final plannedLeft = [
      for (var n = 1; n <= daysInMonth; n++) DateTime(_month.year, _month.month, n),
    ].where((d) => !d.isBefore(today) && !trained.contains(d) && plannedFor(d).isNotEmpty).length;

    return Padding(
      padding: EdgeInsets.fromLTRB(NefaSpace.gutter, 22, NefaSpace.gutter, bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SheetCard(
            padding: const EdgeInsets.fromLTRB(16, 16, 10, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: _months[_month.month - 1],
                                  style: NefaType.style(24, 900, tracking: -.8, color: c.ink),
                                ),
                                TextSpan(
                                  text: '  ${_month.year}',
                                  style: NefaType.style(15, 700, color: c.faint),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          // The summary doubles as the legend.
                          Row(
                            children: [
                              _Dot(color: c.accent, size: 8),
                              const SizedBox(width: 6),
                              Text(
                                plural(trainedThisMonth, 'session'),
                                style: NefaType.style(12.5, 700, color: c.ink, tabular: true),
                              ),
                              if (plannedLeft > 0) ...[
                                const SizedBox(width: 14),
                                _Dot(color: c.accent, size: 5),
                                const SizedBox(width: 6),
                                Text(
                                  '$plannedLeft planned',
                                  style: NefaType.style(12.5, 600, color: c.muted, tabular: true),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    RoundIconButton(
                      icon: Icons.chevron_left_rounded,
                      label: 'Previous month',
                      size: 38,
                      onPressed: () =>
                          setState(() => _month = DateTime(_month.year, _month.month - 1)),
                    ),
                    RoundIconButton(
                      icon: Icons.chevron_right_rounded,
                      label: 'Next month',
                      size: 38,
                      onPressed: () =>
                          setState(() => _month = DateTime(_month.year, _month.month + 1)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          for (final d in const ['M', 'T', 'W', 'T', 'F', 'S', 'S'])
                            Expanded(
                              child: Center(
                                child: Text(d, style: NefaType.style(11.5, 700, color: c.faint)),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      for (var r = 0; r < rows; r++)
                        Row(
                          children: [
                            for (var col = 0; col < 7; col++)
                              Expanded(
                                child: Builder(
                                  builder: (context) {
                                    final d = DateUtils.addDaysToDate(gridStart, r * 7 + col);
                                    final mine = inMonth(d);
                                    final did = mine && trained.contains(d);
                                    return _DayCell(
                                      day: d,
                                      inMonth: mine,
                                      trained: did,
                                      // Join back-to-back training days into a streak.
                                      joinLeft:
                                          did &&
                                          col > 0 &&
                                          trained.contains(DateUtils.addDaysToDate(d, -1)) &&
                                          inMonth(DateUtils.addDaysToDate(d, -1)),
                                      joinRight:
                                          did &&
                                          col < 6 &&
                                          trained.contains(DateUtils.addDaysToDate(d, 1)) &&
                                          inMonth(DateUtils.addDaysToDate(d, 1)),
                                      planned:
                                          mine &&
                                          !did &&
                                          !d.isBefore(today) &&
                                          plannedFor(d).isNotEmpty,
                                      today: DateUtils.isSameDay(d, today),
                                      selected: mine && DateUtils.isSameDay(d, _day),
                                      onTap: mine ? () => setState(() => _day = d) : null,
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Eyebrow(DateUtils.isSameDay(_day, today) ? 'Today' : _weekdays[_day.weekday - 1]),
          const SizedBox(height: 4),
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
                    '${formatClock(h.duration)} · ${plural(h.doneSets, 'set')}',
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

class _Dot extends StatelessWidget {
  const _Dot({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.inMonth,
    required this.trained,
    required this.joinLeft,
    required this.joinRight,
    required this.planned,
    required this.today,
    required this.selected,
    required this.onTap,
  });

  final DateTime day;
  final bool inMonth;
  final bool trained;
  final bool joinLeft;
  final bool joinRight;
  final bool planned;
  final bool today;
  final bool selected;
  final VoidCallback? onTap;

  static const _size = 38.0;

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    final fill = trained
        ? c.accent
        : today && inMonth
        ? c.ink
        : Colors.transparent;
    final ink = !inMonth
        ? c.faint.withValues(alpha: .45)
        : trained
        ? c.onAccent
        : today
        ? c.paper
        : c.ink;
    final band = Expanded(
      child: Container(height: _size, color: c.accent),
    );
    final gap = const Expanded(child: SizedBox());

    return Semantics(
      button: onTap != null,
      selected: selected,
      label:
          '${day.day} ${_months[day.month - 1]}'
          '${trained
              ? ', trained'
              : planned
              ? ', planned'
              : ''}${today ? ', today' : ''}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          height: 48,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // The streak band runs edge to edge behind joined days.
              // Slightly wider than the cell so neighbouring bands meet without a seam.
              if (joinLeft || joinRight)
                Transform.scale(
                  scaleX: 1.04,
                  child: Row(children: [joinLeft ? band : gap, joinRight ? band : gap]),
                ),
              AnimatedContainer(
                duration: NefaMotion.small,
                width: _size,
                height: _size,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
                foregroundDecoration: selected
                    ? BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: trained || today ? c.paper : c.ink,
                          width: trained || today ? 2.5 : 1.6,
                        ),
                      )
                    : null,
                child: Text(
                  '${day.day}',
                  style: NefaType.style(
                    14,
                    trained || today || selected ? 800 : 600,
                    color: ink,
                    tabular: true,
                  ),
                ),
              ),
              if (planned) Positioned(bottom: 3, child: _Dot(color: c.accent, size: 5)),
            ],
          ),
        ),
      ),
    );
  }
}
