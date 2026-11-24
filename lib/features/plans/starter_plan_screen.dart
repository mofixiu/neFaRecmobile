import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/controls.dart';
import '../../shared/widgets/motion.dart';
import '../../shared/widgets/surfaces.dart';
import '../app/navigation.dart';
import '../import/ui/review_screen.dart';
import '../library/domain/library_data.dart';
import '../settings/settings_controller.dart';
import 'starter_plan.dart';

void openStarterPlan(BuildContext context) => push(context, const StarterPlanScreen());

const _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

/// No routine yet? Three questions and neFaRec builds one from the library.
class StarterPlanScreen extends ConsumerStatefulWidget {
  const StarterPlanScreen({super.key});

  @override
  ConsumerState<StarterPlanScreen> createState() => _StarterPlanScreenState();
}

class _StarterPlanScreenState extends ConsumerState<StarterPlanScreen> {
  int _days = 3;
  bool _brandNew = true;
  late Set<Kit> _kits = _fromSettings(ref.read(settingsProvider).equipment);

  static Set<Kit> _fromSettings(Set<String> groups) {
    if (groups.isEmpty) return {Kit.machines, Kit.dumbbells};
    final kits = {
      for (final e in kitGroups.entries)
        if (e.value.any(groups.contains)) e.key,
    };
    return kits.isEmpty ? {Kit.machines, Kit.dumbbells} : kits;
  }

  Future<void> _build(Map<String, LibraryRecord> library) async {
    final unit = ref.read(settingsProvider).unit;
    final draft = buildStarterPlan(
      days: _days,
      kits: _kits,
      brandNew: _brandNew,
      library: library,
      unit: unit,
    );
    // What the gym has is what swaps should use too.
    await ref
        .read(settingsProvider.notifier)
        .update((s) => s.copyWith(equipment: {for (final k in _kits) ...kitGroups[k]!}));
    if (!mounted) return;
    await push(context, RoutineEditorScreen(draft: draft, importing: true), fullscreen: true);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    final library = ref.watch(libraryByIdProvider).valueOrNull;
    final preview = library == null
        ? null
        : buildStarterPlan(days: _days, kits: _kits, brandNew: _brandNew, library: library);
    final heading = Theme.of(context).textTheme.headlineMedium;
    return PaperScaffold(
      body: Column(
        children: [
          const PageBar(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                NefaSpace.gutter,
                0,
                NefaSpace.gutter,
                MediaQuery.paddingOf(context).bottom + 24,
              ),
              children: [
                const Eyebrow('Starter plan'),
                const SizedBox(height: 8),
                Text(
                  'A plan for your first weeks',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 12),
                Text(
                  'Three questions. neFaRec builds a full-body plan from the library, and you can change anything before it’s saved.',
                  style: NefaType.style(14.5, 500, height: 1.5, color: c.muted),
                ),
                const SizedBox(height: 24),
                Text('How many days a week?', style: heading),
                const SizedBox(height: 10),
                Segmented<int>(
                  values: const [2, 3, 4],
                  value: _days,
                  labelOf: (d) => '$d days',
                  onChanged: (d) => setState(() => _days = d),
                ),
                const SizedBox(height: 24),
                Text('What does your gym have?', style: heading),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final k in Kit.values)
                      Pill(
                        label: kitLabel(k),
                        selected: _kits.contains(k),
                        onTap: () => setState(() {
                          final next = {..._kits};
                          next.contains(k) ? next.remove(k) : next.add(k);
                          _kits = next.isEmpty ? {Kit.bodyweight} : next;
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Have you lifted before?', style: heading),
                const SizedBox(height: 10),
                Segmented<bool>(
                  values: const [true, false],
                  value: _brandNew,
                  labelOf: (b) => b ? 'Never' : 'A little',
                  onChanged: (b) => setState(() => _brandNew = b),
                ),
                if (preview != null) ...[
                  const SizedBox(height: 28),
                  Text('Your plan', style: heading),
                  const SizedBox(height: 4),
                  Text(
                    _brandNew
                        ? '2 sets each, 10–12 reps on the main lifts. Start light.'
                        : '3 sets each, 8–12 reps on the main lifts.',
                    style: NefaType.style(13, 500, color: c.muted),
                  ),
                  const SizedBox(height: 12),
                  for (final (i, day) in preview.days.indexed) ...[
                    Rise(
                      index: i,
                      child: SheetCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    day.name,
                                    style: NefaType.style(16, 800, color: c.ink),
                                  ),
                                ),
                                Text(
                                  _dayNames[day.weekdays.bitLength - 1],
                                  style: NefaType.eyebrow(color: c.accentInk),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            for (final e in day.exercises)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  '${e.name}  ·  ${e.sets} × ${e.target.label}${e.perSide ? ' each side' : ''}',
                                  style: NefaType.style(13.5, 500, color: c.ink, tabular: true),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 10),
                  NefaButton(
                    label: 'Check and save it',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () => _build(library!),
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
