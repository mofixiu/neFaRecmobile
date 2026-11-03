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

class _Swap extends ConsumerWidget {
  const _Swap({required this.original});
  final LibraryRecord original;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.nefa;
    final data = ref.watch(libraryDataProvider).valueOrNull;
    final have = ref.watch(settingsProvider).equipment;
    final options = data == null
        ? const <LibraryRecord>[]
        : alternativesFor(original, data.records, equipment: have);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Eyebrow('Equipment you have'),
        const SizedBox(height: 10),
        Wrap(
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
        const SizedBox(height: 6),
        Text(
          have.isEmpty
              ? 'Nothing selected: showing everything.'
              : 'Only showing what you can do with these.',
          style: NefaType.style(12.5, 500, color: c.muted),
        ),
        const SizedBox(height: 16),
        if (options.isEmpty)
          Text(
            'No close match with that equipment. Select more equipment above.',
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
