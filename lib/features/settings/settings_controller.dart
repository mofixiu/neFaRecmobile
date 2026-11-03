import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';
import '../../core/models/training.dart';
import '../../core/providers.dart';

@immutable
class Settings {
  const Settings({
    this.themeMode = ThemeMode.system,
    this.unit = WeightUnit.kg,
    this.defaultRestSeconds = 90,
    this.autoStartRest = true,
    this.haptics = true,
    this.onboarded = false,
    this.equipment = const {},
  });

  final ThemeMode themeMode;
  final WeightUnit unit;
  final int defaultRestSeconds;

  /// Start the rest timer as soon as a set is ticked off.
  final bool autoStartRest;
  final bool haptics;
  final bool onboarded;

  /// Equipment groups you have access to; empty means "anything".
  final Set<String> equipment;

  Settings copyWith({
    ThemeMode? themeMode,
    WeightUnit? unit,
    int? defaultRestSeconds,
    bool? autoStartRest,
    bool? haptics,
    bool? onboarded,
    Set<String>? equipment,
  }) => Settings(
    themeMode: themeMode ?? this.themeMode,
    unit: unit ?? this.unit,
    defaultRestSeconds: defaultRestSeconds ?? this.defaultRestSeconds,
    autoStartRest: autoStartRest ?? this.autoStartRest,
    haptics: haptics ?? this.haptics,
    onboarded: onboarded ?? this.onboarded,
    equipment: equipment ?? this.equipment,
  );

  Map<String, String> toPrefs() => {
    'themeMode': themeMode.name,
    'unit': unit.name,
    'defaultRestSeconds': '$defaultRestSeconds',
    'autoStartRest': '$autoStartRest',
    'haptics': '$haptics',
    'onboarded': '$onboarded',
    'equipment': equipment.join('|'),
  };

  factory Settings.fromPrefs(Map<String, String> p) {
    T pick<T extends Enum>(List<T> values, String? name, T fallback) =>
        values.where((v) => v.name == name).firstOrNull ?? fallback;
    return Settings(
      themeMode: pick(ThemeMode.values, p['themeMode'], ThemeMode.system),
      unit: pick(WeightUnit.values, p['unit'], WeightUnit.kg),
      defaultRestSeconds: int.tryParse(p['defaultRestSeconds'] ?? '') ?? 90,
      autoStartRest: p['autoStartRest'] != 'false',
      haptics: p['haptics'] != 'false',
      onboarded: p['onboarded'] == 'true',
      equipment: {...?p['equipment']?.split('|').where((e) => e.isNotEmpty)},
    );
  }

  static Future<Settings> load(NefaDatabase db) async {
    final rows = await db.select(db.preferences).get();
    return Settings.fromPrefs({for (final r in rows) r.key: r.value});
  }
}

/// Overridden in main with the values read before the first frame.
final initialSettingsProvider = Provider<Settings>((_) => const Settings());

class SettingsController extends Notifier<Settings> {
  @override
  Settings build() {
    final initial = ref.read(initialSettingsProvider);
    ref.read(alertsProvider).hapticsEnabled = initial.haptics;
    return initial;
  }

  /// Re-reads settings from the database, e.g. after restoring a backup.
  Future<void> reload() async {
    state = await Settings.load(ref.read(databaseProvider));
    ref.read(alertsProvider).hapticsEnabled = state.haptics;
  }

  Future<void> update(Settings Function(Settings) change) async {
    state = change(state);
    ref.read(alertsProvider).hapticsEnabled = state.haptics;
    final db = ref.read(databaseProvider);
    await db.batch((b) {
      b.insertAllOnConflictUpdate(db.preferences, [
        for (final e in state.toPrefs().entries)
          PreferencesCompanion.insert(key: e.key, value: e.value),
      ]);
    });
  }
}

final settingsProvider = NotifierProvider<SettingsController, Settings>(SettingsController.new);
