// Renders the app icon from the real ticket mark in the app.
// Run: flutter test tool/icon/render_icon_test.dart
// Then: dart run flutter_launcher_icons
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nefarec/shared/widgets/wordmark.dart';

const _ink = Color(0xFF211E19);

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

    // Full icon: flat ink board, the ticket stub centred.
    await _save(
      tester,
      Container(color: _ink, alignment: Alignment.center, child: const NefaTicketMark(width: 660)),
      'assets/icon/icon.png',
    );

    // Android adaptive foreground: the same ticket inside the 66% safe zone.
    await _save(
      tester,
      Container(
        color: const Color(0x00000000),
        alignment: Alignment.center,
        child: const NefaTicketMark(width: 470),
      ),
      'assets/icon/icon_foreground.png',
    );
  });
}
