import 'package:flutter/foundation.dart';

enum Goal { strength, muscle, general, endurance, mobility }

enum Experience { beginner, intermediate, advanced }

extension GoalText on Goal {
  String get label => switch (this) {
    Goal.strength => 'Get stronger',
    Goal.muscle => 'Build muscle',
    Goal.general => 'General fitness',
    Goal.endurance => 'Endurance',
    Goal.mobility => 'Move better',
  };
}

extension ExperienceText on Experience {
  String get label => switch (this) {
    Experience.beginner => 'New to lifting',
    Experience.intermediate => '1–3 years',
    Experience.advanced => '3+ years',
  };
}

/// Who is training. Works without an account; signing in keeps it on the server.
@immutable
class Profile {
  const Profile({
    this.displayName = '',
    this.goal = Goal.general,
    this.experience = Experience.beginner,
    this.bodyweightKg,
    this.heightCm,
    this.weeklyTarget = 3,
  });

  final String displayName;
  final Goal goal;
  final Experience experience;
  final double? bodyweightKg;
  final double? heightCm;

  /// Sessions you aim for each week; Today shows progress against it.
  final int weeklyTarget;

  String get firstName => displayName.trim().split(RegExp(r'\s+')).first;
  String get initial => displayName.trim().isEmpty ? '·' : displayName.trim()[0].toUpperCase();

  Profile copyWith({
    String? displayName,
    Goal? goal,
    Experience? experience,
    double? bodyweightKg,
    bool clearBodyweight = false,
    double? heightCm,
    bool clearHeight = false,
    int? weeklyTarget,
  }) => Profile(
    displayName: displayName ?? this.displayName,
    goal: goal ?? this.goal,
    experience: experience ?? this.experience,
    bodyweightKg: clearBodyweight ? null : bodyweightKg ?? this.bodyweightKg,
    heightCm: clearHeight ? null : heightCm ?? this.heightCm,
    weeklyTarget: weeklyTarget ?? this.weeklyTarget,
  );

  Map<String, Object?> toJson() => {
    'displayName': displayName,
    'goal': goal.name,
    'experience': experience.name,
    'bodyweightKg': bodyweightKg,
    'heightCm': heightCm,
    'weeklyTarget': weeklyTarget,
  };

  factory Profile.fromJson(Map<String, dynamic> j) {
    T pick<T extends Enum>(List<T> values, Object? name, T fallback) =>
        values.where((v) => v.name == name).firstOrNull ?? fallback;
    return Profile(
      displayName: j['displayName'] as String? ?? '',
      goal: pick(Goal.values, j['goal'], Goal.general),
      experience: pick(Experience.values, j['experience'], Experience.beginner),
      bodyweightKg: (j['bodyweightKg'] as num?)?.toDouble(),
      heightCm: (j['heightCm'] as num?)?.toDouble(),
      weeklyTarget: (j['weeklyTarget'] as num?)?.toInt() ?? 3,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Profile && other.toJson().toString() == toJson().toString();

  @override
  int get hashCode => toJson().toString().hashCode;
}
