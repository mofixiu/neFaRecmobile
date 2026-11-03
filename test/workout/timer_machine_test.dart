import 'package:flutter_test/flutter_test.dart';
import 'package:nefarec/features/workout/domain/timer_machine.dart';

void main() {
  final t0 = DateTime(2026, 11, 2, 18);
  DateTime at(int seconds) => t0.add(Duration(seconds: seconds));

  const plank = WorkoutTimer.idle(kind: TimerKind.hold, target: Duration(seconds: 60));
  const rest = WorkoutTimer.idle(kind: TimerKind.rest, target: Duration(seconds: 90));

  test('counts down, hits the target, then runs into overtime', () {
    final t = plank.start(t0);
    expect(t.phase(at(10)), TimerPhase.running);
    expect(t.remaining(at(10)), const Duration(seconds: 50));
    expect(t.phase(at(60)), TimerPhase.targetReached);
    expect(t.phase(at(75)), TimerPhase.overtime);
    expect(t.overtime(at(75)), const Duration(seconds: 15));
    expect(t.elapsed(at(75)), const Duration(seconds: 75));
  });

  test('reaching zero never stops or dismisses the timer by itself', () {
    final t = rest.start(t0);
    expect(t.isStopped, isFalse);
    expect(t.phase(at(60 * 60)), TimerPhase.overtime);
  });

  test('stop freezes the value: no overtime after stopping', () {
    final stopped = plank.start(t0).stop(at(72));
    expect(stopped.phase(at(500)), TimerPhase.stopped);
    expect(stopped.elapsed(at(500)), const Duration(seconds: 72));
    expect(stopped.overtime(at(500)), const Duration(seconds: 12));
  });

  test('holds pause; pauses do not count', () {
    var t = plank.start(t0).pause(at(20));
    expect(t.phase(at(40)), TimerPhase.paused);
    expect(t.elapsed(at(40)), const Duration(seconds: 20));
    t = t.resume(at(50));
    expect(t.elapsed(at(60)), const Duration(seconds: 30));
    expect(t.targetAt(at(60)), at(90));
  });

  test('rest cannot be paused', () {
    final t = rest.start(t0).pause(at(10));
    expect(t.isPaused, isFalse);
    expect(t.phase(at(20)), TimerPhase.running);
  });

  test('survives a round trip through storage and a 10 minute background', () {
    final running = rest.start(t0);
    final restored = WorkoutTimer.fromJson(running.toJson());
    final back = at(10 * 60);
    expect(restored.phase(back), TimerPhase.overtime);
    expect(restored.overtime(back), const Duration(seconds: 510));
  });

  test('a paused hold stays paused across a restore', () {
    final paused = plank.start(t0).pause(at(30));
    final restored = WorkoutTimer.fromJson(paused.toJson());
    expect(restored.elapsed(at(3600)), const Duration(seconds: 30));
    expect(restored.resume(at(3600)).elapsed(at(3610)), const Duration(seconds: 40));
  });

  test('stopping while paused keeps the paused value', () {
    final t = plank.start(t0).pause(at(30)).stop(at(90));
    expect(t.elapsed(at(200)), const Duration(seconds: 30));
  });

  test('target alert time is only offered while counting down', () {
    final t = rest.start(t0);
    expect(t.targetAt(at(10)), at(90));
    expect(t.targetAt(at(95)), isNull);
    expect(t.stop(at(20)).targetAt(at(20)), isNull);
  });
}
