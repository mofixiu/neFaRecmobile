import 'package:flutter/material.dart';

import 'tokens.dart';

/// The same lift-and-settle push used across aLaStudie, tuned a touch slower.
class _PaperPushTransitionsBuilder extends PageTransitionsBuilder {
  const _PaperPushTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    final enter = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInOutCubic,
    );
    final leave = CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeInOutCubic);
    return FadeTransition(
      opacity: enter,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, .022), end: Offset.zero).animate(enter),
        child: ScaleTransition(
          scale: Tween<double>(begin: .985, end: 1).animate(enter),
          child: FadeTransition(
            opacity: Tween<double>(begin: 1, end: .9).animate(leave),
            child: child,
          ),
        ),
      ),
    );
  }
}

ThemeData buildNefaTheme(Brightness brightness) {
  final c = brightness == Brightness.dark ? NefaColors.dark : NefaColors.light;
  final scheme = ColorScheme(
    brightness: brightness,
    primary: c.ink,
    onPrimary: c.paper,
    secondary: c.accent,
    onSecondary: c.onAccent,
    tertiary: c.blueInk,
    onTertiary: c.paper,
    error: c.danger,
    onError: c.paper,
    surface: c.sheet,
    onSurface: c.ink,
    onSurfaceVariant: c.muted,
    outline: c.rule,
    outlineVariant: c.rule,
    surfaceContainerLowest: c.raised,
    surfaceContainerLow: c.sheet,
    surfaceContainer: c.recessed,
    surfaceContainerHigh: c.recessed,
    surfaceContainerHighest: c.recessed,
  );

  TextStyle t(double size, int weight, {double? height, double tracking = 0}) =>
      NefaType.style(size, weight, height: height, tracking: tracking, color: c.ink);

  const transitions = _PaperPushTransitionsBuilder();

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    fontFamily: NefaType.family,
    scaffoldBackgroundColor: Colors.transparent,
    canvasColor: c.paper,
    dividerColor: c.rule,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    iconTheme: IconThemeData(size: 22, color: c.ink),
    extensions: [c],
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: transitions,
        TargetPlatform.iOS: transitions,
        TargetPlatform.macOS: transitions,
        TargetPlatform.linux: transitions,
        TargetPlatform.windows: transitions,
        TargetPlatform.fuchsia: transitions,
      },
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: c.accent,
      selectionColor: c.accent.withValues(alpha: .25),
      selectionHandleColor: c.accent,
    ),
    textTheme: TextTheme(
      displayLarge: t(52, 900, height: .92, tracking: -2.6),
      displayMedium: t(40, 900, height: .96, tracking: -1.8),
      displaySmall: t(32, 900, height: 1, tracking: -1.3),
      headlineLarge: t(28, 800, height: 1.04, tracking: -1.1),
      headlineMedium: t(22, 800, height: 1.1, tracking: -.7),
      headlineSmall: t(19, 800, height: 1.15, tracking: -.5),
      titleLarge: t(17, 700, height: 1.2, tracking: -.3),
      titleMedium: t(15, 700, height: 1.25, tracking: -.15),
      titleSmall: t(13, 700, height: 1.3),
      bodyLarge: t(15, 500, height: 1.5),
      bodyMedium: t(14, 500, height: 1.5),
      bodySmall: t(12.5, 500, height: 1.45),
      labelLarge: t(15, 800, tracking: -.1),
      labelMedium: t(12, 700, tracking: .3),
      labelSmall: t(11, 700, tracking: 1.4),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0,
      modalElevation: 0,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: c.board,
      contentTextStyle: NefaType.style(14, 600, color: c.onBoard),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NefaRadii.md)),
    ),
  );
}
