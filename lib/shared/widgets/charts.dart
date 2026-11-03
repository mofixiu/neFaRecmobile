import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/tokens.dart';
import 'motion.dart';

/// Vertical bars for one measure over time. One hue; tap a bar to read it.
class ColumnChart extends StatefulWidget {
  const ColumnChart({
    super.key,
    required this.values,
    required this.labels,
    required this.format,
    this.height = 150,
  });

  final List<double> values;
  final List<String> labels;
  final String Function(int index) format;
  final double height;

  @override
  State<ColumnChart> createState() => _ColumnChartState();
}

class _ColumnChartState extends State<ColumnChart> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    final n = widget.values.length;
    final selected = _selected ?? (n - 1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.format(selected), style: NefaType.style(13, 700, color: c.ink, tabular: true)),
        const SizedBox(height: 10),
        SizedBox(
          height: widget.height,
          child: LayoutBuilder(
            builder: (context, box) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (d) {
                final i = (d.localPosition.dx / (box.maxWidth / n)).floor().clamp(0, n - 1);
                HapticFeedback.selectionClick();
                setState(() => _selected = i);
              },
              // Bars grow from the baseline, left to right, when first shown.
              child: Reveal(
                duration: const Duration(milliseconds: 1100),
                builder: (context, t) => CustomPaint(
                  size: Size(box.maxWidth, widget.height),
                  painter: _ColumnsPainter(
                    widget.values,
                    selected,
                    t: t,
                    bar: c.accent,
                    soft: c.accent.withValues(alpha: c.isDark ? .45 : .38),
                    grid: c.rule,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            for (final (i, l) in widget.labels.indexed)
              Expanded(
                child: Text(
                  l,
                  textAlign: TextAlign.center,
                  style: NefaType.style(
                    10,
                    i == selected ? 800 : 600,
                    color: i == selected ? c.ink : c.faint,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ColumnsPainter extends CustomPainter {
  _ColumnsPainter(
    this.values,
    this.selected, {
    this.t = 1,
    required this.bar,
    required this.soft,
    required this.grid,
  });
  final List<double> values;
  final int selected;
  final double t;
  final Color bar, soft, grid;

  @override
  void paint(Canvas canvas, Size size) {
    final max = values.fold(0.0, math.max);
    final g = Paint()
      ..color = grid
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), g);
    if (max <= 0) return;
    final slot = size.width / values.length;
    final w = math.min(28.0, slot - 8);
    for (final (i, v) in values.indexed) {
      if (v <= 0) continue;
      // Each bar starts a little after the one before it.
      final start = i / values.length * .45;
      final grow = Curves.easeOutBack.transform(((t - start) / .55).clamp(0.0, 1.0));
      final h = math.max(3.0, v / max * (size.height - 4)) * grow;
      if (h <= 0) continue;
      final left = slot * i + (slot - w) / 2;
      final r = RRect.fromRectAndCorners(
        Rect.fromLTWH(left, size.height - h, w, h),
        topLeft: const Radius.circular(4),
        topRight: const Radius.circular(4),
      );
      canvas.drawRRect(r, Paint()..color = i == selected ? bar : soft);
    }
  }

  @override
  bool shouldRepaint(_ColumnsPainter old) =>
      old.values != values || old.selected != selected || old.t != t;
}

/// Horizontal bars with labels, for a ranked breakdown.
class BarList extends StatelessWidget {
  const BarList({super.key, required this.rows, this.unit = ''});
  final List<(String, int)> rows;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    final max = rows.fold(0, (m, r) => math.max(m, r.$2));
    return Column(
      children: [
        for (final (label, v) in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                SizedBox(
                  width: 96,
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: NefaType.style(12.5, 700, color: c.ink),
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, box) => Align(
                      alignment: Alignment.centerLeft,
                      child: Reveal(
                        duration: const Duration(milliseconds: 900),
                        curve: Curves.easeOutCubic,
                        builder: (context, t) => Container(
                          height: 12,
                          width: max == 0 ? 0 : math.max(4, box.maxWidth * v / max) * t,
                          decoration: BoxDecoration(
                            color: c.accent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 44,
                  child: CountUp(
                    value: v,
                    format: (n) => '${n.round()}$unit',
                    textAlign: TextAlign.right,
                    style: NefaType.style(12.5, 800, color: c.ink, tabular: true),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// One series over time: 2px line, 8px points, tap to read a point.
class TrendChart extends StatefulWidget {
  const TrendChart({super.key, required this.values, required this.readout, this.height = 140});
  final List<double> values;
  final String Function(int index) readout;
  final double height;

  @override
  State<TrendChart> createState() => _TrendChartState();
}

class _TrendChartState extends State<TrendChart> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    final n = widget.values.length;
    final selected = _selected ?? n - 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.readout(selected), style: NefaType.style(13, 700, color: c.ink, tabular: true)),
        const SizedBox(height: 10),
        SizedBox(
          height: widget.height,
          child: LayoutBuilder(
            builder: (context, box) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (d) {
                if (n < 2) return;
                final i = (d.localPosition.dx / box.maxWidth * (n - 1)).round().clamp(0, n - 1);
                HapticFeedback.selectionClick();
                setState(() => _selected = i);
              },
              // The line draws itself in; each point lands as it is reached.
              child: Reveal(
                duration: const Duration(milliseconds: 1200),
                curve: Curves.easeInOutCubic,
                builder: (context, t) => CustomPaint(
                  size: Size(box.maxWidth, widget.height),
                  painter: _TrendPainter(
                    widget.values,
                    selected,
                    t: t,
                    line: c.accent,
                    grid: c.rule,
                    ring: c.sheet,
                    ink: c.ink,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TrendPainter extends CustomPainter {
  _TrendPainter(
    this.values,
    this.selected, {
    this.t = 1,
    required this.line,
    required this.grid,
    required this.ring,
    required this.ink,
  });
  final List<double> values;
  final int selected;
  final double t;
  final Color line, grid, ring, ink;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    var lo = values.reduce(math.min), hi = values.reduce(math.max);
    if (hi - lo < 1e-6) {
      lo -= 1;
      hi += 1;
    }
    final pad = (hi - lo) * .15;
    lo -= pad;
    hi += pad;
    const inset = 6.0;
    double x(int i) => values.length == 1
        ? size.width / 2
        : inset + i / (values.length - 1) * (size.width - 2 * inset);
    double y(double v) => size.height - (v - lo) / (hi - lo) * size.height;

    final g = Paint()
      ..color = grid
      ..strokeWidth = 1;
    for (var k = 0; k <= 2; k++) {
      final yy = size.height * k / 2;
      canvas.drawLine(Offset(0, yy), Offset(size.width, yy), g);
    }
    final path = Path()..moveTo(x(0), y(values[0]));
    for (var i = 1; i < values.length; i++) {
      path.lineTo(x(i), y(values[i]));
    }
    final metric = path.computeMetrics().firstOrNull;
    canvas.drawPath(
      metric == null ? path : metric.extractPath(0, metric.length * t),
      Paint()
        ..color = line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
    for (var i = 0; i < values.length; i++) {
      final at = values.length == 1 ? 0.0 : i / (values.length - 1);
      final land = ((t - at * .9) / .1).clamp(0.0, 1.0);
      if (land == 0) continue;
      final p = Offset(x(i), y(values[i]));
      final r = (i == selected ? 6.0 : 4.0) * Curves.easeOutBack.transform(land);
      canvas.drawCircle(p, r + 2, Paint()..color = ring);
      canvas.drawCircle(p, r, Paint()..color = i == selected ? ink : line);
    }
  }

  @override
  bool shouldRepaint(_TrendPainter old) =>
      old.values != values || old.selected != selected || old.t != t;
}
