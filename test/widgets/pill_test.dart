import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nefarec/core/theme/nefa_theme.dart';
import 'package:nefarec/shared/widgets/controls.dart';

void main() {
  testWidgets('a long pill label ends in an ellipsis instead of overflowing', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildNefaTheme(Brightness.light),
        home: const Scaffold(
          body: Center(
            child: SizedBox(
              width: 180,
              child: Wrap(
                children: [Pill(label: 'Setup: rack 2 power cage, pins on 4', icon: Icons.build)],
              ),
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    final text = tester.widget<Text>(find.textContaining('SETUP'));
    expect(text.overflow, TextOverflow.ellipsis);
    expect(tester.getSize(find.byType(Pill)).width, lessThanOrEqualTo(180));
  });
}
