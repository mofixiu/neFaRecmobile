import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/controls.dart';
import '../../../shared/widgets/surfaces.dart';
import '../../app/navigation.dart';
import '../domain/library_data.dart';
import '../../../shared/widgets/motion.dart';

const _muscles = [
  'chest',
  'shoulders',
  'lats',
  'middle back',
  'biceps',
  'triceps',
  'quadriceps',
  'hamstrings',
  'glutes',
  'calves',
  'abdominals',
];

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  final _query = TextEditingController();
  String? _muscle;

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
    final data = ref.watch(libraryDataProvider).valueOrNull;
    final index = ref.watch(exerciseIndexProvider).valueOrNull;
    final byId = ref.watch(libraryByIdProvider).valueOrNull ?? const {};
    final q = _query.text.trim();
    final bottom = MediaQuery.paddingOf(context).bottom + 120;

    List<LibraryRecord> list;
    if (data == null) {
      list = const [];
    } else if (q.isNotEmpty && index != null) {
      list = index.search(q, limit: 60).map((e) => byId[e.id]).whereType<LibraryRecord>().toList();
    } else {
      // Common lifts with demos first, then everything else alphabetically.
      list = [...data.records]
        ..sort((a, b) {
          if (a.curated != b.curated) return a.curated ? -1 : 1;
          return a.name.compareTo(b.name);
        });
    }
    if (_muscle != null) {
      list = list.where((r) => r.primaryMuscles.contains(_muscle)).toList();
    }

    return CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        SliverSafeArea(
          bottom: false,
          sliver: SliverPadding(
            padding: const EdgeInsets.fromLTRB(NefaSpace.gutter, 24, NefaSpace.gutter, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PageTitle(
                    'Library',
                    subtitle: '${data?.records.length ?? 880}+ movements with steps and cues.',
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _query,
                    textInputAction: TextInputAction.search,
                    style: NefaType.style(16, 600, color: c.ink),
                    cursorColor: c.accent,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: c.sheet,
                      hintText: 'Search “romanian”, “cable”, “plank”',
                      hintStyle: NefaType.style(15, 500, color: c.faint),
                      prefixIcon: Icon(Icons.search_rounded, color: c.muted),
                      suffixIcon: q.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Clear',
                              icon: Icon(Icons.close_rounded, color: c.muted),
                              onPressed: _query.clear,
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
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: NefaSpace.gutter),
              itemCount: _muscles.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) => Pill(
                label: _muscles[i],
                selected: _muscle == _muscles[i],
                onTap: () => setState(() => _muscle = _muscle == _muscles[i] ? null : _muscles[i]),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(NefaSpace.gutter, 16, NefaSpace.gutter, bottom),
          sliver: list.isEmpty && data != null
              ? SliverToBoxAdapter(
                  child: Notice(
                    text: q.isEmpty
                        ? 'Nothing for that muscle. Clear the filter to see everything.'
                        : 'Nothing matches “$q”. Try a shorter search or a different name.',
                  ),
                )
              : SliverList.builder(
                  itemCount: list.length,
                  itemBuilder: (context, i) => Rise(
                    index: i,
                    child: _Row(record: list[i]),
                  ),
                ),
        ),
      ],
    );
  }
}

class _Row extends ConsumerWidget {
  const _Row({required this.record});
  final LibraryRecord record;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.nefa;
    final video = ref.watch(videoByExerciseProvider).valueOrNull?.containsKey(record.id) ?? false;
    final thumb = bundledDemoAsset(
      record.id,
      0,
      curated: record.curated && record.images.isNotEmpty,
    );
    return Pressable(
      onTap: () => openExercise(context, record.id),
      semanticLabel: record.name,
      scale: .985,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: c.rule.withValues(alpha: .6))),
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: c.isDark ? const Color(0xFFF1E9DA) : c.sheet,
                    borderRadius: BorderRadius.circular(NefaRadii.md - 4),
                    border: Border.all(color: c.rule),
                  ),
                  child: thumb == null
                      ? Center(
                          child: Text(
                            record.name.characters.first,
                            style: NefaType.style(20, 900, color: const Color(0xFF8A8072)),
                          ),
                        )
                      : ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            c.isDark ? const Color(0xFFF1E9DA) : c.sheet,
                            BlendMode.multiply,
                          ),
                          child: Image.asset(thumb, fit: BoxFit.cover, cacheWidth: 160),
                        ),
                ),
                if (video)
                  Positioned(
                    right: -4,
                    bottom: -4,
                    child: Semantics(
                      label: 'Has a video',
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: c.accent,
                          shape: BoxShape.circle,
                          border: Border.all(color: c.paper, width: 2),
                        ),
                        child: Icon(Icons.play_arrow_rounded, size: 12, color: c.onAccent),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(record.name, style: NefaType.style(15, 700, color: c.ink)),
                  const SizedBox(height: 3),
                  Text(
                    [
                      if (record.primaryMuscles.isNotEmpty) record.primaryMuscles.first,
                      if (record.equipment != null) record.equipment!,
                    ].join(' · '),
                    style: NefaType.style(12.5, 500, color: c.muted),
                  ),
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
