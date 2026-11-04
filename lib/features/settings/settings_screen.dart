import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/training.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/controls.dart';
import '../../shared/widgets/surfaces.dart';
import '../../shared/widgets/wordmark.dart';
import '../../core/providers.dart';
import '../../core/services/media_cache.dart';
import '../library/domain/substitution.dart';
import '../library/ui/video_credits.dart';
import '../account/state/account_controller.dart';
import '../account/ui/account_screen.dart';
import 'settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.nefa;
    final s = ref.watch(settingsProvider);
    final ctrl = ref.read(settingsProvider.notifier);

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
                const PageTitle('Settings'),
                const SizedBox(height: 22),
                SheetCard(
                  onTap: () => Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const AccountScreen())),
                  semanticLabel: 'Profile and account',
                  child: Row(
                    children: [
                      Icon(Icons.person_outline_rounded, color: c.ink),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Profile & account', style: NefaType.style(15, 700, color: c.ink)),
                            Text(
                              ref.watch(accountProvider).email ?? 'Not signed in. Backups are off.',
                              style: NefaType.style(12.5, 500, color: c.muted),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: c.muted),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                const Eyebrow('Appearance'),
                const SizedBox(height: 10),
                Segmented<ThemeMode>(
                  values: const [ThemeMode.system, ThemeMode.light, ThemeMode.dark],
                  value: s.themeMode,
                  labelOf: (m) => switch (m) {
                    ThemeMode.system => 'Auto',
                    ThemeMode.light => 'Cream',
                    ThemeMode.dark => 'Espresso',
                  },
                  onChanged: (m) => ctrl.update((x) => x.copyWith(themeMode: m)),
                ),
                const SizedBox(height: 26),
                const Eyebrow('Units'),
                const SizedBox(height: 10),
                Segmented<WeightUnit>(
                  values: WeightUnit.values,
                  value: s.unit,
                  labelOf: (u) => u == WeightUnit.kg ? 'Kilograms' : 'Pounds',
                  onChanged: (u) => ctrl.update((x) => x.copyWith(unit: u)),
                ),
                const SizedBox(height: 8),
                Text(
                  'Used for new routines and totals. Sets you already logged keep their own unit.',
                  style: NefaType.style(12.5, 500, color: c.muted, height: 1.4),
                ),
                const SizedBox(height: 26),
                NefaStepper(
                  label: 'Default rest',
                  value: s.defaultRestSeconds,
                  min: 15,
                  max: 600,
                  step: 15,
                  format: (v) => formatClock(Duration(seconds: v.toInt())),
                  onChanged: (v) => ctrl.update((x) => x.copyWith(defaultRestSeconds: v.toInt())),
                ),
                const SizedBox(height: 8),
                Text(
                  'When a routine doesn’t say how long to rest.',
                  style: NefaType.style(12.5, 500, color: c.muted),
                ),
                const SizedBox(height: 22),
                SheetCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Column(
                    children: [
                      _Toggle(
                        title: 'Start rest after each set',
                        subtitle:
                            'The timer begins when you tick a set off. Supersets go straight to the partner.',
                        value: s.autoStartRest,
                        onChanged: (v) => ctrl.update((x) => x.copyWith(autoStartRest: v)),
                      ),
                      Divider(height: 1, color: c.rule.withValues(alpha: .6)),
                      _Toggle(
                        title: 'Haptics',
                        subtitle: 'Taps, ticks and the triple buzz when a target is hit.',
                        value: s.haptics,
                        onChanged: (v) => ctrl.update((x) => x.copyWith(haptics: v)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                const Eyebrow('Equipment you have'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final g in equipmentGroups.keys)
                      Pill(
                        label: g,
                        selected: s.equipment.contains(g),
                        onTap: () => ctrl.update((x) {
                          final next = {...x.equipment};
                          next.contains(g) ? next.remove(g) : next.add(g);
                          return x.copyWith(equipment: next);
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Swap suggestions only show movements you can do with these. None selected means anything.',
                  style: NefaType.style(12.5, 500, color: c.muted, height: 1.4),
                ),
                const SizedBox(height: 22),
                const _MediaRow(),
                const SizedBox(height: 10),
                const _VideoCreditsRow(),
                const SizedBox(height: 36),
                const Center(child: NefaTicketMark(width: 96)),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    'Bring your routine. Track every rep.',
                    style: NefaType.style(13, 600, color: c.muted),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Everything is stored on this phone and works offline. '
                  'Exercise data and photos: free-exercise-db (Unlicense, public domain). '
                  'Demo videos: wger.de contributors (CC BY-SA 4.0). '
                  'Type: Montserrat (SIL Open Font License). Paper widgets: paper_kit.\n\n'
                  'neFaRec gives general guidance, not medical advice. It does not assess your form or guarantee a movement is safe.',
                  textAlign: TextAlign.center,
                  style: NefaType.style(11.5, 500, color: c.faint, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: NefaType.style(15, 700, color: c.ink)),
                const SizedBox(height: 3),
                Text(subtitle, style: NefaType.style(12.5, 500, color: c.muted, height: 1.4)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: c.accent,
            activeThumbColor: Colors.white,
          ),
        ],
      ),
    );
  }
}

/// Demo photos downloaded for exercises that are not bundled.
class _MediaRow extends StatefulWidget {
  const _MediaRow();
  @override
  State<_MediaRow> createState() => _MediaRowState();
}

class _MediaRowState extends State<_MediaRow> {
  late Future<int> _size = MediaCache.instance.size();

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    return SheetCard(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Downloaded demos', style: NefaType.style(15, 700, color: c.ink)),
                const SizedBox(height: 3),
                FutureBuilder<int>(
                  future: _size,
                  builder: (context, snap) => Text(
                    snap.hasData
                        ? '${(snap.data! / (1024 * 1024)).toStringAsFixed(1)} MB kept for offline use. Common lifts are built in.'
                        : 'Checking…',
                    style: NefaType.style(12.5, 500, color: c.muted, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          Pill(
            label: 'Clear',
            onTap: () async {
              await MediaCache.instance.clear();
              setState(() => _size = MediaCache.instance.size());
            },
          ),
        ],
      ),
    );
  }
}

class _VideoCreditsRow extends ConsumerWidget {
  const _VideoCreditsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.nefa;
    final clips = ref.watch(exerciseVideosProvider).valueOrNull?.clips ?? const [];
    if (clips.isEmpty) return const SizedBox.shrink();
    return SheetCard(
      onTap: () => showVideoCredits(context, clips),
      semanticLabel: 'Video credits',
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Video credits', style: NefaType.style(15, 700, color: c.ink)),
                const SizedBox(height: 3),
                Text(
                  '${clips.length} demo videos, built in. Filmed by the wger.de community.',
                  style: NefaType.style(12.5, 500, color: c.muted, height: 1.4),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: c.faint),
        ],
      ),
    );
  }
}
