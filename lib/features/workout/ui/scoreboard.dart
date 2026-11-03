import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../core/models/training.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/controls.dart';
import '../domain/timer_machine.dart';
import '../state/timer_controller.dart';
import '../../../shared/widgets/motion.dart';

/// Rebuilds every frame while mounted and ticking; [builder] gets the time.
class Clock extends StatefulWidget {
  const Clock({super.key, required this.builder, this.active = true});
  final Widget Function(BuildContext, DateTime now) builder;
  final bool active;

  @override
  State<Clock> createState() => _ClockState();
}

class _ClockState extends State<Clock> with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker((_) => setState(() {}));

  @override
  void initState() {
    super.initState();
    if (widget.active) _ticker.start();
  }

  @override
  void didUpdateWidget(Clock old) {
    super.didUpdateWidget(old);
    if (widget.active && !_ticker.isActive) _ticker.start();
    if (!widget.active && _ticker.isActive) _ticker.stop();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, DateTime.now());
}

/// The big timer. Counts down on ink; at zero it says so, flips to orange and
/// counts the overtime up. It never closes itself.
class Scoreboard extends StatelessWidget {
  const Scoreboard({
    super.key,
    required this.live,
    required this.onStop,
    required this.onPause,
    required this.onResume,
    required this.onAdjust,
    required this.onDismiss,
  });

  final LiveTimer live;
  final VoidCallback onStop;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final ValueChanged<Duration> onAdjust;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final t = live.timer;
    return Clock(
      active: !t.isPaused,
      builder: (context, now) {
        final c = context.nefa;
        final phase = t.phase(now);
        final over = phase == TimerPhase.overtime || phase == TimerPhase.targetReached;
        final bg = over ? c.accent : c.board;
        final fg = over ? c.onAccent : c.onBoard;
        final muted = over ? c.onAccent.withValues(alpha: .72) : c.boardMuted;
        final hold = t.kind == TimerKind.hold;
        final reduce = MediaQuery.disableAnimationsOf(context);

        final big = over
            ? '+${formatClock(t.overtime(now))}'
            : formatClock(_ceil(t.remaining(now)));
        final sub = over
            ? '${formatClock(t.elapsed(now))} total · target ${formatClock(t.target)}'
            : '${formatClock(t.elapsed(now))} of ${formatClock(t.target)}';

        return Semantics(
          liveRegion: phase == TimerPhase.targetReached,
          label: over
              ? '${hold ? 'Hold' : 'Rest'} target reached. ${formatClock(t.overtime(now))} over.'
              : '${formatClock(_ceil(t.remaining(now)))} left',
          child: AnimatedContainer(
            duration: reduce ? Duration.zero : const Duration(milliseconds: 420),
            curve: NefaMotion.ease,
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(NefaRadii.lg + 4),
              border: Border.all(color: c.isDark && !over ? c.boardEdge : bg),
              boxShadow: [
                BoxShadow(
                  color: (over ? c.accent : Colors.black).withValues(alpha: over ? .35 : .22),
                  blurRadius: 36,
                  spreadRadius: -10,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        live.label.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: NefaType.eyebrow(color: muted, size: 10.5),
                      ),
                    ),
                    Pop(
                      trigger: over,
                      scale: 1.3,
                      child: _PhaseChip(phase: phase, fg: fg, bg: over ? c.board : c.boardEdge),
                    ),
                    const SizedBox(width: 4),
                    Pressable(
                      onTap: onDismiss,
                      semanticLabel: 'Dismiss timer',
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(Icons.close_rounded, size: 18, color: muted),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.scaleDown,
                        child: Pop(
                          trigger: over,
                          scale: 1.12,
                          child: Text(big, style: NefaType.board(72, color: fg)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        over
                            ? 'overtime'
                            : hold
                            ? 'hold'
                            : 'rest',
                        style: NefaType.style(15, 700, color: muted),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(sub, style: NefaType.style(13, 600, color: muted, tabular: true)),
                const SizedBox(height: 14),
                SizedBox(
                  height: 22,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _ChalkTicks(
                      progress: t.progress(now),
                      overtime: t.overtime(now),
                      target: t.target,
                      on: fg,
                      off: over ? c.onAccent.withValues(alpha: .28) : c.boardEdge,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (hold)
                  Row(
                    children: [
                      Expanded(
                        child: _BoardButton(
                          label: t.isPaused ? 'Resume' : 'Pause',
                          icon: t.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                          fg: fg,
                          border: muted.withValues(alpha: .5),
                          onTap: t.isPaused ? onResume : onPause,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: _BoardButton(
                          label: 'Stop & log',
                          icon: Icons.stop_rounded,
                          filled: true,
                          fg: over ? c.onBoard : c.onAccent,
                          bg: over ? c.board : c.accent,
                          onTap: onStop,
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      _BoardButton(
                        label: '−15',
                        fg: fg,
                        border: muted.withValues(alpha: .5),
                        onTap: () => onAdjust(const Duration(seconds: -15)),
                      ),
                      const SizedBox(width: 8),
                      _BoardButton(
                        label: '+15',
                        fg: fg,
                        border: muted.withValues(alpha: .5),
                        onTap: () => onAdjust(const Duration(seconds: 15)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _BoardButton(
                          label: over ? 'Next set' : 'Skip rest',
                          icon: Icons.arrow_forward_rounded,
                          filled: true,
                          fg: over ? c.onBoard : c.onAccent,
                          bg: over ? c.board : c.accent,
                          onTap: onStop,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Countdowns read 0:01 until they reach zero, never 0:00 early.
  static Duration _ceil(Duration d) => Duration(seconds: (d.inMilliseconds / 1000).ceil());
}

class _PhaseChip extends StatelessWidget {
  const _PhaseChip({required this.phase, required this.fg, required this.bg});
  final TimerPhase phase;
  final Color fg;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    final label = switch (phase) {
      TimerPhase.targetReached => 'Target hit',
      TimerPhase.overtime => 'Target hit',
      TimerPhase.paused => 'Paused',
      _ => 'Live',
    };
    final icon = switch (phase) {
      TimerPhase.targetReached || TimerPhase.overtime => Icons.check_rounded,
      TimerPhase.paused => Icons.pause_rounded,
      _ => Icons.fiber_manual_record_rounded,
    };
    final c = context.nefa;
    final hit = phase == TimerPhase.targetReached || phase == TimerPhase.overtime;
    return AnimatedContainer(
      duration: NefaMotion.small,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(NefaRadii.sm)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 11,
            color: hit
                ? c.accent
                : phase == TimerPhase.paused
                ? c.onBoard
                : c.accent,
          ),
          const SizedBox(width: 5),
          Text(label.toUpperCase(), style: NefaType.eyebrow(color: c.onBoard, size: 9.5)),
        ],
      ),
    );
  }
}

class _BoardButton extends StatelessWidget {
  const _BoardButton({
    required this.label,
    required this.fg,
    required this.onTap,
    this.icon,
    this.bg,
    this.border,
    this.filled = false,
  });

  final String label;
  final IconData? icon;
  final Color fg;
  final Color? bg;
  final Color? border;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      semanticLabel: label,
      child: AnimatedContainer(
        duration: NefaMotion.small,
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: filled ? bg : Colors.transparent,
          borderRadius: BorderRadius.circular(NefaRadii.md),
          border: Border.all(color: filled ? (bg ?? fg) : (border ?? fg), width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[Icon(icon, size: 19, color: fg), const SizedBox(width: 6)],
            Text(label, style: NefaType.style(15, 800, color: fg, tabular: true)),
          ],
        ),
      ),
    );
  }
}

/// A row of chalk strokes: filled up to the target, then a second, thinner
/// pass for overtime so you can see how far past you are.
class _ChalkTicks extends CustomPainter {
  _ChalkTicks({
    required this.progress,
    required this.overtime,
    required this.target,
    required this.on,
    required this.off,
  });

  final double progress;
  final Duration overtime;
  final Duration target;
  final Color on;
  final Color off;

  static const count = 36;

  @override
  void paint(Canvas canvas, Size size) {
    final gap = size.width / count;
    final rand = math.Random(7);
    final overFraction = target.inMilliseconds == 0
        ? 0.0
        : (overtime.inMilliseconds / target.inMilliseconds).clamp(0.0, 1.0);
    for (var i = 0; i < count; i++) {
      final x = gap * i + gap / 2;
      final jitter = rand.nextDouble() * 2.5;
      final major = i % 6 == 0;
      final h = major ? size.height : size.height * .62;
      final filled = (i + .5) / count <= progress;
      final over = (i + .5) / count <= overFraction;
      final paint = Paint()
        ..strokeCap = StrokeCap.round
        ..strokeWidth = major ? 3.2 : 2.4
        ..color = filled ? on.withValues(alpha: over ? .55 : 1) : off;
      final top = size.height - h + jitter;
      canvas.drawLine(Offset(x + jitter * .2, top), Offset(x - jitter * .2, size.height), paint);
      if (over) {
        // Second chalk pass, slightly offset, for overtime.
        canvas.drawLine(
          Offset(x + 1.6, top + 3),
          Offset(x + .8, size.height),
          Paint()
            ..strokeCap = StrokeCap.round
            ..strokeWidth = 1.6
            ..color = on,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_ChalkTicks old) =>
      old.progress != progress || old.overtime != overtime || old.on != on || old.off != off;
}

/// A small ticking readout for the resume strip.
class MiniClock extends StatelessWidget {
  const MiniClock({super.key, required this.live});
  final LiveTimer live;

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    final t = live.timer;
    return Clock(
      active: !t.isPaused,
      builder: (context, now) {
        final over = t.reachedTarget(now);
        final text = over
            ? '+${formatClock(t.overtime(now))}'
            : formatClock(Duration(seconds: (t.remaining(now).inMilliseconds / 1000).ceil()));
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: over ? c.accent : c.board,
            borderRadius: BorderRadius.circular(NefaRadii.sm),
          ),
          child: Text(
            text,
            style: NefaType.style(14, 800, color: over ? c.onAccent : c.onBoard, tabular: true),
          ),
        );
      },
    );
  }
}

/// Elapsed workout time, ticking once a second.
class ElapsedText extends StatelessWidget {
  const ElapsedText({super.key, required this.since, this.style});
  final DateTime since;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Clock(
      builder: (context, now) => Text(
        formatClock(now.difference(since)),
        style: style ?? NefaType.style(14, 800, color: context.nefa.muted, tabular: true),
      ),
    );
  }
}
