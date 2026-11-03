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
