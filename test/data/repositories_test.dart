import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nefarec/core/db/database.dart';
import 'package:nefarec/core/models/training.dart';
import 'package:nefarec/features/account/data/backup_codec.dart';
import 'package:nefarec/features/import/domain/routine_parser.dart';
import 'package:nefarec/features/library/domain/library_data.dart';
import 'package:nefarec/features/routines/data/routine_repository.dart';
import 'package:nefarec/features/routines/domain/routine_draft.dart';
import 'package:nefarec/features/routines/domain/routine_text.dart';
import 'package:nefarec/features/workout/data/session_repository.dart';
import 'package:nefarec/features/workout/domain/session_models.dart';
import 'package:nefarec/features/workout/domain/timer_machine.dart';

void main() {
  late NefaDatabase db;
  late RoutineRepository routines;
  late SessionRepository sessions;
  late RoutineParser parser;

  setUpAll(() {
    final data = LibraryData.parse(File('assets/exercises/library.json').readAsStringSync());
    parser = RoutineParser(data.buildIndex());
  });

  setUp(() {
    db = NefaDatabase(NativeDatabase.memory());
    routines = RoutineRepository(db);
    sessions = SessionRepository(db);
  });
  tearDown(() => db.close());

  Future<int> importSpec() {
    const text = '''Monday — Push
Incline DB Press 3 × 10 @ 20kg, rest 90 sec
Plank 3 × 45 sec
Landmine press 3x8''';
    return routines.save(RoutineDraft.fromParsed(parser.parse(text), text));
  }

  test('saving an import keeps order, targets and creates customs', () async {
    final id = await importSpec();
    final detail = (await routines.load(id))!;
    final ex = detail.days.single.exercises;
    expect(ex.map((e) => e.exercise.name), ['Incline Dumbbell Press', 'Plank', 'Landmine press']);
    expect(ex[0].sets, hasLength(3));
    expect(ex[0].sets.first.weight, 20);
    expect(ex[1].target, const SetTarget.duration(45));
    expect(ex[2].exercise.exerciseId, startsWith('custom_'));
  });

  test('editing a routine never rewrites a finished session', () async {
    final id = await importSpec();
    final detail = (await routines.load(id))!;
    final sid = await sessions.start(detail, detail.days.single, now: DateTime(2026, 11, 1, 18));
    var s = (await sessions.load(sid))!;
    final first = s.exercises.first.sets.first;
    await sessions.updateSet(first.id, weight: 22.5, reps: 10);
    s = (await sessions.load(sid))!;
    await sessions.completeSet(s.exercises.first.sets.first);
    await sessions.finish(sid, at: DateTime(2026, 11, 1, 19));

    final draft = detail.toDraft();
    final edited = draft.copyWith(
      days: [
        draft.days.single.copyWith(
          exercises: [draft.days.single.exercises.first.copyWith(sets: 5, weight: 30)],
        ),
      ],
    );
    await routines.save(edited);

    final past = (await sessions.load(sid))!;
    expect(past.exercises, hasLength(3));
    expect(past.exercises.first.sets, hasLength(3));
    expect(past.exercises.first.sets.first.weight, 22.5);
    expect(past.exercises.first.sets.first.targetWeight, 20);
    expect((await routines.load(id))!.days.single.exercises.single.sets, hasLength(5));
  });

  test('previous performance and records compare like with like', () async {
    final id = await importSpec();
    final detail = (await routines.load(id))!;
    final day = detail.days.single;

    Future<int> run(DateTime when, double weight, int reps) async {
      final sid = await sessions.start(detail, day, now: when);
      final s = (await sessions.load(sid))!;
      final set = s.exercises.first.sets.first;
      await sessions.updateSet(set.id, weight: weight, reps: reps);
      await sessions.completeSet((await sessions.load(sid))!.exercises.first.sets.first);
      await sessions.finish(sid, at: when.add(const Duration(hours: 1)));
      return sid;
    }

    await run(DateTime(2026, 10, 1), 20, 10);
    final second = await run(DateTime(2026, 10, 8), 22, 10);

    final prev = await sessions.previous('Incline_Dumbbell_Press', excludeSession: second);
    expect(prev!.sets.first.weight, 20);

    final records = await sessions.recordsFor((await sessions.load(second))!);
    expect(records.single.kind, RecordKind.heaviest);
    expect(await sessions.previous('Barbell_Incline_Bench_Press_-_Medium_Grip'), isNull);
  });

  test('starting twice returns the running session', () async {
    final id = await importSpec();
    final detail = (await routines.load(id))!;
    final a = await sessions.start(detail, detail.days.single);
    final b = await sessions.start(detail, detail.days.single);
    expect(a, b);
  });

  test('completed sets cannot be removed', () async {
    final id = await importSpec();
    final detail = (await routines.load(id))!;
    final sid = await sessions.start(detail, detail.days.single);
    final set = (await sessions.load(sid))!.exercises.first.sets.first;
    await sessions.completeSet(set);
    final done = (await sessions.load(sid))!.exercises.first.sets.first;
    expect(await sessions.removeSet(done), isFalse);
    expect(done.reps, 10, reason: 'one tap logs the target reps');
  });

  test('timer persists and restores', () async {
    final t = const WorkoutTimer.idle(
      kind: TimerKind.rest,
      target: Duration(seconds: 90),
    ).start(DateTime(2026, 11, 2, 18));
    await sessions.saveTimer(7, t, label: 'Rest');
    final stored = (await sessions.loadTimer())!;
    expect(stored.sessionId, 7);
    expect(stored.label, 'Rest');
    expect(stored.timer.startedAt, t.startedAt);
    await sessions.clearTimer();
    expect(await sessions.loadTimer(), isNull);
  });

  test('the session stream re-emits after a set is completed', () async {
    final id = await importSpec();
    final detail = (await routines.load(id))!;
    final sid = await sessions.start(detail, detail.days.single);
    final seen = <int>[];
    final sub = sessions.watchSession(sid).listen((d) => seen.add(d!.doneSets));
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await sessions.completeSet((await sessions.load(sid))!.exercises.first.sets.first);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await sub.cancel();
    expect(seen.first, 0);
    expect(seen.last, 1);
  });

  test('a shared routine pastes back into the same routine', () async {
    final id = await importSpec();
    final detail = (await routines.load(id))!;
    final text = routineToText(detail);
    final again = parser.parse(text);
    final original = detail.days.single.exercises;
    final parsed = again.exercises.toList();
    expect(again.days.single.name, detail.days.single.day.name);
    expect(parsed.map((e) => e.sets), original.map((e) => e.sets.length));
    expect(parsed.map((e) => e.target), original.map((e) => e.target));
    expect(parsed.first.weight, 20);
    expect(parsed.first.restSeconds, 90);
  });

  test('schedule and variant round-trip through save and load', () async {
    final id = await importSpec();
    final detail = (await routines.load(id))!;
    await routines.setWeekdays(detail.days.single.day.id, 0x15);
    final draft = (await routines.load(id))!.toDraft();
    final edited = draft.copyWith(
      days: [
        draft.days.single.copyWith(
          exercises: [
            draft.days.single.exercises.first.copyWith(variant: 'Gym A bench'),
            ...draft.days.single.exercises.skip(1),
          ],
        ),
      ],
    );
    await routines.save(edited);
    final back = (await routines.load(id))!;
    expect(back.days.single.day.weekdays, 0x15);
    expect(back.days.single.exercises.first.exercise.variant, 'Gym A bench');
  });

  test('a backup restores routines, history and plans exactly', () async {
    final id = await importSpec();
    final detail = (await routines.load(id))!;
    await routines.setWeekdays(detail.days.single.day.id, 0x05);
    final sid = await sessions.start(detail, detail.days.single, now: DateTime(2026, 11, 1, 18));
    await sessions.completeSet((await sessions.load(sid))!.exercises.first.sets.first);
    await sessions.finish(sid, at: DateTime(2026, 11, 1, 19));

    final snap = await BackupCodec(db).export();
    expect(snap.summary.sessions, 1);
    expect(snap.summary.sets, 1);
    final json = jsonDecode(jsonEncode(snap.payload)) as Map<String, dynamic>;

    await routines.delete(id);
    await sessions.deleteSession(sid);
    expect(await routines.load(id), isNull);

    await BackupCodec(db).restore(json, schemaVersion: snap.schemaVersion);
    final back = (await routines.load(id))!;
    expect(back.days.single.day.weekdays, 0x05);
    expect(back.days.single.exercises.first.sets.first.weight, 20);
    final s = (await sessions.load(sid))!;
    expect(s.session.status, 'completed');
    expect(s.doneSets, 1);
    expect(() => BackupCodec(db).restore(json, schemaVersion: 99), throwsStateError);
  });
}
