// Renders the app icon from the real wordmark.
// Run: flutter test tool/icon/render_icon_test.dart
// Then: dart run flutter_launcher_icons
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _ink = Color(0xFF211E19);
const _cream = Color(0xFFF8F1E4);
const _orange = Color(0xFFFF5A1F);

Widget _mark(double size) {
  TextStyle s(Color c) => TextStyle(
    fontFamily: 'Montserrat',
    fontSize: size,
    height: 1,
    letterSpacing: -size * .05,
    color: c,
    fontWeight: FontWeight.w800,
    fontVariations: const [ui.FontVariation('wght', 800)],
  );
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text.rich(
        TextSpan(
          children: [
            TextSpan(text: 'neFa', style: s(_cream)),
            TextSpan(text: 'R', style: s(_orange)),
            TextSpan(text: 'ec', style: s(_cream)),
          ],
        ),
        textDirection: TextDirection.ltr,
      ),
      SizedBox(height: size * .16),
      // The short heading bar that runs through the paper kit.
      Container(
        width: size * 1.25,
        height: size * .085,
        decoration: BoxDecoration(color: _orange, borderRadius: BorderRadius.circular(size)),
      ),
    ],
  );
}

Future<void> _save(WidgetTester tester, Widget child, String path) async {
  final key = GlobalKey();
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: RepaintBoundary(
          key: key,
          child: SizedBox(width: 1024, height: 1024, child: child),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.runAsync(() async {
    final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File(path)
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

void main() {
  testWidgets('render icon', (tester) async {
    tester.view.physicalSize = const Size(1024, 1024);
    tester.view.devicePixelRatio = 1;
    final font = File('assets/fonts/Montserrat-VariableFont_wght.ttf').readAsBytesSync();
    await tester.runAsync(() async {
      final loader = FontLoader('Montserrat')..addFont(Future.value(ByteData.view(font.buffer)));
      await loader.load();
    });

    // Full icon: ink board, a soft orange glow in one corner, the wordmark.
    await _save(
      tester,
      Container(
        color: _ink,
        child: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(.95, -.95),
              radius: 1.1,
              colors: [Color(0x4DFF5A1F), Color(0x00FF5A1F)],
            ),
          ),
          alignment: Alignment.center,
          child: _mark(188),
        ),
      ),
      'assets/icon/icon.png',
    );

    // Android adaptive foreground: same mark inside the 66% safe zone.
    await _save(
      tester,
      Container(color: const Color(0x00000000), alignment: Alignment.center, child: _mark(128)),
      'assets/icon/icon_foreground.png',
    );
  });
}
