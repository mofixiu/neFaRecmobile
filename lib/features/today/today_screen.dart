import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paper_kit/paper_kit.dart';

import '../../core/models/training.dart';
import '../../core/providers.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/controls.dart';
import '../../shared/widgets/surfaces.dart';
import '../../shared/widgets/wordmark.dart';
import '../app/navigation.dart';
import '../history/calendar_view.dart';
import '../history/session_detail_screen.dart';
import '../routines/data/routine_repository.dart';
import '../settings/settings_controller.dart';
import '../account/state/account_controller.dart';
import '../account/ui/account_screen.dart';
import '../settings/settings_screen.dart';
import '../workout/domain/session_models.dart';
import '../workout/ui/scoreboard.dart';
import '../../shared/widgets/motion.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routines = ref.watch(routinesProvider).valueOrNull ?? const [];
    final history = ref.watch(historyProvider).valueOrNull ?? const [];
    final active = ref.watch(activeSessionProvider).valueOrNull;
    final bottom = MediaQuery.paddingOf(context).bottom + 120;

    return CustomScrollView(
      slivers: [
        SliverSafeArea(
          bottom: false,
          sliver: SliverPadding(
            padding: const EdgeInsets.fromLTRB(NefaSpace.gutter, 8, NefaSpace.gutter, 0),
            sliver: SliverToBoxAdapter(
              child: SizedBox(
                height: 52,
                child: Row(
                  children: [
                    const NefaLogo(size: 24),
                    const Spacer(),
                    RoundIconButton(
                      icon: Icons.content_paste_go_rounded,
                      label: 'Paste a routine',
                      onPressed: () => openPaste(context),
                    ),
                    RoundIconButton(
                      icon: Icons.tune_rounded,
                      label: 'Settings',
                      onPressed: () => push(context, const SettingsScreen()),
                    ),
                    const SizedBox(width: 4),
                    const _AvatarButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(NefaSpace.gutter, 18, NefaSpace.gutter, bottom),
          sliver: SliverList.list(
            children: _stagger([
              _Greeting(),
              const SizedBox(height: 22),
              if (active != null)
                _ActiveHero(sessionId: active.id)
              else if (routines.isNotEmpty)
                _UpNextHero(summary: routines.first, history: history)
              else
                const _FirstRunHero(),
              const SizedBox(height: NefaSpace.section),
              _WeekStrip(history: history),
              if (history.isNotEmpty) ...[
                const SizedBox(height: NefaSpace.section),
                SectionHeader(
                  'Last session',
                  action: 'All',
                  onAction: () => ref.read(shellTabProvider.notifier).state = 2,
                ),
                const SizedBox(height: 12),
                _LastSession(summary: history.first),
              ],
            ]),
          ),
        ),
      ],
    );
  }

  static List<Widget> _stagger(List<Widget> children) {
    var i = 0;
    return [
      for (final child in children) child is SizedBox ? child : _Rise(index: i++, child: child),
    ];
  }
}

/// Fade and rise into place, staggered, once.
class _Rise extends StatefulWidget {
  const _Rise({required this.index, required this.child});
  final int index;
  final Widget child;

  @override
  State<_Rise> createState() => _RiseState();
}

class _RiseState extends State<_Rise> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: NefaMotion.rise);

  @override
  void initState() {
    super.initState();
    Future.delayed(NefaMotion.stagger * widget.index.clamp(0, 6), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;
    return PaperFadeUpTransition(animation: _c, child: widget.child);
  }
}

class _Greeting extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(accountProvider.select((a) => a.profile.firstName));
    final now = DateTime.now();
    final part = now.hour < 5
        ? 'Late one'
        : now.hour < 12
        ? 'Morning'
        : now.hour < 17
        ? 'Afternoon'
        : 'Evening';
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = [
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
    final c = context.nefa;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Eyebrow('${days[now.weekday - 1]} ${now.day} ${months[now.month - 1]}'),
        const SizedBox(height: 8),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: name.isEmpty ? '$part.\n' : '$part, $name.\n'),
              TextSpan(
                text: 'Ready to lift?',
                style: TextStyle(color: c.muted),
              ),
            ],
          ),
          style: Theme.of(context).textTheme.displayMedium,
        ),
      ],
    );
  }
}

class _ActiveHero extends ConsumerWidget {
  const _ActiveHero({required this.sessionId});
  final int sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.nefa;
    final detail = ref.watch(sessionProvider(sessionId)).valueOrNull;
    if (detail == null) return const SizedBox(height: 220);
    final current = detail.exercises.isEmpty ? null : detail.exercises[detail.currentIndex];
    return BoardCard(
      onTap: () => openWorkout(context, sessionId),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('WORKOUT IN PROGRESS', style: NefaType.eyebrow(color: c.boardMuted)),
              ),
              ElapsedText(
                since: detail.session.startedAt,
                style: NefaType.style(14, 800, color: c.onBoard, tabular: true),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            detail.session.title,
            style: NefaType.style(34, 900, height: 1, tracking: -1.4, color: c.onBoard),
          ),
          const SizedBox(height: 8),
          if (current != null)
            Text(
              'Up now · ${current.exercise.name}',
              style: NefaType.style(14, 600, color: c.boardMuted),
            ),
          const SizedBox(height: 18),
          _ProgressRail(done: detail.doneSets, total: detail.totalSets),
          const SizedBox(height: 18),
          NefaButton(
            label: 'Back to workout',
            icon: Icons.play_arrow_rounded,
            onPressed: () => openWorkout(context, sessionId),
          ),
        ],
      ),
    );
  }
}

class _ProgressRail extends StatelessWidget {
  const _ProgressRail({required this.done, required this.total});
  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              for (var i = 0; i < total; i++)
                Expanded(
                  child: AnimatedContainer(
                    duration: NefaMotion.small,
                    curve: NefaMotion.ease,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    decoration: BoxDecoration(
                      color: i < done ? c.accent : c.boardEdge,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text('$done/$total sets', style: NefaType.style(13, 800, color: c.onBoard, tabular: true)),
      ],
    );
  }
}

class _UpNextHero extends ConsumerWidget {
  const _UpNextHero({required this.summary, required this.history});
  final RoutineSummary summary;
  final List<SessionSummary> history;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.nefa;
    final now = DateTime.now();
    final doneToday = {
      for (final h in history)
        if (DateUtils.isSameDay(h.session.startedAt, now)) h.session.dayId,
    };
    // A day you planned for today wins over the rotation.
    final planned = [
      for (final r in ref.watch(allRoutineDetailsProvider).valueOrNull ?? const <RoutineDetail>[])
        for (final d in r.days)
          if (plannedOn(d.day.weekdays, now) && !doneToday.contains(d.day.id)) (r, d),
    ].firstOrNull;
    final rotation = ref.watch(routineProvider(summary.routine.id)).valueOrNull;
    final detail = planned?.$1 ?? rotation;
    if (detail == null || detail.days.isEmpty) return const SizedBox(height: 240);

    // Otherwise the day after the one you did last in this routine.
    final last = history.where((h) => h.session.routineId == detail.routine.id).firstOrNull;
    final lastIndex = detail.days.indexWhere((d) => d.day.id == last?.session.dayId);
    final day = planned?.$2 ?? detail.days[(lastIndex + 1) % detail.days.length];

    return BoardCard(
      onTap: () => openRoutine(context, detail.routine.id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${planned != null ? 'PLANNED TODAY' : 'UP NEXT'} · ${detail.routine.name}'
                      .toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: NefaType.eyebrow(color: c.boardMuted),
                ),
              ),
              if (detail.days.length > 1)
                Text(
                  'DAY ${detail.days.indexOf(day) + 1}/${detail.days.length}',
                  style: NefaType.eyebrow(color: c.accent),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            day.day.name,
            style: NefaType.style(38, 900, height: .98, tracking: -1.6, color: c.onBoard),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _BoardStat(value: '${day.exercises.length}', label: 'exercises'),
              const SizedBox(width: 22),
              _BoardStat(value: '${day.setCount}', label: 'sets'),
              const SizedBox(width: 22),
              _BoardStat(value: '~${_estimateMinutes(day)}', label: 'min'),
            ],
          ),
          const SizedBox(height: 22),
          NefaButton(
            label: 'Start workout',
            icon: Icons.play_arrow_rounded,
            onPressed: () => startWorkout(context, ref, detail, day),
          ),
        ],
      ),
    );
  }

  /// Sets × (40 s of work + the rest), rounded to five minutes.
  int _estimateMinutes(DayPlan day) {
    var seconds = 0;
    for (final e in day.exercises) {
      for (final s in e.sets) {
        seconds += (s.durationSeconds ?? 40) + (e.exercise.restSeconds ?? 90);
      }
    }
    return ((seconds / 60) / 5).ceil() * 5;
  }
}

class _BoardStat extends StatelessWidget {
  const _BoardStat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CountText(value, style: NefaType.value(24, color: c.onBoard)),
        const SizedBox(height: 2),
        Text(label.toUpperCase(), style: NefaType.eyebrow(color: c.boardMuted, size: 9.5)),
      ],
    );
  }
}

/// No routines yet: show the promise in miniature, a pasted note becoming a
/// structured workout.
class _FirstRunHero extends StatelessWidget {
  const _FirstRunHero();

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    return BoardCard(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('BRING YOUR ROUTINE', style: NefaType.eyebrow(color: c.accent)),
          const SizedBox(height: 12),
          Text(
            'Paste it.\nWe’ll set it up.',
            style: NefaType.style(36, 900, height: 1, tracking: -1.5, color: c.onBoard),
          ),
          const SizedBox(height: 12),
          Text(
            'From Notes, WhatsApp, a doc or an AI chat. Sets, reps, timers and rest are read for you to check.',
            style: NefaType.style(14, 500, height: 1.5, color: c.boardMuted),
          ),
          const SizedBox(height: 20),
          const MiniImportScene(),
          const SizedBox(height: 20),
          NefaButton(
            label: 'Paste a routine',
            icon: Icons.content_paste_rounded,
            onPressed: () => openPaste(context),
          ),
        ],
      ),
    );
  }
}

/// A small, real-looking before/after: note → parsed rows.
class MiniImportScene extends StatelessWidget {
  const MiniImportScene({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    final hand = NefaType.style(11.5, 600, height: 1.55, color: const Color(0xFF3A3328));
    return SizedBox(
      height: 150,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 6,
            width: 150,
            child: Transform.rotate(
              angle: -.05,
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 14, 10, 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E3B5),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: const [
                    BoxShadow(color: Color(0x40000000), blurRadius: 12, offset: Offset(0, 6)),
                  ],
                ),
                child: Text(
                  'Mon — Push\nIncline DB 3×10\nLaterals 3×15\nPlank 3×45s\nrest 90',
                  style: hand,
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            width: 170,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: c.paper,
                borderRadius: BorderRadius.circular(NefaRadii.md),
                boxShadow: const [
                  BoxShadow(color: Color(0x55000000), blurRadius: 18, offset: Offset(0, 8)),
                ],
              ),
              child: Column(
                children: [
                  for (final (name, target, flag) in const [
                    ('Incline dumbbell press', '3 × 10', false),
                    ('Side lateral raise', '3 × 15', false),
                    ('Plank', '3 × 45s', true),
                  ])
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 3,
                            height: 22,
                            decoration: BoxDecoration(
                              color: flag ? c.accent : c.ink,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: NefaType.style(10.5, 700, color: c.ink),
                            ),
                          ),
                          Text(
                            target,
                            style: NefaType.style(10.5, 800, color: c.ink, tabular: true),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 4),
                  Container(
                    height: 22,
                    decoration: BoxDecoration(
                      color: c.board,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '+0:24 OVERTIME',
                      style: NefaType.style(9.5, 900, tracking: 1, color: c.accent),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 128,
            top: 92,
            child: Icon(Icons.east_rounded, color: c.accent, size: 26),
          ),
        ],
      ),
    );
  }
}

class _WeekStrip extends ConsumerWidget {
  const _WeekStrip({required this.history});
  final List<SessionSummary> history;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.nefa;
    final unit = ref.watch(settingsProvider).unit;
    final target = ref.watch(accountProvider.select((a) => a.profile.weeklyTarget));
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final week = history.where((h) => !h.session.startedAt.isBefore(monday)).toList();
    final trained = {for (final h in week) h.session.startedAt.weekday};
    final volume = week.fold(0.0, (v, h) => v + h.volumeKg);
    return SheetCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: Eyebrow('This week')),
              Text(
                week.isEmpty
                    ? 'Goal: $target this week'
                    : week.length >= target
                    ? '${plural(week.length, 'session')} · goal hit'
                    : '${week.length} of ${plural(target, 'session')}'
                          '${volume > 0 ? ' · ${_compact(fromKg(volume, unit))} ${unit.name} moved' : ''}',
                style: NefaType.style(12.5, 700, color: c.muted, tabular: true),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Trained days stamp in one after another.
          Reveal(
            duration: const Duration(milliseconds: 1100),
            curve: Curves.linear,
            builder: (context, t) => Row(
              children: [
                for (var d = 1; d <= 7; d++)
                  Expanded(
                    child: Column(
                      children: [
                        Transform.scale(
                          scale: trained.contains(d)
                              ? Curves.elasticOut.transform(
                                  Interval(.06 * d, .5 + .06 * d).transform(t),
                                )
                              : 1,
                          child: AnimatedContainer(
                            duration: NefaMotion.small,
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: trained.contains(d) ? c.accent : Colors.transparent,
                              border: Border.all(
                                color: trained.contains(d)
                                    ? c.accent
                                    : d == now.weekday
                                    ? c.ink
                                    : c.rule,
                                width: d == now.weekday ? 1.8 : 1.2,
                              ),
                            ),
                            child: trained.contains(d)
                                ? Icon(Icons.check_rounded, size: 18, color: c.onAccent)
                                : null,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'MTWTFSS'[d - 1],
                          style: NefaType.style(11, 800, color: d == now.weekday ? c.ink : c.faint),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _compact(double v) {
  if (v >= 10000) return '${(v / 1000).toStringAsFixed(1)}k';
  return v.round().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
}

class _LastSession extends ConsumerWidget {
  const _LastSession({required this.summary});
  final SessionSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.nefa;
    final unit = ref.watch(settingsProvider).unit;
    final s = summary.session;
    return SheetCard(
      onTap: () => push(context, SessionDetailScreen(sessionId: s.id)),
      semanticLabel: 'Open ${s.title}',
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: c.recessed,
              borderRadius: BorderRadius.circular(NefaRadii.md),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${s.startedAt.day}', style: NefaType.value(20, color: c.ink)),
                Text(
                  const [
                    'JAN',
                    'FEB',
                    'MAR',
                    'APR',
                    'MAY',
                    'JUN',
                    'JUL',
                    'AUG',
                    'SEP',
                    'OCT',
                    'NOV',
                    'DEC',
                  ][s.startedAt.month - 1],
                  style: NefaType.eyebrow(color: c.muted, size: 9),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  '${formatClock(summary.duration)} · ${plural(summary.doneSets, 'set')}'
                  '${summary.volumeKg > 0 ? ' · ${_compact(fromKg(summary.volumeKg, unit))} ${unit.name}' : ''}',
                  style: NefaType.style(13, 600, color: c.muted, tabular: true),
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

/// Your initial, in an orange disc: opens profile and account.
class _AvatarButton extends ConsumerWidget {
  const _AvatarButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.nefa;
    final account = ref.watch(accountProvider);
    return Pressable(
      onTap: () => push(context, const AccountScreen()),
      semanticLabel: 'Profile and account',
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: c.ink, shape: BoxShape.circle),
            child: account.profile.displayName.isEmpty
                ? Icon(Icons.person_outline_rounded, size: 20, color: c.paper)
                : Text(account.profile.initial, style: NefaType.style(16, 900, color: c.paper)),
          ),
          if (account.signedIn)
            Positioned(
              right: -1,
              bottom: -1,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: c.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: c.paper, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
