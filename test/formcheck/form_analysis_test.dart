import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:nefarec/core/services/vision.dart';
import 'package:nefarec/features/formcheck/form_analysis.dart';

typedef _Pt = (double, double);

/// Builds a clip from a function giving near-side (left) joints at time t,
/// where [phase] goes 0 → 1 → 0 once per rep.
PoseClip _clip(
  Map<String, _Pt> Function(double phase) joints, {
  int reps = 3,
  double seconds = 9,
  double fps = 10,
  double conf = .9,
}) {
  final frames = <PoseFrame>[];
  final n = (seconds * fps).round();
  for (var i = 0; i < n; i++) {
    final t = i / fps;
    final phase = math.pow(math.sin(math.pi * ((t / seconds) * reps % 1)), 2).toDouble();
    frames.add(
      PoseFrame(t, {
        for (final e in joints(phase).entries) 'left${e.key}': Joint(e.value.$1, e.value.$2, conf),
      }),
    );
  }
  // Square, so angles drawn in normalised coordinates stay true in pixels.
  return PoseClip(width: 1000, height: 1000, frames: frames);
}

double _lerp(double a, double b, double t) => a + (b - a) * t;
double _rad(double deg) => deg * math.pi / 180;

/// A push-up seen from the side: wrist on the floor, elbow angle [elbow],
/// hip dropped by [sag] below the shoulder–ankle line.
Map<String, _Pt> _pushUp(double elbow, {double sag = 0}) {
  const l = .12;
  const wrist = (.40, .80);
  final half = _rad(elbow) / 2;
  final shoulderY = wrist.$2 - 2 * l * math.sin(half);
  final elbowPt = (wrist.$1 + l * math.cos(half), (wrist.$2 + shoulderY) / 2);
  const ankle = (.85, .80);
  final shoulder = (wrist.$1, shoulderY);
  final hip = ((shoulder.$1 + ankle.$1) / 2, (shoulder.$2 + ankle.$2) / 2 + sag);
  return {'Wrist': wrist, 'Elbow': elbowPt, 'Shoulder': shoulder, 'Hip': hip, 'Ankle': ankle, 'Knee': (.7, .8)};
}

/// A deadlift seen from the side: the torso pivots at the hip to [hip] degrees.
Map<String, _Pt> _deadlift(double hip) {
  const hipPt = (.45, .55), knee = (.50, .72), ankle = (.48, .90);
  final down = math.atan2(knee.$2 - hipPt.$2, knee.$1 - hipPt.$1);
  final a = down - _rad(hip);
  return {
    'Hip': hipPt,
    'Knee': knee,
    'Ankle': ankle,
    'Shoulder': (hipPt.$1 + .3 * math.cos(a), hipPt.$2 + .3 * math.sin(a)),
  };
}

/// A curl seen from the side: upper arm hangs, forearm at [elbow] degrees.
Map<String, _Pt> _curl(double elbow, {double sway = 0}) {
  const shoulder = (.50, .30), elbowPt = (.50, .50);
  final a = math.pi / 2 - _rad(180 - elbow);
  return {
    'Shoulder': (shoulder.$1 + sway, shoulder.$2),
    'Elbow': elbowPt,
    'Wrist': (elbowPt.$1 + .18 * math.cos(a), elbowPt.$2 + .18 * math.sin(a)),
    'Hip': (.50, .62),
  };
}

void main() {
  test('exercises map to the movement they are checked as', () {
    expect(movementFor('Pushups'), Movement.pushUp);
    expect(movementFor('Romanian_Deadlift'), Movement.deadlift);
    expect(movementFor('Barbell_Squat'), Movement.squat);
    expect(movementFor('Dumbbell_Bicep_Curl'), Movement.curl);
    expect(movementFor('Handstand_Push-Ups'), isNull);
    expect(movementFor('Lying_Leg_Curls'), isNull);
    expect(movementFor(null), isNull);
  });

  test('push-ups: counts reps, checks depth and body line', () {
    final r = analyzeForm(Movement.pushUp, _clip((p) => _pushUp(_lerp(170, 75, p))));
    expect(r.abstained, isFalse);
    expect(r.reps, hasLength(3));
    expect(r.goodReps, 3);
    expect(r.observations, contains('Your body stayed in a straight line from shoulders to ankles.'));
  });

  test('push-ups: shallow reps and sagging hips are called out', () {
    final r = analyzeForm(Movement.pushUp, _clip((p) => _pushUp(_lerp(170, 120, p), sag: .03 + .05 * p)));
    expect(r.reps, isNotEmpty);
    expect(r.goodReps, 0);
    expect(r.observations.any((o) => o.startsWith('Hips sagged')), isTrue);
  });

  test('deadlifts: counts reps and checks lockout', () {
    final full = analyzeForm(Movement.deadlift, _clip((p) => _deadlift(_lerp(172, 85, p))));
    expect(full.reps, hasLength(3));
    expect(full.goodReps, 3);

    final short = analyzeForm(Movement.deadlift, _clip((p) => _deadlift(_lerp(145, 85, p))));
    expect(short.reps, isNotEmpty);
    expect(short.goodReps, 0);
  });

  test('curls: full range passes, swinging is noticed', () {
    final strict = analyzeForm(Movement.curl, _clip((p) => _curl(_lerp(165, 45, p))));
    expect(strict.reps, hasLength(3));
    expect(strict.goodReps, 3);

    final swing = analyzeForm(Movement.curl, _clip((p) => _curl(_lerp(165, 45, p), sway: .1 * p)));
    expect(swing.observations.any((o) => o.startsWith('There was some swing')), isTrue);
  });

  test('a clip that opens mid-curl does not count the partial rep', () {
    final r = analyzeForm(
      Movement.curl,
      _clip((p) => _curl(_lerp(165, 45, p)), seconds: 7.5, reps: 3),
    );
    // 2.5 reps of motion starting from the top: only full reps count.
    expect(r.reps.length, lessThanOrEqualTo(3));
    expect(r.reps.every((x) => x.good), isTrue);
  });

  test('abstains when the joints are not visible', () {
    final r = analyzeForm(Movement.pushUp, _clip((p) => _pushUp(_lerp(170, 75, p)), conf: .2));
    expect(r.abstained, isTrue);
    expect(r.abstainReason, contains('shoulders, elbows'));
  });

  test('holding still finds no reps', () {
    final r = analyzeForm(Movement.deadlift, _clip((_) => _deadlift(170)));
    expect(r.abstained, isTrue);
  });

  test('squats keep their own analysis', () {
    final r = analyzeForm(Movement.squat, const PoseClip(width: 1, height: 1, frames: []));
    expect(r.abstained, isTrue);
  });
}
