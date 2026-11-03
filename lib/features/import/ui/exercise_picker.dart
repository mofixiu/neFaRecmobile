import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/controls.dart';
import '../../../shared/widgets/sheet.dart';
import '../domain/exercise_index.dart';

class PickedExercise {
  const PickedExercise({required this.name, this.id, this.timed = false});
  final String? id;
  final String name;
  final bool timed;

  /// You chose to keep your own name instead of a library match.
  bool get isCustom => id == null;
}

/// "Which exercise is this?" Search the library, take a suggestion, or keep
/// your own name as a custom exercise.
Future<PickedExercise?> pickExercise(
  BuildContext context, {
  String? typed,
  List<IndexedExercise> suggestions = const [],
}) {
  return showNefaSheet<PickedExercise>(
    context,
    title: typed == null ? 'Add an exercise' : 'Which exercise is this?',
    subtitle: typed == null ? 'Search 880+ movements.' : 'You wrote “$typed”.',
    icon: Icons.search_rounded,
    expand: true,
    builder: (_) => _Picker(typed: typed, suggestions: suggestions),
  );
}

class _Picker extends ConsumerStatefulWidget {
  const _Picker({this.typed, required this.suggestions});
  final String? typed;
  final List<IndexedExercise> suggestions;

  @override
  ConsumerState<_Picker> createState() => _PickerState();
}

class _PickerState extends ConsumerState<_Picker> {
  late final _query = TextEditingController(text: widget.typed ?? '');

  @override
  void initState() {
    super.initState();
    _query.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    final index = ref.watch(exerciseIndexProvider).valueOrNull;
    final q = _query.text.trim();
    final results = index == null || q.isEmpty ? <IndexedExercise>[] : index.search(q, limit: 24);
    final seen = <String>{};
    final rows = [
      if (q == (widget.typed ?? '').trim()) ...widget.suggestions,
      ...results,
    ].where((e) => seen.add(e.id)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _query,
          autofocus: widget.typed == null,
          textInputAction: TextInputAction.search,
          style: NefaType.style(16, 600, color: c.ink),
          cursorColor: c.accent,
          decoration: InputDecoration(
            filled: true,
            fillColor: c.recessed,
            hintText: 'Try “RDL”, “cable fly”, “wall sit”',
            hintStyle: NefaType.style(15, 500, color: c.faint),
            prefixIcon: Icon(Icons.search_rounded, color: c.muted),
            suffixIcon: q.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear',
                    icon: Icon(Icons.close_rounded, color: c.muted),
                    onPressed: _query.clear,
                  ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(NefaRadii.md),
              borderSide: BorderSide(color: c.rule),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(NefaRadii.md),
              borderSide: BorderSide(color: c.rule),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(NefaRadii.md),
              borderSide: BorderSide(color: c.accent, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 14),
        if (q.isNotEmpty)
          _Row(
            title: 'Keep “$q” as my own',
            subtitle: 'A custom exercise. History still tracks it.',
            icon: Icons.edit_outlined,
            accent: true,
            onTap: () => Navigator.pop(context, PickedExercise(name: q)),
          ),
        if (rows.isEmpty && q.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Text(
              'Nothing in the library matches. Keep your own name, or try a shorter search.',
              style: NefaType.style(14, 500, color: c.muted, height: 1.45),
            ),
          ),
        for (final (i, e) in rows.indexed)
          _Row(
            title: e.name,
            subtitle: [
              if (i < widget.suggestions.length && q == (widget.typed ?? '').trim()) 'Suggested',
              if (e.equipment != null) e.equipment!,
              if (e.timed) 'timed',
            ].join(' · '),
            icon: Icons.fitness_center_rounded,
            onTap: () =>
                Navigator.pop(context, PickedExercise(id: e.id, name: e.name, timed: e.timed)),
          ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.accent = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    return Pressable(
      onTap: onTap,
      semanticLabel: title,
      scale: .985,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: c.rule.withValues(alpha: .6))),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: accent ? c.accentWash : c.recessed,
                borderRadius: BorderRadius.circular(NefaRadii.sm + 4),
              ),
              child: Icon(icon, size: 18, color: accent ? c.accentInk : c.muted),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: NefaType.style(15, 700, color: c.ink)),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(subtitle, style: NefaType.style(12.5, 500, color: c.muted)),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: c.faint),
          ],
        ),
      ),
    );
  }
}
