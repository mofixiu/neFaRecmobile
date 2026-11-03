import 'package:flutter/material.dart';
import 'package:paper_kit/paper_kit.dart';

import '../../core/theme/tokens.dart';
import 'controls.dart';

/// A card on the paper: hairline border, two-layer soft shadow.
class SheetCard extends StatelessWidget {
  const SheetCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(NefaSpace.card),
    this.onTap,
    this.color,
    this.borderColor,
    this.radius = NefaRadii.lg,
    this.semanticLabel,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final double radius;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? c.sheet,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor ?? c.rule.withValues(alpha: c.isDark ? 1 : .8)),
        boxShadow: c.isDark ? null : nefaShadow,
      ),
      child: child,
    );
    if (onTap == null) return card;
    return Pressable(onTap: onTap, semanticLabel: semanticLabel, scale: .985, child: card);
  }
}

/// The scoreboard: an ink block for the most important number on screen.
class BoardCard extends StatelessWidget {
  const BoardCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(22),
    this.color,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    final bg = color ?? c.board;
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      curve: NefaMotion.ease,
      padding: padding,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(NefaRadii.lg + 4),
        border: Border.all(color: c.isDark ? c.boardEdge : bg),
        boxShadow: c.isDark ? null : nefaRaisedShadow,
      ),
      child: child,
    );
    if (onTap == null) return card;
    return Pressable(onTap: onTap, scale: .985, child: card);
  }
}

/// Section title with an optional trailing action.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.action, this.onAction, this.eyebrow});
  final String title;
  final String? eyebrow;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (eyebrow != null) ...[Eyebrow(eyebrow!), const SizedBox(height: 6)],
              Text(title, style: Theme.of(context).textTheme.headlineMedium),
            ],
          ),
        ),
        if (action != null)
          Pressable(
            onTap: onAction,
            semanticLabel: action,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
              child: Text(action!, style: NefaType.style(14, 800, color: c.accentInk)),
            ),
          ),
      ],
    );
  }
}

/// A lowercase paper-kit heading with its short bar: used for the big
/// title of each root tab.
class PageTitle extends StatelessWidget {
  const PageTitle(this.title, {super.key, this.subtitle});
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: 10),
        Container(
          width: 28,
          height: 4,
          decoration: BoxDecoration(color: c.accent, borderRadius: BorderRadius.circular(2)),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 12),
          Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: c.muted)),
        ],
      ],
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.action,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String body;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    return SheetCard(
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: c.accentWash, shape: BoxShape.circle),
            child: Icon(icon, color: c.accentInk),
          ),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text(body, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: c.muted)),
          if (action != null) ...[
            const SizedBox(height: 18),
            NefaButton(label: action!, onPressed: onAction, icon: Icons.content_paste_rounded),
          ],
        ],
      ),
    );
  }
}

/// Inline notice for errors and warnings. Never replaces content.
class Notice extends StatelessWidget {
  const Notice({
    super.key,
    required this.text,
    this.tone = NoticeTone.info,
    this.action,
    this.onAction,
  });
  final String text;
  final NoticeTone tone;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    final (bg, fg, icon) = switch (tone) {
      NoticeTone.info => (c.recessed, c.ink, Icons.info_outline_rounded),
      NoticeTone.warn => (c.warnWash, c.warn, Icons.edit_note_rounded),
      NoticeTone.danger => (c.dangerWash, c.danger, Icons.error_outline_rounded),
      NoticeTone.success => (c.successWash, c.success, Icons.check_circle_outline_rounded),
    };
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(NefaRadii.md),
        border: Border.all(color: fg.withValues(alpha: .25)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: fg),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: NefaType.style(13.5, 600, height: 1.35, color: c.ink)),
          ),
          if (action != null)
            Pressable(
              onTap: onAction,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(action!, style: NefaType.style(13, 800, color: fg)),
              ),
            ),
        ],
      ),
    );
  }
}

enum NoticeTone { info, warn, danger, success }

/// A screen on paper. Root tabs and pushed pages both use it.
class PaperScaffold extends StatelessWidget {
  const PaperScaffold({super.key, required this.body, this.bottom, this.resize = true});
  final Widget body;
  final Widget? bottom;
  final bool resize;

  @override
  Widget build(BuildContext context) {
    return PaperBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: resize,
        body: body,
        bottomNavigationBar: bottom,
      ),
    );
  }
}

/// Top bar for pushed screens: back, title, actions. Matches the page.
class PageBar extends StatelessWidget {
  const PageBar({
    super.key,
    this.title,
    this.actions = const [],
    this.onBack,
    this.closeIcon = false,
  });
  final String? title;
  final List<Widget> actions;
  final VoidCallback? onBack;
  final bool closeIcon;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: 60,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              RoundIconButton(
                icon: closeIcon ? Icons.close_rounded : Icons.arrow_back_rounded,
                label: closeIcon ? 'Close' : 'Back',
                onPressed: onBack ?? () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: title == null
                    ? const SizedBox()
                    : Text(
                        title!,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
              ),
              ...actions,
            ],
          ),
        ),
      ),
    );
  }
}
