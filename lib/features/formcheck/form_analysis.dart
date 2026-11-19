import 'dart:math' as math;

import '../../core/services/vision.dart';
import 'squat_analysis.dart';

/// Movements the form check understands. Each is judged from a side view.
enum Movement { squat, pushUp, deadlift, lunge, overheadPress, curl }

const _byMovement = <Movement, Set<String>>{
  Movement.squat: {
    'Barbell_Squat', 'Bodyweight_Squat', 'Goblet_Squat', 'Front_Squat_Clean_Grip', 'Dumbbell_Squat',
    'Barbell_Full_Squat', 'Box_Squat', 'Front_Barbell_Squat', 'Smith_Machine_Squat',
    'Wide_Stance_Barbell_Squat', 'Narrow_Stance_Squats', 'Weighted_Squat', 'Zercher_Squats',
    'Plie_Dumbbell_Squat', 'Front_Squats_With_Two_Kettlebells', 'Squat_with_Bands', 'Squat_with_Chains',
    'Squats_-_With_Bands', 'Overhead_Squat', 'Speed_Squats', 'Olympic_Squat',
  },
  Movement.pushUp: {
    'Pushups', 'Push-Up_Wide', 'Push-Ups_-_Close_Triceps_Position', 'Incline_Push-Up',
    'Incline_Push-Up_Close-Grip', 'Incline_Push-Up_Medium', 'Incline_Push-Up_Wide',
    'Incline_Push-Up_Reverse_Grip', 'Decline_Push-Up', 'Push-Ups_With_Feet_Elevated',
    'Pushups_Close_and_Wide_Hand_Positions', 'Close-Grip_Push-Up_off_of_a_Dumbbell',
  },
  Movement.deadlift: {
    'Barbell_Deadlift', 'Romanian_Deadlift', 'Romanian_Deadlift_from_Deficit', 'Stiff-Legged_Barbell_Deadlift',
    'Stiff-Legged_Dumbbell_Deadlift', 'Smith_Machine_Stiff-Legged_Deadlift', 'Sumo_Deadlift', 'Trap_Bar_Deadlift',
    'Deficit_Deadlift', 'Deadlift_with_Bands', 'Deadlift_with_Chains', 'Sumo_Deadlift_with_Bands',
    'Sumo_Deadlift_with_Chains', 'Axle_Deadlift', 'Snatch_Deadlift', 'Clean_Deadlift', 'Reverse_Band_Deadlift',
    'Reverse_Band_Sumo_Deadlift',
  },
  Movement.lunge: {
    'Barbell_Lunge', 'Barbell_Walking_Lunge', 'Bodyweight_Walking_Lunge', 'Dumbbell_Lunges',
    'Dumbbell_Rear_Lunge', 'Split_Squat_with_Dumbbells', 'Split_Squats', 'Elevated_Back_Lunge',
  },
  Movement.overheadPress: {
    'Barbell_Shoulder_Press', 'Dumbbell_Shoulder_Press', 'Standing_Military_Press', 'Seated_Barbell_Military_Press',
    'Standing_Dumbbell_Press', 'Standing_Palms-In_Dumbbell_Press', 'Push_Press', 'Two-Arm_Kettlebell_Military_Press',
    'Machine_Shoulder_Military_Press', 'Smith_Machine_Overhead_Shoulder_Press',
  },
  Movement.curl: {
    'Barbell_Curl', 'Dumbbell_Bicep_Curl', 'Hammer_Curls', 'EZ-Bar_Curl', 'Close-Grip_EZ_Bar_Curl',
    'Close-Grip_Standing_Barbell_Curl', 'Wide-Grip_Standing_Barbell_Curl', 'Reverse_Barbell_Curl',
    'Standing_Biceps_Cable_Curl', 'Cable_Hammer_Curls_-_Rope_Attachment', 'Preacher_Curl', 'Seated_Dumbbell_Curl',
    'Standing_Dumbbell_Reverse_Curl', 'Zottman_Curl', 'Concentration_Curls',
  },
};

/// The movement an exercise is checked as, or null if the form check can't judge it.
Movement? movementFor(String? exerciseId) {
  if (exerciseId == null) return null;
  for (final e in _byMovement.entries) {
    if (e.value.contains(exerciseId)) return e.key;
  }
  return null;
}

/// How to film each movement, and what gets measured.
String filmingTip(Movement m) => switch (m) {
  Movement.squat =>
    'Film one set side-on, whole body in frame, phone at hip height. neFaRec finds your hips, knees '
        'and ankles in each frame and measures depth, tempo and consistency.',
  Movement.pushUp =>
    'Film one set from the side with the phone on the floor about two metres away, whole body in frame. '
        'neFaRec tracks your shoulders, elbows, hips and ankles and checks depth, body line and tempo.',
  Movement.deadlift =>
    'Film one set side-on, whole body and the bar in frame, phone at hip height. neFaRec tracks your '
        'shoulders, hips and knees and checks how far you hinge, whether you lock out, and tempo.',
  Movement.lunge =>
    'Film one set side-on, whole body in frame, phone at hip height. neFaRec tracks your hips, knees and '
        'shoulders and checks lunge depth, how upright you stay, and tempo.',
  Movement.overheadPress =>
    'Film one set side-on, arms and hips in frame. neFaRec tracks your shoulders, elbows and wrists and '
        'checks lockout overhead, how low the weight comes, and whether you lean back.',
  Movement.curl =>
    'Film one set side-on, the arm nearest the phone fully in frame. neFaRec tracks your shoulder, elbow '
        'and wrist and checks range of motion and how much you swing.',
};

class FormRep {
  const FormRep({
    required this.start,
    required this.bottom,
    required this.end,
    required this.angle,
    required this.good,
    required this.downSeconds,
    required this.upSeconds,
    required this.line,
  });

  final double start;
  final double bottom;
  final double end;

  /// The movement's key angle at the deepest point of the rep, degrees.
  final double angle;

  /// The rep met the movement's main target (depth, lockout or range).
  final bool good;
  final double downSeconds;
  final double upSeconds;

  /// One-line summary for the per-rep list.
  final String line;
}

/// What the clip shows for one set, for any movement.
class FormReport {
  const FormReport({
    required this.movement,
    required this.reps,
    required this.coverage,
    required this.confidence,
    required this.side,
    required this.series,
    required this.seriesLabel,
    required this.goodLabel,
    required this.observations,
    this.guide,
    this.abstainReason,
  });

  const FormReport.abstain(this.movement, String reason, {this.coverage = 0})
    : reps = const [],
      confidence = 0,
      side = '',
      series = const [],
      seriesLabel = '',
      goodLabel = '',
      observations = const [],
      guide = null,
      abstainReason = reason;

  final Movement movement;
  final List<FormRep> reps;
  final double coverage;
  final double confidence;
  final String side;

  /// (time, angle) for the chart.
  final List<(double, double)> series;

  /// e.g. 'Elbow angle'.
  final String seriesLabel;

  /// Reference line on the chart (90° is thigh-parallel or elbows at a right angle).
  final double? guide;

  /// Stat label for reps that met the target, e.g. 'chest low'.
  final String goodLabel;
  final List<String> observations;
  final String? abstainReason;

  bool get abstained => abstainReason != null;
  int get goodReps => reps.where((r) => r.good).length;
}

FormReport analyzeForm(Movement m, PoseClip clip) => switch (m) {
  Movement.squat => _fromSquat(analyzeSquat(clip)),
  Movement.pushUp => _analyze(clip, _pushUp),
  Movement.deadlift => _analyze(clip, _deadlift),
  Movement.lunge => _analyze(clip, _lunge),
  Movement.overheadPress => _analyze(clip, _press),
  Movement.curl => _analyze(clip, _curl),
};

FormReport _fromSquat(SquatReport r) {
  if (r.abstained) return FormReport.abstain(Movement.squat, r.abstainReason!, coverage: r.coverage);
  return FormReport(
    movement: Movement.squat,
    reps: [
      for (final x in r.reps)
        FormRep(
          start: x.start,
          bottom: x.bottom,
          end: x.end,
          angle: x.minKneeAngle,
          good: x.hipBelowKnee,
          downSeconds: x.descentSeconds,
          upSeconds: x.ascentSeconds,
          line:
              '${x.minKneeAngle.round()}° knee · ${x.hipBelowKnee ? 'hip at/below knee' : 'above knee'} · '
              '${x.descentSeconds.toStringAsFixed(1)} s down / ${x.ascentSeconds.toStringAsFixed(1)} s up'
              '${x.torsoLean == null ? '' : ' · lean ${x.torsoLean!.round()}°'}',
        ),
    ],
    coverage: r.coverage,
    confidence: r.confidence,
    side: r.side,
    series: r.kneeAngles,
    seriesLabel: 'Knee angle',
    guide: 90,
    goodLabel: 'to knee level',
    observations: squatObservations(r),
  );
}

// ---------------------------------------------------------------------------
// A movement is a driving angle that sits high at rest and drops during each
// rep (elbows bend, hips hinge, knees bend), plus its own checks per rep.

typedef _P = math.Point<double>;

class _Frame {
  _Frame(this.t, this.p, this.confidence);
  final double t;

  /// Joint positions in pixels, near side unprefixed ('shoulder'), far side 'far:knee'.
  final Map<String, _P> p;
  final double confidence;
}

class _Spec {
  const _Spec({
    required this.movement,
    required this.required,
    required this.jointsText,
    required this.angle,
    required this.seriesLabel,
    required this.goodLabel,
    required this.guide,
    required this.rep,
    required this.observe,
    this.startsAtRest = true,
  });
  final Movement movement;

  /// Sets start from the rest position (arms straight, standing tall), so a clip
  /// that opens mid-rep has a partial first rep to ignore. False for presses and
  /// deadlifts, which can start from the shoulders or the floor.
  final bool startsAtRest;

  /// Near-side joints that must be visible for a frame to count.
  final List<String> required;

  /// How those joints are named to the user, for the abstain message.
  final String jointsText;
  final double Function(_Frame f) angle;
  final String seriesLabel;
  final String goodLabel;
  final double? guide;

  /// Builds the rep summary from its frames: [start..end], deepest at [bottom].
  final FormRep Function(List<_Frame> f, List<double> a, int start, int bottom, int end) rep;
  final List<String> Function(List<FormRep> reps, List<_Frame> f, List<double> a) observe;
}

const _minCoverage = .6;
const _minConfidence = .35;

FormReport _analyze(PoseClip clip, _Spec spec) {
  final m = spec.movement;
  if (clip.frames.length < 10) {
    return FormReport.abstain(m, 'The clip is too short. Record at least two full reps.');
  }
  const names = ['Shoulder', 'Elbow', 'Wrist', 'Hip', 'Knee', 'Ankle'];
  double sideScore(String s) => clip.frames.fold(0.0, (sum, f) {
    for (final j in spec.required) {
      sum += f.joints['$s${j[0].toUpperCase()}${j.substring(1)}']?.confidence ?? 0;
    }
    return sum;
  });
  final side = sideScore('left') >= sideScore('right') ? 'left' : 'right';
  final far = side == 'left' ? 'right' : 'left';

  final frames = <_Frame>[];
  for (final f in clip.frames) {
    final p = <String, _P>{};
    var conf = 0.0;
    var ok = true;
    for (final n in names) {
      final near = f.joints['$side$n'];
      final key = n.toLowerCase();
      if (near != null && near.confidence >= .3) {
        p[key] = math.Point(near.x * clip.width, near.y * clip.height);
      }
      final other = f.joints['$far$n'];
      if (other != null && other.confidence >= .3) {
        p['far:$key'] = math.Point(other.x * clip.width, other.y * clip.height);
      }
    }
    for (final j in spec.required) {
      final c = f.joints['$side${j[0].toUpperCase()}${j.substring(1)}']?.confidence ?? 0;
      if (c < .3) ok = false;
      conf += c;
    }
    if (ok) frames.add(_Frame(f.t, p, conf / spec.required.length));
  }

  final coverage = frames.length / clip.frames.length;
  if (coverage < _minCoverage) {
    return FormReport.abstain(
      m,
      'Your ${spec.jointsText} were only clear in ${(coverage * 100).round()}% of the clip. '
      'Film from the side with your whole body in frame and good light.',
      coverage: coverage,
    );
  }
  final confidence = frames.fold(0.0, (s, f) => s + f.confidence) / frames.length;
  if (confidence < _minConfidence) {
    return FormReport.abstain(
      m,
      'The body landmarks were too uncertain to measure. Try brighter light and fitted clothing.',
      coverage: coverage,
    );
  }

  final raw = _smooth([for (final f in frames) spec.angle(f)], 3);
  final a = _smooth(raw, 5);
  final sorted = [...a]..sort();
  final top = sorted[(sorted.length * .9).floor().clamp(0, sorted.length - 1)];
  final low = sorted[(sorted.length * .05).floor()];
  final range = top - low;

  final reps = <FormRep>[];
  if (range >= 25) {
    final enter = top - .55 * range;
    final leave = top - .2 * range;
    var inRep = false;
    var start = 0, bottom = 0;
    for (var i = 0; i < a.length; i++) {
      if (!inRep && a[i] < enter) {
        inRep = true;
        start = i;
        while (start > 0 && a[start - 1] < leave) {
          start--;
        }
        bottom = i;
      } else if (inRep) {
        if (a[i] < a[bottom]) bottom = i;
        if (a[i] > leave) {
          inRep = false;
          final openStart = start == 0 && spec.startsAtRest;
          if (!openStart && frames[i].t - frames[start].t >= .35) {
            reps.add(spec.rep(frames, raw, start, bottom, i));
          }
        }
      }
    }
  }

  if (reps.isEmpty) {
    return FormReport.abstain(
      m,
      'No complete reps were found. Film side-on and include the full movement, top to bottom.',
      coverage: coverage,
    );
  }
  return FormReport(
    movement: m,
    reps: reps,
    coverage: coverage,
    confidence: confidence,
    side: side,
    series: [for (var i = 0; i < frames.length; i++) (frames[i].t, raw[i])],
    seriesLabel: spec.seriesLabel,
    guide: spec.guide,
    goodLabel: spec.goodLabel,
    observations: spec.observe(reps, frames, raw),
  );
}

// ---------------------------------------------------------------------------
// Movements

final _pushUp = _Spec(
  movement: Movement.pushUp,
  required: const ['shoulder', 'elbow', 'wrist', 'hip', 'ankle'],
  jointsText: 'shoulders, elbows, hips and ankles',
  angle: (f) => _angle(f.p['shoulder']!, f.p['elbow']!, f.p['wrist']!),
  seriesLabel: 'Elbow angle',
  goodLabel: 'chest low',
  guide: 90,
  rep: (f, a, s, b, e) {
    final minElbow = _minIn(a, s, e);
    final line = _bodyLine(f[b]);
    final good = minElbow <= 95;
    final body = line.$1 >= 160 ? 'straight body' : (line.$2 ? 'hips sagging' : 'hips piked');
    return FormRep(
      start: f[s].t,
      bottom: f[b].t,
      end: f[e].t,
      angle: minElbow,
      good: good,
      downSeconds: f[b].t - f[s].t,
      upSeconds: f[e].t - f[b].t,
      line: '${minElbow.round()}° elbow · ${good ? 'chest low' : 'not low enough'} · $body',
    );
  },
  observe: (reps, f, a) {
    final n = reps.length;
    final good = reps.where((r) => r.good).length;
    var sag = 0, pike = 0;
    for (final r in reps) {
      final line = _bodyLine(f.firstWhere((x) => x.t >= r.bottom));
      if (line.$1 < 160) line.$2 ? sag++ : pike++;
    }
    final down = _mean(reps.map((r) => r.downSeconds));
    final up = _mean(reps.map((r) => r.upSeconds));
    return [
      '$n rep${n == 1 ? '' : 's'} detected.',
      'Elbows bent to about 90° or less on $good of $n reps (in this camera view).',
      if (sag == 0 && pike == 0) 'Your body stayed in a straight line from shoulders to ankles.',
      if (sag > 0) 'Hips sagged below the shoulder-to-ankle line on $sag of $n reps.',
      if (pike > 0) 'Hips piked up above the shoulder-to-ankle line on $pike of $n reps.',
      'Average lowering ${down.toStringAsFixed(1)} s, pushing up ${up.toStringAsFixed(1)} s.',
      if (good < n) 'Some reps stopped short. Lower until your elbows reach about 90°, chest just off the floor.',
      if (sag > 0) 'Squeeze your glutes and brace your stomach to keep your hips in line.',
      if (down < .5) 'The lowering was quick. A controlled second on the way down is easier to repeat.',
    ];
  },
);

final _deadlift = _Spec(
  movement: Movement.deadlift,
  required: const ['shoulder', 'hip', 'knee'],
  jointsText: 'shoulders, hips and knees',
  angle: (f) => _angle(f.p['shoulder']!, f.p['hip']!, f.p['knee']!),
  seriesLabel: 'Hip angle',
  goodLabel: 'locked out',
  guide: null,
  startsAtRest: false,
  rep: (f, a, s, b, e) {
    final hinge = _minIn(a, s, e);
    // Lockout: the most open hip angle shortly after the rep comes back up.
    final until = _indexAfter(f, e, .6);
    final lockout = _maxIn(a, b, until);
    // If the clip stops right as the lifter stands, don't call the rep short.
    final cutOff = f.last.t - f[e].t < .3;
    final good = lockout >= 160 || cutOff;
    final torso = _torsoFromFloor(f[b]);
    return FormRep(
      start: f[s].t,
      bottom: f[b].t,
      end: f[e].t,
      angle: hinge,
      good: good,
      downSeconds: f[b].t - f[s].t,
      upSeconds: f[e].t - f[b].t,
      line:
          '${hinge.round()}° hinge · ${good ? 'locked out' : 'not locked out'} · '
          '${torso == null ? '' : 'torso ${torso.round()}° · '}'
          '${(f[e].t - f[b].t).toStringAsFixed(1)} s up',
    );
  },
  observe: (reps, f, a) {
    final n = reps.length;
    final good = reps.where((r) => r.good).length;
    final hinge = _mean(reps.map((r) => r.angle));
    final torsos = [for (final r in reps) _torsoFromFloor(f.firstWhere((x) => x.t >= r.bottom))].whereType<double>();
    final down = _mean(reps.map((r) => r.downSeconds));
    final up = _mean(reps.map((r) => r.upSeconds));
    return [
      '$n rep${n == 1 ? '' : 's'} detected.',
      'You stood all the way up, hips locked out, on $good of $n reps.',
      'Your hips hinged to about ${hinge.round()}° at the bottom'
          '${torsos.isEmpty ? '' : ', torso about ${_mean(torsos).round()}° from the floor'}.',
      'Average lowering ${down.toStringAsFixed(1)} s, lifting ${up.toStringAsFixed(1)} s.',
      if (good < n) 'Finish every rep standing tall: push your hips through until they are under your shoulders.',
      if (down < .5) 'The weight came down fast. Lowering it under control is easier on your back.',
      'One camera can\'t see whether your back rounds, so keep an eye on that yourself.',
    ];
  },
);

final _lunge = _Spec(
  movement: Movement.lunge,
  required: const ['shoulder', 'hip', 'knee', 'ankle'],
  jointsText: 'hips, knees and ankles',
  angle: (f) {
    final near = _angle(f.p['hip']!, f.p['knee']!, f.p['ankle']!);
    final fh = f.p['far:hip'], fk = f.p['far:knee'], fa = f.p['far:ankle'];
    if (fh == null || fk == null || fa == null) return near;
    return math.min(near, _angle(fh, fk, fa));
  },
  seriesLabel: 'Knee angle',
  goodLabel: 'to parallel',
  guide: 90,
  rep: (f, a, s, b, e) {
    final knee = _minIn(a, s, e);
    final good = knee <= 100;
    final lean = _torsoLean(f[b]);
    return FormRep(
      start: f[s].t,
      bottom: f[b].t,
      end: f[e].t,
      angle: knee,
      good: good,
      downSeconds: f[b].t - f[s].t,
      upSeconds: f[e].t - f[b].t,
      line: '${knee.round()}° knee · ${good ? 'to parallel' : 'above parallel'} · lean ${lean.round()}°',
    );
  },
  observe: (reps, f, a) {
    final n = reps.length;
    final good = reps.where((r) => r.good).length;
    final lean = _mean([for (final r in reps) _torsoLean(f.firstWhere((x) => x.t >= r.bottom))]);
    final down = _mean(reps.map((r) => r.downSeconds));
    final up = _mean(reps.map((r) => r.upSeconds));
    return [
      '$n rep${n == 1 ? '' : 's'} detected.',
      'Your front knee reached about 90° on $good of $n reps (in this camera view).',
      'Your torso leaned about ${lean.round()}° from upright at the bottom.',
      'Average lowering ${down.toStringAsFixed(1)} s, standing up ${up.toStringAsFixed(1)} s.',
      if (good < n) 'Some reps stayed high. Drop your back knee until it nearly touches the floor.',
      if (lean > 25) 'You leaned forward quite a bit. Keep your chest up and your weight over the front foot.',
    ];
  },
);

final _press = _Spec(
  movement: Movement.overheadPress,
  required: const ['shoulder', 'elbow', 'wrist', 'hip'],
  jointsText: 'shoulders, elbows and wrists',
  angle: (f) => _angle(f.p['shoulder']!, f.p['elbow']!, f.p['wrist']!),
  seriesLabel: 'Elbow angle',
  goodLabel: 'locked out',
  guide: 90,
  startsAtRest: false,
  rep: (f, a, s, b, e) {
    final bottomAngle = _minIn(a, s, e);
    final until = _indexAfter(f, e, .6);
    final lockout = _maxIn(a, b, until);
    final top = _argMax(a, b, until);
    final overhead = f[top].p['wrist']!.y < f[top].p['shoulder']!.y;
    final cutOff = f.last.t - f[e].t < .3;
    final good = (lockout >= 155 && overhead) || cutOff;
    final lean = _torsoLean(f[top]);
    return FormRep(
      start: f[s].t,
      bottom: f[b].t,
      end: f[e].t,
      angle: bottomAngle,
      good: good,
      downSeconds: f[b].t - f[s].t,
      upSeconds: f[e].t - f[b].t,
      line: '${lockout.round()}° at the top · ${good ? 'locked out' : 'short of lockout'} · lean ${lean.round()}°',
    );
  },
  observe: (reps, f, a) {
    final n = reps.length;
    final good = reps.where((r) => r.good).length;
    final deep = reps.where((r) => r.angle <= 90).length;
    final lean = _mean([
      for (final r in reps) _torsoLean(f.lastWhere((x) => x.t <= r.end + .3, orElse: () => f.last)),
    ]);
    final down = _mean(reps.map((r) => r.downSeconds));
    final up = _mean(reps.map((r) => r.upSeconds));
    return [
      '$n rep${n == 1 ? '' : 's'} detected.',
      'Arms locked out overhead on $good of $n reps.',
      'The weight came down to about shoulder level on $deep of $n reps.',
      'Average lowering ${down.toStringAsFixed(1)} s, pressing ${up.toStringAsFixed(1)} s.',
      if (good < n) 'Some reps stopped short. Press until your arms are straight and the weight is over your head.',
      if (lean > 12) 'You leaned back about ${lean.round()}°. Squeeze your glutes to keep your ribs down.',
    ];
  },
);

final _curl = _Spec(
  movement: Movement.curl,
  required: const ['shoulder', 'elbow', 'wrist', 'hip'],
  jointsText: 'shoulder, elbow and wrist',
  angle: (f) => _angle(f.p['shoulder']!, f.p['elbow']!, f.p['wrist']!),
  seriesLabel: 'Elbow angle',
  goodLabel: 'full range',
  guide: null,
  rep: (f, a, s, b, e) {
    final squeeze = _minIn(a, s, e);
    final before = _maxIn(a, _indexBefore(f, s, .6), s);
    final after = _maxIn(a, e, _indexAfter(f, e, .6));
    final straight = math.min(before, after);
    final good = squeeze <= 70 && straight >= 140;
    final swing = _swing(f, s, e);
    return FormRep(
      start: f[s].t,
      bottom: f[b].t,
      end: f[e].t,
      angle: squeeze,
      good: good,
      downSeconds: f[e].t - f[b].t,
      upSeconds: f[b].t - f[s].t,
      line: '${squeeze.round()}°–${straight.round()}° · ${good ? 'full range' : 'partial range'} · '
          'swing ${swing.round()}°',
    );
  },
  observe: (reps, f, a) {
    final n = reps.length;
    final good = reps.where((r) => r.good).length;
    final swing = _mean([for (final r in reps) _swing(f, _indexAt(f, r.start), _indexAt(f, r.end))]);
    final up = _mean(reps.map((r) => r.upSeconds));
    final down = _mean(reps.map((r) => r.downSeconds));
    return [
      '$n rep${n == 1 ? '' : 's'} detected.',
      'Full range, arms straight at the bottom and curled up top, on $good of $n reps.',
      'Your torso moved about ${swing.round()}° during each rep.',
      'Average curling up ${up.toStringAsFixed(1)} s, lowering ${down.toStringAsFixed(1)} s.',
      if (good < n) 'Some reps were partial. Straighten your arms at the bottom and curl all the way up.',
      if (swing > 12) 'There was some swing. Keep your elbows at your sides so your biceps do the work.',
      if (down < .6) 'The lowering was quick. Slowing it down works the muscle more.',
    ];
  },
);

// ---------------------------------------------------------------------------
// Geometry

double _angle(_P a, _P b, _P c) {
  final v1 = a - b, v2 = c - b;
  final dot = v1.x * v2.x + v1.y * v2.y;
  final m = v1.magnitude * v2.magnitude;
  if (m == 0) return 180;
  return math.acos((dot / m).clamp(-1.0, 1.0)) * 180 / math.pi;
}

/// Shoulder–hip–ankle angle (180 = straight) and whether the hip sits below
/// the shoulder–ankle line (a sag) rather than above it (a pike). Image y is down.
(double, bool) _bodyLine(_Frame f) {
  final s = f.p['shoulder']!, h = f.p['hip']!, a = f.p['ankle']!;
  final angle = _angle(s, h, a);
  final t = a.x == s.x ? 0.5 : ((h.x - s.x) / (a.x - s.x)).clamp(0.0, 1.0);
  final lineY = s.y + (a.y - s.y) * t;
  return (angle, h.y > lineY);
}

/// Shoulder–hip line from vertical, degrees.
double _torsoLean(_Frame f) {
  final s = f.p['shoulder']!, h = f.p['hip']!;
  return math.atan2((s.x - h.x).abs(), (h.y - s.y).abs()) * 180 / math.pi;
}

/// Shoulder–hip line from horizontal, degrees, if the shoulder is visible.
double? _torsoFromFloor(_Frame f) {
  final s = f.p['shoulder'], h = f.p['hip'];
  if (s == null || h == null) return null;
  return math.atan2((h.y - s.y).abs(), (s.x - h.x).abs()) * 180 / math.pi;
}

/// How much the torso rocked during a rep (and just around it), degrees.
double _swing(List<_Frame> f, int s, int e) {
  var lo = 180.0, hi = 0.0;
  for (var i = _indexBefore(f, s, .4); i <= _indexAfter(f, e, .4); i++) {
    final l = _torsoLean(f[i]);
    lo = math.min(lo, l);
    hi = math.max(hi, l);
  }
  return hi - lo;
}

double _minIn(List<double> a, int s, int e) {
  var m = a[s];
  for (var i = s; i <= e; i++) {
    m = math.min(m, a[i]);
  }
  return m;
}

double _maxIn(List<double> a, int s, int e) {
  var m = a[s];
  for (var i = s; i <= e; i++) {
    m = math.max(m, a[i]);
  }
  return m;
}

int _argMax(List<double> a, int s, int e) {
  var best = s;
  for (var i = s; i <= e; i++) {
    if (a[i] > a[best]) best = i;
  }
  return best;
}

int _indexAfter(List<_Frame> f, int i, double seconds) {
  var j = i;
  while (j + 1 < f.length && f[j + 1].t <= f[i].t + seconds) {
    j++;
  }
  return j;
}

int _indexBefore(List<_Frame> f, int i, double seconds) {
  var j = i;
  while (j > 0 && f[j - 1].t >= f[i].t - seconds) {
    j--;
  }
  return j;
}

int _indexAt(List<_Frame> f, double t) {
  final i = f.indexWhere((x) => x.t >= t);
  return i < 0 ? f.length - 1 : i;
}

double _mean(Iterable<double> v) => v.isEmpty ? 0 : v.reduce((a, b) => a + b) / v.length;

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
