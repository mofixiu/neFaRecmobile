import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/services/vision.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/controls.dart';
import '../../shared/widgets/surfaces.dart';
import 'form_analysis.dart';
import 'live_form.dart';

/// Live form check: the camera watches the set, reps are counted and
/// measured as they happen, and Finish hands back the full report.
/// Frames are read on the phone and never stored.
class LiveFormCheckScreen extends StatefulWidget {
  const LiveFormCheckScreen({super.key, required this.exerciseName, required this.movement});
  final String exerciseName;
  final Movement movement;

  @override
  State<LiveFormCheckScreen> createState() => _LiveFormCheckScreenState();
}

class _LiveFormCheckScreenState extends State<LiveFormCheckScreen> {
  static const _vision = VisionService();

  List<CameraDescription> _cameras = const [];
  CameraDescription? _camera;
  CameraController? _controller;
  late LiveFormTracker _tracker = LiveFormTracker(widget.movement);
  String? _error;
  bool _busy = false;
  DateTime? _start;
  int _flash = 0;

  @override
  void initState() {
    super.initState();
    _open();
  }

  Future<void> _open() async {
    try {
      _cameras = await availableCameras();
    } on CameraException catch (e) {
      setState(() => _error = _message(e));
      return;
    }
    if (_cameras.isEmpty) {
      setState(() => _error = 'No camera on this device. Use Choose a video instead.');
      return;
    }
    // Front camera first, so you can glance at the screen while you lift.
    final front = _cameras.where((c) => c.lensDirection == CameraLensDirection.front);
    await _use(front.isNotEmpty ? front.first : _cameras.first);
  }

  Future<void> _use(CameraDescription camera) async {
    final old = _controller;
    setState(() {
      _controller = null;
      _camera = camera;
      _tracker = LiveFormTracker(widget.movement);
      _start = null;
    });
    await old?.dispose();
    final controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
    );
    try {
      await controller.initialize();
      await controller.lockCaptureOrientation(DeviceOrientation.portraitUp);
      await controller.startImageStream(_onFrame);
    } on CameraException catch (e) {
      await controller.dispose();
      if (mounted) setState(() => _error = _message(e));
      return;
    }
    if (!mounted) {
      await controller.dispose();
      return;
    }
    setState(() => _controller = controller);
  }

  String _message(CameraException e) => switch (e.code) {
    'CameraAccessDenied' || 'CameraAccessDeniedWithoutPrompt' || 'CameraAccessRestricted' =>
      'neFaRec needs the camera to watch your set. Allow it in Settings, then try again.',
    _ => 'The camera could not start. (${e.description ?? e.code})',
  };

  void _onFrame(CameraImage image) {
    final camera = _camera;
    if (_busy || camera == null || !mounted) return;
    _busy = true;
    final now = DateTime.now();
    _start ??= now;
    final t = now.difference(_start!).inMicroseconds / 1e6;
    final plane = image.planes.first;
    // Android frames come in sensor orientation; iOS frames are already upright.
    final rotation = Platform.isAndroid || image.width > image.height ? camera.sensorOrientation : 0;
    // The front preview is a mirror. iOS frames are mirrored to match; Android's are not.
    final mirror = Platform.isAndroid && camera.lensDirection == CameraLensDirection.front;
    _vision
        .poseFromFrame(
          bytes: plane.bytes,
          width: image.width,
          height: image.height,
          bytesPerRow: plane.bytesPerRow,
          rotation: rotation,
        )
        .then((pose) {
          if (!mounted) return;
          final shown = mirror
              ? LivePose(
                  width: pose.width,
                  height: pose.height,
                  joints: {
                    for (final e in pose.joints.entries)
                      e.key: Joint(1 - e.value.x, e.value.y, e.value.confidence),
                  },
                )
              : pose;
          final newRep = _tracker.add(t, shown);
          if (newRep) {
            HapticFeedback.mediumImpact();
            _flash++;
          }
          setState(() {});
        })
        .catchError((Object _) {})
        .whenComplete(() => _busy = false);
  }

  Future<void> _finish() async {
    final report = _tracker.finish();
    await _controller?.stopImageStream().catchError((Object _) {});
    if (mounted) Navigator.of(context).pop(report);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    final controller = _controller;
    final canFlip = _cameras.length > 1 && controller != null;
    return Scaffold(
      backgroundColor: c.board,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
              child: Row(
                children: [
                  RoundIconButton(
                    icon: Icons.close_rounded,
                    label: 'Close',
                    color: c.onBoard,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(color: c.accent, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 6),
                            Text('LIVE FORM CHECK', style: NefaType.eyebrow(color: c.accent)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.exerciseName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: NefaType.style(17, 800, color: c.onBoard),
                        ),
                      ],
                    ),
                  ),
                  if (canFlip)
                    RoundIconButton(
                      icon: Icons.cameraswitch_rounded,
                      label: 'Switch camera',
                      color: c.onBoard,
                      onPressed: () {
                        final next = _cameras.firstWhere(
                          (x) => x.lensDirection != _camera?.lensDirection,
                          orElse: () => _cameras.first,
                        );
                        _use(next);
                      },
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: NefaSpace.gutter),
                child: Center(child: _preview(context, controller)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(NefaSpace.gutter, 14, NefaSpace.gutter, 12),
              child: _panel(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _preview(BuildContext context, CameraController? controller) {
    final c = context.nefa;
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Notice(text: _error!, tone: NoticeTone.warn),
      );
    }
    if (controller == null || !controller.value.isInitialized) {
      return Text('Starting the camera…', style: NefaType.style(14, 600, color: c.boardMuted));
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(NefaRadii.lg + 4),
      child: AspectRatio(
        aspectRatio: 1 / controller.value.aspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CameraPreview(controller),
            CustomPaint(
              painter: _SkeletonPainter(
                tracker: _tracker,
                line: c.accent,
                joint: c.onBoard,
                faint: c.onBoard.withValues(alpha: .35),
                label: c.board,
              ),
            ),
            if (!_tracker.visible)
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: c.board.withValues(alpha: .86),
                    borderRadius: BorderRadius.circular(NefaRadii.md),
                  ),
                  child: Text(
                    'Step back until your whole body is in frame, side-on to the camera.',
                    textAlign: TextAlign.center,
                    style: NefaType.style(13.5, 700, height: 1.35, color: c.onBoard),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _panel(BuildContext context) {
    final c = context.nefa;
    final t = _tracker;
    final angle = t.angle;
    final last = t.lastRep;
    final status = !t.visible
        ? 'Waiting for you to step into frame.'
        : last == null
        ? 'Go. Each rep counts when you’re back at the start.'
        : 'Rep ${t.reps}: ${last.line}';
    return BoardCard(
      color: const Color(0xFF2E2A24),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _LiveStat(
                  label: 'reps',
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    transitionBuilder: (child, a) => ScaleTransition(scale: a, child: child),
                    child: Text(
                      '${t.reps}',
                      key: ValueKey(_flash),
                      style: NefaType.board(36, color: c.onBoard),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _LiveStat(
                  label: angleJoints[widget.movement]!.$2.toLowerCase(),
                  child: Text(
                    angle == null ? '–' : '${angle.round()}°',
                    style: NefaType.board(36, color: c.onBoard),
                  ),
                ),
              ),
              Expanded(
                child: _LiveStat(
                  label: t.goodLabel,
                  child: Text(
                    '${t.goodReps}/${t.reps}',
                    style: NefaType.board(36, color: c.accent),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(status, style: NefaType.style(13.5, 600, height: 1.4, color: c.boardMuted)),
          const SizedBox(height: 14),
          NefaButton(
            label: 'Finish set',
            icon: Icons.check_rounded,
            onPressed: _controller == null ? null : _finish,
          ),
        ],
      ),
    );
  }
}

class _LiveStat extends StatelessWidget {
  const _LiveStat({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        child,
        const SizedBox(height: 4),
        Text(label.toUpperCase(), style: NefaType.eyebrow(color: c.boardMuted, size: 9.5)),
      ],
    );
  }
}

/// The measured side's limbs over the camera, with the live angle at the joint.
class _SkeletonPainter extends CustomPainter {
  _SkeletonPainter({
    required this.tracker,
    required this.line,
    required this.joint,
    required this.faint,
    required this.label,
  });
  final LiveFormTracker tracker;
  final Color line, joint, faint, label;

  @override
  void paint(Canvas canvas, Size size) {
    final side = tracker.side;
    if (side == null) return;
    final other = side == 'left' ? 'right' : 'left';
    final joints = tracker.joints;
    Offset? at(String s, String n) {
      final j = joints['$s$n'];
      if (j == null || j.confidence < .3) return null;
      return Offset(j.x * size.width, j.y * size.height);
    }

    final chain = drawnChain[tracker.movement]!;
    final faintPaint = Paint()
      ..color = faint
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i + 1 < chain.length; i++) {
      final a = at(other, chain[i]), b = at(other, chain[i + 1]);
      if (a != null && b != null) canvas.drawLine(a, b, faintPaint);
    }
    final strong = Paint()
      ..color = line
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    final points = [for (final n in chain) at(side, n)];
    for (var i = 0; i + 1 < points.length; i++) {
      final a = points[i], b = points[i + 1];
      if (a != null && b != null) canvas.drawLine(a, b, strong);
    }
    for (final p in points.whereType<Offset>()) {
      canvas.drawCircle(p, 7, Paint()..color = joint);
      canvas.drawCircle(
        p,
        7,
        Paint()
          ..color = line
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }
    final angle = tracker.angle;
    final vertex = at(side, angleJoints[tracker.movement]!.$2);
    if (angle == null || vertex == null) return;
    final tp = TextPainter(
      text: TextSpan(text: '${angle.round()}°', style: NefaType.style(18, 800, color: joint)),
      textDirection: TextDirection.ltr,
    )..layout();
    final box = Rect.fromCenter(
      center: vertex + Offset(vertex.dx > size.width / 2 ? -54 : 54, -10),
      width: tp.width + 22,
      height: tp.height + 10,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(box, const Radius.circular(20)),
      Paint()..color = label.withValues(alpha: .85),
    );
    tp.paint(canvas, box.center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_SkeletonPainter old) => true;
}
