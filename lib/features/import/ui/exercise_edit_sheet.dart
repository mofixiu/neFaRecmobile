import 'package:flutter/material.dart';

import '../../../core/models/training.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/controls.dart';
import '../../../shared/widgets/sheet.dart';
import '../../routines/domain/routine_draft.dart';
import '../domain/exercise_index.dart';
import 'exercise_picker.dart';

/// Edit one exercise's targets. Anything you change becomes "explicit".
Future<ExerciseDraft?> editExercise(BuildContext context, ExerciseDraft draft) {
  final key = GlobalKey<_EditorState>();
  return showNefaSheet<ExerciseDraft>(
    context,
    title: draft.name,
    subtitle: draft.sourceLine == null ? null : '“${draft.sourceLine}”',
    icon: Icons.tune_rounded,
    builder: (_) => _Editor(key: key, initial: draft),
    footer: (context) => NefaButton(
      label: 'Done',
      icon: Icons.check_rounded,
      onPressed: () async {
        // Let a focused field commit before reading the result.
        FocusScope.of(context).unfocus();
        await Future<void>.delayed(Duration.zero);
        if (context.mounted) Navigator.pop(context, key.currentState?.result);
      },
    ),
  );
}

class _Editor extends StatefulWidget {
  const _Editor({super.key, required this.initial});
  final ExerciseDraft initial;

  @override
  State<_Editor> createState() => _EditorState();
}

class _EditorState extends State<_Editor> {
  late ExerciseDraft d = widget.initial;
  late final _notes = TextEditingController(text: d.notes ?? '');
  late final _tempo = TextEditingController(text: d.tempo ?? '');
  late final _variant = TextEditingController(text: d.variant ?? '');

  ExerciseDraft get result => d.copyWith(
    notes: _notes.text.trim(),
    tempo: _tempo.text.trim().isEmpty ? null : _tempo.text.trim().toUpperCase(),
    variant: _variant.text.trim(),
    clearVariant: _variant.text.trim().isEmpty,
  );

  @override
  void dispose() {
    _notes.dispose();
    _tempo.dispose();
    _variant.dispose();
    super.dispose();
  }

  void _target(SetTarget t) => setState(
    () => d = d.copyWith(
      target: t,
      targetFrom: Provenance.explicit,
      clearPerSet: true,
      timed: t.isTimed,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    final t = d.target;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Pressable(
          onTap: () async {
            final picked = await pickExercise(
              context,
              typed: d.typedName ?? d.name,
              suggestions: d.candidates,
            );
            if (picked == null) return;
            setState(() {
              d = picked.isCustom
                  ? d.copyWith(name: picked.name, clearExercise: true, status: MatchStatus.exact)
                  : d.copyWith(name: picked.name, exerciseId: picked.id, status: MatchStatus.exact);
              if (picked.timed && !d.target.isTimed) {
                d = d.copyWith(
                  target: const SetTarget.duration(30),
                  targetFrom: Provenance.suggested,
                );
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: c.recessed,
              borderRadius: BorderRadius.circular(NefaRadii.md),
              border: Border.all(color: c.rule),
            ),
            child: Row(
              children: [
                Icon(Icons.swap_horiz_rounded, color: c.muted),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('EXERCISE', style: NefaType.eyebrow(color: c.muted, size: 10)),
                      const SizedBox(height: 3),
                      Text(d.name, style: NefaType.style(15, 700, color: c.ink)),
                    ],
                  ),
                ),
                Text('Change', style: NefaType.style(13, 800, color: c.accentInk)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Segmented<TargetKind>(
          values: TargetKind.values,
          value: t.kind,
          labelOf: (k) => switch (k) {
            TargetKind.reps => 'Reps',
            TargetKind.range => 'Range',
            TargetKind.failure => 'Failure',
            TargetKind.duration => 'Time',
          },
          onChanged: (k) => _target(switch (k) {
            TargetKind.reps => SetTarget.reps(t.repsMax ?? 10),
            TargetKind.range => SetTarget.range(t.repsMin ?? 8, (t.repsMax ?? 8) + 4),
            TargetKind.failure => const SetTarget.failure(),
            TargetKind.duration => SetTarget.duration(t.durationSeconds ?? 30),
          }),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: NefaStepper(
                label: 'Sets',
                value: d.sets,
                min: 1,
                max: 20,
                highlighted: d.setsFrom != Provenance.explicit,
                format: (v) => '$v',
                onChanged: (v) => setState(
                  () => d = d.copyWith(
                    sets: v.toInt(),
                    setsFrom: Provenance.explicit,
                    clearPerSet: true,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: switch (t.kind) {
                TargetKind.reps => NefaStepper(
                  label: 'Reps',
                  value: t.repsMin!,
                  min: 1,
                  max: 100,
                  highlighted: d.targetFrom != Provenance.explicit,
                  format: (v) => '$v',
                  onChanged: (v) => _target(SetTarget.reps(v.toInt())),
                ),
                TargetKind.duration => NefaStepper(
                  label: 'Time',
                  value: t.durationSeconds!,
                  min: 5,
                  max: 3600,
                  step: 5,
                  highlighted: d.targetFrom != Provenance.explicit,
                  format: (v) => formatClock(Duration(seconds: v.toInt())),
                  onChanged: (v) => _target(SetTarget.duration(v.toInt())),
                ),
                TargetKind.failure => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TARGET', style: NefaType.eyebrow(color: c.muted)),
                    const SizedBox(height: 8),
                    Container(
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: c.recessed,
                        borderRadius: BorderRadius.circular(NefaRadii.md),
                        border: Border.all(color: c.rule),
                      ),
                      child: Text(
                        'As many as you can',
                        style: NefaType.style(13, 700, color: c.ink),
                      ),
                    ),
                  ],
                ),
                TargetKind.range => const SizedBox(),
              },
            ),
          ],
        ),
        if (t.kind == TargetKind.range) ...[
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: NefaStepper(
                  label: 'From',
                  value: t.repsMin!,
                  min: 1,
                  max: t.repsMax! - 1,
                  format: (v) => '$v',
                  onChanged: (v) => _target(SetTarget.range(v.toInt(), t.repsMax!)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: NefaStepper(
                  label: 'To',
                  value: t.repsMax!,
                  min: t.repsMin! + 1,
                  max: 100,
                  format: (v) => '$v',
                  onChanged: (v) => _target(SetTarget.range(t.repsMin!, v.toInt())),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('LOAD', style: NefaType.eyebrow(color: c.muted)),
                  const SizedBox(height: 4),
                  RuledNumberField(
                    value: d.weight,
                    decimal: true,
                    hint: '—',
                    width: double.infinity,
                    semanticLabel: 'Load',
                    onCommitted: (v) => setState(
                      () => d = v == null
                          ? d.copyWith(clearWeight: true)
                          : d.copyWith(weight: v.toDouble()),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 120,
              child: Segmented<WeightUnit>(
                values: WeightUnit.values,
                value: d.unit,
                labelOf: (u) => u.name,
                onChanged: (u) => setState(() => d = d.copyWith(unit: u)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        NefaStepper(
          label: d.restFrom == Provenance.explicit ? 'Rest' : 'Rest · your default',
          value: d.restSeconds ?? 90,
          min: 0,
          max: 900,
          step: 15,
          highlighted: d.restFrom != Provenance.explicit,
          format: (v) => v == 0 ? 'None' : formatClock(Duration(seconds: v.toInt())),
          onChanged: (v) =>
              setState(() => d = d.copyWith(restSeconds: v.toInt(), restFrom: Provenance.explicit)),
        ),
        const SizedBox(height: 18),
        _TextLine(label: 'Tempo', controller: _tempo, hint: '3-1-1-0'),
        const SizedBox(height: 14),
        _TextLine(label: 'Machine or setup', controller: _variant, hint: 'Gym A cable, 2:1 pulley'),
        const SizedBox(height: 14),
        _TextLine(label: 'Notes', controller: _notes, hint: 'Pause at the bottom', maxLines: 3),
      ],
    );
  }
}

class _TextLine extends StatelessWidget {
  const _TextLine({required this.label, required this.controller, this.hint, this.maxLines = 1});
  final String label;
  final TextEditingController controller;
  final String? hint;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: NefaType.eyebrow(color: c.muted)),
        TextField(
          controller: controller,
          maxLines: maxLines,
          minLines: 1,
          style: NefaType.style(15, 600, color: c.ink),
          cursorColor: c.accent,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: NefaType.style(15, 500, color: c.faint),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: c.rule, width: 1.2)),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: c.accent, width: 1.6),
            ),
          ),
        ),
      ],
    );
  }
}
