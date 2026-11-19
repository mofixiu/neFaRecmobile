import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:nefarec/core/services/vision.dart';
import 'package:nefarec/features/formcheck/form_analysis.dart';
import 'package:nefarec/features/formcheck/live_form.dart';

/// A side-on push-up at elbow angle [elbow], hips in line, on a square frame.
LivePose _pushUp(double elbow, {double conf = .9}) {
  const l = .12;
  const wrist = (.40, .80);
  final half = elbow * math.pi / 360;
  final shoulderY = wrist.$2 - 2 * l * math.sin(half);
  final elbowPt = (wrist.$1 + l * math.cos(half), (wrist.$2 + shoulderY) / 2);
  const ankle = (.85, .80);
  final shoulder = (wrist.$1, shoulderY);
  final hip = ((shoulder.$1 + ankle.$1) / 2, (shoulder.$2 + ankle.$2) / 2);
  Joint j((double, double) p) => Joint(p.$1, p.$2, conf);
  return LivePose(
    width: 1000,
    height: 1000,
    joints: {
      'leftWrist': j(wrist),
      'leftElbow': j(elbowPt),
      'leftShoulder': j(shoulder),
      'leftHip': j(hip),
      'leftKnee': j((.7, .8)),
      'leftAnkle': j(ankle),
    },
  );
}

/// Feeds [seconds] of push-ups at 10 fps, [reps] reps, starting from the top.
List<bool> _feed(LiveFormTracker t, {int reps = 3, double seconds = 9, double start = 0, double conf = .9}) {
  final counted = <bool>[];
  for (var i = 0; i < (seconds * 10).round(); i++) {
    final time = start + i / 10;
    final phase = math.pow(math.sin(math.pi * ((i / 10 / seconds) * reps % 1)), 2).toDouble();
    counted.add(t.add(time, _pushUp(170 - 95 * phase, conf: conf)));
  }
  // Then hold at the top for a second, as you would after the last rep.
  for (var i = 0; i < 10; i++) {
    counted.add(t.add(start + seconds + i / 10, _pushUp(170, conf: conf)));
  }
  return counted;
}

void main() {
  test('counts push-ups live as each one finishes', () {
    final t = LiveFormTracker(Movement.pushUp);
    final counted = _feed(t);
    expect(t.reps, 3);
    expect(t.goodReps, 3);
    // Exactly one "new rep" signal per rep, never early.
    expect(counted.where((x) => x), hasLength(3));
    expect(counted.indexOf(true), greaterThan(20));
    expect(t.lastRep!.line, contains('chest low'));
  });

  test('reports the live angle and which side it measures', () {
    final t = LiveFormTracker(Movement.pushUp);
    t.add(0, _pushUp(90));
    expect(t.visible, isTrue);
    expect(t.side, 'left');
    expect(t.angle, closeTo(90, 2));
  });

  test('waits for the person before counting', () {
    final t = LiveFormTracker(Movement.pushUp);
    for (var i = 0; i < 20; i++) {
      t.add(i / 10, const LivePose(width: 1000, height: 1000, joints: {}));
    }
    expect(t.visible, isFalse);
    expect(t.angle, isNull);
    _feed(t, start: 2);
    expect(t.reps, 3);
  });

  test('finish gives the same report as checking a video', () {
    final t = LiveFormTracker(Movement.pushUp);
    _feed(t);
    final r = t.finish();
    expect(r.abstained, isFalse);
    expect(r.reps, hasLength(3));
    expect(r.observations.first, '3 reps detected.');
  });

  test('finish abstains when nobody was in frame', () {
    final t = LiveFormTracker(Movement.squat);
    t.add(0, const LivePose(width: 1, height: 1, joints: {}));
    expect(t.finish().abstained, isTrue);
  });

  test('walking out of frame after the set keeps the reps', () {
    final t = LiveFormTracker(Movement.pushUp);
    _feed(t);
    expect(t.reps, 3);
    // Twenty seconds of nobody in view before tapping Finish.
    for (var i = 0; i < 200; i++) {
      t.add(10 + i / 10, const LivePose(width: 1000, height: 1000, joints: {}));
    }
    expect(t.reps, 3);
    expect(t.visible, isFalse);
    expect(t.finish().reps, hasLength(3));
  });

  test('a blurry frame keeps the last pose on screen briefly', () {
    final t = LiveFormTracker(Movement.pushUp);
    t.add(0, _pushUp(100));
    t.add(.1, _pushUp(100, conf: .1));
    expect(t.visible, isTrue);
    expect(t.angle, closeTo(100, 2));
    t.add(1, _pushUp(100, conf: .1));
    expect(t.visible, isFalse);
  });
}
