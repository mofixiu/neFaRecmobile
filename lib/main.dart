import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/db/database.dart';
import 'core/providers.dart';
import 'core/services/alerts.dart';
import 'core/services/demo_seed.dart';
import 'features/settings/settings_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  final db = NefaDatabase();
  if (DemoSeed.enabled) {
    final seeding = ProviderContainer(overrides: [databaseProvider.overrideWithValue(db)]);
    await DemoSeed.run(db, await seeding.read(exerciseIndexProvider.future));
    seeding.dispose();
  }
  final settings = await Settings.load(db);
  final alerts = AlertService();
  await alerts.init();

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        alertsProvider.overrideWithValue(alerts),
        initialSettingsProvider.overrideWithValue(settings),
      ],
      child: const NefaApp(),
    ),
  );
}
