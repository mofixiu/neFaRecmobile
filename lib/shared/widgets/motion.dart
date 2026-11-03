import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';

bool _still(BuildContext context) => MediaQuery.disableAnimationsOf(context);

/// Fades and rises into place once, after [index] × the stagger step.
/// Indexes past 8 share one delay so long lists don't trickle in.
class Rise extends StatefulWidget {
  const Rise({super.key, required this.child, this.index = 0, this.distance = 14});
  final Widget child;
  final int index;
  final double distance;

  @override
  State<Rise> createState() => _RiseState();
}

class _RiseState extends State<Rise> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: NefaMotion.rise);

  @override
  void initState() {
    super.initState();
    Future.delayed(NefaMotion.stagger * widget.index.clamp(0, 8), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_still(context)) return widget.child;
    final t = CurvedAnimation(parent: _c, curve: NefaMotion.ease);
    return AnimatedBuilder(
      animation: t,
      builder: (context, child) => Opacity(
        opacity: t.value,
        child: Transform.translate(
          offset: Offset(0, widget.distance * (1 - t.value)),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}

/// A number that counts up to its value, and rolls to new values.
class CountUp extends StatelessWidget {
  const CountUp({
    super.key,
    required this.value,
    required this.style,
    this.format,
    this.textAlign,
    this.duration = const Duration(milliseconds: 900),
  });

  final num value;
  final TextStyle style;
  final String Function(num v)? format;
  final TextAlign? textAlign;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final f = format ?? (num v) => v.round().toString();
    if (_still(context)) return Text(f(value), style: style, textAlign: textAlign);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Text(f(v), style: style, textAlign: textAlign),
    );
  }
}

/// A stat label that counts up when it is a plain whole number ("12",
/// "~25") and shows as-is otherwise ("1:30", "4.2k", "—").
class CountText extends StatelessWidget {
  const CountText(this.text, {super.key, required this.style});
  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final m = RegExp(r'^(\D?)(\d+)$').firstMatch(text);
    if (m == null) return Text(text, style: style);
    final prefix = m.group(1)!;
    return CountUp(
      value: int.parse(m.group(2)!),
      style: style,
      format: (v) => '$prefix${v.round()}',
    );
  }
}

/// Pops (a quick overshooting scale) whenever [trigger] changes to a new value.
class Pop extends StatefulWidget {
  const Pop({super.key, required this.trigger, required this.child, this.scale = 1.22});
  final Object? trigger;
  final Widget child;
  final double scale;

  @override
  State<Pop> createState() => _PopState();
}

class _PopState extends State<Pop> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));

  @override
  void didUpdateWidget(Pop old) {
    super.didUpdateWidget(old);
    // Something becoming done, selected or reached pops; turning off doesn't.
    final on = widget.trigger != false && widget.trigger != null;
    if (old.trigger != widget.trigger && on && !_still(context)) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Up fast, then settle with a small bounce.
    final scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: widget.scale).chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: widget.scale, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 70,
      ),
    ]).animate(_c);
    return ScaleTransition(scale: scale, child: widget.child);
  }
}

/// Like [IndexedStack] (every child keeps its state) but the incoming child
/// fades and lifts in.
class FadeIndexedStack extends StatefulWidget {
  const FadeIndexedStack({super.key, required this.index, required this.children});
  final int index;
  final List<Widget> children;

  @override
  State<FadeIndexedStack> createState() => _FadeIndexedStackState();
}

class _FadeIndexedStackState extends State<FadeIndexedStack> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
    value: 1,
  );

  @override
  void didUpdateWidget(FadeIndexedStack old) {
    super.didUpdateWidget(old);
    if (old.index != widget.index && !_still(context)) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = CurvedAnimation(parent: _c, curve: NefaMotion.ease);
    return AnimatedBuilder(
      animation: t,
      builder: (context, child) => Opacity(
        opacity: .2 + .8 * t.value,
        child: Transform.translate(offset: Offset(0, 10 * (1 - t.value)), child: child),
      ),
      child: IndexedStack(index: widget.index, children: widget.children),
    );
  }
}

/// Runs 0 → 1 once when first shown: for charts that grow or draw in.
class Reveal extends StatelessWidget {
  const Reveal({
    super.key,
    required this.builder,
    this.duration = const Duration(milliseconds: 900),
    this.curve = Curves.easeOutCubic,
  });

  final Widget Function(BuildContext context, double t) builder;
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    if (_still(context)) return builder(context, 1);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: curve,
      builder: (context, t, _) => builder(context, t),
    );
  }
}
