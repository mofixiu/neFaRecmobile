/// The target-and-overtime timer, as plain data.
///
/// Nothing here ticks. Every value is derived from recorded timestamps, so the
/// timer is correct after the app is backgrounded, suspended or killed: persist
/// the [WorkoutTimer], read it back, and ask it about `now`.
library;

enum TimerKind {
  /// Between sets. Cannot be paused: rest is rest.
  rest,

  /// A prescribed duration: planks, wall sits, dead hangs.
  hold,
}

enum TimerPhase {
  idle,

  /// Counting down toward the target.
  running,

  /// Just hit zero. Lasts [WorkoutTimer.targetMoment] so the UI can celebrate.
  targetReached,

  /// Past the target, counting up. Stays until you stop it.
  overtime,
  paused,

  /// Stopped by you. The elapsed value is frozen.
  stopped,
}

class WorkoutTimer {
  const WorkoutTimer({
    required this.kind,
    required this.target,
    this.startedAt,
    this.pausedAt,
    this.pausedTotal = Duration.zero,
    this.stoppedAt,
    this.setLogId,
  });

  const WorkoutTimer.idle({required this.kind, required this.target, this.setLogId})
    : startedAt = null,
      pausedAt = null,
      pausedTotal = Duration.zero,
      stoppedAt = null;

  static const targetMoment = Duration(milliseconds: 1600);

  final TimerKind kind;
  final Duration target;
  final DateTime? startedAt;
  final DateTime? pausedAt;
  final Duration pausedTotal;
  final DateTime? stoppedAt;

  /// The set this timer belongs to: a hold records into it, a rest follows it.
  final int? setLogId;

  bool get canPause => kind == TimerKind.hold;
  bool get isStarted => startedAt != null;
  bool get isStopped => stoppedAt != null;
  bool get isPaused => pausedAt != null && stoppedAt == null;

  /// Active time, excluding pauses, frozen once stopped.
  Duration elapsed(DateTime now) {
    final start = startedAt;
    if (start == null) return Duration.zero;
    final end = stoppedAt ?? pausedAt ?? now;
    final d = end.difference(start) - pausedTotal;
    return d.isNegative ? Duration.zero : d;
  }

  Duration remaining(DateTime now) {
    final r = target - elapsed(now);
    return r.isNegative ? Duration.zero : r;
  }

  Duration overtime(DateTime now) {
    final o = elapsed(now) - target;
    return o.isNegative ? Duration.zero : o;
  }

  bool reachedTarget(DateTime now) => elapsed(now) >= target;

  /// 0 → 1 toward the target, then stays at 1.
  double progress(DateTime now) {
    if (target <= Duration.zero) return 1;
    return (elapsed(now).inMilliseconds / target.inMilliseconds).clamp(0.0, 1.0);
  }

  /// When the target will be reached, for scheduling an alert. Null if it is
  /// not running, already past, or paused.
  DateTime? targetAt(DateTime now) {
    final start = startedAt;
    if (start == null || isStopped || isPaused) return null;
    if (reachedTarget(now)) return null;
    return start.add(pausedTotal + target);
  }

  TimerPhase phase(DateTime now) {
    if (!isStarted) return TimerPhase.idle;
    if (isStopped) return TimerPhase.stopped;
    if (isPaused) return TimerPhase.paused;
    final e = elapsed(now);
    if (e < target) return TimerPhase.running;
    if (e < target + targetMoment) return TimerPhase.targetReached;
    return TimerPhase.overtime;
  }

  WorkoutTimer start(DateTime now) {
    if (isStarted && !isStopped) return this;
    return WorkoutTimer(kind: kind, target: target, startedAt: now, setLogId: setLogId);
  }

  WorkoutTimer pause(DateTime now) {
    if (!canPause || !isStarted || isStopped || isPaused) return this;
    return _copy(pausedAt: now);
  }

  WorkoutTimer resume(DateTime now) {
    final paused = pausedAt;
    if (paused == null || isStopped) return this;
    return WorkoutTimer(
      kind: kind,
      target: target,
      startedAt: startedAt,
      pausedTotal: pausedTotal + now.difference(paused),
      setLogId: setLogId,
    );
  }

  /// Ends the timer. Overtime stops accumulating here.
  WorkoutTimer stop(DateTime now) {
    if (!isStarted || isStopped) return this;
    // Stopping while paused freezes at the pause point.
    return _copy(stoppedAt: pausedAt ?? now);
  }

  WorkoutTimer _copy({DateTime? pausedAt, DateTime? stoppedAt}) => WorkoutTimer(
    kind: kind,
    target: target,
    startedAt: startedAt,
    pausedAt: pausedAt ?? this.pausedAt,
    pausedTotal: pausedTotal,
    stoppedAt: stoppedAt ?? this.stoppedAt,
    setLogId: setLogId,
  );

  Map<String, Object?> toJson() => {
    'kind': kind.name,
    'targetMs': target.inMilliseconds,
    'startedAt': startedAt?.toUtc().toIso8601String(),
    'pausedAt': pausedAt?.toUtc().toIso8601String(),
    'pausedTotalMs': pausedTotal.inMilliseconds,
    'stoppedAt': stoppedAt?.toUtc().toIso8601String(),
    'setLogId': setLogId,
  };

  factory WorkoutTimer.fromJson(Map<String, Object?> j) {
    DateTime? t(Object? v) => v == null ? null : DateTime.parse(v as String).toLocal();
    return WorkoutTimer(
      kind: TimerKind.values.byName(j['kind'] as String),
      target: Duration(milliseconds: j['targetMs'] as int),
      startedAt: t(j['startedAt']),
      pausedAt: t(j['pausedAt']),
      pausedTotal: Duration(milliseconds: (j['pausedTotalMs'] as int?) ?? 0),
      stoppedAt: t(j['stoppedAt']),
      setLogId: j['setLogId'] as int?,
    );
  }
}
