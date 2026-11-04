import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/models/training.dart';
import '../../../core/providers.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/controls.dart';
import '../../../shared/widgets/sheet.dart';
import '../../../shared/widgets/surfaces.dart';
import '../../app/navigation.dart';
import '../../import/ui/review_screen.dart';
import '../data/routine_repository.dart';
import '../../history/calendar_view.dart';
import '../domain/routine_text.dart';
import '../../../shared/widgets/dialog.dart';
import '../../../shared/widgets/motion.dart';

class RoutineDetailScreen extends ConsumerStatefulWidget {
  const RoutineDetailScreen({super.key, required this.routineId});
  final int routineId;

  @override
  ConsumerState<RoutineDetailScreen> createState() => _RoutineDetailScreenState();
}

class _RoutineDetailScreenState extends ConsumerState<RoutineDetailScreen> {
  int _day = 0;

  Future<void> _plan(int dayId, String name, int current) async {
    var mask = current;
    final saved = await showNefaSheet<int>(
      context,
      title: 'Plan $name',
      subtitle: 'Pick the days you usually do it. Today shows it as up next.',
      icon: Icons.event_outlined,
      builder: (context) => StatefulBuilder(
        builder: (context, set) => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var d = 0; d < 7; d++)
              Pill(
                label: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d],
                selected: mask & (1 << d) != 0,
                onTap: () => set(() => mask ^= 1 << d),
              ),
          ],
        ),
      ),
      footer: (context) => NefaButton(
        label: 'Save plan',
        icon: Icons.check_rounded,
        onPressed: () => Navigator.pop(context, mask),
      ),
    );
    if (saved != null) {
      await ref.read(routineRepositoryProvider).setWeekdays(dayId, saved);
      ref.invalidate(allRoutineDetailsProvider);
    }
  }

  Future<void> _menu(RoutineDetail detail) async {
    final action = await showNefaSheet<String>(
      context,
      title: detail.routine.name,
      icon: Icons.more_horiz_rounded,
      builder: (context) => Column(
        children: [
          _MenuRow(
            icon: Icons.edit_outlined,
            label: 'Edit routine',
            onTap: () => Navigator.pop(context, 'edit'),
          ),
          _MenuRow(
            icon: Icons.ios_share_rounded,
            label: 'Share as text (for a coach or client)',
            onTap: () => Navigator.pop(context, 'share'),
          ),
          if (detail.routine.sourceText != null)
            _MenuRow(
              icon: Icons.notes_rounded,
              label: 'See the original text',
              onTap: () => Navigator.pop(context, 'source'),
            ),
          _MenuRow(
            icon: Icons.delete_outline_rounded,
            label: 'Delete routine',
            danger: true,
            onTap: () => Navigator.pop(context, 'delete'),
          ),
        ],
      ),
    );
    if (!mounted || action == null) return;
    switch (action) {
      case 'edit':
        await push(context, RoutineEditorScreen(draft: detail.toDraft()));
      case 'share':
        await SharePlus.instance.share(
          ShareParams(text: routineToText(detail), subject: detail.routine.name),
        );
      case 'source':
        await showNefaSheet<void>(
          context,
          title: 'What you pasted',
          icon: Icons.notes_rounded,
          builder: (context) => SelectableText(
            detail.routine.sourceText!,
            style: NefaType.style(14.5, 500, height: 1.6, color: context.nefa.ink),
          ),
        );
      case 'delete':
        final ok = await showConfirm(
          context,
          title: 'Delete ${detail.routine.name}?',
          body: 'Only the plan is removed. Every workout you did with it stays in your history.',
          confirm: 'Delete routine',
          cancel: 'Keep it',
          destructive: true,
        );
        if (ok) {
          await ref.read(routineRepositoryProvider).delete(detail.routine.id);
          if (mounted) Navigator.of(context).pop();
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    final detail = ref.watch(routineProvider(widget.routineId)).valueOrNull;
    final bottom = MediaQuery.paddingOf(context).bottom;
    if (detail == null) return const PaperScaffold(body: PageBar());
    final dayIndex = _day.clamp(0, (detail.days.length - 1).clamp(0, 99));
    final day = detail.days.isEmpty ? null : detail.days[dayIndex];

    return PaperScaffold(
      body: Column(
        children: [
          PageBar(
            actions: [
              RoundIconButton(
                icon: Icons.more_horiz_rounded,
                label: 'More',
                onPressed: () => _menu(detail),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(NefaSpace.gutter, 4, NefaSpace.gutter, 24),
              children: [
                PageTitle(
                  detail.routine.name,
                  subtitle:
                      '${plural(detail.days.length, 'day')} · '
                      '${plural(detail.days.fold(0, (n, d) => n + d.exercises.length), 'exercise')}',
                ),
                if (detail.days.length > 1) ...[
                  const SizedBox(height: 22),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: detail.days.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, i) => Pill(
                        label: detail.days[i].day.name,
                        selected: i == dayIndex,
                        onTap: () => setState(() => _day = i),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                if (day != null) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          day.day.name,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      Text(
                        plural(day.setCount, 'set'),
                        style: NefaType.style(13, 800, color: c.muted, tabular: true),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Pill(
                    label: day.day.weekdays == 0
                        ? 'Plan days'
                        : 'Planned: ${weekdayNames(day.day.weekdays)}',
                    icon: Icons.event_outlined,
                    background: day.day.weekdays == 0 ? null : c.accentWash,
                    foreground: day.day.weekdays == 0 ? null : c.accentInk,
                    onTap: () => _plan(day.day.id, day.day.name, day.day.weekdays),
                  ),
                  const SizedBox(height: 12),
                  for (final (i, e) in day.exercises.indexed) ...[
                    Rise(
                      index: i,
                      child: _PlanRow(index: i, plan: e),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
                if (detail.routine.notes != null) ...[
                  const SizedBox(height: 12),
                  Notice(text: detail.routine.notes!),
                ],
              ],
            ),
          ),
          if (day != null)
            Padding(
              padding: EdgeInsets.fromLTRB(NefaSpace.gutter, 8, NefaSpace.gutter, 12 + bottom),
              child: NefaButton(
                label: 'Start ${day.day.name}',
                icon: Icons.play_arrow_rounded,
                onPressed: day.exercises.isEmpty
                    ? null
                    : () => startWorkout(context, ref, detail, day),
              ),
            ),
        ],
      ),
    );
  }
}

class _PlanRow extends StatelessWidget {
  const _PlanRow({required this.index, required this.plan});
  final int index;
  final ExercisePlan plan;

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    final e = plan.exercise;
    final weight = plan.sets.isEmpty ? null : plan.sets.first.weight;
    final unit = plan.sets.isEmpty ? WeightUnit.kg : plan.sets.first.unit;
    return SheetCard(
      onTap: e.exerciseId == null || e.exerciseId!.startsWith('custom_')
          ? null
          : () => openExercise(context, e.exerciseId!),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              '${index + 1}'.padLeft(2, '0'),
              style: NefaType.style(13, 900, color: c.accentInk, tabular: true),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (e.groupLabel != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: c.ink,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(e.groupLabel!, style: NefaType.style(10, 900, color: c.paper)),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Expanded(child: Text(e.name, style: Theme.of(context).textTheme.titleMedium)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  [
                    '${plan.sets.length} × ${plan.target.short}${plan.target.kind == TargetKind.reps || plan.target.kind == TargetKind.range ? ' reps' : ''}',
                    if (weight != null) formatWeight(weight, unit),
                    if (e.restSeconds != null && e.restSeconds! > 0)
                      'rest ${formatClock(Duration(seconds: e.restSeconds!))}',
                    if (e.tempo != null) 'tempo ${e.tempo}',
                  ].join(' · '),
                  style: NefaType.style(13, 600, color: c.muted, tabular: true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    final fg = danger ? c.danger : c.ink;
    return Pressable(
      onTap: onTap,
      semanticLabel: label,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: c.rule.withValues(alpha: .6))),
        ),
        child: Row(
          children: [
            Icon(icon, color: fg, size: 21),
            const SizedBox(width: 14),
            Text(label, style: NefaType.style(15, 700, color: fg)),
          ],
        ),
      ),
    );
  }
}

/// "Mon, Wed, Fri" from a weekday mask (bit 0 = Monday).
String weekdayNames(int mask) => [
  for (var d = 0; d < 7; d++)
    if (mask & (1 << d) != 0) const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d],
].join(', ');
