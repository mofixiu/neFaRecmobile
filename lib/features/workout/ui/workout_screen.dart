import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paper_kit/paper_kit.dart';

import '../../../core/db/database.dart';
import '../../../core/models/training.dart';
import '../../../core/providers.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/controls.dart';
import '../../../shared/widgets/sheet.dart';
import '../../../shared/widgets/surfaces.dart';
import '../../account/state/account_controller.dart';
import '../../formcheck/form_check_screen.dart';
import '../../library/ui/exercise_demo.dart';
import '../../library/ui/swap_sheet.dart';
import '../../settings/settings_controller.dart';
import '../domain/progression.dart';
import '../domain/session_models.dart';
import '../domain/timer_machine.dart';
import '../state/timer_controller.dart';
import 'scoreboard.dart';
import 'summary_screen.dart';
import '../../../shared/widgets/dialog.dart';
import '../../../shared/widgets/motion.dart';

class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({super.key, required this.sessionId});
  final int sessionId;

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen> {
  PageController? _pages;
  int _page = 0;

  /// True while a finger is on the finish ticket, so a rightward drag tears
  /// it instead of paging back.
  bool _holdingTicket = false;

  @override
  void dispose() {
    _pages?.dispose();
    super.dispose();
  }

  void _goTo(int i) {
    _pages?.animateToPage(i, duration: NefaMotion.page, curve: NefaMotion.ease);
  }

  Future<void> _finish(SessionDetail detail) async {
    final repo = ref.read(sessionRepositoryProvider);
    await ref.read(timerProvider.notifier).dismiss();
    await repo.finish(detail.session.id);
    HapticFeedback.heavyImpact();
    unawaited(ref.read(accountProvider.notifier).autoBackupAfterWorkout());
    if (!mounted) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => SummaryScreen(sessionId: detail.session.id, fresh: true)),
    );
  }

  Future<void> _menu(SessionDetail detail) async {
    final action = await showNefaSheet<String>(
      context,
      title: detail.session.title,
      subtitle: '${detail.doneSets} of ${plural(detail.totalSets, 'set')} done',
      icon: Icons.more_horiz_rounded,
      builder: (context) => Column(
        children: [
          _Row(Icons.flag_outlined, 'Finish workout now', () => Navigator.pop(context, 'finish')),
          _Row(
            Icons.swap_vert_rounded,
            'Reorder exercises',
            () => Navigator.pop(context, 'reorder'),
          ),
          _Row(
            Icons.delete_outline_rounded,
            'Discard workout',
            () => Navigator.pop(context, 'discard'),
            danger: true,
          ),
        ],
      ),
    );
    if (!mounted || action == null) return;
    switch (action) {
      case 'finish':
        await _finish(detail);
      case 'reorder':
        await _reorder(detail);
      case 'discard':
        final ok = await showConfirm(
          context,
          title: 'Discard this workout?',
          body:
              'Every set you logged in ${detail.session.title} is deleted and won’t appear in '
              'your history. This can’t be undone.',
          confirm: 'Discard workout',
          cancel: 'Keep training',
          destructive: true,
        );
        if (ok) {
          await ref.read(timerProvider.notifier).dismiss();
          await ref.read(sessionRepositoryProvider).discard(detail.session.id);
          if (mounted) Navigator.of(context).pop();
        }
    }
  }

  Future<void> _reorder(SessionDetail detail) async {
    await showNefaSheet<void>(
      context,
      title: 'Reorder',
      subtitle: 'Finished exercises keep their sets.',
      icon: Icons.swap_vert_rounded,
      builder: (context) => _ReorderList(detail: detail),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    final async = ref.watch(sessionProvider(widget.sessionId));
    final detail = async.valueOrNull;
    final live = ref.watch(timerProvider);
    final timer = live?.sessionId == widget.sessionId ? live : null;

    if (detail == null) {
      return PaperScaffold(
        body: async.isLoading
            ? const SizedBox()
            : Column(
                children: [
                  const PageBar(closeIcon: true),
                  const Padding(
                    padding: EdgeInsets.all(NefaSpace.gutter),
                    child: Notice(
                      text: 'This workout is no longer here. It may have been discarded.',
                    ),
                  ),
                ],
              ),
      );
    }
    _pages ??= PageController(initialPage: _page = detail.currentIndex);

    return PaperScaffold(
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
              child: Row(
                children: [
                  RoundIconButton(
                    icon: Icons.keyboard_arrow_down_rounded,
                    label: 'Minimise workout',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          detail.session.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: NefaType.style(15, 800, color: c.ink),
                        ),
                        const SizedBox(height: 2),
                        ElapsedText(
                          since: detail.session.startedAt,
                          style: NefaType.style(12.5, 700, color: c.muted, tabular: true),
                        ),
                      ],
                    ),
                  ),
                  RoundIconButton(
                    icon: Icons.more_horiz_rounded,
                    label: 'Workout options',
                    onPressed: () => _menu(detail),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(NefaSpace.gutter, 10, NefaSpace.gutter, 6),
            child: _ExerciseRail(detail: detail, page: _page, onTap: _goTo),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pages,
              physics: _holdingTicket ? const NeverScrollableScrollPhysics() : null,
              itemCount: detail.exercises.length,
              onPageChanged: (i) {
                HapticFeedback.selectionClick();
                setState(() => _page = i);
              },
              itemBuilder: (context, i) => _ExercisePage(
                detail: detail,
                index: i,
                active: i == _page,
                bottomInset: timer == null ? 24 : 300,
                onFinish: () => _finish(detail),
                onTicketHold: (v) => setState(() => _holdingTicket = v),
                onNext: i + 1 < detail.exercises.length ? () => _goTo(i + 1) : null,
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            switchInCurve: NefaMotion.ease,
            transitionBuilder: (child, anim) => SizeTransition(
              sizeFactor: anim,
              axisAlignment: -1,
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: timer == null
                ? const SizedBox(width: double.infinity, key: ValueKey('none'))
                : MediaQuery.viewInsetsOf(context).bottom > 0
                ? Padding(
                    // Typing a weight: keep the timer visible but out of the way.
                    key: const ValueKey('mini'),
                    padding: const EdgeInsets.fromLTRB(NefaSpace.gutter, 6, NefaSpace.gutter, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            timer.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: NefaType.style(12.5, 700, color: c.muted),
                          ),
                        ),
                        const SizedBox(width: 10),
                        MiniClock(live: timer),
                      ],
                    ),
                  )
                : Padding(
                    key: const ValueKey('timer'),
                    padding: EdgeInsets.fromLTRB(
                      12,
                      0,
                      12,
                      MediaQuery.paddingOf(context).bottom + 8,
                    ),
                    child: Scoreboard(
                      live: timer,
                      onStop: () async {
                        final hold = timer.timer.kind == TimerKind.hold;
                        await ref.read(timerProvider.notifier).stop();
                        if (hold) _maybeRest(detail, timer.timer.setLogId);
                      },
                      onPause: () => ref.read(timerProvider.notifier).pause(),
                      onResume: () => ref.read(timerProvider.notifier).resume(),
                      onAdjust: (d) => ref.read(timerProvider.notifier).adjust(d),
                      onDismiss: () => ref.read(timerProvider.notifier).dismiss(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  /// After a hold is logged, rest begins if you have that switched on.
  Future<void> _maybeRest(SessionDetail before, int? setId) async {
    final fresh = await ref.read(sessionRepositoryProvider).load(widget.sessionId);
    if (fresh == null || !mounted) return;
    startRestAfter(ref, fresh, setId);
  }
}

/// Starts the rest that follows [setId], labelled with what comes next.
void startRestAfter(WidgetRef ref, SessionDetail detail, int? setId) {
  final settings = ref.read(settingsProvider);
  if (!settings.autoStartRest || setId == null) return;
  final flat = [
    for (final e in detail.exercises)
      if (!e.exercise.skipped)
        for (final s in e.sets) (e, s),
  ];
  final at = flat.indexWhere((p) => p.$2.id == setId);
  if (at < 0) return;
  final owner = flat[at].$1;
  final next = flat.skip(at + 1).where((p) => !p.$2.isDone).firstOrNull;
  if (next == null) return; // That was the last set: no rest needed.
  // Supersets move straight to the partner exercise.
  final sameGroup =
      owner.exercise.groupLabel != null &&
      next.$1.exercise.groupLabel == owner.exercise.groupLabel &&
      next.$1.exercise.id != owner.exercise.id;
  if (sameGroup) return;
  final seconds = owner.exercise.restSeconds ?? settings.defaultRestSeconds;
  if (seconds <= 0) return;
  ref
      .read(timerProvider.notifier)
      .startRest(
        sessionId: detail.session.id,
        seconds: seconds,
        afterSetId: setId,
        label: 'Rest · next: ${next.$1.exercise.name}, set ${next.$2.position + 1}',
      );
}

class _ExerciseRail extends StatelessWidget {
  const _ExerciseRail({required this.detail, required this.page, required this.onTap});
  final SessionDetail detail;
  final int page;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    return Row(
      children: [
        for (final (i, e) in detail.exercises.indexed)
          Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                child: Semantics(
                  label: '${e.exercise.name}, ${e.done} of ${plural(e.sets.length, 'set')}',
                  selected: i == page,
                  button: true,
                  child: AnimatedContainer(
                    duration: NefaMotion.small,
                    height: i == page ? 8 : 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: e.exercise.skipped ? c.rule : c.recessed,
                      border: Border.all(color: i == page ? c.ink : Colors.transparent, width: 1.2),
                    ),
                    child: AnimatedFractionallySizedBox(
                      duration: const Duration(milliseconds: 420),
                      curve: NefaMotion.ease,
                      alignment: Alignment.centerLeft,
                      widthFactor: e.sets.isEmpty ? 0 : e.done / e.sets.length,
                      child: Container(
                        decoration: BoxDecoration(
                          color: e.isComplete ? c.success : c.accent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ExercisePage extends ConsumerWidget {
  const _ExercisePage({
    required this.detail,
    required this.index,
    required this.active,
    required this.bottomInset,
    required this.onFinish,
    required this.onNext,
    required this.onTicketHold,
  });

  final SessionDetail detail;
  final int index;

  /// The page on screen; only it plays its demo video.
  final bool active;
  final double bottomInset;
  final VoidCallback onFinish;
  final VoidCallback? onNext;
  final ValueChanged<bool> onTicketHold;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.nefa;
    final ex = detail.exercises[index];
    final e = ex.exercise;
    final record = e.exerciseId == null
        ? null
        : ref.watch(libraryByIdProvider).valueOrNull?[e.exerciseId];
    final prev = e.exerciseId == null
        ? null
        : ref.watch(previousProvider((e.exerciseId!, detail.session.id, e.variant))).valueOrNull;
    final last = index == detail.exercises.length - 1;
    final target = ex.sets.isEmpty ? null : ex.sets.first.target;

    return ListView(
      padding: EdgeInsets.fromLTRB(NefaSpace.gutter, 8, NefaSpace.gutter, bottomInset),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        ExerciseDemo(exerciseId: e.exerciseId, name: e.name, active: active),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: Eyebrow(
                [
                  'Exercise ${index + 1} of ${detail.exercises.length}',
                  if (e.groupLabel != null) 'Superset ${e.groupLabel}',
                ].join(' · '),
              ),
            ),
            if (e.skipped) Pill(label: 'Skipped', background: c.recessed),
            if (ex.isComplete)
              Pill(
                label: 'Done',
                icon: Icons.check_rounded,
                background: c.successWash,
                foreground: c.success,
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(e.name, style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (target != null)
              Pill(
                label: '${ex.sets.length} × ${target.label}${e.perSide ? ' each side' : ''}',
                background: c.sheet,
              ),
            if (e.restSeconds != null && e.restSeconds! > 0)
              Pill(
                label: 'Rest ${formatClock(Duration(seconds: e.restSeconds!))}',
                icon: Icons.timer_outlined,
                background: c.sheet,
              ),
            if (e.tempo != null) Pill(label: 'Tempo ${e.tempo}', background: c.sheet),
            if (record != null && record.instructions.isNotEmpty)
              Pill(
                label: 'How to',
                icon: Icons.menu_book_outlined,
                background: c.board,
                foreground: c.onBoard,
                onTap: () => showCues(context, record),
              ),
            if (record != null)
              Pill(
                label: 'Swap',
                icon: Icons.swap_horiz_rounded,
                background: c.sheet,
                onTap: () async {
                  final pick = await showSwapSheet(context, record);
                  if (pick == null) return;
                  await ref
                      .read(sessionRepositoryProvider)
                      .swapExercise(ex, exerciseId: pick.id, name: pick.name, timed: pick.timed);
                },
              ),
            Pill(
              label: e.variant == null ? 'Add setup' : 'Setup: ${e.variant}',
              icon: Icons.precision_manufacturing_outlined,
              background: c.sheet,
              onTap: () => _editVariant(context, ref, e.id, e.variant),
            ),
            if (formCheckSupported(e.exerciseId))
              Pill(
                label: 'Form check',
                icon: Icons.videocam_outlined,
                background: c.accentWash,
                foreground: c.accentInk,
                onTap: () => openFormCheck(context, exerciseName: e.name),
              ),
          ],
        ),
        if (e.notes != null && e.notes!.isNotEmpty) ...[
          const SizedBox(height: 14),
          Notice(text: e.notes!),
        ],
        const SizedBox(height: 22),
        if (!ex.isComplete && !e.skipped)
          _SuggestionCard(ex: ex, previous: prev, equipment: record?.equipment),
        _SetTable(detail: detail, ex: ex, previous: prev),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: NefaButton(
                label: 'Add set',
                icon: Icons.add_rounded,
                tone: ButtonTone.ghost,
                height: 48,
                onPressed: () => ref.read(sessionRepositoryProvider).addSet(ex),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: NefaButton(
                label: e.skipped ? 'Unskip' : 'Skip',
                icon: e.skipped ? Icons.undo_rounded : Icons.skip_next_rounded,
                tone: ButtonTone.ghost,
                height: 48,
                onPressed: () async {
                  await ref.read(sessionRepositoryProvider).setSkipped(e.id, !e.skipped);
                  if (!e.skipped) onNext?.call();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 26),
        if (last)
          FinishTicket(
            label: 'Finish ${detail.session.title}',
            onFinish: onFinish,
            onHold: onTicketHold,
          )
        else if (ex.isFinished && onNext != null)
          NefaButton(
            label: 'Next exercise',
            icon: Icons.arrow_forward_rounded,
            tone: ButtonTone.ink,
            onPressed: onNext,
          ),
      ],
    );
  }
}

class _SetTable extends ConsumerWidget {
  const _SetTable({required this.detail, required this.ex, required this.previous});
  final SessionDetail detail;
  final SessionExerciseDetail ex;
  final PreviousPerformance? previous;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.nefa;
    final timed = ex.exercise.timed;
    final unit = ex.sets.isEmpty ? ref.watch(settingsProvider).unit : ex.sets.first.unit;
    return SheetCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 10, 8),
      child: Column(
        children: [
          if (previous != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10, left: 2),
              child: Row(
                children: [
                  Icon(Icons.history_rounded, size: 15, color: c.muted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Last time · ${_short(previous!.date)} · ${previous!.sets.map((s) => _prevLabel(s)).join(', ')}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: NefaType.style(12.5, 600, color: c.muted, tabular: true),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              const SizedBox(width: 40, child: Eyebrow('Set')),
              Expanded(child: Eyebrow(timed ? 'Target' : 'Last')),
              if (!timed) SizedBox(width: 72, child: Center(child: Eyebrow(unit.name))),
              SizedBox(
                width: timed ? 110 : 60,
                child: Center(child: Eyebrow(timed ? 'Held' : 'Reps')),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 4),
          for (final s in ex.sets)
            _SetRow(
              key: ValueKey(s.id),
              detail: detail,
              ex: ex,
              set: s,
              previous: previous?.forPosition(s.position),
            ),
        ],
      ),
    );
  }

  static String _short(DateTime d) =>
      '${d.day} ${const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][d.month - 1]}';
}

String _prevLabel(SetLog s) {
  if (s.kind == TargetKind.duration || s.durationSeconds != null && s.reps == null) {
    return formatClock(Duration(seconds: s.durationSeconds ?? 0));
  }
  final w = s.weight;
  final reps = s.reps ?? 0;
  if (w == null || w == 0) return '$reps';
  final wt = w == w.roundToDouble() ? w.toStringAsFixed(0) : w.toStringAsFixed(1);
  return '$wt×$reps';
}

class _SetRow extends ConsumerWidget {
  const _SetRow({
    super.key,
    required this.detail,
    required this.ex,
    required this.set,
    required this.previous,
  });

  final SessionDetail detail;
  final SessionExerciseDetail ex;
  final SetLog set;
  final SetLog? previous;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.nefa;
    final repo = ref.read(sessionRepositoryProvider);
    final done = set.isDone;
    final timed = set.kind == TargetKind.duration;
    final live = ref.watch(timerProvider);
    final holding =
        live != null && live.timer.kind == TimerKind.hold && live.timer.setLogId == set.id;
    final weightHint = set.targetWeight ?? previous?.weight;
    final repsHint = switch (set.kind) {
      TargetKind.reps => '${set.targetRepsMin}',
      TargetKind.range => '${set.targetRepsMin}–${set.targetRepsMax}',
      TargetKind.failure => 'max',
      TargetKind.duration => '',
    };

    Future<void> toggle(bool value) async {
      if (!value) {
        await repo.uncompleteSet(set.id);
        return;
      }
      if (set.weight == null && weightHint != null && !timed) {
        await repo.updateSet(set.id, weight: weightHint);
      }
      final fresh = (await repo.load(
        detail.session.id,
      ))?.exercises.expand((e) => e.sets).where((s) => s.id == set.id).firstOrNull;
      if (fresh == null) return;
      await repo.completeSet(fresh);
      HapticFeedback.mediumImpact();
      final after = await repo.load(detail.session.id);
      if (after != null) startRestAfter(ref, after, set.id);
    }

    return AnimatedContainer(
      duration: NefaMotion.small,
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: done ? c.successWash.withValues(alpha: .7) : Colors.transparent,
        borderRadius: BorderRadius.circular(NefaRadii.md - 4),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Center(
              child: Pop(
                trigger: done,
                scale: 1.35,
                child: AnimatedContainer(
                  duration: NefaMotion.small,
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done ? c.success : c.recessed,
                  ),
                  child: AnimatedSwitcher(
                    duration: NefaMotion.small,
                    transitionBuilder: (child, a) => ScaleTransition(scale: a, child: child),
                    child: done
                        ? Icon(
                            Icons.check_rounded,
                            key: const ValueKey('done'),
                            size: 16,
                            color: c.paper,
                          )
                        : Text(
                            '${set.position + 1}',
                            key: const ValueKey('n'),
                            style: NefaType.style(12.5, 900, color: c.ink, tabular: true),
                          ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              timed
                  ? formatClock(Duration(seconds: set.targetDurationSeconds ?? 0))
                  : previous == null
                  ? '—'
                  : _prevLabel(previous!),
              style: NefaType.style(13.5, 700, color: timed ? c.ink : c.faint, tabular: true),
            ),
          ),
          if (!timed) ...[
            RuledNumberField(
              value: set.weight,
              decimal: true,
              width: 72,
              hint: weightHint == null ? '—' : _num(weightHint),
              semanticLabel: 'Weight for set ${set.position + 1}',
              onCommitted: (v) => v == null
                  ? repo.updateSet(set.id, clearWeight: true)
                  : repo.updateSet(set.id, weight: v.toDouble()),
            ),
            RuledNumberField(
              value: set.reps,
              width: 60,
              hint: repsHint,
              semanticLabel: 'Reps for set ${set.position + 1}',
              onCommitted: (v) => v == null
                  ? repo.updateSet(set.id, clearReps: true)
                  : repo.updateSet(set.id, reps: v.toInt()),
            ),
          ] else
            SizedBox(
              width: 110,
              child: Center(
                child: done || set.durationSeconds != null
                    ? Text(
                        formatClock(Duration(seconds: set.durationSeconds ?? 0)),
                        style: NefaType.value(19, color: c.ink),
                      )
                    : Pill(
                        label: holding ? 'Holding' : 'Start',
                        icon: holding ? Icons.timer_rounded : Icons.play_arrow_rounded,
                        selected: !holding,
                        background: holding ? c.accentWash : null,
                        foreground: holding ? c.accentInk : null,
                        onTap: holding
                            ? null
                            : () => ref
                                  .read(timerProvider.notifier)
                                  .startHold(
                                    sessionId: detail.session.id,
                                    seconds: set.targetDurationSeconds ?? 30,
                                    setId: set.id,
                                    label: '${ex.exercise.name} · set ${set.position + 1}',
                                  ),
                      ),
              ),
            ),
          SizedBox(
            width: 48,
            child: Center(
              child: PaperCheckbox(
                value: done,
                strike: false,
                onChanged: holding ? (_) {} : toggle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _num(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
}

class _ReorderList extends ConsumerStatefulWidget {
  const _ReorderList({required this.detail});
  final SessionDetail detail;

  @override
  ConsumerState<_ReorderList> createState() => _ReorderListState();
}

class _ReorderListState extends ConsumerState<_ReorderList> {
  late var items = [...widget.detail.exercises];

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      itemCount: items.length,
      onReorder: (from, to) async {
        final target = to > from ? to - 1 : to;
        setState(() {
          final it = items.removeAt(from);
          items.insert(target, it);
        });
        await ref.read(sessionRepositoryProvider).moveExercise(widget.detail, from, target);
      },
      itemBuilder: (context, i) => Container(
        key: ValueKey(items[i].exercise.id),
        height: 56,
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: c.rule.withValues(alpha: .6))),
        ),
        child: Row(
          children: [
            ReorderableDragStartListener(
              index: i,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(Icons.drag_indicator_rounded, color: c.faint),
              ),
            ),
            Expanded(
              child: Text(items[i].exercise.name, style: NefaType.style(15, 700, color: c.ink)),
            ),
            Text(
              '${items[i].done}/${items[i].sets.length}',
              style: NefaType.style(13, 700, color: c.muted, tabular: true),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.icon, this.label, this.onTap, {this.danger = false});
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

/// paper_kit's tear ticket, made easier to tear on a phone: its stub sits at
/// the screen edge with little room to drag, so a rightward drag that starts
/// anywhere on the ticket tears it too.
class FinishTicket extends StatefulWidget {
  const FinishTicket({
    super.key,
    required this.label,
    required this.onFinish,
    required this.onHold,
  });
  final String label;
  final VoidCallback onFinish;
  final ValueChanged<bool> onHold;

  @override
  State<FinishTicket> createState() => _FinishTicketState();
}

class _FinishTicketState extends State<FinishTicket> {
  final _ticket = GlobalKey<PaperTearToConfirmState>();
  Offset? _start;
  bool _done = false;

  static const _distance = 56.0;

  void _release() {
    _start = null;
    widget.onHold(false);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (e) {
        _start = e.position;
        widget.onHold(true);
      },
      onPointerMove: (e) {
        final start = _start;
        if (start == null || _done) return;
        final d = e.position - start;
        if (d.dx > _distance && d.dy.abs() < 48) {
          _done = true;
          _ticket.currentState?.tear();
        }
      },
      onPointerUp: (_) => _release(),
      onPointerCancel: (_) => _release(),
      child: PaperTearToConfirm(
        key: _ticket,
        label: widget.label,
        stubLabel: 'tear',
        confirmedLabel: 'finished',
        onConfirmed: widget.onFinish,
      ),
    );
  }
}

Future<void> _editVariant(BuildContext context, WidgetRef ref, int id, String? current) async {
  final value = await showPrompt(
    context,
    title: 'Machine or setup',
    body:
        'Loads only compare between sessions on the same setup, so a heavy cable stack '
        'never looks like a PR on a light one.',
    initial: current,
    hint: 'Gym A cable, 2:1 pulley',
    label: 'Setup',
    icon: Icons.precision_manufacturing_outlined,
    capitalization: TextCapitalization.words,
    // Saving it empty clears the setup.
    allowEmpty: true,
  );
  if (value != null) await ref.read(sessionRepositoryProvider).setVariant(id, value);
}

/// Today's rule-based nudge, with a one-tap way to use it. Optional: it never
/// changes anything until you tap Use.
class _SuggestionCard extends ConsumerStatefulWidget {
  const _SuggestionCard({required this.ex, required this.previous, required this.equipment});
  final SessionExerciseDetail ex;
  final PreviousPerformance? previous;
  final String? equipment;

  @override
  ConsumerState<_SuggestionCard> createState() => _SuggestionCardState();
}

class _SuggestionCardState extends ConsumerState<_SuggestionCard> {
  bool _hidden = false;

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    final ex = widget.ex;
    if (_hidden || ex.sets.isEmpty) return const SizedBox();
    final s = suggestNext(
      previous: widget.previous,
      target: ex.sets.first.target,
      plannedSets: ex.sets.length,
      equipment: widget.equipment,
    );
    if (s == null) return const SizedBox();
    final unit = ex.sets.first.unit;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        decoration: BoxDecoration(
          color: c.accentWash,
          borderRadius: BorderRadius.circular(NefaRadii.lg - 4),
          border: Border.all(color: c.accent.withValues(alpha: .35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up_rounded, size: 18, color: c.accentInk),
                const SizedBox(width: 8),
                Text('TRY TODAY', style: NefaType.eyebrow(color: c.accentInk)),
                const Spacer(),
                Text(s.label(unit), style: NefaType.value(20, color: c.ink)),
              ],
            ),
            const SizedBox(height: 8),
            Text(s.reason, style: NefaType.style(13, 500, height: 1.45, color: c.ink)),
            const SizedBox(height: 10),
            Row(
              children: [
                Pill(
                  label: 'Use it',
                  icon: Icons.check_rounded,
                  selected: true,
                  onTap: () async {
                    await ref
                        .read(sessionRepositoryProvider)
                        .applySuggestion(ex, weight: s.weight, seconds: s.seconds);
                    setState(() => _hidden = true);
                  },
                ),
                const SizedBox(width: 8),
                Pill(label: 'Not today', onTap: () => setState(() => _hidden = true)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
