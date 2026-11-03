import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paper_kit/paper_kit.dart';

import '../../core/theme/tokens.dart';
import '../../shared/widgets/controls.dart';
import '../../shared/widgets/wordmark.dart';
import '../settings/settings_controller.dart';
import '../today/today_screen.dart';
import '../workout/domain/timer_machine.dart';
import '../workout/state/timer_controller.dart';
import '../workout/ui/scoreboard.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pages = PageController();
  // The demo timer starts a few seconds short of its target so you watch it
  // tip into overtime.
  final _demoStart = DateTime.now().subtract(const Duration(seconds: 84));

  static const _slides = [
    (
      'Bring your\nroutine.',
      'Paste it from Notes, WhatsApp, a doc or an AI chat. neFaRec reads the sets, reps, timers and rest, and you check it.',
    ),
    (
      'Every rep,\nlogged.',
      'Tick sets off as you go. Last time’s numbers sit beside each set, so you know what to beat.',
    ),
    (
      'Time that\ntells the truth.',
      'At zero the timer says so and keeps counting. You decide when the hold or the rest is over.',
    ),
  ];

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _finish() {
    HapticFeedback.mediumImpact();
    ref.read(settingsProvider.notifier).update((s) => s.copyWith(onboarded: true));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return PaperBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AnimatedBuilder(
          animation: _pages,
          builder: (context, _) {
            final page = _pages.hasClients ? (_pages.page ?? 0) : 0.0;
            return Stack(
              children: [
                // A soft orange wash that drifts with the story.
                Positioned(
                  top: -160 + page * 40,
                  right: -180 + page * 70,
                  child: IgnorePointer(
                    child: Container(
                      width: 460,
                      height: 460,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            c.accent.withValues(alpha: c.isDark ? .22 : .28),
                            c.accent.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(NefaSpace.gutter, 12, 8, 0),
                        child: Row(
                          children: [
                            const NefaWordmark(size: 24),
                            const Spacer(),
                            TextButton(
                              onPressed: _finish,
                              child: Text('Skip', style: NefaType.style(14, 800, color: c.muted)),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: PageView.builder(
                          controller: _pages,
                          itemCount: _slides.length,
                          onPageChanged: (_) => HapticFeedback.selectionClick(),
                          itemBuilder: (context, i) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: NefaSpace.gutter),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Spacer(),
                                Center(
                                  child: SizedBox(
                                    width: 340,
                                    height: 300,
                                    child: FittedBox(
                                      child: SizedBox(width: 340, height: 300, child: _scene(i)),
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  _slides[i].$1,
                                  style: Theme.of(context).textTheme.displayLarge,
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  _slides[i].$2,
                                  style: NefaType.style(15.5, 500, height: 1.5, color: c.muted),
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          NefaSpace.gutter,
                          0,
                          NefaSpace.gutter,
                          bottom > 0 ? 4 : 16,
                        ),
                        child: Row(
                          children: [
                            for (var i = 0; i < _slides.length; i++)
                              Container(
                                margin: const EdgeInsets.only(right: 6),
                                height: 8,
                                // Indicators stretch with the swipe, not after it.
                                width: 8 + 20 * (1 - (page - i).abs()).clamp(0.0, 1.0),
                                decoration: BoxDecoration(
                                  color: Color.lerp(
                                    c.rule,
                                    c.accent,
                                    (1 - (page - i).abs()).clamp(0.0, 1.0),
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            const Spacer(),
                            NefaButton(
                              label: page > _slides.length - 1.5 ? 'Get started' : 'Next',
                              icon: Icons.arrow_forward_rounded,
                              expand: false,
                              onPressed: page > _slides.length - 1.5
                                  ? _finish
                                  : () => _pages.nextPage(
                                      duration: NefaMotion.page,
                                      curve: NefaMotion.ease,
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _scene(int i) => switch (i) {
    0 => const Center(
      child: SizedBox(width: 330, child: _BoardFrame(child: MiniImportScene())),
    ),
    1 => const _LogScene(),
    _ => Center(
      child: SizedBox(
        width: 330,
        child: IgnorePointer(
          child: Scoreboard(
            live: LiveTimer(
              sessionId: 0,
              label: 'Rest · next: lateral raise, set 2',
              timer: WorkoutTimer(
                kind: TimerKind.rest,
                target: const Duration(seconds: 90),
                startedAt: _demoStart,
              ),
            ),
            onStop: () {},
            onPause: () {},
            onResume: () {},
            onAdjust: (_) {},
            onDismiss: () {},
          ),
        ),
      ),
    ),
  };
}

class _BoardFrame extends StatelessWidget {
  const _BoardFrame({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    return Transform.rotate(
      angle: .02,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.board,
          borderRadius: BorderRadius.circular(NefaRadii.lg + 4),
          boxShadow: nefaRaisedShadow,
        ),
        child: child,
      ),
    );
  }
}

class _LogScene extends StatelessWidget {
  const _LogScene();

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    Widget row(int n, String last, String kg, String reps, bool done) => Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: done ? c.successWash.withValues(alpha: .7) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(shape: BoxShape.circle, color: done ? c.success : c.recessed),
            child: Text('$n', style: NefaType.style(12, 900, color: done ? c.paper : c.ink)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(last, style: NefaType.style(13, 700, color: c.faint, tabular: true)),
          ),
          SizedBox(
            width: 56,
            child: Text(
              kg,
              textAlign: TextAlign.center,
              style: NefaType.value(19, color: c.ink),
            ),
          ),
          SizedBox(
            width: 44,
            child: Text(
              reps,
              textAlign: TextAlign.center,
              style: NefaType.value(19, color: c.ink),
            ),
          ),
          IgnorePointer(
            child: PaperCheckbox(value: done, strike: false, onChanged: (_) {}),
          ),
        ],
      ),
    );
    return Center(
      child: Transform.rotate(
        angle: -.025,
        child: Container(
          width: 330,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: c.sheet,
            borderRadius: BorderRadius.circular(NefaRadii.lg),
            border: Border.all(color: c.rule),
            boxShadow: nefaRaisedShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('INCLINE DUMBBELL PRESS', style: NefaType.eyebrow(color: c.muted)),
              const SizedBox(height: 6),
              Text('Last time · 12kg × 10, 10, 9', style: NefaType.style(12, 600, color: c.muted)),
              const SizedBox(height: 10),
              row(1, '12×10', '14', '10', true),
              row(2, '12×10', '14', '9', true),
              row(3, '12×9', '14', '', false),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: c.accent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('PR', style: NefaType.style(10, 900, color: c.onAccent)),
                  ),
                  const SizedBox(width: 8),
                  Text('Heaviest yet · 14 kg', style: NefaType.style(12.5, 700, color: c.ink)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
