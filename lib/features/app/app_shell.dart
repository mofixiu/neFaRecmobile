import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paper_kit/paper_kit.dart';

import '../../core/providers.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/controls.dart';
import '../../shared/widgets/floating_nav.dart';
import '../history/history_screen.dart';
import '../library/ui/library_screen.dart';
import '../routines/ui/routines_screen.dart';
import '../today/today_screen.dart';
import '../workout/state/timer_controller.dart';
import '../workout/ui/scoreboard.dart';
import 'navigation.dart';
import '../../shared/widgets/motion.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  static const destinations = [
    NavDestination('Today', Icons.wb_sunny_outlined, Icons.wb_sunny_rounded),
    NavDestination('Routines', Icons.view_agenda_outlined, Icons.view_agenda_rounded),
    NavDestination('History', Icons.receipt_long_outlined, Icons.receipt_long_rounded),
    NavDestination('Library', Icons.menu_book_outlined, Icons.menu_book_rounded),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(shellTabProvider);
    final active = ref.watch(activeSessionProvider).valueOrNull;
    return PaperBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: FadeIndexedStack(
          index: index,
          children: const [TodayScreen(), RoutinesScreen(), HistoryScreen(), LibraryScreen()],
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSize(
              duration: NefaMotion.small,
              child: active == null
                  ? const SizedBox(width: double.infinity)
                  : _ResumeStrip(
                      title: active.title,
                      startedAt: active.startedAt,
                      onTap: () => openWorkout(context, active.id),
                    ),
            ),
            FloatingNav(
              destinations: destinations,
              index: index,
              onSelect: (i) => ref.read(shellTabProvider.notifier).state = i,
            ),
          ],
        ),
      ),
    );
  }
}

/// Floats above the nav while a workout is running anywhere in the app.
class _ResumeStrip extends ConsumerWidget {
  const _ResumeStrip({required this.title, required this.startedAt, required this.onTap});
  final String title;
  final DateTime startedAt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.nefa;
    final timer = ref.watch(timerProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Pressable(
        onTap: onTap,
        semanticLabel: 'Back to $title',
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: c.raised,
            borderRadius: BorderRadius.circular(NefaRadii.lg),
            border: Border.all(color: c.rule),
            boxShadow: nefaRaisedShadow,
          ),
          child: Row(
            children: [
              const _RecDot(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('IN PROGRESS', style: NefaType.eyebrow(color: c.accentInk, size: 10)),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: NefaType.style(14.5, 800, color: c.ink),
                    ),
                  ],
                ),
              ),
              if (timer != null) MiniClock(live: timer) else ElapsedText(since: startedAt),
              const SizedBox(width: 6),
              Icon(Icons.chevron_right_rounded, color: c.muted),
            ],
          ),
        ),
      ),
    );
  }
}

/// The "recording" light: a softly pulsing orange dot.
class _RecDot extends StatefulWidget {
  const _RecDot();
  @override
  State<_RecDot> createState() => _RecDotState();
}

class _RecDotState extends State<_RecDot> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    if (MediaQuery.disableAnimationsOf(context)) _c.stop();
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) => Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: c.accent,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: c.accent.withValues(alpha: .5 * _c.value),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}
