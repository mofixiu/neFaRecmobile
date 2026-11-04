import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/models/training.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/controls.dart';
import '../../../shared/widgets/surfaces.dart';
import '../../app/navigation.dart';
import '../data/routine_repository.dart';
import '../../../shared/widgets/motion.dart';

class RoutinesScreen extends ConsumerWidget {
  const RoutinesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routines = ref.watch(routinesProvider);
    final bottom = MediaQuery.paddingOf(context).bottom + 120;
    return CustomScrollView(
      slivers: [
        SliverSafeArea(
          bottom: false,
          sliver: SliverPadding(
            padding: const EdgeInsets.fromLTRB(NefaSpace.gutter, 24, NefaSpace.gutter, 0),
            sliver: SliverToBoxAdapter(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: PageTitle('Routines', subtitle: 'Everything you’ve brought in.'),
                  ),
                  NefaButton(
                    label: 'Paste',
                    icon: Icons.add_rounded,
                    expand: false,
                    height: 46,
                    onPressed: () => openPaste(context),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(NefaSpace.gutter, 26, NefaSpace.gutter, bottom),
          sliver: routines.when(
            loading: () => const SliverToBoxAdapter(child: SizedBox()),
            error: (e, _) => SliverToBoxAdapter(
              child: Notice(text: 'Routines could not be loaded. $e', tone: NoticeTone.danger),
            ),
            data: (list) => list.isEmpty
                ? SliverToBoxAdapter(
                    child: EmptyState(
                      icon: Icons.view_agenda_outlined,
                      title: 'No routines yet',
                      body:
                          'Paste one from your notes, a chat or an AI answer. You check it before anything is saved.',
                      action: 'Paste a routine',
                      onAction: () => openPaste(context),
                    ),
                  )
                : SliverList.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => Rise(
                      index: i,
                      child: _RoutineCard(summary: list[i]),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _RoutineCard extends StatelessWidget {
  const _RoutineCard({required this.summary});
  final RoutineSummary summary;

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    final last = summary.lastPerformed;
    return SheetCard(
      onTap: () => openRoutine(context, summary.routine.id),
      semanticLabel: 'Open ${summary.routine.name}',
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: c.board,
              borderRadius: BorderRadius.circular(NefaRadii.md),
            ),
            alignment: Alignment.center,
            child: Text(
              summary.routine.name.isEmpty
                  ? '·'
                  : summary.routine.name.characters.first.toUpperCase(),
              style: NefaType.style(24, 900, color: c.accent),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summary.routine.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  [
                    '${summary.dayCount} day${summary.dayCount == 1 ? '' : 's'}',
                    plural(summary.exerciseCount, 'exercise'),
                    last == null ? 'not started' : 'last ${_ago(last)}',
                  ].join(' · '),
                  style: NefaType.style(13, 600, color: c.muted),
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

String _ago(DateTime t) {
  final d = DateTime.now().difference(t);
  if (d.inDays == 0) return 'today';
  if (d.inDays == 1) return 'yesterday';
  if (d.inDays < 7) return '${d.inDays} days ago';
  if (d.inDays < 30) return '${d.inDays ~/ 7} wk ago';
  return '${d.inDays ~/ 30} mo ago';
}
