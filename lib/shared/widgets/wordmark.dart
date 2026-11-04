import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';

/// The neFaRec wordmark: Montserrat ExtraBold, tight, with the R in signal
/// orange. Set [accentR] to false for a single-ink mark.
class NefaWordmark extends StatelessWidget {
  const NefaWordmark({super.key, this.size = 24, this.color, this.accentR = true});

  final double size;
  final Color? color;
  final bool accentR;

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    final ink = color ?? c.ink;
    final style = NefaType.style(size, 800, height: 1, tracking: -size * .05, color: ink);
    return Semantics(
      label: 'neFaRec',
      header: true,
      child: ExcludeSemantics(
        child: Text.rich(
          TextSpan(
            style: style,
            children: [
              const TextSpan(text: 'neFa'),
              TextSpan(
                text: 'R',
                style: accentR ? style.copyWith(color: c.accent) : null,
              ),
              const TextSpan(text: 'ec'),
            ],
          ),
          textScaler: TextScaler.noScaling,
        ),
      ),
    );
  }
}

/// The neFaRec mark: an orange ticket stub, notched and perforated across the
/// middle like the sheets and the finish ticket, with "neFa" above the tear
/// and "Rec" below it (the R in paper). With [label] off it is a plain glyph
/// to sit beside the wordmark.
class NefaTicketMark extends StatelessWidget {
  const NefaTicketMark({super.key, this.width = 84, this.label = true});

  final double width;
  final bool label;

  static const orange = Color(0xFFFF5A1F);
  static const ink = Color(0xFF211E19);
  static const paper = Color(0xFFF8F1E4);

  /// Height to width, from the icon artwork.
  static const ratio = 64 / 84;

  @override
  Widget build(BuildContext context) {
    final height = width * ratio;
    final size = width * .25;
    final style = NefaType.style(size, 900, height: 1, tracking: -size * .05, color: ink);
    Widget half(InlineSpan span) => Expanded(
      child: Center(child: Text.rich(span, textScaler: TextScaler.noScaling)),
    );
    return Semantics(
      label: label ? 'neFaRec' : null,
      excludeSemantics: true,
      child: SizedBox(
        width: width,
        height: height,
        child: CustomPaint(
          painter: TicketMarkPainter(fill: orange, perforation: ink),
          child: label
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: height * .04),
                  child: Column(
                    children: [
                      half(TextSpan(text: 'neFa', style: style)),
                      half(
                        TextSpan(
                          style: style,
                          children: [
                            TextSpan(
                              text: 'R',
                              style: style.copyWith(color: paper),
                            ),
                            const TextSpan(text: 'ec'),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

/// Paints the ticket stub: a softly cornered card with a semicircle bitten out
/// of each side at the tear, and a dashed perforation between them.
class TicketMarkPainter extends CustomPainter {
  const TicketMarkPainter({required this.fill, required this.perforation});
  final Color fill;
  final Color perforation;

  @override
  void paint(Canvas canvas, Size size) {
    final r = Offset.zero & size;
    final notch = size.height * .125;
    final mid = r.center.dy;
    final card = Path()..addRRect(RRect.fromRectAndRadius(r, Radius.circular(size.width * .045)));
    final bites = Path()
      ..addOval(Rect.fromCircle(center: Offset(r.left, mid), radius: notch))
      ..addOval(Rect.fromCircle(center: Offset(r.right, mid), radius: notch));
    canvas.drawPath(Path.combine(PathOperation.difference, card, bites), Paint()..color = fill);

    final dash = Paint()
      ..color = perforation
      ..strokeWidth = size.height * .036
      ..strokeCap = StrokeCap.round;
    final step = size.width * .072;
    for (var x = notch + step * .9; x + step * .45 < size.width - notch - step * .4; x += step) {
      canvas.drawLine(Offset(x, mid), Offset(x + step * .45, mid), dash);
    }
  }

  @override
  bool shouldRepaint(TicketMarkPainter old) => old.fill != fill || old.perforation != perforation;
}

/// The plain ticket glyph and the wordmark, side by side.
class NefaLogo extends StatelessWidget {
  const NefaLogo({super.key, this.size = 24, this.color});
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(child: NefaTicketMark(width: size * 1.15, label: false)),
        SizedBox(width: size * .38),
        NefaWordmark(size: size, color: color),
      ],
    );
  }
}
