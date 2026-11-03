import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/tokens.dart';
import 'controls.dart';

/// Every dialog in neFaRec: a paper ticket with a perforated tear line above
/// its buttons, notched at both edges. It rises in over a soft blur.
Future<T?> showNefaDialog<T>(BuildContext context, {required WidgetBuilder builder}) {
  final reduce = MediaQuery.disableAnimationsOf(context);
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: Colors.black.withValues(alpha: .32),
    transitionDuration: reduce ? Duration.zero : const Duration(milliseconds: 280),
    pageBuilder: (context, _, _) => builder(context),
    transitionBuilder: (context, anim, _, child) {
      final t = CurvedAnimation(
        parent: anim,
        curve: NefaMotion.ease,
        reverseCurve: Curves.easeInCubic,
      );
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6 * t.value, sigmaY: 6 * t.value),
        child: FadeTransition(
          opacity: t,
          child: AnimatedBuilder(
            animation: t,
            builder: (context, child) => Transform.translate(
              offset: Offset(0, 18 * (1 - t.value)),
              child: Transform.scale(scale: .94 + .06 * t.value, child: child),
            ),
            child: child,
          ),
        ),
      );
    },
  );
}

/// Asks before doing something. True only when the main button is tapped.
Future<bool> showConfirm(
  BuildContext context, {
  required String title,
  String? body,
  required String confirm,
  String cancel = 'Cancel',
  IconData icon = Icons.help_outline_rounded,
  bool destructive = false,
}) async {
  final ok = await showNefaDialog<bool>(
    context,
    builder: (context) => NefaDialog(
      icon: destructive ? Icons.delete_outline_rounded : icon,
      destructive: destructive,
      title: title,
      body: body,
      actions: [
        NefaButton(
          label: confirm,
          tone: destructive ? ButtonTone.danger : ButtonTone.accent,
          height: _buttonHeight,
          onPressed: () {
            HapticFeedback.mediumImpact();
            Navigator.pop(context, true);
          },
        ),
        NefaButton(
          label: cancel,
          tone: ButtonTone.ghost,
          height: _buttonHeight,
          onPressed: () => Navigator.pop(context, false),
        ),
      ],
    ),
  );
  return ok ?? false;
}

/// Asks for one line of text. Null when cancelled.
Future<String?> showPrompt(
  BuildContext context, {
  required String title,
  String? body,
  String? initial,
  String? hint,
  String label = 'Name',
  String confirm = 'Save',
  IconData icon = Icons.edit_outlined,
  TextCapitalization capitalization = TextCapitalization.sentences,
  bool allowEmpty = false,
}) {
  return showNefaDialog<String>(
    context,
    builder: (context) => _Prompt(
      title: title,
      body: body,
      initial: initial,
      hint: hint,
      label: label,
      confirm: confirm,
      icon: icon,
      capitalization: capitalization,
      allowEmpty: allowEmpty,
    ),
  );
}

const _buttonHeight = 52.0;
const _gap = 10.0;
const _actionsTop = 18.0;
const _actionsBottom = 20.0;

/// The ticket card. [actions] sit below the perforation, stacked full width.
class NefaDialog extends StatelessWidget {
  const NefaDialog({
    super.key,
    required this.title,
    required this.actions,
    this.body,
    this.icon,
    this.destructive = false,
    this.child,
  });

  final String title;
  final String? body;
  final IconData? icon;
  final bool destructive;
  final Widget? child;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    final media = MediaQuery.of(context);
    final actionsHeight =
        _actionsTop + _actionsBottom + actions.length * _buttonHeight + (actions.length - 1) * _gap;
    final (wash, ink) = destructive ? (c.dangerWash, c.danger) : (c.accentWash, c.accentInk);

    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Material(
              type: MaterialType.transparency,
              child: DecoratedBox(
                decoration: ShapeDecoration(
                  color: c.raised,
                  shape: _TicketBorder(
                    notchFromBottom: actionsHeight,
                    side: BorderSide(color: c.rule),
                  ),
                  shadows: nefaRaisedShadow,
                ),
                child: Semantics(
                  scopesRoute: true,
                  namesRoute: true,
                  explicitChildNodes: true,
                  label: title,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (icon != null) ...[
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(color: wash, shape: BoxShape.circle),
                                child: Icon(icon, color: ink, size: 24),
                              ),
                              const SizedBox(height: 16),
                            ],
                            Text(
                              title,
                              style: NefaType.style(
                                22,
                                900,
                                height: 1.12,
                                tracking: -.7,
                                color: c.ink,
                              ),
                            ),
                            if (body != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                body!,
                                style: NefaType.style(14.5, 500, height: 1.5, color: c.muted),
                              ),
                            ],
                            if (child != null) ...[const SizedBox(height: 18), child!],
                          ],
                        ),
                      ),
                      // The tear line.
                      SizedBox(height: 1, child: CustomPaint(painter: _Perforation(c.rule))),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, _actionsTop, 22, _actionsBottom),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (final (i, a) in actions.indexed) ...[
                              if (i > 0) const SizedBox(height: _gap),
                              a,
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Owns its text controller, so nothing is disposed while the dialog is
/// still animating closed.
class _Prompt extends StatefulWidget {
  const _Prompt({
    required this.title,
    required this.label,
    required this.confirm,
    required this.icon,
    required this.capitalization,
    required this.allowEmpty,
    this.body,
    this.initial,
    this.hint,
  });

  final String title;
  final String? body;
  final String? initial;
  final String? hint;
  final String label;
  final String confirm;
  final IconData icon;
  final TextCapitalization capitalization;
  final bool allowEmpty;

  @override
  State<_Prompt> createState() => _PromptState();
}

class _PromptState extends State<_Prompt> {
  late final _text = TextEditingController(text: widget.initial ?? '')
    ..selection = TextSelection(baseOffset: 0, extentOffset: (widget.initial ?? '').length);

  @override
  void initState() {
    super.initState();
    _text.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  bool get _canSave => widget.allowEmpty || _text.text.trim().isNotEmpty;

  void _save() {
    if (!_canSave) return;
    HapticFeedback.mediumImpact();
    Navigator.pop(context, _text.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(NefaRadii.md),
      borderSide: BorderSide(color: c.rule),
    );
    return NefaDialog(
      icon: widget.icon,
      title: widget.title,
      body: widget.body,
      actions: [
        NefaButton(
          label: widget.confirm,
          height: _buttonHeight,
          onPressed: _canSave ? _save : null,
        ),
        NefaButton(
          label: 'Cancel',
          tone: ButtonTone.ghost,
          height: _buttonHeight,
          onPressed: () => Navigator.pop(context),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow(widget.label),
          const SizedBox(height: 8),
          TextField(
            controller: _text,
            autofocus: true,
            textCapitalization: widget.capitalization,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
            style: NefaType.style(17, 700, color: c.ink),
            cursorColor: c.accent,
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: c.recessed,
              hintText: widget.hint,
              hintStyle: NefaType.style(15, 500, color: c.faint),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: border,
              enabledBorder: border,
              focusedBorder: border.copyWith(borderSide: BorderSide(color: c.accent, width: 1.6)),
              suffixIcon: _text.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear',
                      icon: Icon(Icons.cancel_rounded, color: c.faint, size: 20),
                      onPressed: _text.clear,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A rounded card with semicircle notches cut into both sides at the tear line.
class _TicketBorder extends ShapeBorder {
  const _TicketBorder({required this.notchFromBottom, this.side = BorderSide.none});

  final double notchFromBottom;
  final BorderSide side;

  static const radius = 28.0;
  static const notch = 10.0;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  Path _path(Rect r) {
    final y = r.bottom - notchFromBottom;
    final card = Path()..addRRect(RRect.fromRectAndRadius(r, const Radius.circular(radius)));
    final cuts = Path()
      ..addOval(Rect.fromCircle(center: Offset(r.left, y), radius: notch))
      ..addOval(Rect.fromCircle(center: Offset(r.right, y), radius: notch));
    return Path.combine(PathOperation.difference, card, cuts);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) => _path(rect);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => _path(rect.deflate(side.width));

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none) return;
    canvas.drawPath(_path(rect.deflate(side.width / 2)), side.toPaint());
  }

  @override
  ShapeBorder scale(double t) =>
      _TicketBorder(notchFromBottom: notchFromBottom * t, side: side.scale(t));
}

class _Perforation extends CustomPainter {
  _Perforation(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    // Leave room for the notches at each end.
    for (var x = 18.0; x < size.width - 18; x += 9) {
      canvas.drawLine(Offset(x, 0), Offset(x + 4, 0), p);
    }
  }

  @override
  bool shouldRepaint(_Perforation old) => old.color != color;
}
