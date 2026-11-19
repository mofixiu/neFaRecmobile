import 'dart:math' as math;

import '../../core/services/vision.dart';
import 'form_analysis.dart';

/// The joints a movement is judged on, near side: the angle is measured at
/// the middle one. Also what has to be visible before a frame counts.
const angleJoints = <Movement, (String, String, String)>{
  Movement.squat: ('Hip', 'Knee', 'Ankle'),
  Movement.lunge: ('Hip', 'Knee', 'Ankle'),
  Movement.deadlift: ('Shoulder', 'Hip', 'Knee'),
  Movement.pushUp: ('Shoulder', 'Elbow', 'Wrist'),
  Movement.overheadPress: ('Shoulder', 'Elbow', 'Wrist'),
  Movement.curl: ('Shoulder', 'Elbow', 'Wrist'),
};

/// The limb chain drawn over the camera, near side, for each movement.
const drawnChain = <Movement, List<String>>{
  Movement.squat: ['Shoulder', 'Hip', 'Knee', 'Ankle'],
  Movement.lunge: ['Shoulder', 'Hip', 'Knee', 'Ankle'],
  Movement.deadlift: ['Shoulder', 'Hip', 'Knee', 'Ankle'],
  Movement.pushUp: ['Wrist', 'Elbow', 'Shoulder', 'Hip', 'Knee', 'Ankle'],
  Movement.overheadPress: ['Wrist', 'Elbow', 'Shoulder', 'Hip'],
  Movement.curl: ['Wrist', 'Elbow', 'Shoulder', 'Hip'],
};

/// Follows a set as it happens: collects camera frames, re-runs the same
/// analysis as the video check every half second, and reports reps as they
/// finish. [finish] gives the full report for the set.
class LiveFormTracker {
  LiveFormTracker(this.movement, {this.analyseEvery = .5, this.maxFrames = 3000});

  final Movement movement;

  /// Seconds between re-analyses of the frames so far.
  final double analyseEvery;
  final int maxFrames;

  final _frames = <PoseFrame>[];
  double _width = 1, _height = 1;
  double _lastAnalysed = -1;
  int? _firstVisible;
  FormReport? _report;
  Map<String, Joint> _latest = const {};
  String? _side;

  /// Adds one frame at [t] seconds into the set. Returns true when a new rep
  /// was counted with this frame.
  bool add(double t, LivePose pose) {
    _width = pose.width;
    _height = pose.height;
    _latest = pose.joints;
    final frame = PoseFrame(t, pose.joints);
    if (_firstVisible == null && _sideFor(pose.joints) != null) _firstVisible = _frames.length;
    _frames.add(frame);
    if (_frames.length > maxFrames) {
      _frames.removeAt(0);
      if (_firstVisible != null && _firstVisible! > 0) _firstVisible = _firstVisible! - 1;
    }
    if (_firstVisible == null || t - _lastAnalysed < analyseEvery) return false;
    _lastAnalysed = t;
    final before = reps;
    _report = analyzeForm(movement, _clip());
    return reps > before;
  }

  PoseClip _clip() => PoseClip(
    width: _width,
    height: _height,
    frames: _frames.sublist(_firstVisible ?? 0),
  );

  /// The near side whose angle joints are all visible in [joints], if any.
  String? _sideFor(Map<String, Joint> joints) {
    final (a, b, c) = angleJoints[movement]!;
    double score(String s) {
      final ja = joints['$s$a'], jb = joints['$s$b'], jc = joints['$s$c'];
      if (ja == null || jb == null || jc == null) return -1;
      if (ja.confidence < .3 || jb.confidence < .3 || jc.confidence < .3) return -1;
      return ja.confidence + jb.confidence + jc.confidence;
    }

    final l = score('left'), r = score('right');
    if (l < 0 && r < 0) return null;
    return l >= r ? 'left' : 'right';
  }

  /// The person's measured joints are in this frame.
  bool get visible => (_side = _sideFor(_latest)) != null;

  /// Which side is being measured right now.
  String? get side => _side ?? _sideFor(_latest);

  /// Latest landmarks, normalised to the upright frame.
  Map<String, Joint> get joints => _latest;

  double get frameWidth => _width;
  double get frameHeight => _height;

  /// The movement's angle in the latest frame, degrees.
  double? get angle {
    final s = _sideFor(_latest);
    if (s == null) return null;
    final (a, b, c) = angleJoints[movement]!;
    Point p(String n) => Point(_latest['$s$n']!.x * _width, _latest['$s$n']!.y * _height);
    return _angle(p(a), p(b), p(c));
  }

  /// Reps counted so far (a rep counts once you are back at the start).
  int get reps => (_report == null || _report!.abstained) ? 0 : _report!.reps.length;

  int get goodReps => (_report == null || _report!.abstained) ? 0 : _report!.goodReps;

  FormRep? get lastRep => reps == 0 ? null : _report!.reps.last;

  /// The label for reps that met the target, e.g. 'chest low'.
  String get goodLabel => _report?.goodLabel.isNotEmpty == true ? _report!.goodLabel : _defaultGoodLabel;

  String get _defaultGoodLabel => switch (movement) {
    Movement.squat => 'to knee level',
    Movement.pushUp => 'chest low',
    Movement.deadlift || Movement.overheadPress => 'locked out',
    Movement.lunge => 'to parallel',
    Movement.curl => 'full range',
  };

  /// Seconds of the set so far.
  double get seconds => _frames.isEmpty ? 0 : _frames.last.t - _frames.first.t;

  /// The full report for everything filmed.
  FormReport finish() {
    if (_firstVisible == null || _frames.length < 10) {
      return FormReport.abstain(
        movement,
        'Your body wasn’t clear enough in the camera. Stand side-on with your whole body in frame.',
      );
    }
    return analyzeForm(movement, _clip());
  }
}

typedef Point = math.Point<double>;

double _angle(Point a, Point b, Point c) {
  final v1 = a - b, v2 = c - b;
  final dot = v1.x * v2.x + v1.y * v2.y;
  final m = v1.magnitude * v2.magnitude;
  if (m == 0) return 180;
  return math.acos((dot / m).clamp(-1.0, 1.0)) * 180 / math.pi;
}
