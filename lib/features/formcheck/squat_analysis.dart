import 'dart:math' as math;

import '../../core/services/vision.dart';

/// What the clip shows for one squat rep. Every number is measured from 2D
/// landmarks in a side view, so it is an approximation, not a diagnosis.
class SquatRep {
  const SquatRep({
    required this.start,
    required this.bottom,
    required this.end,
    required this.minKneeAngle,
    required this.hipBelowKnee,
    required this.descentSeconds,
    required this.ascentSeconds,
    this.torsoLean,
  });

  final double start;
  final double bottom;
  final double end;

  /// Smallest hip–knee–ankle angle in the rep, degrees (180 = straight leg).
  final double minKneeAngle;

  /// The hip landmark dropped to or below the knee landmark in this view.
  final bool hipBelowKnee;
  final double descentSeconds;
  final double ascentSeconds;

  /// Shoulder–hip line from vertical at the bottom, degrees, if visible.
  final double? torsoLean;
}

class SquatReport {
  const SquatReport({
    required this.reps,
    required this.coverage,
    required this.confidence,
    required this.side,
    required this.kneeAngles,
    this.abstainReason,
  });

  const SquatReport.abstain(String reason, {double coverage = 0})
    : this(
        reps: const [],
        coverage: coverage,
        confidence: 0,
        side: '',
        kneeAngles: const [],
        abstainReason: reason,
      );

  final List<SquatRep> reps;

  /// Share of frames where hip, knee and ankle were all seen.
  final double coverage;

  /// Mean landmark confidence over usable frames, 0–1.
  final double confidence;
  final String side;

  /// (time, knee angle) for the chart.
  final List<(double, double)> kneeAngles;

  /// Set when the clip was not good enough to say anything.
  final String? abstainReason;

  bool get abstained => abstainReason != null;
}

/// Thresholds below which the analysis refuses to report.
const minCoverage = .6;
const minConfidence = .35;

SquatReport analyzeSquat(PoseClip clip) {
  final frames = clip.frames;
  if (frames.length < 10) {
    return const SquatReport.abstain('The clip is too short. Record at least two full reps.');
  }

  double sideScore(String s) => frames.fold(
    0.0,
    (sum, f) =>
        sum +
        (f.joints['${s}Hip']?.confidence ?? 0) +
        (f.joints['${s}Knee']?.confidence ?? 0) +
        (f.joints['${s}Ankle']?.confidence ?? 0),
  );
  final side = sideScore('left') >= sideScore('right') ? 'left' : 'right';

  final w = clip.width, h = clip.height;
  final samples = <_Sample>[];
  for (final f in frames) {
    final hip = f.joints['${side}Hip'];
    final knee = f.joints['${side}Knee'];
    final ankle = f.joints['${side}Ankle'];
    if (hip == null || knee == null || ankle == null) continue;
    if (hip.confidence < .3 || knee.confidence < .3 || ankle.confidence < .3) continue;
    final shoulder = f.joints['${side}Shoulder'];
    samples.add(
      _Sample(
        t: f.t,
        hip: math.Point(hip.x * w, hip.y * h),
        knee: math.Point(knee.x * w, knee.y * h),
        ankle: math.Point(ankle.x * w, ankle.y * h),
        shoulder: shoulder != null && shoulder.confidence >= .3
            ? math.Point(shoulder.x * w, shoulder.y * h)
            : null,
        confidence: (hip.confidence + knee.confidence + ankle.confidence) / 3,
      ),
    );
  }

  final coverage = samples.length / frames.length;
  if (coverage < minCoverage) {
    return SquatReport.abstain(
      'Your hips, knees and ankles were only clear in ${(coverage * 100).round()}% of the clip. '
      'Film side-on with your whole body in frame and good light.',
      coverage: coverage,
    );
  }
  final confidence = samples.fold(0.0, (s, x) => s + x.confidence) / samples.length;
  if (confidence < minConfidence) {
    return SquatReport.abstain(
      'The body landmarks were too uncertain to measure. Try brighter light and fitted clothing.',
      coverage: coverage,
    );
  }

  // Hip height, y-down: bigger = lower. Smoothed to steady the landmarks.
  final depth = _smooth(samples.map((s) => s.hip.y).toList(), 5);
  final legs = samples.map((s) => s.hip.distanceTo(s.ankle)).toList()..sort();
  final leg = legs[(legs.length * .8).floor().clamp(0, legs.length - 1)];
  final sorted = [...depth]..sort();
  final standing = sorted[(sorted.length * .1).floor()];
  final down = standing + .22 * leg;
  final up = standing + .10 * leg;

  final reps = <SquatRep>[];
  var inRep = false;
  var startIdx = 0;
  var bottomIdx = 0;
  for (var i = 0; i < depth.length; i++) {
    if (!inRep && depth[i] > down) {
      inRep = true;
      // Walk back to where the descent began.
      startIdx = i;
      while (startIdx > 0 && depth[startIdx - 1] > up) {
        startIdx--;
      }
      bottomIdx = i;
    } else if (inRep) {
      if (depth[i] > depth[bottomIdx]) bottomIdx = i;
      if (depth[i] < up) {
        inRep = false;
        reps.add(_rep(samples, startIdx, bottomIdx, i));
      }
    }
  }

  return SquatReport(
    reps: reps,
    coverage: coverage,
    confidence: confidence,
    side: side,
    kneeAngles: [for (final s in samples) (s.t, _angle(s.hip, s.knee, s.ankle))],
    abstainReason: reps.isEmpty
        ? 'No complete squat reps were found. Stand side-on, start and finish standing tall.'
        : null,
  );
}

SquatRep _rep(List<_Sample> s, int start, int bottom, int end) {
  var minAngle = 180.0;
  for (var i = start; i <= end; i++) {
    minAngle = math.min(minAngle, _angle(s[i].hip, s[i].knee, s[i].ankle));
  }
  final b = s[bottom];
  double? lean;
  if (b.shoulder != null) {
    final dx = b.shoulder!.x - b.hip.x;
    final dy = b.hip.y - b.shoulder!.y;
    lean = math.atan2(dx.abs(), dy) * 180 / math.pi;
  }
  return SquatRep(
    start: s[start].t,
    bottom: b.t,
    end: s[end].t,
    minKneeAngle: minAngle,
    hipBelowKnee: b.hip.y >= b.knee.y,
    descentSeconds: b.t - s[start].t,
    ascentSeconds: s[end].t - b.t,
    torsoLean: lean,
  );
}

double _angle(math.Point<double> a, math.Point<double> b, math.Point<double> c) {
  final v1 = a - b, v2 = c - b;
  final dot = v1.x * v2.x + v1.y * v2.y;
  final m = v1.magnitude * v2.magnitude;
  if (m == 0) return 180;
  return math.acos((dot / m).clamp(-1.0, 1.0)) * 180 / math.pi;
}

List<double> _smooth(List<double> v, int window) {
  final half = window ~/ 2;
  return [
    for (var i = 0; i < v.length; i++)
      () {
        var sum = 0.0, n = 0;
        for (var j = math.max(0, i - half); j <= math.min(v.length - 1, i + half); j++) {
          sum += v[j];
          n++;
        }
        return sum / n;
      }(),
  ];
}

class _Sample {
  _Sample({
    required this.t,
    required this.hip,
    required this.knee,
    required this.ankle,
    required this.shoulder,
    required this.confidence,
  });
  final double t;
  final math.Point<double> hip, knee, ankle;
  final math.Point<double>? shoulder;
  final double confidence;
}

/// Plain-language observations. Measured facts first, then cautious cues.
List<String> squatObservations(SquatReport r) {
  if (r.abstained) return const [];
  final n = r.reps.length;
  final below = r.reps.where((x) => x.hipBelowKnee).length;
  final angles = r.reps.map((x) => x.minKneeAngle).toList();
  final mean = angles.reduce((a, b) => a + b) / n;
  final spread = angles.reduce(math.max) - angles.reduce(math.min);
  final descent = r.reps.map((x) => x.descentSeconds).reduce((a, b) => a + b) / n;
  final ascent = r.reps.map((x) => x.ascentSeconds).reduce((a, b) => a + b) / n;
  final leans = r.reps.map((x) => x.torsoLean).whereType<double>().toList();

  return [
    '$n rep${n == 1 ? '' : 's'} detected.',
    'Hip reached knee level or lower on $below of $n reps (in this camera view).',
    'Smallest knee angle averaged ${mean.round()}° (about 90° is thigh-parallel; '
        'this is a 2D estimate).',
    'Average lowering ${descent.toStringAsFixed(1)} s, standing up ${ascent.toStringAsFixed(1)} s.',
    if (spread > 15)
      'Depth varied by about ${spread.round()}° between reps. Matching depth each rep makes progress easier to compare.',
    if (below < n && mean > 100)
      'Some reps stopped above parallel. If you meant to squat deeper, slow the last part of the descent and pause at the bottom.',
    if (descent < .6)
      'The lowering was quick. A controlled one-to-two-second descent is easier to repeat and to judge.',
    if (leans.isNotEmpty && leans.reduce(math.max) > 50)
      'Your torso leaned forward more than 50° at the bottom of at least one rep. That can be normal for your build, '
          'bar position or stance, so treat it as something to watch, not an error.',
  ];
}
