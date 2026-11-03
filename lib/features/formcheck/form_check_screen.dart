import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/services/vision.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/controls.dart';
import '../../shared/widgets/surfaces.dart';
import '../app/navigation.dart';
import 'squat_analysis.dart';
import '../../shared/widgets/motion.dart';

/// Squat variations the first analysis understands. Others are not offered.
const _squats = {
  'Barbell_Squat',
  'Bodyweight_Squat',
  'Goblet_Squat',
  'Front_Squat_Clean_Grip',
  'Dumbbell_Squat',
  'Barbell_Full_Squat',
  'Box_Squat',
};

bool formCheckSupported(String? exerciseId) =>
    exerciseId != null && _squats.contains(exerciseId) && const VisionService().isSupported;

void openFormCheck(BuildContext context, {required String exerciseName}) =>
    push(context, FormCheckScreen(exerciseName: exerciseName));

/// Form check (beta): film a squat side-on, get measured observations.
/// Runs entirely on the phone and never stores the video.
class FormCheckScreen extends StatefulWidget {
  const FormCheckScreen({super.key, required this.exerciseName});
  final String exerciseName;

  @override
  State<FormCheckScreen> createState() => _FormCheckScreenState();
}

class _FormCheckScreenState extends State<FormCheckScreen> {
  SquatReport? _report;
  bool _working = false;
  String? _error;

  Future<void> _pick(ImageSource source) async {
    final video = await ImagePicker().pickVideo(
      source: source,
      maxDuration: const Duration(seconds: 45),
    );
    if (video == null) return;
    setState(() {
      _working = true;
      _error = null;
      _report = null;
    });
    try {
      final clip = await const VisionService().poseFromVideo(video.path, fps: 12);
      if (!mounted) return;
      setState(() => _report = analyzeSquat(clip));
    } catch (e) {
      if (mounted) setState(() => _error = 'That video could not be read on this device. ($e)');
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    final r = _report;
    return PaperScaffold(
      body: Column(
        children: [
          const PageBar(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                NefaSpace.gutter,
                0,
                NefaSpace.gutter,
                MediaQuery.paddingOf(context).bottom + 24,
              ),
              children: [
                Row(
                  children: [
                    const Eyebrow('Form check'),
                    const SizedBox(width: 8),
                    Pill(label: 'Beta', background: c.accentWash, foreground: c.accentInk),
                  ],
                ),
                const SizedBox(height: 8),
                Text(widget.exerciseName, style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 14),
                Text(
                  'Film one set side-on, whole body in frame, phone at hip height. '
                  'neFaRec finds your hips, knees and ankles in each frame and measures depth, '
                  'tempo and consistency.',
                  style: NefaType.style(14.5, 500, height: 1.5, color: c.muted),
                ),
                const SizedBox(height: 14),
                const Notice(
                  text:
                      'Processed on this phone. The video is not uploaded or saved by neFaRec. '
                      'This is a 2D estimate, not a safety check or a diagnosis.',
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: NefaButton(
                        label: 'Record',
                        icon: Icons.videocam_rounded,
                        loading: _working,
                        onPressed: _working ? null : () => _pick(ImageSource.camera),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: NefaButton(
                        label: 'Choose video',
                        icon: Icons.video_library_outlined,
                        tone: ButtonTone.ghost,
                        onPressed: _working ? null : () => _pick(ImageSource.gallery),
                      ),
                    ),
                  ],
                ),
                if (_working) ...[
                  const SizedBox(height: 18),
                  Text(
                    'Reading the clip frame by frame…',
                    style: NefaType.style(13.5, 600, color: c.muted),
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 18),
                  Notice(text: _error!, tone: NoticeTone.danger),
                ],
                if (r != null) ...[
                  const SizedBox(height: 26),
                  if (r.abstained)
                    Notice(text: r.abstainReason!, tone: NoticeTone.warn)
                  else
                    _Results(report: r),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({required this.report});
  final SquatReport report;

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    final r = report;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BoardCard(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _Stat(value: '${r.reps.length}', label: 'reps'),
                  _Stat(
                    value: '${r.reps.where((x) => x.hipBelowKnee).length}/${r.reps.length}',
                    label: 'to knee level',
                  ),
                  _Stat(value: '${(r.confidence * 100).round()}%', label: 'confidence'),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 120,
                width: double.infinity,
                child: CustomPaint(
                  painter: _AngleChart(
                    r.kneeAngles,
                    r.reps,
                    line: c.accent,
                    grid: c.boardEdge,
                    text: c.boardMuted,
                    band: c.onBoard.withValues(alpha: .06),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Knee angle over the clip (${r.side} side). Shaded bands are reps; lower is deeper.',
                style: NefaType.style(11.5, 500, color: c.boardMuted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text('What the clip shows', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        for (final line in squatObservations(r))
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(color: c.accent, shape: BoxShape.circle),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(line, style: NefaType.style(14, 500, height: 1.5, color: c.ink)),
                ),
              ],
            ),
          ),
        const SizedBox(height: 6),
        Text('Per rep', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        for (final (i, rep) in r.reps.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              '${i + 1}.  ${rep.minKneeAngle.round()}° knee · '
              '${rep.hipBelowKnee ? 'hip at/below knee' : 'above knee'} · '
              '${rep.descentSeconds.toStringAsFixed(1)} s down / ${rep.ascentSeconds.toStringAsFixed(1)} s up'
              '${rep.torsoLean == null ? '' : ' · lean ${rep.torsoLean!.round()}°'}',
              style: NefaType.style(13, 600, color: c.muted, tabular: true),
            ),
          ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CountText(value, style: NefaType.value(26, color: c.onBoard)),
          const SizedBox(height: 4),
          Text(label.toUpperCase(), style: NefaType.eyebrow(color: c.boardMuted, size: 9.5)),
        ],
      ),
    );
  }
}

class _AngleChart extends CustomPainter {
  _AngleChart(
    this.points,
    this.reps, {
    required this.line,
    required this.grid,
    required this.text,
    required this.band,
  });
  final List<(double, double)> points;
  final List<SquatRep> reps;
  final Color line, grid, text, band;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final t0 = points.first.$1, t1 = points.last.$1;
    double x(double t) => (t - t0) / (t1 - t0 == 0 ? 1 : t1 - t0) * size.width;
    double y(double a) => (1 - ((a - 40) / 140).clamp(0.0, 1.0)) * size.height;

    for (final r in reps) {
      canvas.drawRect(Rect.fromLTRB(x(r.start), 0, x(r.end), size.height), Paint()..color = band);
    }
    final g = Paint()
      ..color = grid
      ..strokeWidth = 1;
    for (final a in [90.0, 135.0, 180.0]) {
      canvas.drawLine(Offset(0, y(a)), Offset(size.width, y(a)), g);
      final tp = TextPainter(
        text: TextSpan(
          text: '${a.round()}°',
          style: TextStyle(color: text, fontSize: 9),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(size.width - tp.width, y(a) - tp.height - 1));
    }
    final path = Path()..moveTo(x(points.first.$1), y(points.first.$2));
    for (final p in points.skip(1)) {
      path.lineTo(x(p.$1), y(p.$2));
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_AngleChart old) => old.points != points;
}
