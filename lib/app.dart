import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paper_kit/paper_kit.dart';

import 'core/theme/nefa_theme.dart';
import 'features/app/app_shell.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/settings/settings_controller.dart';

/// paper_kit sets only [FontWeight]; Montserrat is one variable file, so the
/// weight axis has to be set too.
TextStyle _variableWeight(TextStyle style) {
  final w = style.fontWeight ?? FontWeight.w500;
  final value = (FontWeight.values.indexOf(w) + 1) * 100;
  return style.copyWith(fontVariations: [FontVariation.weight(value.toDouble())]);
}

class NefaApp extends ConsumerWidget {
  const NefaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return MaterialApp(
      title: 'neFaRec',
      debugShowCheckedModeBanner: false,
      themeMode: settings.themeMode,
      theme: buildNefaTheme(Brightness.light),
      darkTheme: buildNefaTheme(Brightness.dark),
      builder: (context, child) {
        final brightness = Theme.of(context).brightness;
        final dark = brightness == Brightness.dark;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark).copyWith(
            systemNavigationBarColor: Colors.transparent,
          ),
          child: PaperInkReveal(
            theme: PaperThemeData.fromBrightness(brightness, fontBuilder: _variableWeight),
            // Our theme sits inside so it wins over the kit's Material theme.
            // Overlays (like the printed receipt toast) sit outside any
            // Material, so give them a real default text style too.
            child: Theme(
              data: buildNefaTheme(brightness),
              child: Builder(
                builder: (context) =>
                    DefaultTextStyle(style: Theme.of(context).textTheme.bodyMedium!, child: child!),
              ),
            ),
          ),
        );
      },
      home: const _Root(),
    );
  }
}

/// Swaps onboarding for the app in place once you finish it.
class _Root extends ConsumerWidget {
  const _Root();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarded = ref.watch(settingsProvider.select((s) => s.onboarded));
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 420),
      child: onboarded ? const AppShell() : const OnboardingScreen(),
    );
  }
}
