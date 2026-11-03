import '../../../core/models/training.dart';
import '../../workout/domain/session_models.dart';
import '../data/routine_repository.dart';

/// A routine as plain text that neFaRec (or a person) can read back. This is
/// how a coach sends a program: share it, the client pastes it.
String routineToText(RoutineDetail r) {
  final out = StringBuffer();
  for (final (i, d) in r.days.indexed) {
    if (i > 0) out.writeln();
    out.writeln(d.day.name);
    final inGroup = <String, int>{};
    for (final e in d.exercises) {
      final x = e.exercise;
      final t = e.target;
      final target = switch (t.kind) {
        TargetKind.reps => '${t.repsMin}',
        TargetKind.range => '${t.repsMin}-${t.repsMax}',
        TargetKind.failure => 'failure',
        TargetKind.duration => '${t.durationSeconds} sec',
      };
      final w = e.sets.isEmpty ? null : e.sets.first.weight;
      final unit = e.sets.isEmpty ? WeightUnit.kg : e.sets.first.unit;
      final label = x.groupLabel == null
          ? ''
          : '${x.groupLabel}${inGroup.update(x.groupLabel!, (n) => n + 1, ifAbsent: () => 1)}. ';
      final parts = <String>[
        '$label${x.name} ${e.sets.length} x $target',
        if (w != null) '@ ${_n(w)}${unit.name}',
      ];
      var line = parts.join(' ');
      if (x.restSeconds != null && x.restSeconds! > 0) line += ', rest ${x.restSeconds} sec';
      if (x.tempo != null) line += ' tempo ${x.tempo}';
      out.writeln(line);
      if (x.notes != null && x.notes!.isNotEmpty) out.writeln('Note: ${x.notes}');
    }
  }
  out.writeln();
  out.write('Shared from neFaRec');
  return out.toString();
}

String _n(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

/// A finished session for a coach: readable text.
String sessionToText(SessionDetail d) {
  final s = d.session;
  final out = StringBuffer()
    ..writeln('${s.title} · ${s.startedAt.day}/${s.startedAt.month}/${s.startedAt.year}')
    ..writeln(
      'Time ${formatClock(d.elapsed(s.endedAt ?? DateTime.now()))} · '
      '${d.doneSets}/${d.totalSets} sets · ${d.volumeKg.round()} kg volume',
    )
    ..writeln();
  for (final e in d.exercises) {
    final done = e.sets.where((x) => x.isDone).toList();
    if (done.isEmpty && !e.exercise.skipped) continue;
    out.writeln(
      e.exercise.skipped
          ? '${e.exercise.name}: skipped'
          : '${e.exercise.name}${e.exercise.variant == null ? '' : ' (${e.exercise.variant})'}',
    );
    for (final x in done) {
      final value = x.kind == TargetKind.duration || (x.durationSeconds != null && x.reps == null)
          ? formatClock(Duration(seconds: x.durationSeconds ?? 0))
          : '${x.weight == null ? '' : '${_n(x.weight!)} ${x.unit.name} × '}${x.reps ?? 0}';
      out.writeln('  ${x.position + 1}. $value');
    }
  }
  return out.toString().trimRight();
}

/// One row per completed set, for spreadsheets.
String sessionToCsv(SessionDetail d) {
  final rows = <List<String>>[
    ['date', 'workout', 'exercise', 'setup', 'set', 'weight', 'unit', 'reps', 'seconds'],
  ];
  final date = d.session.startedAt.toIso8601String().substring(0, 10);
  for (final e in d.exercises) {
    for (final x in e.sets.where((x) => x.isDone)) {
      rows.add([
        date,
        d.session.title,
        e.exercise.name,
        e.exercise.variant ?? '',
        '${x.position + 1}',
        x.weight == null ? '' : _n(x.weight!),
        x.unit.name,
        '${x.reps ?? ''}',
        '${x.durationSeconds ?? ''}',
      ]);
    }
  }
  String cell(String v) => v.contains(RegExp('[",\n]')) ? '"${v.replaceAll('"', '""')}"' : v;
  return rows.map((r) => r.map(cell).join(',')).join('\n');
}
