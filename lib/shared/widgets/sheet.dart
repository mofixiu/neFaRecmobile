import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';
import 'controls.dart';

/// Every sheet: a floating paper ticket, lifted off the screen edges, with a
/// tab to pull it, an icon medallion, a scrolling body and, when there is one,
/// a footer torn off along a perforated line with notches at both edges.
Future<T?> showNefaSheet<T>(
  BuildContext context, {
  required String title,
  String? subtitle,
  IconData? icon,
  required WidgetBuilder builder,
  WidgetBuilder? footer,
  bool expand = false,
}) {
  final reduce = MediaQuery.disableAnimationsOf(context);
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    barrierColor: Colors.black.withValues(alpha: .34),
    sheetAnimationStyle: reduce
        ? AnimationStyle.noAnimation
        : const AnimationStyle(
            duration: Duration(milliseconds: 440),
            reverseDuration: Duration(milliseconds: 260),
          ),
    builder: (context) => NefaSheet(
      title: title,
      subtitle: subtitle,
      icon: icon,
      expand: expand,
      footer: footer == null ? null : footer(context),
      child: Builder(builder: builder),
    ),
  );
}

class NefaSheet extends StatelessWidget {
  const NefaSheet({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.icon,
    this.footer,
    this.expand = false,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget child;
  final Widget? footer;
  final bool expand;

  static const _radius = 32.0;
  static const _inset = 8.0;

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    final media = MediaQuery.of(context);
    final keyboard = media.viewInsets.bottom;
    // Sit just above the home indicator, or right on the keyboard.
    final bottom = keyboard > 0 ? keyboard + _inset : math.max(_inset, media.padding.bottom - 18);
    final maxHeight = (media.size.height - media.padding.top - bottom) * (expand ? .95 : .9);
    final route = ModalRoute.of(context)?.animation ?? kAlwaysCompleteAnimation;
    final reveal = CurvedAnimation(
      parent: route,
      curve: const Interval(.25, 1, curve: NefaMotion.ease),
    );
    final pop = CurvedAnimation(
      parent: route,
      curve: const Interval(.3, 1, curve: Curves.elasticOut),
    );

    final body = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        // The pull tab.
        Container(
          width: 38,
          height: 5,
          decoration: BoxDecoration(color: c.rule, borderRadius: BorderRadius.circular(3)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 14, 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null) ...[
                ScaleTransition(
                  scale: Tween(begin: .55, end: 1.0).animate(pop),
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(color: c.accentWash, shape: BoxShape.circle),
                    child: Icon(icon, color: c.accentInk, size: 22),
                  ),
                ),
                const SizedBox(width: 14),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: NefaType.style(21, 900, height: 1.12, tracking: -.6, color: c.ink),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 5),
                      Text(
                        subtitle!,
                        style: NefaType.style(13.5, 500, height: 1.4, color: c.muted),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              RoundIconButton(
                icon: Icons.close_rounded,
                label: 'Close',
                size: 40,
                filled: true,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ],
          ),
        ),
        Flexible(
          fit: expand ? FlexFit.tight : FlexFit.loose,
          child: FadeTransition(
            opacity: reveal,
            child: SlideTransition(
              position: Tween(begin: const Offset(0, .04), end: Offset.zero).animate(reveal),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 14, 20, footer == null ? 22 : 18),
                child: child,
              ),
            ),
          ),
        ),
      ],
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(_inset, 0, _inset, bottom),
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          constraints: BoxConstraints(maxHeight: maxHeight),
          height: expand ? maxHeight : null,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_radius),
            boxShadow: nefaRaisedShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                fit: expand ? FlexFit.tight : FlexFit.loose,
                child: DecoratedBox(
                  decoration: ShapeDecoration(
                    color: c.raised,
                    shape: TicketPiece(
                      topRadius: _radius,
                      bottomRadius: footer == null ? _radius : 0,
                      notchBottom: footer != null,
                    ),
                  ),
                  child: body,
                ),
              ),
              if (footer != null)
                DecoratedBox(
                  decoration: ShapeDecoration(
                    color: c.raised,
                    shape: const TicketPiece(bottomRadius: _radius, notchTop: true),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 1, child: CustomPaint(painter: Perforation(c.rule))),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
                        child: FadeTransition(opacity: reveal, child: footer),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One half of a ticket. Pieces stacked on top of each other read as one card
/// with semicircle notches cut where they meet, whatever their heights.
class TicketPiece extends ShapeBorder {
  const TicketPiece({
    this.topRadius = 0,
    this.bottomRadius = 0,
    this.notchTop = false,
    this.notchBottom = false,
  });

  final double topRadius;
  final double bottomRadius;
  final bool notchTop;
  final bool notchBottom;

  static const notch = 10.0;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  Path _path(Rect r) {
    var card = Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          r,
          topLeft: Radius.circular(topRadius),
          topRight: Radius.circular(topRadius),
          bottomLeft: Radius.circular(bottomRadius),
          bottomRight: Radius.circular(bottomRadius),
        ),
      );
    final cuts = Path();
    if (notchTop) {
      cuts
        ..addOval(Rect.fromCircle(center: r.topLeft, radius: notch))
        ..addOval(Rect.fromCircle(center: r.topRight, radius: notch));
    }
    if (notchBottom) {
      cuts
        ..addOval(Rect.fromCircle(center: r.bottomLeft, radius: notch))
        ..addOval(Rect.fromCircle(center: r.bottomRight, radius: notch));
    }
    if (notchTop || notchBottom) card = Path.combine(PathOperation.difference, card, cuts);
    return card;
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) => _path(rect);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => _path(rect);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => TicketPiece(
    topRadius: topRadius * t,
    bottomRadius: bottomRadius * t,
    notchTop: notchTop,
    notchBottom: notchBottom,
  );
}

/// The dashed tear line between ticket pieces.
class Perforation extends CustomPainter {
  Perforation(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    for (var x = 18.0; x < size.width - 18; x += 9) {
      canvas.drawLine(Offset(x, 0), Offset(x + 4, 0), p);
    }
  }

  @override
  bool shouldRepaint(Perforation old) => old.color != color;
}
