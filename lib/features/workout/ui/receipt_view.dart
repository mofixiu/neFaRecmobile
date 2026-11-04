import 'package:flutter/material.dart';
import 'package:paper_kit/paper_kit.dart';

import '../../../core/db/database.dart';
import '../../../core/models/training.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/wordmark.dart';
import '../domain/session_models.dart';

/// A workout printed as a gym till receipt, torn at the bottom, stamped.
class ReceiptView extends StatelessWidget {
  const ReceiptView({
    super.key,
    required this.detail,
    required this.records,
    required this.unit,
    this.stamp = 1,
  });

  final SessionDetail detail;
  final List<PersonalRecord> records;
  final WeightUnit unit;

  /// 0 → 1: how far the DONE stamp has landed.
  final double stamp;

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    const ink = Color(0xFF211E19);
    const faint = Color(0xFF8A8072);
    const paper = Color(0xFFFFFCF4);
    final s = detail.session;
    final body = NefaType.style(13, 600, color: ink, tabular: true, height: 1.35);
    final small = NefaType.style(11.5, 600, color: faint, tabular: true);
    final volume = fromKg(detail.volumeKg, unit);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        PhysicalShape(
          clipper: const _TornBottom(),
          color: paper,
          elevation: 6,
          shadowColor: c.isDark ? Colors.black : const Color(0x88281A0E),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(child: NefaWordmark(size: 22, color: ink)),
                const SizedBox(height: 6),
                Center(
                  child: Text('WORKOUT RECEIPT', style: NefaType.eyebrow(color: faint, size: 10)),
                ),
                const SizedBox(height: 14),
                _Dashed(),
                const SizedBox(height: 10),
                _Line(
                  s.title,
                  _date(s.startedAt),
                  style: NefaType.style(13, 800, color: ink),
                  right: small,
                ),
                if (s.routineName != null && s.routineName != s.title)
                  _Line(s.routineName!, _time(s.startedAt), style: small, right: small),
                const SizedBox(height: 10),
                _Dashed(),
                const SizedBox(height: 10),
                for (final ex in detail.exercises.where(
                  (e) => e.done > 0 || e.exercise.skipped,
                )) ...[
                  _Line(
                    ex.exercise.name,
                    ex.exercise.skipped ? 'SKIPPED' : '${ex.done} SET${ex.done == 1 ? '' : 'S'}',
                    style: NefaType.style(13, 800, color: ink),
                    right: small,
                  ),
                  for (final set in ex.sets.where((x) => x.isDone))
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: _Line(
                        '  ${set.position + 1}.',
                        _setText(set),
                        style: small,
                        right: body,
                      ),
                    ),
                  const SizedBox(height: 8),
                ],
                _Dashed(),
                const SizedBox(height: 10),
                _Line(
                  'TIME',
                  formatClock(detail.elapsed(s.endedAt ?? DateTime.now())),
                  style: body,
                  right: body,
                ),
                _Line('SETS', '${detail.doneSets} / ${detail.totalSets}', style: body, right: body),
                if (volume > 0)
                  _Line('VOLUME', '${volume.round()} ${unit.name}', style: body, right: body),
                const SizedBox(height: 10),
                _Dashed(),
                const SizedBox(height: 12),
                _Line(
                  'TOTAL',
                  records.isEmpty
                      ? 'DONE'
                      : '${records.length} PR${records.length == 1 ? '' : 'S'}',
                  style: NefaType.style(18, 900, color: ink),
                  right: NefaType.style(18, 900, color: ink),
                ),
                for (final r in records) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: c.accent,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text('PR', style: NefaType.style(9.5, 900, color: Colors.white)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${r.exerciseName} · ${r.label}',
                          style: small.copyWith(color: ink),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Volume = load × reps on completed sets. Est. 1RM uses Epley and is an estimate.',
                    textAlign: TextAlign.center,
                    style: NefaType.style(9.5, 500, color: faint, height: 1.4),
                  ),
                ),
                const SizedBox(height: 10),
                Center(child: _Barcode(seed: s.id)),
              ],
            ),
          ),
        ),
        // Over the barcode corner, clear of every number.
        Positioned(
          right: 12,
          bottom: 10,
          child: Opacity(
            opacity: stamp.clamp(0, 1),
            child: Transform.scale(
              scale: 1.6 - .6 * Curves.easeOutBack.transform(stamp.clamp(0, 1)),
              child: Transform.rotate(
                angle: -.22,
                child: PaperStampImpression(
                  label: records.isEmpty ? 'done' : 'new pr',
                  color: records.isEmpty ? const Color(0xFFB8432F) : c.accent,
                  seed: s.id,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static String _setText(SetLog s) {
    if (s.durationSeconds != null && s.reps == null) {
      return formatClock(Duration(seconds: s.durationSeconds!));
    }
    final w = s.weight;
    final reps = s.reps ?? 0;
    if (w == null || w == 0) return '$reps reps';
    return '${formatWeight(w, s.unit)} × $reps';
  }

  static String _date(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  static String _time(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

class _Line extends StatelessWidget {
  const _Line(this.left, this.value, {required this.style, required this.right});
  final String left;
  final String value;
  final TextStyle style;
  final TextStyle right;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Text(left, style: style, overflow: TextOverflow.ellipsis),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: CustomPaint(size: const Size.fromHeight(12), painter: _Dots()),
            ),
          ),
          Text(value, style: right),
        ],
      ),
    );
  }
}

class _Dots extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0x558A8072);
    for (var x = 0.0; x < size.width; x += 4) {
      canvas.drawCircle(Offset(x, size.height - 2), .8, p);
    }
  }

  @override
  bool shouldRepaint(_Dots oldDelegate) => false;
}

class _Dashed extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: const Size.fromHeight(1), painter: _DashPainter());
}

class _DashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0x888A8072)
      ..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += 7) {
      canvas.drawLine(Offset(x, 0), Offset(x + 3.5, 0), p);
    }
  }

  @override
  bool shouldRepaint(_DashPainter oldDelegate) => false;
}

class _Barcode extends StatelessWidget {
  const _Barcode({required this.seed});
  final int seed;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(size: const Size(180, 34), painter: _BarcodePainter(seed)),
    );
  }
}

class _BarcodePainter extends CustomPainter {
  _BarcodePainter(this.seed);
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0xFF211E19);
    var x = 0.0;
    var v = seed * 2654435761 % 4294967296;
    while (x < size.width) {
      v = (v * 1103515245 + 12345) % 2147483648;
      final w = 1.0 + (v % 3);
      if ((v >> 3) % 2 == 0) canvas.drawRect(Rect.fromLTWH(x, 0, w, size.height), p);
      x += w + 1;
    }
  }

  @override
  bool shouldRepaint(_BarcodePainter old) => old.seed != seed;
}

/// Zigzag torn edge along the bottom.
class _TornBottom extends CustomClipper<Path> {
  const _TornBottom();

  @override
  Path getClip(Size size) {
    const tooth = 9.0;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height - tooth);
    var x = size.width;
    var down = true;
    while (x > 0) {
      x -= tooth;
      path.lineTo(x.clamp(0, size.width), down ? size.height : size.height - tooth);
      down = !down;
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_TornBottom oldClipper) => false;
}
