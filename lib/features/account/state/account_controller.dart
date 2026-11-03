import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database.dart';
import '../../../core/models/training.dart';
import '../../../core/providers.dart';
import '../../../core/services/api_client.dart';
import '../../history/calendar_view.dart';
import '../../settings/settings_controller.dart';
import '../data/backup_codec.dart';
import '../domain/profile.dart';

final tokenStoreProvider = Provider((_) => TokenStore());
final apiClientProvider = Provider((ref) => ApiClient(tokens: ref.watch(tokenStoreProvider)));

class BackupInfo {
  const BackupInfo({
    required this.id,
    required this.createdAt,
    required this.summary,
    required this.sizeBytes,
    this.device,
  });

  factory BackupInfo.fromJson(Map<String, dynamic> j) => BackupInfo(
    id: j['id'] as String,
    createdAt: DateTime.parse(j['createdAt'] as String).toLocal(),
    summary: Map<String, int>.from(
      (j['summary'] as Map).map((k, v) => MapEntry(k as String, (v as num).toInt())),
    ),
    sizeBytes: (j['sizeBytes'] as num).toInt(),
    device: j['device'] as String?,
  );

  final String id;
  final DateTime createdAt;
  final Map<String, int> summary;
  final int sizeBytes;
  final String? device;
}

@immutable
class AccountState {
  const AccountState({
    this.profile = const Profile(),
    this.email,
    this.autoBackup = true,
    this.lastBackupAt,
    this.busy = false,
  });

  final Profile profile;

  /// Signed in when set.
  final String? email;

  /// Back up after every finished workout.
  final bool autoBackup;
  final DateTime? lastBackupAt;
  final bool busy;

  bool get signedIn => email != null;

  AccountState copyWith({
    Profile? profile,
    String? email,
    bool signOut = false,
    bool? autoBackup,
    DateTime? lastBackupAt,
    bool? busy,
  }) => AccountState(
    profile: profile ?? this.profile,
    email: signOut ? null : email ?? this.email,
    autoBackup: autoBackup ?? this.autoBackup,
    lastBackupAt: lastBackupAt ?? this.lastBackupAt,
    busy: busy ?? this.busy,
  );
}

const _accountKey = 'account';

/// Profile, sign-in and cloud backups. Everything works signed out; the
/// account adds a profile that follows you and restorable backups.
class AccountController extends Notifier<AccountState> {
  ApiClient get _api => ref.read(apiClientProvider);
  NefaDatabase get _db => ref.read(databaseProvider);

  @override
  AccountState build() {
    Future.microtask(_load);
    return const AccountState();
  }

  Future<void> _load() async {
    final row = await (_db.select(
      _db.preferences,
    )..where((p) => p.key.equals(_accountKey))).getSingleOrNull();
    if (row != null) {
      final j = jsonDecode(row.value) as Map<String, dynamic>;
      state = AccountState(
        profile: Profile.fromJson(Map<String, dynamic>.from(j['profile'] as Map? ?? const {})),
        email: j['email'] as String?,
        autoBackup: j['autoBackup'] as bool? ?? true,
        lastBackupAt: j['lastBackupAt'] == null
            ? null
            : DateTime.parse(j['lastBackupAt'] as String),
      );
    }
    // Refresh the profile from the server if signed in; stay quiet offline.
    if (state.signedIn) {
      try {
        _applyServer(await _api.get('/me'));
      } on ApiException catch (e) {
        if (e.status == 401) await _forgetSession();
      }
    }
  }

  Future<void> _persist() async {
    await _db
        .into(_db.preferences)
        .insertOnConflictUpdate(
          PreferencesCompanion(
            key: const Value(_accountKey),
            value: Value(
              jsonEncode({
                'profile': state.profile.toJson(),
                'email': state.email,
                'autoBackup': state.autoBackup,
                'lastBackupAt': state.lastBackupAt?.toIso8601String(),
              }),
            ),
          ),
        );
  }

  void _applyServer(Map<String, dynamic>? json) {
    if (json == null) return;
    final user = json['user'] as Map<String, dynamic>?;
    final p = json['profile'] as Map<String, dynamic>?;
    state = state.copyWith(
      email: user?['email'] as String?,
      profile: p == null ? null : Profile.fromJson(p),
    );
    final unit = p?['unit'] as String?;
    if (unit != null) {
      ref
          .read(settingsProvider.notifier)
          .update((s) => s.copyWith(unit: unit == 'lb' ? WeightUnit.lb : WeightUnit.kg));
    }
  }

  Future<T> _busy<T>(Future<T> Function() work) async {
    state = state.copyWith(busy: true);
    try {
      return await work();
    } finally {
      state = state.copyWith(busy: false);
    }
  }

  /// Saves locally at once; pushes to the server when signed in.
  Future<void> saveProfile(Profile profile) async {
    state = state.copyWith(profile: profile);
    await _persist();
    if (!state.signedIn) return;
    _applyServer(
      await _api.patch('/me/profile', {
        ...profile.toJson(),
        'unit': ref.read(settingsProvider).unit.name,
      }),
    );
    await _persist();
  }

  Future<void> signUp({required String email, required String password, required String name}) =>
      _busy(() async {
        // The profile you set up before having an account; the server only
        // knows defaults, so this is pushed up straight after.
        final local = name.trim().isEmpty
            ? state.profile
            : state.profile.copyWith(displayName: name.trim());
        final json = await _api.anonymous('/auth/signup', {
          'email': email,
          'password': password,
          'displayName': local.displayName.isEmpty ? 'Lifter' : local.displayName,
          'device': defaultTargetPlatform.name,
        });
        await _signedIn(json);
        await saveProfile(local);
      });

  Future<void> signIn({required String email, required String password}) => _busy(() async {
    final json = await _api.anonymous('/auth/login', {
      'email': email,
      'password': password,
      'device': defaultTargetPlatform.name,
    });
    await _signedIn(json);
  });

  Future<void> _signedIn(Map<String, dynamic> json) async {
    await ref
        .read(tokenStoreProvider)
        .save(json['accessToken'] as String, json['refreshToken'] as String);
    _applyServer(json);
    await _persist();
  }

  Future<void> signOut() => _busy(() async {
    final refresh = await ref.read(tokenStoreProvider).refresh();
    if (refresh != null) {
      try {
        await _api.anonymous('/auth/logout', {'refreshToken': refresh});
      } on ApiException {
        // Offline: the token simply expires on the server.
      }
    }
    await _forgetSession();
  });

  Future<void> _forgetSession() async {
    await ref.read(tokenStoreProvider).clear();
    state = state.copyWith(signOut: true);
    await _persist();
  }

  /// Removes the account and all its backups from the server. Workouts on
  /// this phone are kept.
  Future<void> deleteAccount() => _busy(() async {
    await _api.delete('/me');
    await _forgetSession();
  });

  void setAutoBackup(bool on) {
    state = state.copyWith(autoBackup: on);
    _persist();
  }

  Future<List<BackupInfo>> listBackups() async {
    final json = await _api.get('/backups');
    return [
      for (final b in (json?['backups'] as List? ?? const []))
        BackupInfo.fromJson(Map<String, dynamic>.from(b as Map)),
    ];
  }

  Future<void> backupNow() => _busy(_backup);

  Future<void> _backup() async {
    final snap = await BackupCodec(_db).export();
    await _api.post('/backups', {
      'device': defaultTargetPlatform.name,
      'appVersion': '1.0.0',
      'schemaVersion': snap.schemaVersion,
      'summary': snap.summary.toJson(),
      'payload': snap.payload,
    });
    state = state.copyWith(lastBackupAt: DateTime.now());
    await _persist();
  }

  /// Called after a workout is finished. Never throws: offline is fine.
  Future<void> autoBackupAfterWorkout() async {
    if (!state.signedIn || !state.autoBackup) return;
    try {
      await _backup();
    } catch (e) {
      debugPrint('auto backup skipped: $e');
    }
  }

  /// Replaces this phone's routines and history with a backup.
  Future<void> restore(String backupId) => _busy(() async {
    final json = await _api.get('/backups/$backupId');
    final keep = state;
    await BackupCodec(_db).restore(
      Map<String, dynamic>.from(json!['payload'] as Map),
      schemaVersion: (json['schemaVersion'] as num).toInt(),
    );
    // The backup carried its own copy of this record; keep the live session.
    state = keep;
    await _persist();
    await ref.read(settingsProvider.notifier).reload();
    ref.invalidate(exerciseIndexProvider);
    ref.invalidate(allRoutineDetailsProvider);
    ref.invalidate(historyProvider);
    ref.invalidate(routinesProvider);
  });
}

final accountProvider = NotifierProvider<AccountController, AccountState>(AccountController.new);
