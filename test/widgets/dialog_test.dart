import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nefarec/core/theme/nefa_theme.dart';
import 'package:nefarec/shared/widgets/dialog.dart';

Widget _app(void Function(BuildContext) onTap) => MaterialApp(
  theme: buildNefaTheme(Brightness.light),
  home: Builder(
    builder: (context) => Scaffold(
      body: Center(
        child: TextButton(onPressed: () => onTap(context), child: const Text('open')),
      ),
    ),
  ),
);

void main() {
  testWidgets('prompt returns text and closes without touching a disposed controller', (
    tester,
  ) async {
    String? result = 'unset';
    await tester.pumpWidget(
      _app((context) async {
        result = await showPrompt(
          context,
          title: 'Machine or setup',
          initial: 'Old',
          allowEmpty: true,
        );
      }),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Machine or setup'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Gym A cable');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(result, 'Gym A cable');
    expect(find.text('Machine or setup'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('prompt cancel returns null', (tester) async {
    String? result = 'unset';
    await tester.pumpWidget(
      _app((context) async {
        result = await showPrompt(context, title: 'Rename this day', initial: 'Push');
      }),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(result, isNull);
  });

  testWidgets('a required prompt cannot be saved empty', (tester) async {
    String? result = 'unset';
    await tester.pumpWidget(
      _app((context) async {
        result = await showPrompt(context, title: 'Rename this day', initial: 'Push');
      }),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '   ');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Rename this day'), findsOneWidget);
    expect(result, 'unset');
  });

  testWidgets('confirm is true only from the main button', (tester) async {
    bool? result;
    await tester.pumpWidget(
      _app((context) async {
        result = await showConfirm(
          context,
          title: 'Discard this workout?',
          confirm: 'Discard workout',
          destructive: true,
        );
      }),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard workout'));
    await tester.pumpAndSettle();
    expect(result, isTrue);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(5, 5)); // the dimmed background
    await tester.pumpAndSettle();
    expect(result, isFalse);
  });
}
