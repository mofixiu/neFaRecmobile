import 'package:flutter/material.dart';

/// Colour roles for nefaRec. Paper and ink come from paper_kit's palettes; the
/// one hot accent is signal orange. Read with `context.nefa`.
@immutable
class NefaColors extends ThemeExtension<NefaColors> {
  const NefaColors({
    required this.brightness,
    required this.paper,
    required this.sheet,
    required this.raised,
    required this.recessed,
    required this.ink,
    required this.muted,
    required this.faint,
    required this.rule,
    required this.accent,
    required this.onAccent,
    required this.accentInk,
    required this.accentWash,
    required this.board,
    required this.onBoard,
    required this.boardMuted,
    required this.boardEdge,
    required this.success,
    required this.successWash,
    required this.warn,
    required this.warnWash,
    required this.danger,
    required this.dangerWash,
    required this.blueInk,
    required this.highlighter,
    required this.nav,
    required this.onNav,
  });

  final Brightness brightness;

  /// The page.
  final Color paper;

  /// Cards.
  final Color sheet;

  /// Sheets, selected segments, floating controls.
  final Color raised;

  /// Inputs and segmented tracks.
  final Color recessed;
  final Color ink;
  final Color muted;
  final Color faint;
  final Color rule;

  /// Signal orange: primary action, live timer, the R in the wordmark.
  final Color accent;
  final Color onAccent;

  /// Orange that is dark enough to read as small text on paper.
  final Color accentInk;
  final Color accentWash;

  /// The scoreboard: the ink-black block that holds timers and hero values.
  final Color board;
  final Color onBoard;
  final Color boardMuted;
  final Color boardEdge;

  /// Completed sets and personal records.
  final Color success;
  final Color successWash;

  /// Values nefaRec suggested rather than read from your text.
  final Color warn;
  final Color warnWash;

  /// Errors and destructive actions only.
  final Color danger;
  final Color dangerWash;

  /// The pen that ticks sets off.
  final Color blueInk;

  /// Highlighter stroke under suggested values.
  final Color highlighter;

  /// The floating bottom bar.
  final Color nav;
  final Color onNav;

  bool get isDark => brightness == Brightness.dark;

  static const light = NefaColors(
    brightness: Brightness.light,
    paper: Color(0xFFF4ECDE),
    sheet: Color(0xFFFBF7EF),
    raised: Color(0xFFFFFCF6),
    recessed: Color(0xFFEDE3D1),
    ink: Color(0xFF211E19),
    muted: Color(0xFF6B6256),
    faint: Color(0xFF9D9386),
    rule: Color(0xFFD8CEBC),
    accent: Color(0xFFFF5A1F),
    onAccent: Color(0xFFFFFFFF),
    accentInk: Color(0xFFC2410C),
    accentWash: Color(0xFFFFE4D6),
    board: Color(0xFF211E19),
    onBoard: Color(0xFFF8F1E4),
    boardMuted: Color(0xFFA79D8E),
    boardEdge: Color(0xFF3A352D),
    success: Color(0xFF4E7A3F),
    successWash: Color(0xFFE3EBD6),
    warn: Color(0xFF9A6514),
    warnWash: Color(0xFFF6E7C4),
    danger: Color(0xFFB8432F),
    dangerWash: Color(0xFFF6DDD5),
    blueInk: Color(0xFF3F5D7D),
    highlighter: Color(0x80F2C14E),
    nav: Color(0xFF211E19),
    onNav: Color(0xFFB9B0A2),
  );

  static const dark = NefaColors(
    brightness: Brightness.dark,
    paper: Color(0xFF171512),
    sheet: Color(0xFF211F1B),
    raised: Color(0xFF2A2722),
    recessed: Color(0xFF12100D),
    ink: Color(0xFFF8F3EA),
    muted: Color(0xFFB9B0A2),
    faint: Color(0xFF81786C),
    rule: Color(0xFF3B372F),
    accent: Color(0xFFFF7A45),
    onAccent: Color(0xFF1A0E08),
    accentInk: Color(0xFFFF9466),
    accentWash: Color(0xFF3D2216),
    board: Color(0xFF0E0D0B),
    onBoard: Color(0xFFF8F1E4),
    boardMuted: Color(0xFF9B9283),
    boardEdge: Color(0xFF35312A),
    success: Color(0xFF93B683),
    successWash: Color(0xFF243020),
    warn: Color(0xFFE0B15C),
    warnWash: Color(0xFF3A2E17),
    danger: Color(0xFFE0715C),
    dangerWash: Color(0xFF3D211B),
    blueInk: Color(0xFF8FB0D6),
    highlighter: Color(0x66C9962E),
    nav: Color(0xFF2A2722),
    onNav: Color(0xFF9B9283),
  );

  @override
  NefaColors copyWith() => this;

  @override
  NefaColors lerp(NefaColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return NefaColors(
      brightness: t < .5 ? brightness : other.brightness,
      paper: l(paper, other.paper),
      sheet: l(sheet, other.sheet),
      raised: l(raised, other.raised),
      recessed: l(recessed, other.recessed),
      ink: l(ink, other.ink),
      muted: l(muted, other.muted),
      faint: l(faint, other.faint),
      rule: l(rule, other.rule),
      accent: l(accent, other.accent),
      onAccent: l(onAccent, other.onAccent),
      accentInk: l(accentInk, other.accentInk),
      accentWash: l(accentWash, other.accentWash),
      board: l(board, other.board),
      onBoard: l(onBoard, other.onBoard),
      boardMuted: l(boardMuted, other.boardMuted),
      boardEdge: l(boardEdge, other.boardEdge),
      success: l(success, other.success),
      successWash: l(successWash, other.successWash),
      warn: l(warn, other.warn),
      warnWash: l(warnWash, other.warnWash),
      danger: l(danger, other.danger),
      dangerWash: l(dangerWash, other.dangerWash),
      blueInk: l(blueInk, other.blueInk),
      highlighter: l(highlighter, other.highlighter),
      nav: l(nav, other.nav),
      onNav: l(onNav, other.onNav),
    );
  }
}

abstract final class NefaRadii {
  /// Chips, badges, tiny controls.
  static const sm = 8.0;

  /// Buttons, inputs, inner tiles.
  static const md = 16.0;

  /// Cards, sheets, dialogs, the nav bar.
  static const lg = 24.0;
}

abstract final class NefaSpace {
  static const gutter = 20.0;
  static const card = 18.0;
  static const section = 32.0;
}

abstract final class NefaMotion {
  static const press = Duration(milliseconds: 110);
  static const small = Duration(milliseconds: 200);
  static const crossFade = Duration(milliseconds: 280);
  static const rise = Duration(milliseconds: 380);
  static const stagger = Duration(milliseconds: 45);
  static const page = Duration(milliseconds: 420);
  static const Curve ease = Cubic(0.215, 0.61, 0.355, 1);
}

/// Montserrat ships as one variable font, so every style sets the `wght` axis
/// explicitly as well as [FontWeight].
abstract final class NefaType {
  static const family = 'Montserrat';

  static TextStyle style(
    double size,
    int weight, {
    double? height,
    double tracking = 0,
    Color? color,
    bool tabular = false,
  }) {
    return TextStyle(
      fontFamily: family,
      fontSize: size,
      height: height,
      letterSpacing: tracking,
      color: color,
      fontWeight: FontWeight.values[((weight ~/ 100) - 1).clamp(0, 8)],
      fontVariations: [FontVariation.weight(weight.toDouble())],
      fontFeatures: tabular ? const [FontFeature.tabularFigures()] : null,
    );
  }

  /// The scoreboard number.
  static TextStyle board(double size, {Color? color}) =>
      style(size, 900, height: .92, tracking: -size * .045, color: color, tabular: true);

  /// A big logged value: weights, reps, volumes.
  static TextStyle value(double size, {Color? color}) =>
      style(size, 800, height: 1, tracking: -size * .03, color: color, tabular: true);

  /// Uppercase eyebrows, field labels and pills.
  static TextStyle eyebrow({Color? color, double size = 11}) =>
      style(size, 700, height: 1.2, tracking: 1.6, color: color);
}

const nefaShadow = [
  BoxShadow(color: Color(0x0F211E19), blurRadius: 2, offset: Offset(0, 1)),
  BoxShadow(color: Color(0x14211E19), blurRadius: 24, spreadRadius: -8, offset: Offset(0, 12)),
];

const nefaRaisedShadow = [
  BoxShadow(color: Color(0x14211E19), blurRadius: 3, offset: Offset(0, 1)),
  BoxShadow(color: Color(0x29211E19), blurRadius: 40, spreadRadius: -12, offset: Offset(0, 22)),
];

extension NefaContext on BuildContext {
  NefaColors get nefa => Theme.of(this).extension<NefaColors>()!;
}
