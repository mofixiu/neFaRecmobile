import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/tokens.dart';

/// Shallow scale dip on press: the app's one press response.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scale = .97,
    this.haptic = true,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scale;
  final bool haptic;
  final String? semanticLabel;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null || widget.onLongPress != null;
    return Semantics(
      button: enabled,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => _set(true) : null,
        onTapUp: enabled ? (_) => _set(false) : null,
        onTapCancel: () => _set(false),
        onTap: widget.onTap == null
            ? null
            : () {
                if (widget.haptic) HapticFeedback.lightImpact();
                widget.onTap!();
              },
        onLongPress: widget.onLongPress,
        child: AnimatedScale(
          scale: _down ? widget.scale : 1,
          duration: NefaMotion.press,
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}

enum ButtonTone { accent, ink, ghost, danger }

/// Filled 56px button. One accent action per screen.
class NefaButton extends StatelessWidget {
  const NefaButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.tone = ButtonTone.accent,
    this.loading = false,
    this.expand = true,
    this.height = 56,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final ButtonTone tone;
  final bool loading;
  final bool expand;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    final disabled = onPressed == null;
    final (bg, fg, border) = disabled
        ? (c.recessed, c.faint, c.rule)
        : switch (tone) {
            ButtonTone.accent => (c.accent, c.onAccent, c.accent),
            ButtonTone.ink => (c.ink, c.paper, c.ink),
            ButtonTone.ghost => (Colors.transparent, c.ink, c.rule),
            ButtonTone.danger => (c.danger, c.isDark ? c.paper : Colors.white, c.danger),
          };
    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[Icon(icon, size: 20, color: fg), const SizedBox(width: 10)],
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: NefaType.style(16, 800, tracking: -.2, color: fg),
          ),
        ),
        if (loading) ...[const SizedBox(width: 10), _Dots(color: fg)],
      ],
    );
    return Pressable(
      onTap: disabled || loading ? null : onPressed,
      semanticLabel: label,
      child: AnimatedContainer(
        duration: NefaMotion.small,
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(NefaRadii.md),
          border: Border.all(color: border, width: 1.2),
          boxShadow: !disabled && tone == ButtonTone.accent
              ? [
                  BoxShadow(
                    color: c.accent.withValues(alpha: c.isDark ? .22 : .32),
                    blurRadius: 22,
                    spreadRadius: -8,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: ExcludeSemantics(child: content),
      ),
    );
  }
}

class _Dots extends StatefulWidget {
  const _Dots({required this.color});
  final Color color;
  @override
  State<_Dots> createState() => _DotsState();
}

class _DotsState extends State<_Dots> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
    ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 3; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Opacity(
                opacity: .35 + .65 * ((((_c.value * 3) - i) % 3) < 1 ? 1 : 0),
                child: CircleAvatar(radius: 2.6, backgroundColor: widget.color),
              ),
            ),
        ],
      ),
    );
  }
}

/// Round icon button, 44px target.
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.label,
    this.filled = false,
    this.size = 44,
    this.color,
    this.background,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String label;
  final bool filled;
  final double size;
  final Color? color;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    return Tooltip(
      message: label,
      child: Pressable(
        onTap: onPressed,
        semanticLabel: label,
        scale: .92,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: background ?? (filled ? c.sheet : Colors.transparent),
            border: filled ? Border.all(color: c.rule) : null,
          ),
          child: Icon(icon, size: size * .48, color: color ?? c.ink),
        ),
      ),
    );
  }
}

/// − value + for set counts, seconds and reps.
class NefaStepper extends StatelessWidget {
  const NefaStepper({
    super.key,
    required this.value,
    required this.onChanged,
    required this.format,
    this.step = 1,
    this.min = 0,
    this.max = 999,
    this.label,
    this.highlighted = false,
  });

  final num value;
  final ValueChanged<num> onChanged;
  final String Function(num) format;
  final num step;
  final num min;
  final num max;
  final String? label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    Widget btn(IconData icon, num next, String l) => RoundIconButton(
      icon: icon,
      label: l,
      size: 40,
      filled: true,
      onPressed: next < min || next > max
          ? null
          : () {
              HapticFeedback.selectionClick();
              onChanged(next);
            },
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!.toUpperCase(), style: NefaType.eyebrow(color: c.muted)),
          const SizedBox(height: 8),
        ],
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: c.recessed,
            borderRadius: BorderRadius.circular(NefaRadii.md),
            border: Border.all(color: c.rule),
          ),
          child: Row(
            children: [
              btn(Icons.remove_rounded, value - step, 'Less'),
              Expanded(
                child: Center(
                  child: Highlight(
                    active: highlighted,
                    child: Text(format(value), style: NefaType.value(22, color: c.ink)),
                  ),
                ),
              ),
              btn(Icons.add_rounded, value + step, 'More'),
            ],
          ),
        ),
      ],
    );
  }
}

/// A highlighter stroke behind text that nefaRec suggested rather than read.
class Highlight extends StatelessWidget {
  const Highlight({super.key, required this.child, this.active = true});
  final Widget child;
  final bool active;

  @override
  Widget build(BuildContext context) {
    if (!active) return child;
    return CustomPaint(painter: _HighlighterPainter(context.nefa.highlighter), child: child);
  }
}

class _HighlighterPainter extends CustomPainter {
  _HighlighterPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final top = size.height * .52;
    final path = Path()
      ..moveTo(-3, top + 2)
      ..quadraticBezierTo(size.width * .5, top - 1.5, size.width + 4, top + 1)
      ..lineTo(size.width + 3, size.height + 1)
      ..quadraticBezierTo(size.width * .45, size.height + 3, -2, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_HighlighterPainter old) => old.color != color;
}

/// A short pill: status, metadata, target summary.
class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.label,
    this.icon,
    this.background,
    this.foreground,
    this.onTap,
    this.selected = false,
  });

  final String label;
  final IconData? icon;
  final Color? background;
  final Color? foreground;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    final bg = selected ? c.ink : background ?? c.recessed;
    final fg = selected ? c.paper : foreground ?? c.ink;
    final pill = AnimatedContainer(
      duration: NefaMotion.small,
      constraints: const BoxConstraints(minHeight: 30),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(NefaRadii.sm),
        border: Border.all(
          color: selected
              ? c.ink
              : bg == c.recessed
              ? c.rule
              : bg,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 14, color: fg), const SizedBox(width: 6)],
          Flexible(
            child: Text(
              label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: NefaType.eyebrow(color: fg, size: 10.5),
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return pill;
    return Pressable(onTap: onTap, semanticLabel: label, child: pill);
  }
}

/// Small uppercase label.
class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.color});
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) =>
      Text(text.toUpperCase(), style: NefaType.eyebrow(color: color ?? context.nefa.muted));
}

/// Segmented control: recessed track, raised thumb that slides.
class Segmented<T> extends StatelessWidget {
  const Segmented({
    super.key,
    required this.values,
    required this.value,
    required this.labelOf,
    required this.onChanged,
  });

  final List<T> values;
  final T value;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    final index = values.indexOf(value);
    return LayoutBuilder(
      builder: (context, box) {
        final w = (box.maxWidth - 8) / values.length;
        return Container(
          height: 48,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: c.recessed,
            borderRadius: BorderRadius.circular(NefaRadii.md),
            border: Border.all(color: c.rule),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 260),
                curve: NefaMotion.ease,
                left: w * index,
                top: 0,
                bottom: 0,
                width: w,
                child: Container(
                  decoration: BoxDecoration(
                    color: c.raised,
                    borderRadius: BorderRadius.circular(NefaRadii.md - 4),
                    boxShadow: nefaShadow,
                    border: Border.all(color: c.rule.withValues(alpha: .6)),
                  ),
                ),
              ),
              Row(
                children: [
                  for (final v in values)
                    Expanded(
                      child: Semantics(
                        selected: v == value,
                        button: true,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            onChanged(v);
                          },
                          child: Center(
                            child: AnimatedDefaultTextStyle(
                              duration: NefaMotion.small,
                              style: NefaType.style(13, 700, color: v == value ? c.ink : c.muted),
                              child: Text(labelOf(v)),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A numeric field that is just a ruled line, like a logbook.
class RuledNumberField extends StatefulWidget {
  const RuledNumberField({
    super.key,
    required this.value,
    required this.onCommitted,
    this.hint,
    this.suffix,
    this.decimal = false,
    this.width = 64,
    this.enabled = true,
    this.semanticLabel,
  });

  final num? value;
  final ValueChanged<num?> onCommitted;
  final String? hint;
  final String? suffix;
  final bool decimal;
  final double width;
  final bool enabled;
  final String? semanticLabel;

  @override
  State<RuledNumberField> createState() => _RuledNumberFieldState();
}

class _RuledNumberFieldState extends State<RuledNumberField> {
  late final _controller = TextEditingController(text: _fmt(widget.value));
  final _focus = FocusNode();

  String _fmt(num? v) {
    if (v == null) return '';
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      setState(() {});
      if (!_focus.hasFocus) _commit();
    });
  }

  @override
  void didUpdateWidget(RuledNumberField old) {
    super.didUpdateWidget(old);
    if (!_focus.hasFocus && old.value != widget.value) {
      _controller.text = _fmt(widget.value);
    }
  }

  void _commit() {
    final t = _controller.text.trim().replaceAll(',', '.');
    final v = t.isEmpty ? null : (widget.decimal ? double.tryParse(t) : int.tryParse(t));
    if (v != widget.value) widget.onCommitted(v);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    final focused = _focus.hasFocus;
    return SizedBox(
      width: widget.width,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          TextField(
            controller: _controller,
            focusNode: _focus,
            enabled: widget.enabled,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.numberWithOptions(decimal: widget.decimal),
            textInputAction: TextInputAction.done,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(widget.decimal ? r'[0-9.,]' : r'[0-9]')),
              LengthLimitingTextInputFormatter(6),
            ],
            onSubmitted: (_) => _commit(),
            style: NefaType.value(20, color: c.ink),
            cursorColor: c.accent,
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: widget.hint,
              hintStyle: NefaType.value(20, color: c.faint),
              suffixText: widget.suffix,
              suffixStyle: NefaType.style(11, 700, color: c.muted),
              contentPadding: const EdgeInsets.only(bottom: 6, top: 8),
              semanticCounterText: widget.semanticLabel,
            ),
          ),
          Positioned(
            left: 2,
            right: 2,
            bottom: 0,
            child: Stack(
              children: [
                Container(height: 1.2, color: c.rule),
                AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 240),
                  curve: NefaMotion.ease,
                  widthFactor: focused ? 1 : 0,
                  alignment: Alignment.centerLeft,
                  child: Container(height: 1.6, color: c.accent),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
