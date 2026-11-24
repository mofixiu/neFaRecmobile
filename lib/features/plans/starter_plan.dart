import '../../core/models/training.dart';
import '../import/domain/exercise_index.dart';
import '../library/domain/library_data.dart';
import '../routines/domain/routine_draft.dart';

/// What a gym has, in beginner terms.
enum Kit { machines, dumbbells, barbell, bodyweight }

String kitLabel(Kit k) => switch (k) {
  Kit.machines => 'Machines',
  Kit.dumbbells => 'Dumbbells',
  Kit.barbell => 'Barbell and rack',
  Kit.bodyweight => 'Just my body',
};

/// The equipment groups (Settings › equipment) each kit stands for.
const kitGroups = <Kit, Set<String>>{
  Kit.machines: {'Machines', 'Cables'},
  Kit.dumbbells: {'Dumbbells', 'Kettlebells'},
  Kit.barbell: {'Barbell'},
  Kit.bodyweight: {'Bodyweight'},
};

/// A movement every plan needs, and the exercises that cover it on each kit,
/// best for a beginner first.
enum Slot { squat, hinge, push, pullDown, row, press, singleLeg, core, arms }

const _options = <Slot, Map<Kit, List<String>>>{
  Slot.squat: {
    Kit.machines: ['Leg_Press', 'Hack_Squat'],
    Kit.dumbbells: ['Goblet_Squat'],
    Kit.barbell: ['Barbell_Squat'],
    Kit.bodyweight: ['Bodyweight_Squat'],
  },
  Slot.hinge: {
    Kit.machines: ['Seated_Leg_Curl', 'Lying_Leg_Curls'],
    Kit.dumbbells: ['Stiff-Legged_Dumbbell_Deadlift'],
    Kit.barbell: ['Romanian_Deadlift'],
    Kit.bodyweight: ['Butt_Lift_Bridge'],
  },
  Slot.push: {
    Kit.machines: ['Machine_Bench_Press', 'Leverage_Chest_Press'],
    Kit.dumbbells: ['Dumbbell_Bench_Press', 'Incline_Dumbbell_Press'],
    Kit.barbell: ['Barbell_Bench_Press_-_Medium_Grip'],
    Kit.bodyweight: ['Incline_Push-Up', 'Pushups'],
  },
  Slot.pullDown: {
    Kit.machines: ['Wide-Grip_Lat_Pulldown', 'Close-Grip_Front_Lat_Pulldown'],
    Kit.dumbbells: ['One-Arm_Dumbbell_Row'],
    Kit.barbell: ['Bent_Over_Barbell_Row'],
    Kit.bodyweight: ['Inverted_Row'],
  },
  Slot.row: {
    Kit.machines: ['Seated_Cable_Rows'],
    Kit.dumbbells: ['One-Arm_Dumbbell_Row'],
    Kit.barbell: ['Bent_Over_Barbell_Row'],
    Kit.bodyweight: ['Inverted_Row', 'Superman'],
  },
  Slot.press: {
    Kit.machines: ['Machine_Shoulder_Military_Press', 'Leverage_Shoulder_Press'],
    Kit.dumbbells: ['Dumbbell_Shoulder_Press'],
    Kit.barbell: ['Standing_Military_Press'],
    Kit.bodyweight: ['Pushups'],
  },
  Slot.singleLeg: {
    Kit.machines: ['Leg_Extensions'],
    Kit.dumbbells: ['Dumbbell_Lunges', 'Dumbbell_Step_Ups'],
    Kit.bodyweight: ['Bodyweight_Walking_Lunge'],
  },
  Slot.core: {
    Kit.bodyweight: ['Plank', 'Dead_Bug', 'Crunches'],
    Kit.machines: ['Cable_Crunch'],
  },
  Slot.arms: {
    Kit.dumbbells: ['Dumbbell_Bicep_Curl', 'Hammer_Curls'],
    Kit.machines: ['Triceps_Pushdown'],
    Kit.bodyweight: ['Bench_Dips'],
  },
};

/// Every exercise a starter plan can use, for tests.
Iterable<String> get starterExerciseIds => _options.values.expand((m) => m.values).expand((l) => l);

/// Beginners do best on machines first: they guide the movement.
const _preference = [Kit.machines, Kit.dumbbells, Kit.barbell, Kit.bodyweight];

/// Done one side at a time.
const _oneSide = {
  'One-Arm_Dumbbell_Row',
  'Dumbbell_Lunges',
  'Dumbbell_Step_Ups',
  'Bodyweight_Walking_Lunge',
  'Dead_Bug',
};

const _days = <int, List<(String, List<Slot>)>>{
  2: [
    ('Full body A', [Slot.squat, Slot.push, Slot.pullDown, Slot.hinge, Slot.core]),
    ('Full body B', [Slot.hinge, Slot.press, Slot.row, Slot.singleLeg, Slot.core]),
  ],
  3: [
    ('Full body A', [Slot.squat, Slot.push, Slot.pullDown, Slot.hinge, Slot.core]),
    ('Full body B', [Slot.hinge, Slot.press, Slot.row, Slot.singleLeg, Slot.core]),
    ('Full body C', [Slot.squat, Slot.push, Slot.row, Slot.singleLeg, Slot.core]),
  ],
  4: [
    ('Upper A', [Slot.push, Slot.pullDown, Slot.press, Slot.row, Slot.arms]),
    ('Lower A', [Slot.squat, Slot.hinge, Slot.singleLeg, Slot.core]),
    ('Upper B', [Slot.press, Slot.row, Slot.push, Slot.pullDown, Slot.arms]),
    ('Lower B', [Slot.hinge, Slot.squat, Slot.singleLeg, Slot.core]),
  ],
};

/// Training days spread through the week. Bit 0 = Monday.
const _weekdays = <int, List<int>>{
  2: [1 << 0, 1 << 3],
  3: [1 << 0, 1 << 2, 1 << 4],
  4: [1 << 0, 1 << 1, 1 << 3, 1 << 4],
};

/// Builds a beginner routine for [days] a week (2–4) with the [kits] your gym
/// has. Every movement is covered; when your kit can't cover one, bodyweight
/// fills in. Brand-new lifters get two easier sets; others get three.
RoutineDraft buildStarterPlan({
  required int days,
  required Set<Kit> kits,
  required bool brandNew,
  required Map<String, LibraryRecord> library,
  WeightUnit unit = WeightUnit.kg,
}) {
  final template = _days[days.clamp(2, 4)]!;
  final usedCount = <String, int>{};
  final dayDrafts = <DayDraft>[];

  for (final (d, (dayName, slots)) in template.indexed) {
    final today = <String>{};
    final exercises = <ExerciseDraft>[];
    for (final slot in slots) {
      final id = _pick(slot, kits, today, usedCount, library);
      if (id == null) continue;
      today.add(id);
      usedCount[id] = (usedCount[id] ?? 0) + 1;
      exercises.add(_exercise(library[id]!, slot, brandNew, unit));
    }
    dayDrafts.add(
      DayDraft(name: dayName, exercises: exercises, weekdays: _weekdays[template.length]![d]),
    );
  }

  final have = _preference
      .where(kits.contains)
      .map(kitLabel)
      .map((s) => s.toLowerCase())
      .join(', ');
  return RoutineDraft(
    name: '$days-day starter plan',
    days: dayDrafts,
    notes:
        'Built by neFaRec for ${have.isEmpty ? 'bodyweight' : have}. '
        'Start light. After each set, say how it felt and neFaRec sets the next weight. '
        'When every set feels easy, it adds weight.',
  );
}

String? _pick(
  Slot slot,
  Set<Kit> kits,
  Set<String> today,
  Map<String, int> used,
  Map<String, LibraryRecord> library,
) {
  final byKit = _options[slot]!;
  // Core is bodyweight first; everything else follows the beginner order.
  final order = slot == Slot.core ? [Kit.bodyweight, ..._preference] : _preference;
  final candidates = <String>[
    for (final k in order)
      if (kits.contains(k) || k == Kit.bodyweight) ...?byKit[k],
  ].where((id) => library.containsKey(id) && !today.contains(id)).toList();
  if (candidates.isEmpty) return null;
  // Keep the preferred kit, but spread repeats: the least-used option of the
  // best kit that has one.
  final bestKit = order.firstWhere(
    (k) =>
        (kits.contains(k) || k == Kit.bodyweight) &&
        (byKit[k] ?? const []).any(candidates.contains),
  );
  final pool = byKit[bestKit]!.where(candidates.contains).toList()
    ..sort((a, b) => (used[a] ?? 0).compareTo(used[b] ?? 0));
  return pool.first;
}

ExerciseDraft _exercise(LibraryRecord r, Slot slot, bool brandNew, WeightUnit unit) {
  final main = const {
    Slot.squat,
    Slot.hinge,
    Slot.push,
    Slot.pullDown,
    Slot.row,
    Slot.press,
  }.contains(slot);
  final sets = brandNew ? 2 : 3;
  final SetTarget target;
  if (r.timed) {
    target = SetTarget.duration(brandNew ? 20 : 30);
  } else if (slot == Slot.core) {
    target = const SetTarget.range(10, 15);
  } else if (main) {
    target = brandNew ? const SetTarget.range(10, 12) : const SetTarget.range(8, 12);
  } else {
    target = const SetTarget.range(10, 15);
  }
  return ExerciseDraft(
    name: r.name,
    exerciseId: r.id,
    status: MatchStatus.exact,
    sets: sets,
    target: target,
    unit: unit,
    restSeconds: main ? 90 : 60,
    timed: r.timed,
    perSide: _oneSide.contains(r.id),
  );
}
