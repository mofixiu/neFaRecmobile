import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/controls.dart';
import '../../../shared/widgets/sheet.dart';
import '../../settings/settings_controller.dart';
import '../domain/library_data.dart';
import '../domain/substitution.dart';

/// "This machine's taken." Pick an alternative that trains the same muscles
/// with the equipment you have. Returns the chosen record.
Future<LibraryRecord?> showSwapSheet(BuildContext context, LibraryRecord original) {
  return showNefaSheet<LibraryRecord>(
    context,
    title: 'Swap ${original.name}',
    subtitle: 'Same muscles, your equipment. Sets and reps stay; loads reset.',
    icon: Icons.swap_horiz_rounded,
    expand: true,
    builder: (_) => _Swap(original: original),
  );
}

class _Swap extends ConsumerStatefulWidget {
  const _Swap({required this.original});
  final LibraryRecord original;

  @override
  ConsumerState<_Swap> createState() => _SwapState();
}

class _SwapState extends ConsumerState<_Swap> {
  /// The equipment chips stay folded behind one row until you want them.
  bool _filtering = false;

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    final data = ref.watch(libraryDataProvider).valueOrNull;
    final have = ref.watch(settingsProvider).equipment;
    final options = data == null
        ? const <LibraryRecord>[]
        : alternativesFor(widget.original, data.records, equipment: have);
    final summary = have.isEmpty
        ? 'Anything'
        : have.length <= 2
        ? have.map((g) => '${g[0].toUpperCase()}${g.substring(1)}').join(', ')
        : '${have.length} kinds';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Pressable(
          onTap: () => setState(() => _filtering = !_filtering),
          semanticLabel: 'Equipment: $summary',
          scale: .985,
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 11, 10, 11),
            decoration: BoxDecoration(
              color: c.recessed,
              borderRadius: BorderRadius.circular(NefaRadii.md),
            ),
            child: Row(
              children: [
                Icon(Icons.tune_rounded, size: 18, color: c.muted),
                const SizedBox(width: 10),
                Text('Equipment', style: NefaType.style(14, 600, color: c.muted)),
                const Spacer(),
                Text(summary, style: NefaType.style(14, 700, color: c.ink)),
                AnimatedRotation(
                  turns: _filtering ? .5 : 0,
                  duration: NefaMotion.small,
                  child: Icon(Icons.expand_more_rounded, color: c.faint),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: NefaMotion.small,
          curve: NefaMotion.ease,
          alignment: Alignment.topCenter,
          child: !_filtering
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final g in equipmentGroups.keys)
                        Pill(
                          label: g,
                          selected: have.contains(g),
                          onTap: () => ref.read(settingsProvider.notifier).update((s) {
                            final next = {...s.equipment};
                            next.contains(g) ? next.remove(g) : next.add(g);
                            return s.copyWith(equipment: next);
                          }),
                        ),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 10),
        if (options.isEmpty)
          Text(
            'No close match with that equipment. Add more under Equipment above.',
            style: NefaType.style(14, 500, color: c.muted, height: 1.45),
          ),
        for (final r in options)
          Pressable(
            onTap: () => Navigator.pop(context, r),
            semanticLabel: 'Swap to ${r.name}',
            scale: .985,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: c.rule.withValues(alpha: .6))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.name, style: NefaType.style(15, 700, color: c.ink)),
                        const SizedBox(height: 3),
                        Text(
                          [
                            if (r.equipment != null) r.equipment!,
                            r.primaryMuscles.join(', '),
                            if (r.mechanic != null) r.mechanic!,
                          ].join(' · '),
                          style: NefaType.style(12.5, 500, color: c.muted),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.swap_horiz_rounded, color: c.accentInk),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
