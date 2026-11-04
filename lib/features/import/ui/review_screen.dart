import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paper_kit/paper_kit.dart';

import '../../../core/models/training.dart';
import '../../../core/providers.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/controls.dart';
import '../../../shared/widgets/surfaces.dart';
import '../../app/navigation.dart';
import '../../history/calendar_view.dart';
import '../../routines/domain/routine_draft.dart';
import '../../settings/settings_controller.dart';
import '../domain/exercise_index.dart';
import 'exercise_edit_sheet.dart';
import 'exercise_picker.dart';
import '../../../shared/widgets/dialog.dart';
import '../../../shared/widgets/motion.dart';

/// Reviews a fresh import or edits a saved routine. Same screen, same rules:
/// nothing is saved until you say so, and suggested values stay marked.
class RoutineEditorScreen extends ConsumerStatefulWidget {
  const RoutineEditorScreen({super.key, required this.draft, this.importing = false});
  final RoutineDraft draft;
  final bool importing;

  @override
  ConsumerState<RoutineEditorScreen> createState() => _RoutineEditorScreenState();
}

class _RoutineEditorScreenState extends ConsumerState<RoutineEditorScreen> {
  late RoutineDraft draft = widget.draft;
  late final _name = TextEditingController(text: draft.name);
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _setDay(int dayIndex, DayDraft day) {
    final days = [...draft.days]..[dayIndex] = day;
    setState(() => draft = draft.copyWith(days: days));
  }

  void _replace(int dayIndex, int i, ExerciseDraft e) {
    final ex = [...draft.days[dayIndex].exercises]..[i] = e;
    _setDay(dayIndex, draft.days[dayIndex].copyWith(exercises: ex));
  }

  void _remove(int dayIndex, int i) {
    final removed = draft.days[dayIndex].exercises[i];
    final ex = [...draft.days[dayIndex].exercises]..removeAt(i);
    _setDay(dayIndex, draft.days[dayIndex].copyWith(exercises: ex));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Removed ${removed.name}'),
          action: SnackBarAction(
            label: 'Undo',
            textColor: context.nefa.accent,
            onPressed: () {
              final back = [...draft.days[dayIndex].exercises]..insert(i, removed);
              _setDay(dayIndex, draft.days[dayIndex].copyWith(exercises: back));
            },
          ),
        ),
      );
  }

  Future<void> _edit(int dayIndex, int i) async {
    final updated = await editExercise(context, draft.days[dayIndex].exercises[i]);
    if (updated != null) _replace(dayIndex, i, updated);
  }

  Future<void> _resolve(int dayIndex, int i) async {
    final e = draft.days[dayIndex].exercises[i];
    final picked = await pickExercise(
      context,
      typed: e.typedName ?? e.name,
      suggestions: e.candidates,
    );
    if (picked == null) return;
    var next = picked.isCustom
        ? e.copyWith(name: picked.name, clearExercise: true, status: MatchStatus.exact)
        : e.copyWith(name: picked.name, exerciseId: picked.id, status: MatchStatus.exact);
    if (picked.timed && !next.target.isTimed) {
      next = next.copyWith(target: const SetTarget.duration(30), targetFrom: Provenance.suggested);
    }
    _replace(dayIndex, i, next);
  }

  Future<void> _add(int dayIndex) async {
    final picked = await pickExercise(context);
    if (picked == null || !mounted) return;
    final settings = ref.read(settingsProvider);
    final e = ExerciseDraft(
      name: picked.name,
      exerciseId: picked.id,
      target: picked.timed ? const SetTarget.duration(30) : const SetTarget.reps(10),
      restSeconds: settings.defaultRestSeconds,
      unit: settings.unit,
    );
    final edited = await editExercise(context, e);
    final ex = [...draft.days[dayIndex].exercises, edited ?? e];
    _setDay(dayIndex, draft.days[dayIndex].copyWith(exercises: ex));
  }

  Future<void> _renameDay(int dayIndex) async {
    final name = await showPrompt(
      context,
      title: 'Rename this day',
      body: 'Shown on Today, in the calendar and on your workout receipts.',
      initial: draft.days[dayIndex].name,
      hint: 'Monday — Push',
      label: 'Day name',
      icon: Icons.calendar_today_outlined,
      capitalization: TextCapitalization.words,
    );
    if (name != null && name.isNotEmpty) {
      _setDay(dayIndex, draft.days[dayIndex].copyWith(name: name));
    }
  }

  void _addDay() {
    setState(
      () => draft = draft.copyWith(
        days: [
          ...draft.days,
          DayDraft(name: 'Day ${draft.days.length + 1}', exercises: []),
        ],
      ),
    );
  }

  void _dismissIssue(int i) {
    final issues = [...draft.issues]..removeAt(i);
    setState(() => draft = draft.copyWith(issues: issues));
  }

  Future<void> _issueAsExercise(int i) async {
    final line = draft.issues[i].line;
    final picked = await pickExercise(context, typed: line);
    if (picked == null || !mounted) return;
    _dismissIssue(i);
    if (draft.days.isEmpty) _addDay();
    final settings = ref.read(settingsProvider);
    final e = ExerciseDraft(
      name: picked.name,
      exerciseId: picked.id,
      typedName: line,
      status: MatchStatus.exact,
      setsFrom: Provenance.suggested,
      targetFrom: Provenance.suggested,
      restSeconds: settings.defaultRestSeconds,
      restFrom: Provenance.defaulted,
      target: picked.timed ? const SetTarget.duration(30) : const SetTarget.reps(10),
      sourceLine: line,
    );
    final last = draft.days.length - 1;
    _setDay(last, draft.days[last].copyWith(exercises: [...draft.days[last].exercises, e]));
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    final named = draft.copyWith(
      name: _name.text.trim().isEmpty ? draft.name : _name.text.trim(),
      days: draft.days.where((d) => d.exercises.isNotEmpty).toList(),
    );
    if (named.days.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Add at least one exercise before saving.')));
      return;
    }
    setState(() => _saving = true);
    final id = await ref.read(routineRepositoryProvider).save(named);
    ref.invalidate(exerciseIndexProvider);
    ref.invalidate(allRoutineDetailsProvider);
    HapticFeedback.mediumImpact();
    if (!mounted) return;
    final nav = Navigator.of(context);
    if (widget.importing) {
      // Printed from this screen's overlay context; the receipt outlives it.
      PaperReceipt.show(
        context,
        title: 'routine saved',
        lines: [
          PaperReceiptLine('days', '${named.days.length}'),
          PaperReceiptLine('exercises', '${named.exercises.length}'),
          PaperReceiptLine('sets', '${named.exercises.fold(0, (n, e) => n + e.sets)}'),
        ],
        footer: named.name,
      );
      nav.popUntil((r) => r.isFirst);
      ref.read(shellTabProvider.notifier).state = 1;
      openRoutine(nav.context, id);
    } else {
      nav.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    final bottom = MediaQuery.paddingOf(context).bottom;
    final confirm = draft.toConfirm;
    final suggested = draft.suggested;

    return PaperScaffold(
      body: Column(
        children: [
          PageBar(title: widget.importing ? 'Review' : 'Edit routine'),
          Expanded(
            child: CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(NefaSpace.gutter, 0, NefaSpace.gutter, 8),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Eyebrow(widget.importing ? 'Check what was read' : 'Routine'),
                        TextField(
                          controller: _name,
                          style: Theme.of(context).textTheme.displaySmall,
                          cursorColor: c.accent,
                          maxLines: 2,
                          minLines: 1,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Pill(label: plural(draft.exercises.length, 'exercise')),
                            if (draft.days.length > 1) Pill(label: '${draft.days.length} days'),
                            if (confirm > 0)
                              Pill(
                                label: '$confirm to confirm',
                                icon: Icons.help_outline_rounded,
                                background: c.accentWash,
                                foreground: c.accentInk,
                              ),
                            if (suggested > 0)
                              Pill(
                                label: '$suggested suggested',
                                icon: Icons.brush_rounded,
                                background: c.warnWash,
                                foreground: c.warn,
                              ),
                          ],
                        ),
                        if (widget.importing && (confirm > 0 || suggested > 0)) ...[
                          const SizedBox(height: 14),
                          Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(text: 'Values with a '),
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Highlight(
                                    child: Text(
                                      'highlight',
                                      style: NefaType.style(13.5, 700, color: c.ink),
                                    ),
                                  ),
                                ),
                                const TextSpan(
                                  text:
                                      ' weren’t in your text; neFaRec filled them in. Tap any card to change it.',
                                ),
                              ],
                            ),
                            style: NefaType.style(13.5, 500, height: 1.5, color: c.muted),
                          ),
                        ],
                        for (final (i, issue) in draft.issues.indexed) ...[
                          const SizedBox(height: 12),
                          _IssueCard(
                            line: issue.line,
                            message: issue.message,
                            onAdd: () => _issueAsExercise(i),
                            onSkip: () => _dismissIssue(i),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                for (final (dayIndex, day) in draft.days.indexed) ...[
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(NefaSpace.gutter, 22, NefaSpace.gutter, 10),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        children: [
                          Expanded(
                            child: Pressable(
                              onTap: () => _renameDay(dayIndex),
                              semanticLabel: 'Rename ${day.name}',
                              child: Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      day.name,
                                      style: Theme.of(context).textTheme.headlineMedium,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(Icons.edit_outlined, size: 16, color: c.faint),
                                ],
                              ),
                            ),
                          ),
                          Text(
                            '${day.exercises.length}',
                            style: NefaType.style(13, 800, color: c.muted, tabular: true),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: NefaSpace.gutter),
                    sliver: SliverReorderableList(
                      itemCount: day.exercises.length,
                      onReorder: (from, to) {
                        final ex = [...day.exercises];
                        final item = ex.removeAt(from);
                        ex.insert(to > from ? to - 1 : to, item);
                        HapticFeedback.selectionClick();
                        _setDay(dayIndex, day.copyWith(exercises: ex));
                      },
                      proxyDecorator: (child, _, anim) => Material(
                        color: Colors.transparent,
                        child: ScaleTransition(
                          scale: Tween(begin: 1.0, end: 1.03).animate(anim),
                          child: child,
                        ),
                      ),
                      itemBuilder: (context, i) {
                        final e = day.exercises[i];
                        return Padding(
                          key: ValueKey(e.key),
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Dismissible(
                            key: ValueKey('d${e.key}'),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) => _remove(dayIndex, i),
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 24),
                              decoration: BoxDecoration(
                                color: c.dangerWash,
                                borderRadius: BorderRadius.circular(NefaRadii.lg),
                              ),
                              child: Icon(Icons.delete_outline_rounded, color: c.danger),
                            ),
                            child: Rise(
                              index: i,
                              child: _ExerciseCard(
                                draft: e,
                                index: i,
                                onTap: () => _edit(dayIndex, i),
                                onResolve: () => _resolve(dayIndex, i),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: NefaSpace.gutter),
                    sliver: SliverToBoxAdapter(
                      child: Pressable(
                        onTap: () => _add(dayIndex),
                        semanticLabel: 'Add an exercise to ${day.name}',
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(NefaRadii.lg),
                            border: Border.all(color: c.rule, width: 1.2),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_rounded, color: c.ink, size: 20),
                              const SizedBox(width: 8),
                              Text('Add exercise', style: NefaType.style(14, 800, color: c.ink)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(NefaSpace.gutter, 18, NefaSpace.gutter, 30),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: Pressable(
                        onTap: _addDay,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            '+ Add a day',
                            style: NefaType.style(14, 800, color: c.accentInk),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(NefaSpace.gutter, 12, NefaSpace.gutter, 12 + bottom),
            decoration: BoxDecoration(
              color: c.paper,
              border: Border(top: BorderSide(color: c.rule.withValues(alpha: .7))),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (confirm > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      '$confirm unconfirmed ${confirm == 1 ? 'name is' : 'names are'} kept as your own exercise.',
                      textAlign: TextAlign.center,
                      style: NefaType.style(12.5, 600, color: c.muted),
                    ),
                  ),
                NefaButton(
                  label: widget.importing ? 'Save routine' : 'Save changes',
                  icon: Icons.check_rounded,
                  loading: _saving,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IssueCard extends StatelessWidget {
  const _IssueCard({
    required this.line,
    required this.message,
    required this.onAdd,
    required this.onSkip,
  });
  final String line;
  final String message;
  final VoidCallback onAdd;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.warnWash,
        borderRadius: BorderRadius.circular(NefaRadii.md),
        border: Border.all(color: c.warn.withValues(alpha: .3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.help_outline_rounded, size: 18, color: c.warn),
              const SizedBox(width: 8),
              Expanded(
                child: Text('“$line”', style: NefaType.style(14, 700, color: c.ink)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(message, style: NefaType.style(13, 500, height: 1.4, color: c.muted)),
          const SizedBox(height: 10),
          Row(
            children: [
              Pill(label: 'Add as exercise', icon: Icons.add_rounded, onTap: onAdd, selected: true),
              const SizedBox(width: 8),
              Pill(label: 'Skip', onTap: onSkip),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.draft,
    required this.index,
    required this.onTap,
    required this.onResolve,
  });

  final ExerciseDraft draft;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onResolve;

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    final e = draft;
    final value = NefaType.style(15, 800, color: c.ink, tabular: true);
    final setsText = e.perSetReps?.join(' · ');

    return SheetCard(
      onTap: onTap,
      semanticLabel: 'Edit ${e.name}',
      padding: const EdgeInsets.fromLTRB(6, 14, 14, 14),
      borderColor: e.needsMatch ? c.accent.withValues(alpha: .6) : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReorderableDragStartListener(
            index: index,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6, 2, 6, 8),
              child: Icon(Icons.drag_indicator_rounded, color: c.faint, size: 20),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (e.group != null) ...[
                      Container(
                        margin: const EdgeInsets.only(right: 8, top: 1),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: c.ink,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(e.group!, style: NefaType.style(11, 900, color: c.paper)),
                      ),
                    ],
                    Expanded(child: Text(e.name, style: Theme.of(context).textTheme.titleMedium)),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  runSpacing: 6,
                  children: [
                    Highlight(
                      active: e.setsFrom != Provenance.explicit,
                      child: Text('${e.sets}', style: value),
                    ),
                    Text(' × ', style: NefaType.style(14, 600, color: c.muted)),
                    Highlight(
                      active: e.targetFrom != Provenance.explicit,
                      child: Text(setsText ?? e.target.label, style: value),
                    ),
                    if (e.weight != null) ...[
                      Text('  @ ', style: NefaType.style(14, 600, color: c.muted)),
                      Text(formatWeight(e.weight, e.unit), style: value),
                    ],
                    if (e.perSide)
                      Text('  each side', style: NefaType.style(13, 600, color: c.muted)),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    Highlight(
                      active: e.restFrom != Provenance.explicit,
                      child: Text(
                        e.restSeconds == null || e.restSeconds == 0
                            ? 'no rest'
                            : 'rest ${formatClock(Duration(seconds: e.restSeconds!))}',
                        style: NefaType.style(12.5, 700, color: c.muted, tabular: true),
                      ),
                    ),
                    if (e.tempo != null)
                      Text('· tempo ${e.tempo}', style: NefaType.style(12.5, 700, color: c.muted)),
                    if (e.notes != null && e.notes!.isNotEmpty)
                      Text('· ${e.notes}', style: NefaType.style(12.5, 600, color: c.muted)),
                  ],
                ),
                if (e.needsMatch) ...[
                  const SizedBox(height: 12),
                  Pressable(
                    onTap: onResolve,
                    semanticLabel: 'Confirm which exercise ${e.name} is',
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
                      decoration: BoxDecoration(
                        color: c.accentWash,
                        borderRadius: BorderRadius.circular(NefaRadii.md - 4),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.help_outline_rounded, size: 17, color: c.accentInk),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              e.status == MatchStatus.uncertain && e.exerciseId != null
                                  ? 'Is this ${e.name}? Tap to confirm or pick another.'
                                  : 'Not in the library. Pick a match or keep it as yours.',
                              style: NefaType.style(12.5, 700, height: 1.35, color: c.accentInk),
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded, size: 18, color: c.accentInk),
                        ],
                      ),
                    ),
                  ),
                ],
                if (e.sourceLine != null && e.typedName != null && e.typedName != e.name) ...[
                  const SizedBox(height: 8),
                  Text(
                    'You wrote “${e.typedName}”',
                    style: NefaType.style(12, 600, color: c.faint),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
