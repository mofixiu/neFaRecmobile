import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/training.dart';
import '../../../core/providers.dart';
import '../../../core/services/live_activity.dart';
import '../domain/timer_machine.dart';

@immutable
class LiveTimer {
  const LiveTimer({required this.sessionId, required this.timer, required this.label});
  final int sessionId;
  final WorkoutTimer timer;

  /// "Rest · next up: Lateral raise" or "Plank · set 2".
  final String label;

  LiveTimer withTimer(WorkoutTimer t) => LiveTimer(sessionId: sessionId, timer: t, label: label);
}

/// Owns the one running timer. State changes are persisted immediately and
/// the display is always recomputed from timestamps, so backgrounding,
/// locking or killing the app never loses or distorts time.
class TimerController extends Notifier<LiveTimer?> {
  Timer? _targetAlarm;
  AppLifecycleListener? _lifecycle;

  DateTime get _now => ref.read(clockProvider)();

  @override
  LiveTimer? build() {
    _lifecycle = AppLifecycleListener(onResume: _reconcile);
    ref.onDispose(() {
      _targetAlarm?.cancel();
      _lifecycle?.dispose();
    });
    Future.microtask(_restore);
    return null;
  }

  Future<void> _restore() async {
    final stored = await ref.read(sessionRepositoryProvider).loadTimer();
    if (stored == null) return;
    state = LiveTimer(sessionId: stored.sessionId, timer: stored.timer, label: stored.label);
    _arm();
    _mirror(state!);
  }

  /// Called when the app returns to the foreground. The stored timestamps are
  /// already right; this re-arms the in-app alert and repaints.
  void _reconcile() {
    final live = state;
    if (live == null) return;
    state = live.withTimer(live.timer);
    _arm();
  }

  Future<void> startRest({
    required int sessionId,
    required int seconds,
    int? afterSetId,
    String label = 'Rest',
  }) => _begin(
    LiveTimer(
      sessionId: sessionId,
      label: label,
      timer: WorkoutTimer.idle(
        kind: TimerKind.rest,
        target: Duration(seconds: seconds),
        setLogId: afterSetId,
      ).start(_now),
    ),
  );

  Future<void> startHold({
    required int sessionId,
    required int seconds,
    required int setId,
    String label = 'Hold',
  }) => _begin(
    LiveTimer(
      sessionId: sessionId,
      label: label,
      timer: WorkoutTimer.idle(
        kind: TimerKind.hold,
        target: Duration(seconds: seconds),
        setLogId: setId,
      ).start(_now),
    ),
  );

  Future<void> _begin(LiveTimer live) async {
    final alerts = ref.read(alertsProvider);
    alerts.commit();
    unawaited(alerts.requestPermission());
    await _set(live);
  }

  Future<void> pause() async {
    final live = state;
    if (live == null) return;
    ref.read(alertsProvider).tick();
    await _set(live.withTimer(live.timer.pause(_now)));
  }

  Future<void> resume() async {
    final live = state;
    if (live == null) return;
    ref.read(alertsProvider).tick();
    await _set(live.withTimer(live.timer.resume(_now)));
  }

  /// Adds or removes time from the target while it runs.
  Future<void> adjust(Duration delta) async {
    final live = state;
    if (live == null) return;
    final t = live.timer;
    var target = t.target + delta;
    if (target < const Duration(seconds: 5)) target = const Duration(seconds: 5);
    ref.read(alertsProvider).tick();
    await _set(
      live.withTimer(
        WorkoutTimer(
          kind: t.kind,
          target: target,
          startedAt: t.startedAt,
          pausedAt: t.pausedAt,
          pausedTotal: t.pausedTotal,
          stoppedAt: t.stoppedAt,
          setLogId: t.setLogId,
        ),
      ),
    );
  }

  /// Ends the timer. A hold records its actual duration into its set and ticks
  /// it off; a rest simply ends. Returns the recorded duration for a hold.
  Future<Duration?> stop() async {
    final live = state;
    if (live == null) return null;
    final stopped = live.timer.stop(_now);
    final elapsed = stopped.elapsed(_now);
    await _clear();
    ref.read(alertsProvider).commit();
    if (stopped.kind == TimerKind.hold && stopped.setLogId != null) {
      final repo = ref.read(sessionRepositoryProvider);
      await repo.updateSet(stopped.setLogId!, durationSeconds: elapsed.inSeconds);
      final session = await repo.load(live.sessionId);
      final set = session?.exercises
          .expand((e) => e.sets)
          .where((s) => s.id == stopped.setLogId)
          .firstOrNull;
      if (set != null) await repo.completeSet(set, at: _now);
      return elapsed;
    }
    return null;
  }

  /// Clears the timer without recording anything.
  Future<void> dismiss() async {
    ref.read(alertsProvider).tap();
    await _clear();
  }

  Future<void> _set(LiveTimer live) async {
    state = live;
    await ref
        .read(sessionRepositoryProvider)
        .saveTimer(live.sessionId, live.timer, label: live.label);
    _arm();
    _mirror(live);
  }

  /// Shows the timer on the lock screen and in the Dynamic Island.
  void _mirror(LiveTimer live) {
    final t = live.timer;
    final start = t.startedAt;
    if (start == null || t.isStopped) return;
    final now = _now;
    // The target moment, shifted by any time spent paused.
    final targetAt = now.add(t.target - t.elapsed(now));
    const LiveActivityService().show(
      label: live.label,
      kind: t.kind.name,
      startedAt: targetAt.subtract(t.target),
      targetAt: targetAt,
      target: t.target,
      pausedElapsed: t.isPaused ? t.elapsed(now) : null,
    );
  }

  Future<void> _clear() async {
    _targetAlarm?.cancel();
    const LiveActivityService().end();
    state = null;
    await ref.read(alertsProvider).cancelTarget();
    await ref.read(sessionRepositoryProvider).clearTimer();
  }

  /// Schedules the background notification and an in-app haptic for the moment
  /// the target is reached.
  void _arm() {
    _targetAlarm?.cancel();
    final live = state;
    final alerts = ref.read(alertsProvider);
    final at = live?.timer.targetAt(_now);
    if (live == null || at == null) {
      alerts.cancelTarget();
      return;
    }
    final hold = live.timer.kind == TimerKind.hold;
    alerts.scheduleTarget(
      at,
      title: hold ? 'Target hit' : 'Rest is up',
      body: hold
          ? '${formatClock(live.timer.target)} done. Keep going or stop when ready.'
          : '${formatClock(live.timer.target)} rest done. Go when you are ready.',
    );
    _targetAlarm = Timer(at.difference(_now), () {
      alerts.targetReached();
      final current = state;
      if (current != null) state = current.withTimer(current.timer);
    });
  }
}

final timerProvider = NotifierProvider<TimerController, LiveTimer?>(TimerController.new);
