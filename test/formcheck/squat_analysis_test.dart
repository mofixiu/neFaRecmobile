import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:nefarec/core/services/vision.dart';
import 'package:nefarec/features/formcheck/squat_analysis.dart';

/// A synthetic side-on squatter: [reps] reps over [seconds], to [depth]
/// (0 = standing, 1 = hip at knee height).
PoseClip _clip({
  int reps = 3,
  double seconds = 9,
  double depth = 1.1,
  double conf = .9,
  double fps = 10,
}) {
  final frames = <PoseFrame>[];
  final n = (seconds * fps).round();
  for (var i = 0; i < n; i++) {
    final t = i / fps;
    final phase = (t / seconds) * reps;
    final s = math.pow(math.sin(math.pi * (phase % 1)), 2).toDouble() * depth;
    const ankle = (x: .5, y: .9);
    const knee = (x: .58, y: .7);
    // Hip moves from above the knee (standing, y=.5) toward/below it.
    final hipY = .5 + .2 * s;
    final hipX = .5 - .08 * s;
    frames.add(
      PoseFrame(t, {
        'leftAnkle': const Joint(.5, .9, .9).withConf(conf),
        'leftKnee': Joint(knee.x, knee.y, conf),
        'leftHip': Joint(hipX, hipY, conf),
        'leftShoulder': Joint(hipX + .05 + .1 * s, hipY - .3, conf),
        'rightAnkle': Joint(ankle.x, ankle.y, .1),
      }),
    );
  }
  return PoseClip(width: 1080, height: 1920, frames: frames);
}

extension on Joint {
  Joint withConf(double c) => Joint(x, y, c);
}

void main() {
  test('counts reps and measures depth', () {
    final r = analyzeSquat(_clip());
    expect(r.abstained, isFalse);
    expect(r.side, 'left');
    expect(r.reps, hasLength(3));
    expect(r.reps.every((x) => x.hipBelowKnee), isTrue);
    expect(squatObservations(r).first, '3 reps detected.');
  });

  test('shallow reps are reported as above knee level', () {
    final r = analyzeSquat(_clip(depth: .55));
    expect(r.reps, isNotEmpty);
    expect(r.reps.any((x) => x.hipBelowKnee), isFalse);
  });

  test('abstains when landmarks are unreliable', () {
    final r = analyzeSquat(_clip(conf: .2));
    expect(r.abstained, isTrue);
    expect(r.reps, isEmpty);
  });

  test('abstains on a clip that is too short', () {
    expect(analyzeSquat(_clip(seconds: .5)).abstained, isTrue);
  });

  test('standing still finds no reps', () {
    final r = analyzeSquat(_clip(depth: 0));
    expect(r.abstained, isTrue);
  });
}
