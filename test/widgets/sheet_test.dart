import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nefarec/core/theme/nefa_theme.dart';
import 'package:nefarec/shared/widgets/sheet.dart';

void main() {
  testWidgets('a sheet with a footer opens, lays out and closes cleanly', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildNefaTheme(Brightness.dark),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => showNefaSheet<void>(
                  context,
                  title: 'Swap exercise',
                  subtitle: 'Same muscles, your equipment',
                  icon: Icons.swap_horiz_rounded,
                  builder: (_) => Column(children: [for (var i = 0; i < 40; i++) Text('Row $i')]),
                  footer: (_) => const Text('Footer'),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Swap exercise'), findsOneWidget);
    expect(find.text('Footer'), findsOneWidget);
    // A long body scrolls inside the sheet instead of overflowing.
    expect(tester.takeException(), isNull);

    await tester.tap(find.bySemanticsLabel('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Swap exercise'), findsNothing);
  });
}
