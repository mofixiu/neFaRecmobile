/// Shared training vocabulary used by the parser, the database and the UI.
library;

enum TargetKind { reps, range, failure, duration }

/// Where a value came from. The import review shows anything that is not
/// [explicit] with a highlighter mark so you can see what nefaRec filled in.
enum Provenance { explicit, suggested, defaulted }

enum WeightUnit { kg, lb }

/// What one prescribed set asks for.
class SetTarget {
  const SetTarget._({required this.kind, this.repsMin, this.repsMax, this.durationSeconds});

  const SetTarget.reps(int reps) : this._(kind: TargetKind.reps, repsMin: reps, repsMax: reps);

  const SetTarget.range(int min, int max)
    : this._(kind: TargetKind.range, repsMin: min, repsMax: max);

  const SetTarget.failure() : this._(kind: TargetKind.failure);

  const SetTarget.duration(int seconds)
    : this._(kind: TargetKind.duration, durationSeconds: seconds);

  factory SetTarget.fromParts({
    required TargetKind kind,
    int? repsMin,
    int? repsMax,
    int? durationSeconds,
  }) {
    return switch (kind) {
      TargetKind.reps => SetTarget.reps(repsMin ?? repsMax ?? 10),
      TargetKind.range => SetTarget.range(repsMin ?? 8, repsMax ?? 12),
      TargetKind.failure => const SetTarget.failure(),
      TargetKind.duration => SetTarget.duration(durationSeconds ?? 30),
    };
  }

  final TargetKind kind;
  final int? repsMin;
  final int? repsMax;
  final int? durationSeconds;

  bool get isTimed => kind == TargetKind.duration;

  /// "10 reps", "8–12 reps", "to failure", "45 sec".
  String get label => switch (kind) {
    TargetKind.reps => '$repsMin reps',
    TargetKind.range => '$repsMin–$repsMax reps',
    TargetKind.failure => 'to failure',
    TargetKind.duration => formatSeconds(durationSeconds!),
  };

  /// The short form used next to a set count: "10", "8–12", "F", "45s".
  String get short => switch (kind) {
    TargetKind.reps => '$repsMin',
    TargetKind.range => '$repsMin–$repsMax',
    TargetKind.failure => 'failure',
    TargetKind.duration => formatSeconds(durationSeconds!, compact: true),
  };

  @override
  bool operator ==(Object other) =>
      other is SetTarget &&
      other.kind == kind &&
      other.repsMin == repsMin &&
      other.repsMax == repsMax &&
      other.durationSeconds == durationSeconds;

  @override
  int get hashCode => Object.hash(kind, repsMin, repsMax, durationSeconds);

  @override
  String toString() => 'SetTarget($label)';
}

/// "45 sec", "1:30", "2 min". Compact gives "45s", "1:30", "2m".
String formatSeconds(int seconds, {bool compact = false}) {
  if (seconds < 60) return compact ? '${seconds}s' : '$seconds sec';
  final m = seconds ~/ 60;
  final s = seconds % 60;
  if (s == 0) return compact ? '${m}m' : '$m min';
  return '$m:${s.toString().padLeft(2, '0')}';
}

/// Clock face for timers: "0:45", "1:30", "12:04", "1:02:10".
String formatClock(Duration d) {
  final total = d.inSeconds.abs();
  final h = total ~/ 3600;
  final m = (total % 3600) ~/ 60;
  final s = total % 60;
  final ss = s.toString().padLeft(2, '0');
  if (h > 0) return '$h:${m.toString().padLeft(2, '0')}:$ss';
  return '$m:$ss';
}

String formatWeight(double? weight, WeightUnit unit) {
  if (weight == null) return '—';
  final text = weight == weight.roundToDouble()
      ? weight.toStringAsFixed(0)
      : weight.toStringAsFixed(1);
  return '$text ${unit.name}';
}

/// Epley estimate. Only meaningful for 1–12 rep sets; callers label it an estimate.
double? estimatedOneRepMax(double weight, int reps) {
  if (reps <= 0 || reps > 12 || weight <= 0) return null;
  if (reps == 1) return weight;
  return weight * (1 + reps / 30);
}
