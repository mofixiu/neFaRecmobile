import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/tokens.dart';
import 'motion.dart';

class NavDestination {
  const NavDestination(this.label, this.icon, this.selectedIcon);
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

/// The floating ink bar. The selected tab becomes an orange pill that slides.
class FloatingNav extends StatelessWidget {
  const FloatingNav({
    super.key,
    required this.destinations,
    required this.index,
    required this.onSelect,
  });

  final List<NavDestination> destinations;
  final int index;
  final ValueChanged<int> onSelect;

  static const height = 68.0;

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, bottom > 0 ? bottom - 6 : 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(NefaRadii.lg + 6),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            height: height,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: c.nav.withValues(alpha: .94),
              borderRadius: BorderRadius.circular(NefaRadii.lg + 6),
              border: Border.all(color: c.isDark ? c.rule : c.nav),
            ),
            child: LayoutBuilder(
              builder: (context, box) {
                final w = box.maxWidth / destinations.length;
                return Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 340),
                      curve: NefaMotion.ease,
                      left: w * index,
                      top: 0,
                      bottom: 0,
                      width: w,
                      child: Container(
                        decoration: BoxDecoration(
                          color: c.accent,
                          borderRadius: BorderRadius.circular(NefaRadii.lg),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        for (final (i, d) in destinations.indexed)
                          Expanded(
                            child: Semantics(
                              button: true,
                              selected: i == index,
                              label: d.label,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  if (i != index) HapticFeedback.selectionClick();
                                  onSelect(i);
                                },
                                child: ExcludeSemantics(
                                  child: _Item(d: d, selected: i == index),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.d, required this.selected});
  final NavDestination d;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    final fg = selected ? c.onAccent : c.onNav;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Pop(
          trigger: selected,
          scale: 1.25,
          child: Icon(selected ? d.selectedIcon : d.icon, size: 22, color: fg),
        ),
        const SizedBox(height: 4),
        Text(d.label.toUpperCase(), style: NefaType.style(9.5, 800, tracking: 1.1, color: fg)),
      ],
    );
  }
}
