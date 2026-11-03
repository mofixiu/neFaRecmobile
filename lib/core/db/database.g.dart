// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CustomExercisesTable extends CustomExercises
    with TableInfo<$CustomExercisesTable, CustomExercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _equipmentMeta = const VerificationMeta('equipment');
  @override
  late final GeneratedColumn<String> equipment = GeneratedColumn<String>(
    'equipment',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timedMeta = const VerificationMeta('timed');
  @override
  late final GeneratedColumn<bool> timed = GeneratedColumn<bool>(
    'timed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("timed" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, equipment, timed, notes, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomExercise> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('equipment')) {
      context.handle(
        _equipmentMeta,
        equipment.isAcceptableOrUnknown(data['equipment']!, _equipmentMeta),
      );
    }
    if (data.containsKey('timed')) {
      context.handle(_timedMeta, timed.isAcceptableOrUnknown(data['timed']!, _timedMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(_notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomExercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomExercise(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      equipment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipment'],
      ),
      timed: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}timed'])!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CustomExercisesTable createAlias(String alias) {
    return $CustomExercisesTable(attachedDatabase, alias);
  }
}

class CustomExercise extends DataClass implements Insertable<CustomExercise> {
  final String id;
  final String name;
  final String? equipment;
  final bool timed;
  final String? notes;
  final DateTime createdAt;
  const CustomExercise({
    required this.id,
    required this.name,
    this.equipment,
    required this.timed,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || equipment != null) {
      map['equipment'] = Variable<String>(equipment);
    }
    map['timed'] = Variable<bool>(timed);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CustomExercisesCompanion toCompanion(bool nullToAbsent) {
    return CustomExercisesCompanion(
      id: Value(id),
      name: Value(name),
      equipment: equipment == null && nullToAbsent ? const Value.absent() : Value(equipment),
      timed: Value(timed),
      notes: notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory CustomExercise.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomExercise(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      equipment: serializer.fromJson<String?>(json['equipment']),
      timed: serializer.fromJson<bool>(json['timed']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'equipment': serializer.toJson<String?>(equipment),
      'timed': serializer.toJson<bool>(timed),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CustomExercise copyWith({
    String? id,
    String? name,
    Value<String?> equipment = const Value.absent(),
    bool? timed,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => CustomExercise(
    id: id ?? this.id,
    name: name ?? this.name,
    equipment: equipment.present ? equipment.value : this.equipment,
    timed: timed ?? this.timed,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  CustomExercise copyWithCompanion(CustomExercisesCompanion data) {
    return CustomExercise(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      equipment: data.equipment.present ? data.equipment.value : this.equipment,
      timed: data.timed.present ? data.timed.value : this.timed,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomExercise(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('equipment: $equipment, ')
          ..write('timed: $timed, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, equipment, timed, notes, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomExercise &&
          other.id == this.id &&
          other.name == this.name &&
          other.equipment == this.equipment &&
          other.timed == this.timed &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class CustomExercisesCompanion extends UpdateCompanion<CustomExercise> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> equipment;
  final Value<bool> timed;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CustomExercisesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.equipment = const Value.absent(),
    this.timed = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomExercisesCompanion.insert({
    required String id,
    required String name,
    this.equipment = const Value.absent(),
    this.timed = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<CustomExercise> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? equipment,
    Expression<bool>? timed,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (equipment != null) 'equipment': equipment,
      if (timed != null) 'timed': timed,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomExercisesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? equipment,
    Value<bool>? timed,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CustomExercisesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      equipment: equipment ?? this.equipment,
      timed: timed ?? this.timed,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (equipment.present) {
      map['equipment'] = Variable<String>(equipment.value);
    }
    if (timed.present) {
      map['timed'] = Variable<bool>(timed.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomExercisesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('equipment: $equipment, ')
          ..write('timed: $timed, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LearnedAliasesTable extends LearnedAliases
    with TableInfo<$LearnedAliasesTable, LearnedAlias> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LearnedAliasesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _aliasMeta = const VerificationMeta('alias');
  @override
  late final GeneratedColumn<String> alias = GeneratedColumn<String>(
    'alias',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta('exerciseId');
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [alias, exerciseId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'learned_aliases';
  @override
  VerificationContext validateIntegrity(
    Insertable<LearnedAlias> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('alias')) {
      context.handle(_aliasMeta, alias.isAcceptableOrUnknown(data['alias']!, _aliasMeta));
    } else if (isInserting) {
      context.missing(_aliasMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {alias};
  @override
  LearnedAlias map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LearnedAlias(
      alias: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alias'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
    );
  }

  @override
  $LearnedAliasesTable createAlias(String alias) {
    return $LearnedAliasesTable(attachedDatabase, alias);
  }
}

class LearnedAlias extends DataClass implements Insertable<LearnedAlias> {
  final String alias;
  final String exerciseId;
  const LearnedAlias({required this.alias, required this.exerciseId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['alias'] = Variable<String>(alias);
    map['exercise_id'] = Variable<String>(exerciseId);
    return map;
  }

  LearnedAliasesCompanion toCompanion(bool nullToAbsent) {
    return LearnedAliasesCompanion(alias: Value(alias), exerciseId: Value(exerciseId));
  }

  factory LearnedAlias.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LearnedAlias(
      alias: serializer.fromJson<String>(json['alias']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'alias': serializer.toJson<String>(alias),
      'exerciseId': serializer.toJson<String>(exerciseId),
    };
  }

  LearnedAlias copyWith({String? alias, String? exerciseId}) =>
      LearnedAlias(alias: alias ?? this.alias, exerciseId: exerciseId ?? this.exerciseId);
  LearnedAlias copyWithCompanion(LearnedAliasesCompanion data) {
    return LearnedAlias(
      alias: data.alias.present ? data.alias.value : this.alias,
      exerciseId: data.exerciseId.present ? data.exerciseId.value : this.exerciseId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LearnedAlias(')
          ..write('alias: $alias, ')
          ..write('exerciseId: $exerciseId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(alias, exerciseId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LearnedAlias && other.alias == this.alias && other.exerciseId == this.exerciseId);
}

class LearnedAliasesCompanion extends UpdateCompanion<LearnedAlias> {
  final Value<String> alias;
  final Value<String> exerciseId;
  final Value<int> rowid;
  const LearnedAliasesCompanion({
    this.alias = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LearnedAliasesCompanion.insert({
    required String alias,
    required String exerciseId,
    this.rowid = const Value.absent(),
  }) : alias = Value(alias),
       exerciseId = Value(exerciseId);
  static Insertable<LearnedAlias> custom({
    Expression<String>? alias,
    Expression<String>? exerciseId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (alias != null) 'alias': alias,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LearnedAliasesCompanion copyWith({
    Value<String>? alias,
    Value<String>? exerciseId,
    Value<int>? rowid,
  }) {
    return LearnedAliasesCompanion(
      alias: alias ?? this.alias,
      exerciseId: exerciseId ?? this.exerciseId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (alias.present) {
      map['alias'] = Variable<String>(alias.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LearnedAliasesCompanion(')
          ..write('alias: $alias, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoutinesTable extends Routines with TableInfo<$RoutinesTable, Routine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceTextMeta = const VerificationMeta('sourceText');
  @override
  late final GeneratedColumn<String> sourceText = GeneratedColumn<String>(
    'source_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta('archived');
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("archived" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    notes,
    sourceText,
    createdAt,
    updatedAt,
    archived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routines';
  @override
  VerificationContext validateIntegrity(Insertable<Routine> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(_notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('source_text')) {
      context.handle(
        _sourceTextMeta,
        sourceText.isAcceptableOrUnknown(data['source_text']!, _sourceTextMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Routine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Routine(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      sourceText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_text'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
    );
  }

  @override
  $RoutinesTable createAlias(String alias) {
    return $RoutinesTable(attachedDatabase, alias);
  }
}

class Routine extends DataClass implements Insertable<Routine> {
  final int id;
  final String name;
  final String? notes;

  /// The text you pasted, kept for reference.
  final String? sourceText;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool archived;
  const Routine({
    required this.id,
    required this.name,
    this.notes,
    this.sourceText,
    required this.createdAt,
    required this.updatedAt,
    required this.archived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || sourceText != null) {
      map['source_text'] = Variable<String>(sourceText);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['archived'] = Variable<bool>(archived);
    return map;
  }

  RoutinesCompanion toCompanion(bool nullToAbsent) {
    return RoutinesCompanion(
      id: Value(id),
      name: Value(name),
      notes: notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      sourceText: sourceText == null && nullToAbsent ? const Value.absent() : Value(sourceText),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      archived: Value(archived),
    );
  }

  factory Routine.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Routine(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      notes: serializer.fromJson<String?>(json['notes']),
      sourceText: serializer.fromJson<String?>(json['sourceText']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      archived: serializer.fromJson<bool>(json['archived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'notes': serializer.toJson<String?>(notes),
      'sourceText': serializer.toJson<String?>(sourceText),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'archived': serializer.toJson<bool>(archived),
    };
  }

  Routine copyWith({
    int? id,
    String? name,
    Value<String?> notes = const Value.absent(),
    Value<String?> sourceText = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? archived,
  }) => Routine(
    id: id ?? this.id,
    name: name ?? this.name,
    notes: notes.present ? notes.value : this.notes,
    sourceText: sourceText.present ? sourceText.value : this.sourceText,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    archived: archived ?? this.archived,
  );
  Routine copyWithCompanion(RoutinesCompanion data) {
    return Routine(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      notes: data.notes.present ? data.notes.value : this.notes,
      sourceText: data.sourceText.present ? data.sourceText.value : this.sourceText,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      archived: data.archived.present ? data.archived.value : this.archived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Routine(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('notes: $notes, ')
          ..write('sourceText: $sourceText, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archived: $archived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, notes, sourceText, createdAt, updatedAt, archived);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Routine &&
          other.id == this.id &&
          other.name == this.name &&
          other.notes == this.notes &&
          other.sourceText == this.sourceText &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.archived == this.archived);
}

class RoutinesCompanion extends UpdateCompanion<Routine> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> notes;
  final Value<String?> sourceText;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> archived;
  const RoutinesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.notes = const Value.absent(),
    this.sourceText = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.archived = const Value.absent(),
  });
  RoutinesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.notes = const Value.absent(),
    this.sourceText = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.archived = const Value.absent(),
  }) : name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Routine> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? notes,
    Expression<String>? sourceText,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? archived,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (notes != null) 'notes': notes,
      if (sourceText != null) 'source_text': sourceText,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (archived != null) 'archived': archived,
    });
  }

  RoutinesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? notes,
    Value<String?>? sourceText,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? archived,
  }) {
    return RoutinesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      sourceText: sourceText ?? this.sourceText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archived: archived ?? this.archived,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (sourceText.present) {
      map['source_text'] = Variable<String>(sourceText.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutinesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('notes: $notes, ')
          ..write('sourceText: $sourceText, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archived: $archived')
          ..write(')'))
        .toString();
  }
}

class $RoutineDaysTable extends RoutineDays with TableInfo<$RoutineDaysTable, RoutineDay> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutineDaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _routineIdMeta = const VerificationMeta('routineId');
  @override
  late final GeneratedColumn<int> routineId = GeneratedColumn<int>(
    'routine_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES routines (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta('position');
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weekdaysMeta = const VerificationMeta('weekdays');
  @override
  late final GeneratedColumn<int> weekdays = GeneratedColumn<int>(
    'weekdays',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, routineId, name, position, weekdays];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routine_days';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoutineDay> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('routine_id')) {
      context.handle(
        _routineIdMeta,
        routineId.isAcceptableOrUnknown(data['routine_id']!, _routineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_routineIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('weekdays')) {
      context.handle(
        _weekdaysMeta,
        weekdays.isAcceptableOrUnknown(data['weekdays']!, _weekdaysMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoutineDay map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutineDay(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      routineId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}routine_id'],
      )!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      weekdays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekdays'],
      )!,
    );
  }

  @override
  $RoutineDaysTable createAlias(String alias) {
    return $RoutineDaysTable(attachedDatabase, alias);
  }
}

class RoutineDay extends DataClass implements Insertable<RoutineDay> {
  final int id;
  final int routineId;
  final String name;
  final int position;

  /// Days of the week this day is planned for: bit 0 = Monday … bit 6 = Sunday.
  final int weekdays;
  const RoutineDay({
    required this.id,
    required this.routineId,
    required this.name,
    required this.position,
    required this.weekdays,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['routine_id'] = Variable<int>(routineId);
    map['name'] = Variable<String>(name);
    map['position'] = Variable<int>(position);
    map['weekdays'] = Variable<int>(weekdays);
    return map;
  }

  RoutineDaysCompanion toCompanion(bool nullToAbsent) {
    return RoutineDaysCompanion(
      id: Value(id),
      routineId: Value(routineId),
      name: Value(name),
      position: Value(position),
      weekdays: Value(weekdays),
    );
  }

  factory RoutineDay.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutineDay(
      id: serializer.fromJson<int>(json['id']),
      routineId: serializer.fromJson<int>(json['routineId']),
      name: serializer.fromJson<String>(json['name']),
      position: serializer.fromJson<int>(json['position']),
      weekdays: serializer.fromJson<int>(json['weekdays']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'routineId': serializer.toJson<int>(routineId),
      'name': serializer.toJson<String>(name),
      'position': serializer.toJson<int>(position),
      'weekdays': serializer.toJson<int>(weekdays),
    };
  }

  RoutineDay copyWith({int? id, int? routineId, String? name, int? position, int? weekdays}) =>
      RoutineDay(
        id: id ?? this.id,
        routineId: routineId ?? this.routineId,
        name: name ?? this.name,
        position: position ?? this.position,
        weekdays: weekdays ?? this.weekdays,
      );
  RoutineDay copyWithCompanion(RoutineDaysCompanion data) {
    return RoutineDay(
      id: data.id.present ? data.id.value : this.id,
      routineId: data.routineId.present ? data.routineId.value : this.routineId,
      name: data.name.present ? data.name.value : this.name,
      position: data.position.present ? data.position.value : this.position,
      weekdays: data.weekdays.present ? data.weekdays.value : this.weekdays,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoutineDay(')
          ..write('id: $id, ')
          ..write('routineId: $routineId, ')
          ..write('name: $name, ')
          ..write('position: $position, ')
          ..write('weekdays: $weekdays')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, routineId, name, position, weekdays);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutineDay &&
          other.id == this.id &&
          other.routineId == this.routineId &&
          other.name == this.name &&
          other.position == this.position &&
          other.weekdays == this.weekdays);
}

class RoutineDaysCompanion extends UpdateCompanion<RoutineDay> {
  final Value<int> id;
  final Value<int> routineId;
  final Value<String> name;
  final Value<int> position;
  final Value<int> weekdays;
  const RoutineDaysCompanion({
    this.id = const Value.absent(),
    this.routineId = const Value.absent(),
    this.name = const Value.absent(),
    this.position = const Value.absent(),
    this.weekdays = const Value.absent(),
  });
  RoutineDaysCompanion.insert({
    this.id = const Value.absent(),
    required int routineId,
    required String name,
    required int position,
    this.weekdays = const Value.absent(),
  }) : routineId = Value(routineId),
       name = Value(name),
       position = Value(position);
  static Insertable<RoutineDay> custom({
    Expression<int>? id,
    Expression<int>? routineId,
    Expression<String>? name,
    Expression<int>? position,
    Expression<int>? weekdays,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (routineId != null) 'routine_id': routineId,
      if (name != null) 'name': name,
      if (position != null) 'position': position,
      if (weekdays != null) 'weekdays': weekdays,
    });
  }

  RoutineDaysCompanion copyWith({
    Value<int>? id,
    Value<int>? routineId,
    Value<String>? name,
    Value<int>? position,
    Value<int>? weekdays,
  }) {
    return RoutineDaysCompanion(
      id: id ?? this.id,
      routineId: routineId ?? this.routineId,
      name: name ?? this.name,
      position: position ?? this.position,
      weekdays: weekdays ?? this.weekdays,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (routineId.present) {
      map['routine_id'] = Variable<int>(routineId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (weekdays.present) {
      map['weekdays'] = Variable<int>(weekdays.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutineDaysCompanion(')
          ..write('id: $id, ')
          ..write('routineId: $routineId, ')
          ..write('name: $name, ')
          ..write('position: $position, ')
          ..write('weekdays: $weekdays')
          ..write(')'))
        .toString();
  }
}

class $RoutineExercisesTable extends RoutineExercises
    with TableInfo<$RoutineExercisesTable, RoutineExercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutineExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _dayIdMeta = const VerificationMeta('dayId');
  @override
  late final GeneratedColumn<int> dayId = GeneratedColumn<int>(
    'day_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES routine_days (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta('exerciseId');
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta('position');
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupLabelMeta = const VerificationMeta('groupLabel');
  @override
  late final GeneratedColumn<String> groupLabel = GeneratedColumn<String>(
    'group_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _restSecondsMeta = const VerificationMeta('restSeconds');
  @override
  late final GeneratedColumn<int> restSeconds = GeneratedColumn<int>(
    'rest_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Provenance, int> restFrom = GeneratedColumn<int>(
    'rest_from',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  ).withConverter<Provenance>($RoutineExercisesTable.$converterrestFrom);
  static const VerificationMeta _tempoMeta = const VerificationMeta('tempo');
  @override
  late final GeneratedColumn<String> tempo = GeneratedColumn<String>(
    'tempo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _perSideMeta = const VerificationMeta('perSide');
  @override
  late final GeneratedColumn<bool> perSide = GeneratedColumn<bool>(
    'per_side',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("per_side" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _timedMeta = const VerificationMeta('timed');
  @override
  late final GeneratedColumn<bool> timed = GeneratedColumn<bool>(
    'timed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("timed" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _variantMeta = const VerificationMeta('variant');
  @override
  late final GeneratedColumn<String> variant = GeneratedColumn<String>(
    'variant',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    dayId,
    exerciseId,
    name,
    position,
    groupLabel,
    restSeconds,
    restFrom,
    tempo,
    notes,
    perSide,
    timed,
    variant,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routine_exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoutineExercise> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('day_id')) {
      context.handle(_dayIdMeta, dayId.isAcceptableOrUnknown(data['day_id']!, _dayIdMeta));
    } else if (isInserting) {
      context.missing(_dayIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('group_label')) {
      context.handle(
        _groupLabelMeta,
        groupLabel.isAcceptableOrUnknown(data['group_label']!, _groupLabelMeta),
      );
    }
    if (data.containsKey('rest_seconds')) {
      context.handle(
        _restSecondsMeta,
        restSeconds.isAcceptableOrUnknown(data['rest_seconds']!, _restSecondsMeta),
      );
    }
    if (data.containsKey('tempo')) {
      context.handle(_tempoMeta, tempo.isAcceptableOrUnknown(data['tempo']!, _tempoMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(_notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('per_side')) {
      context.handle(_perSideMeta, perSide.isAcceptableOrUnknown(data['per_side']!, _perSideMeta));
    }
    if (data.containsKey('timed')) {
      context.handle(_timedMeta, timed.isAcceptableOrUnknown(data['timed']!, _timedMeta));
    }
    if (data.containsKey('variant')) {
      context.handle(_variantMeta, variant.isAcceptableOrUnknown(data['variant']!, _variantMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoutineExercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutineExercise(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      dayId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}day_id'])!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      ),
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      groupLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_label'],
      ),
      restSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rest_seconds'],
      ),
      restFrom: $RoutineExercisesTable.$converterrestFrom.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}rest_from'])!,
      ),
      tempo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tempo'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      perSide: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}per_side'],
      )!,
      timed: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}timed'])!,
      variant: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}variant'],
      ),
    );
  }

  @override
  $RoutineExercisesTable createAlias(String alias) {
    return $RoutineExercisesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Provenance, int, int> $converterrestFrom =
      const EnumIndexConverter<Provenance>(Provenance.values);
}

class RoutineExercise extends DataClass implements Insertable<RoutineExercise> {
  final int id;
  final int dayId;

  /// Library or custom id. Null while an imported name is still unresolved.
  final String? exerciseId;
  final String name;
  final int position;
  final String? groupLabel;
  final int? restSeconds;
  final Provenance restFrom;
  final String? tempo;
  final String? notes;
  final bool perSide;
  final bool timed;

  /// The specific machine or setup ("Gym A cable, 2:1 pulley"). Loads are only
  /// compared between sets with the same variant.
  final String? variant;
  const RoutineExercise({
    required this.id,
    required this.dayId,
    this.exerciseId,
    required this.name,
    required this.position,
    this.groupLabel,
    this.restSeconds,
    required this.restFrom,
    this.tempo,
    this.notes,
    required this.perSide,
    required this.timed,
    this.variant,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['day_id'] = Variable<int>(dayId);
    if (!nullToAbsent || exerciseId != null) {
      map['exercise_id'] = Variable<String>(exerciseId);
    }
    map['name'] = Variable<String>(name);
    map['position'] = Variable<int>(position);
    if (!nullToAbsent || groupLabel != null) {
      map['group_label'] = Variable<String>(groupLabel);
    }
    if (!nullToAbsent || restSeconds != null) {
      map['rest_seconds'] = Variable<int>(restSeconds);
    }
    {
      map['rest_from'] = Variable<int>($RoutineExercisesTable.$converterrestFrom.toSql(restFrom));
    }
    if (!nullToAbsent || tempo != null) {
      map['tempo'] = Variable<String>(tempo);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['per_side'] = Variable<bool>(perSide);
    map['timed'] = Variable<bool>(timed);
    if (!nullToAbsent || variant != null) {
      map['variant'] = Variable<String>(variant);
    }
    return map;
  }

  RoutineExercisesCompanion toCompanion(bool nullToAbsent) {
    return RoutineExercisesCompanion(
      id: Value(id),
      dayId: Value(dayId),
      exerciseId: exerciseId == null && nullToAbsent ? const Value.absent() : Value(exerciseId),
      name: Value(name),
      position: Value(position),
      groupLabel: groupLabel == null && nullToAbsent ? const Value.absent() : Value(groupLabel),
      restSeconds: restSeconds == null && nullToAbsent ? const Value.absent() : Value(restSeconds),
      restFrom: Value(restFrom),
      tempo: tempo == null && nullToAbsent ? const Value.absent() : Value(tempo),
      notes: notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      perSide: Value(perSide),
      timed: Value(timed),
      variant: variant == null && nullToAbsent ? const Value.absent() : Value(variant),
    );
  }

  factory RoutineExercise.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutineExercise(
      id: serializer.fromJson<int>(json['id']),
      dayId: serializer.fromJson<int>(json['dayId']),
      exerciseId: serializer.fromJson<String?>(json['exerciseId']),
      name: serializer.fromJson<String>(json['name']),
      position: serializer.fromJson<int>(json['position']),
      groupLabel: serializer.fromJson<String?>(json['groupLabel']),
      restSeconds: serializer.fromJson<int?>(json['restSeconds']),
      restFrom: $RoutineExercisesTable.$converterrestFrom.fromJson(
        serializer.fromJson<int>(json['restFrom']),
      ),
      tempo: serializer.fromJson<String?>(json['tempo']),
      notes: serializer.fromJson<String?>(json['notes']),
      perSide: serializer.fromJson<bool>(json['perSide']),
      timed: serializer.fromJson<bool>(json['timed']),
      variant: serializer.fromJson<String?>(json['variant']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dayId': serializer.toJson<int>(dayId),
      'exerciseId': serializer.toJson<String?>(exerciseId),
      'name': serializer.toJson<String>(name),
      'position': serializer.toJson<int>(position),
      'groupLabel': serializer.toJson<String?>(groupLabel),
      'restSeconds': serializer.toJson<int?>(restSeconds),
      'restFrom': serializer.toJson<int>(
        $RoutineExercisesTable.$converterrestFrom.toJson(restFrom),
      ),
      'tempo': serializer.toJson<String?>(tempo),
      'notes': serializer.toJson<String?>(notes),
      'perSide': serializer.toJson<bool>(perSide),
      'timed': serializer.toJson<bool>(timed),
      'variant': serializer.toJson<String?>(variant),
    };
  }

  RoutineExercise copyWith({
    int? id,
    int? dayId,
    Value<String?> exerciseId = const Value.absent(),
    String? name,
    int? position,
    Value<String?> groupLabel = const Value.absent(),
    Value<int?> restSeconds = const Value.absent(),
    Provenance? restFrom,
    Value<String?> tempo = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    bool? perSide,
    bool? timed,
    Value<String?> variant = const Value.absent(),
  }) => RoutineExercise(
    id: id ?? this.id,
    dayId: dayId ?? this.dayId,
    exerciseId: exerciseId.present ? exerciseId.value : this.exerciseId,
    name: name ?? this.name,
    position: position ?? this.position,
    groupLabel: groupLabel.present ? groupLabel.value : this.groupLabel,
    restSeconds: restSeconds.present ? restSeconds.value : this.restSeconds,
    restFrom: restFrom ?? this.restFrom,
    tempo: tempo.present ? tempo.value : this.tempo,
    notes: notes.present ? notes.value : this.notes,
    perSide: perSide ?? this.perSide,
    timed: timed ?? this.timed,
    variant: variant.present ? variant.value : this.variant,
  );
  RoutineExercise copyWithCompanion(RoutineExercisesCompanion data) {
    return RoutineExercise(
      id: data.id.present ? data.id.value : this.id,
      dayId: data.dayId.present ? data.dayId.value : this.dayId,
      exerciseId: data.exerciseId.present ? data.exerciseId.value : this.exerciseId,
      name: data.name.present ? data.name.value : this.name,
      position: data.position.present ? data.position.value : this.position,
      groupLabel: data.groupLabel.present ? data.groupLabel.value : this.groupLabel,
      restSeconds: data.restSeconds.present ? data.restSeconds.value : this.restSeconds,
      restFrom: data.restFrom.present ? data.restFrom.value : this.restFrom,
      tempo: data.tempo.present ? data.tempo.value : this.tempo,
      notes: data.notes.present ? data.notes.value : this.notes,
      perSide: data.perSide.present ? data.perSide.value : this.perSide,
      timed: data.timed.present ? data.timed.value : this.timed,
      variant: data.variant.present ? data.variant.value : this.variant,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoutineExercise(')
          ..write('id: $id, ')
          ..write('dayId: $dayId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('name: $name, ')
          ..write('position: $position, ')
          ..write('groupLabel: $groupLabel, ')
          ..write('restSeconds: $restSeconds, ')
          ..write('restFrom: $restFrom, ')
          ..write('tempo: $tempo, ')
          ..write('notes: $notes, ')
          ..write('perSide: $perSide, ')
          ..write('timed: $timed, ')
          ..write('variant: $variant')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    dayId,
    exerciseId,
    name,
    position,
    groupLabel,
    restSeconds,
    restFrom,
    tempo,
    notes,
    perSide,
    timed,
    variant,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutineExercise &&
          other.id == this.id &&
          other.dayId == this.dayId &&
          other.exerciseId == this.exerciseId &&
          other.name == this.name &&
          other.position == this.position &&
          other.groupLabel == this.groupLabel &&
          other.restSeconds == this.restSeconds &&
          other.restFrom == this.restFrom &&
          other.tempo == this.tempo &&
          other.notes == this.notes &&
          other.perSide == this.perSide &&
          other.timed == this.timed &&
          other.variant == this.variant);
}

class RoutineExercisesCompanion extends UpdateCompanion<RoutineExercise> {
  final Value<int> id;
  final Value<int> dayId;
  final Value<String?> exerciseId;
  final Value<String> name;
  final Value<int> position;
  final Value<String?> groupLabel;
  final Value<int?> restSeconds;
  final Value<Provenance> restFrom;
  final Value<String?> tempo;
  final Value<String?> notes;
  final Value<bool> perSide;
  final Value<bool> timed;
  final Value<String?> variant;
  const RoutineExercisesCompanion({
    this.id = const Value.absent(),
    this.dayId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.name = const Value.absent(),
    this.position = const Value.absent(),
    this.groupLabel = const Value.absent(),
    this.restSeconds = const Value.absent(),
    this.restFrom = const Value.absent(),
    this.tempo = const Value.absent(),
    this.notes = const Value.absent(),
    this.perSide = const Value.absent(),
    this.timed = const Value.absent(),
    this.variant = const Value.absent(),
  });
  RoutineExercisesCompanion.insert({
    this.id = const Value.absent(),
    required int dayId,
    this.exerciseId = const Value.absent(),
    required String name,
    required int position,
    this.groupLabel = const Value.absent(),
    this.restSeconds = const Value.absent(),
    this.restFrom = const Value.absent(),
    this.tempo = const Value.absent(),
    this.notes = const Value.absent(),
    this.perSide = const Value.absent(),
    this.timed = const Value.absent(),
    this.variant = const Value.absent(),
  }) : dayId = Value(dayId),
       name = Value(name),
       position = Value(position);
  static Insertable<RoutineExercise> custom({
    Expression<int>? id,
    Expression<int>? dayId,
    Expression<String>? exerciseId,
    Expression<String>? name,
    Expression<int>? position,
    Expression<String>? groupLabel,
    Expression<int>? restSeconds,
    Expression<int>? restFrom,
    Expression<String>? tempo,
    Expression<String>? notes,
    Expression<bool>? perSide,
    Expression<bool>? timed,
    Expression<String>? variant,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dayId != null) 'day_id': dayId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (name != null) 'name': name,
      if (position != null) 'position': position,
      if (groupLabel != null) 'group_label': groupLabel,
      if (restSeconds != null) 'rest_seconds': restSeconds,
      if (restFrom != null) 'rest_from': restFrom,
      if (tempo != null) 'tempo': tempo,
      if (notes != null) 'notes': notes,
      if (perSide != null) 'per_side': perSide,
      if (timed != null) 'timed': timed,
      if (variant != null) 'variant': variant,
    });
  }

  RoutineExercisesCompanion copyWith({
    Value<int>? id,
    Value<int>? dayId,
    Value<String?>? exerciseId,
    Value<String>? name,
    Value<int>? position,
    Value<String?>? groupLabel,
    Value<int?>? restSeconds,
    Value<Provenance>? restFrom,
    Value<String?>? tempo,
    Value<String?>? notes,
    Value<bool>? perSide,
    Value<bool>? timed,
    Value<String?>? variant,
  }) {
    return RoutineExercisesCompanion(
      id: id ?? this.id,
      dayId: dayId ?? this.dayId,
      exerciseId: exerciseId ?? this.exerciseId,
      name: name ?? this.name,
      position: position ?? this.position,
      groupLabel: groupLabel ?? this.groupLabel,
      restSeconds: restSeconds ?? this.restSeconds,
      restFrom: restFrom ?? this.restFrom,
      tempo: tempo ?? this.tempo,
      notes: notes ?? this.notes,
      perSide: perSide ?? this.perSide,
      timed: timed ?? this.timed,
      variant: variant ?? this.variant,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dayId.present) {
      map['day_id'] = Variable<int>(dayId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (groupLabel.present) {
      map['group_label'] = Variable<String>(groupLabel.value);
    }
    if (restSeconds.present) {
      map['rest_seconds'] = Variable<int>(restSeconds.value);
    }
    if (restFrom.present) {
      map['rest_from'] = Variable<int>(
        $RoutineExercisesTable.$converterrestFrom.toSql(restFrom.value),
      );
    }
    if (tempo.present) {
      map['tempo'] = Variable<String>(tempo.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (perSide.present) {
      map['per_side'] = Variable<bool>(perSide.value);
    }
    if (timed.present) {
      map['timed'] = Variable<bool>(timed.value);
    }
    if (variant.present) {
      map['variant'] = Variable<String>(variant.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutineExercisesCompanion(')
          ..write('id: $id, ')
          ..write('dayId: $dayId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('name: $name, ')
          ..write('position: $position, ')
          ..write('groupLabel: $groupLabel, ')
          ..write('restSeconds: $restSeconds, ')
          ..write('restFrom: $restFrom, ')
          ..write('tempo: $tempo, ')
          ..write('notes: $notes, ')
          ..write('perSide: $perSide, ')
          ..write('timed: $timed, ')
          ..write('variant: $variant')
          ..write(')'))
        .toString();
  }
}

class $RoutineSetsTable extends RoutineSets with TableInfo<$RoutineSetsTable, RoutineSet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutineSetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _routineExerciseIdMeta = const VerificationMeta(
    'routineExerciseId',
  );
  @override
  late final GeneratedColumn<int> routineExerciseId = GeneratedColumn<int>(
    'routine_exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES routine_exercises (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta('position');
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TargetKind, int> kind = GeneratedColumn<int>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  ).withConverter<TargetKind>($RoutineSetsTable.$converterkind);
  static const VerificationMeta _repsMinMeta = const VerificationMeta('repsMin');
  @override
  late final GeneratedColumn<int> repsMin = GeneratedColumn<int>(
    'reps_min',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repsMaxMeta = const VerificationMeta('repsMax');
  @override
  late final GeneratedColumn<int> repsMax = GeneratedColumn<int>(
    'reps_max',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta('durationSeconds');
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
    'weight',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<WeightUnit, int> unit = GeneratedColumn<int>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  ).withConverter<WeightUnit>($RoutineSetsTable.$converterunit);
  @override
  late final GeneratedColumnWithTypeConverter<Provenance, int> setsFrom = GeneratedColumn<int>(
    'sets_from',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  ).withConverter<Provenance>($RoutineSetsTable.$convertersetsFrom);
  @override
  late final GeneratedColumnWithTypeConverter<Provenance, int> targetFrom = GeneratedColumn<int>(
    'target_from',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  ).withConverter<Provenance>($RoutineSetsTable.$convertertargetFrom);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    routineExerciseId,
    position,
    kind,
    repsMin,
    repsMax,
    durationSeconds,
    weight,
    unit,
    setsFrom,
    targetFrom,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routine_sets';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoutineSet> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('routine_exercise_id')) {
      context.handle(
        _routineExerciseIdMeta,
        routineExerciseId.isAcceptableOrUnknown(
          data['routine_exercise_id']!,
          _routineExerciseIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_routineExerciseIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('reps_min')) {
      context.handle(_repsMinMeta, repsMin.isAcceptableOrUnknown(data['reps_min']!, _repsMinMeta));
    }
    if (data.containsKey('reps_max')) {
      context.handle(_repsMaxMeta, repsMax.isAcceptableOrUnknown(data['reps_max']!, _repsMaxMeta));
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(data['duration_seconds']!, _durationSecondsMeta),
      );
    }
    if (data.containsKey('weight')) {
      context.handle(_weightMeta, weight.isAcceptableOrUnknown(data['weight']!, _weightMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoutineSet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutineSet(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      routineExerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}routine_exercise_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      kind: $RoutineSetsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}kind'])!,
      ),
      repsMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps_min'],
      ),
      repsMax: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps_max'],
      ),
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      ),
      weight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight'],
      ),
      unit: $RoutineSetsTable.$converterunit.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}unit'])!,
      ),
      setsFrom: $RoutineSetsTable.$convertersetsFrom.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}sets_from'])!,
      ),
      targetFrom: $RoutineSetsTable.$convertertargetFrom.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}target_from'])!,
      ),
    );
  }

  @override
  $RoutineSetsTable createAlias(String alias) {
    return $RoutineSetsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TargetKind, int, int> $converterkind =
      const EnumIndexConverter<TargetKind>(TargetKind.values);
  static JsonTypeConverter2<WeightUnit, int, int> $converterunit =
      const EnumIndexConverter<WeightUnit>(WeightUnit.values);
  static JsonTypeConverter2<Provenance, int, int> $convertersetsFrom =
      const EnumIndexConverter<Provenance>(Provenance.values);
  static JsonTypeConverter2<Provenance, int, int> $convertertargetFrom =
      const EnumIndexConverter<Provenance>(Provenance.values);
}

class RoutineSet extends DataClass implements Insertable<RoutineSet> {
  final int id;
  final int routineExerciseId;
  final int position;
  final TargetKind kind;
  final int? repsMin;
  final int? repsMax;
  final int? durationSeconds;
  final double? weight;
  final WeightUnit unit;
  final Provenance setsFrom;
  final Provenance targetFrom;
  const RoutineSet({
    required this.id,
    required this.routineExerciseId,
    required this.position,
    required this.kind,
    this.repsMin,
    this.repsMax,
    this.durationSeconds,
    this.weight,
    required this.unit,
    required this.setsFrom,
    required this.targetFrom,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['routine_exercise_id'] = Variable<int>(routineExerciseId);
    map['position'] = Variable<int>(position);
    {
      map['kind'] = Variable<int>($RoutineSetsTable.$converterkind.toSql(kind));
    }
    if (!nullToAbsent || repsMin != null) {
      map['reps_min'] = Variable<int>(repsMin);
    }
    if (!nullToAbsent || repsMax != null) {
      map['reps_max'] = Variable<int>(repsMax);
    }
    if (!nullToAbsent || durationSeconds != null) {
      map['duration_seconds'] = Variable<int>(durationSeconds);
    }
    if (!nullToAbsent || weight != null) {
      map['weight'] = Variable<double>(weight);
    }
    {
      map['unit'] = Variable<int>($RoutineSetsTable.$converterunit.toSql(unit));
    }
    {
      map['sets_from'] = Variable<int>($RoutineSetsTable.$convertersetsFrom.toSql(setsFrom));
    }
    {
      map['target_from'] = Variable<int>($RoutineSetsTable.$convertertargetFrom.toSql(targetFrom));
    }
    return map;
  }

  RoutineSetsCompanion toCompanion(bool nullToAbsent) {
    return RoutineSetsCompanion(
      id: Value(id),
      routineExerciseId: Value(routineExerciseId),
      position: Value(position),
      kind: Value(kind),
      repsMin: repsMin == null && nullToAbsent ? const Value.absent() : Value(repsMin),
      repsMax: repsMax == null && nullToAbsent ? const Value.absent() : Value(repsMax),
      durationSeconds: durationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(durationSeconds),
      weight: weight == null && nullToAbsent ? const Value.absent() : Value(weight),
      unit: Value(unit),
      setsFrom: Value(setsFrom),
      targetFrom: Value(targetFrom),
    );
  }

  factory RoutineSet.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutineSet(
      id: serializer.fromJson<int>(json['id']),
      routineExerciseId: serializer.fromJson<int>(json['routineExerciseId']),
      position: serializer.fromJson<int>(json['position']),
      kind: $RoutineSetsTable.$converterkind.fromJson(serializer.fromJson<int>(json['kind'])),
      repsMin: serializer.fromJson<int?>(json['repsMin']),
      repsMax: serializer.fromJson<int?>(json['repsMax']),
      durationSeconds: serializer.fromJson<int?>(json['durationSeconds']),
      weight: serializer.fromJson<double?>(json['weight']),
      unit: $RoutineSetsTable.$converterunit.fromJson(serializer.fromJson<int>(json['unit'])),
      setsFrom: $RoutineSetsTable.$convertersetsFrom.fromJson(
        serializer.fromJson<int>(json['setsFrom']),
      ),
      targetFrom: $RoutineSetsTable.$convertertargetFrom.fromJson(
        serializer.fromJson<int>(json['targetFrom']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'routineExerciseId': serializer.toJson<int>(routineExerciseId),
      'position': serializer.toJson<int>(position),
      'kind': serializer.toJson<int>($RoutineSetsTable.$converterkind.toJson(kind)),
      'repsMin': serializer.toJson<int?>(repsMin),
      'repsMax': serializer.toJson<int?>(repsMax),
      'durationSeconds': serializer.toJson<int?>(durationSeconds),
      'weight': serializer.toJson<double?>(weight),
      'unit': serializer.toJson<int>($RoutineSetsTable.$converterunit.toJson(unit)),
      'setsFrom': serializer.toJson<int>($RoutineSetsTable.$convertersetsFrom.toJson(setsFrom)),
      'targetFrom': serializer.toJson<int>(
        $RoutineSetsTable.$convertertargetFrom.toJson(targetFrom),
      ),
    };
  }

  RoutineSet copyWith({
    int? id,
    int? routineExerciseId,
    int? position,
    TargetKind? kind,
    Value<int?> repsMin = const Value.absent(),
    Value<int?> repsMax = const Value.absent(),
    Value<int?> durationSeconds = const Value.absent(),
    Value<double?> weight = const Value.absent(),
    WeightUnit? unit,
    Provenance? setsFrom,
    Provenance? targetFrom,
  }) => RoutineSet(
    id: id ?? this.id,
    routineExerciseId: routineExerciseId ?? this.routineExerciseId,
    position: position ?? this.position,
    kind: kind ?? this.kind,
    repsMin: repsMin.present ? repsMin.value : this.repsMin,
    repsMax: repsMax.present ? repsMax.value : this.repsMax,
    durationSeconds: durationSeconds.present ? durationSeconds.value : this.durationSeconds,
    weight: weight.present ? weight.value : this.weight,
    unit: unit ?? this.unit,
    setsFrom: setsFrom ?? this.setsFrom,
    targetFrom: targetFrom ?? this.targetFrom,
  );
  RoutineSet copyWithCompanion(RoutineSetsCompanion data) {
    return RoutineSet(
      id: data.id.present ? data.id.value : this.id,
      routineExerciseId: data.routineExerciseId.present
          ? data.routineExerciseId.value
          : this.routineExerciseId,
      position: data.position.present ? data.position.value : this.position,
      kind: data.kind.present ? data.kind.value : this.kind,
      repsMin: data.repsMin.present ? data.repsMin.value : this.repsMin,
      repsMax: data.repsMax.present ? data.repsMax.value : this.repsMax,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      weight: data.weight.present ? data.weight.value : this.weight,
      unit: data.unit.present ? data.unit.value : this.unit,
      setsFrom: data.setsFrom.present ? data.setsFrom.value : this.setsFrom,
      targetFrom: data.targetFrom.present ? data.targetFrom.value : this.targetFrom,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoutineSet(')
          ..write('id: $id, ')
          ..write('routineExerciseId: $routineExerciseId, ')
          ..write('position: $position, ')
          ..write('kind: $kind, ')
          ..write('repsMin: $repsMin, ')
          ..write('repsMax: $repsMax, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('weight: $weight, ')
          ..write('unit: $unit, ')
          ..write('setsFrom: $setsFrom, ')
          ..write('targetFrom: $targetFrom')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    routineExerciseId,
    position,
    kind,
    repsMin,
    repsMax,
    durationSeconds,
    weight,
    unit,
    setsFrom,
    targetFrom,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutineSet &&
          other.id == this.id &&
          other.routineExerciseId == this.routineExerciseId &&
          other.position == this.position &&
          other.kind == this.kind &&
          other.repsMin == this.repsMin &&
          other.repsMax == this.repsMax &&
          other.durationSeconds == this.durationSeconds &&
          other.weight == this.weight &&
          other.unit == this.unit &&
          other.setsFrom == this.setsFrom &&
          other.targetFrom == this.targetFrom);
}

class RoutineSetsCompanion extends UpdateCompanion<RoutineSet> {
  final Value<int> id;
  final Value<int> routineExerciseId;
  final Value<int> position;
  final Value<TargetKind> kind;
  final Value<int?> repsMin;
  final Value<int?> repsMax;
  final Value<int?> durationSeconds;
  final Value<double?> weight;
  final Value<WeightUnit> unit;
  final Value<Provenance> setsFrom;
  final Value<Provenance> targetFrom;
  const RoutineSetsCompanion({
    this.id = const Value.absent(),
    this.routineExerciseId = const Value.absent(),
    this.position = const Value.absent(),
    this.kind = const Value.absent(),
    this.repsMin = const Value.absent(),
    this.repsMax = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.weight = const Value.absent(),
    this.unit = const Value.absent(),
    this.setsFrom = const Value.absent(),
    this.targetFrom = const Value.absent(),
  });
  RoutineSetsCompanion.insert({
    this.id = const Value.absent(),
    required int routineExerciseId,
    required int position,
    required TargetKind kind,
    this.repsMin = const Value.absent(),
    this.repsMax = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.weight = const Value.absent(),
    this.unit = const Value.absent(),
    this.setsFrom = const Value.absent(),
    this.targetFrom = const Value.absent(),
  }) : routineExerciseId = Value(routineExerciseId),
       position = Value(position),
       kind = Value(kind);
  static Insertable<RoutineSet> custom({
    Expression<int>? id,
    Expression<int>? routineExerciseId,
    Expression<int>? position,
    Expression<int>? kind,
    Expression<int>? repsMin,
    Expression<int>? repsMax,
    Expression<int>? durationSeconds,
    Expression<double>? weight,
    Expression<int>? unit,
    Expression<int>? setsFrom,
    Expression<int>? targetFrom,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (routineExerciseId != null) 'routine_exercise_id': routineExerciseId,
      if (position != null) 'position': position,
      if (kind != null) 'kind': kind,
      if (repsMin != null) 'reps_min': repsMin,
      if (repsMax != null) 'reps_max': repsMax,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (weight != null) 'weight': weight,
      if (unit != null) 'unit': unit,
      if (setsFrom != null) 'sets_from': setsFrom,
      if (targetFrom != null) 'target_from': targetFrom,
    });
  }

  RoutineSetsCompanion copyWith({
    Value<int>? id,
    Value<int>? routineExerciseId,
    Value<int>? position,
    Value<TargetKind>? kind,
    Value<int?>? repsMin,
    Value<int?>? repsMax,
    Value<int?>? durationSeconds,
    Value<double?>? weight,
    Value<WeightUnit>? unit,
    Value<Provenance>? setsFrom,
    Value<Provenance>? targetFrom,
  }) {
    return RoutineSetsCompanion(
      id: id ?? this.id,
      routineExerciseId: routineExerciseId ?? this.routineExerciseId,
      position: position ?? this.position,
      kind: kind ?? this.kind,
      repsMin: repsMin ?? this.repsMin,
      repsMax: repsMax ?? this.repsMax,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      weight: weight ?? this.weight,
      unit: unit ?? this.unit,
      setsFrom: setsFrom ?? this.setsFrom,
      targetFrom: targetFrom ?? this.targetFrom,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (routineExerciseId.present) {
      map['routine_exercise_id'] = Variable<int>(routineExerciseId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (kind.present) {
      map['kind'] = Variable<int>($RoutineSetsTable.$converterkind.toSql(kind.value));
    }
    if (repsMin.present) {
      map['reps_min'] = Variable<int>(repsMin.value);
    }
    if (repsMax.present) {
      map['reps_max'] = Variable<int>(repsMax.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (unit.present) {
      map['unit'] = Variable<int>($RoutineSetsTable.$converterunit.toSql(unit.value));
    }
    if (setsFrom.present) {
      map['sets_from'] = Variable<int>($RoutineSetsTable.$convertersetsFrom.toSql(setsFrom.value));
    }
    if (targetFrom.present) {
      map['target_from'] = Variable<int>(
        $RoutineSetsTable.$convertertargetFrom.toSql(targetFrom.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutineSetsCompanion(')
          ..write('id: $id, ')
          ..write('routineExerciseId: $routineExerciseId, ')
          ..write('position: $position, ')
          ..write('kind: $kind, ')
          ..write('repsMin: $repsMin, ')
          ..write('repsMax: $repsMax, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('weight: $weight, ')
          ..write('unit: $unit, ')
          ..write('setsFrom: $setsFrom, ')
          ..write('targetFrom: $targetFrom')
          ..write(')'))
        .toString();
  }
}

class $WorkoutSessionsTable extends WorkoutSessions
    with TableInfo<$WorkoutSessionsTable, WorkoutSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _routineIdMeta = const VerificationMeta('routineId');
  @override
  late final GeneratedColumn<int> routineId = GeneratedColumn<int>(
    'routine_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dayIdMeta = const VerificationMeta('dayId');
  @override
  late final GeneratedColumn<int> dayId = GeneratedColumn<int>(
    'day_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _routineNameMeta = const VerificationMeta('routineName');
  @override
  late final GeneratedColumn<String> routineName = GeneratedColumn<String>(
    'routine_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta('endedAt');
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    routineId,
    dayId,
    title,
    routineName,
    startedAt,
    endedAt,
    status,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('routine_id')) {
      context.handle(
        _routineIdMeta,
        routineId.isAcceptableOrUnknown(data['routine_id']!, _routineIdMeta),
      );
    }
    if (data.containsKey('day_id')) {
      context.handle(_dayIdMeta, dayId.isAcceptableOrUnknown(data['day_id']!, _dayIdMeta));
    }
    if (data.containsKey('title')) {
      context.handle(_titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('routine_name')) {
      context.handle(
        _routineNameMeta,
        routineName.isAcceptableOrUnknown(data['routine_name']!, _routineNameMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(_endedAtMeta, endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta, status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(_notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutSession(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      routineId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}routine_id'],
      ),
      dayId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}day_id']),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      routineName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}routine_name'],
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $WorkoutSessionsTable createAlias(String alias) {
    return $WorkoutSessionsTable(attachedDatabase, alias);
  }
}

class WorkoutSession extends DataClass implements Insertable<WorkoutSession> {
  final int id;
  final int? routineId;
  final int? dayId;
  final String title;
  final String? routineName;
  final DateTime startedAt;
  final DateTime? endedAt;

  /// active, completed or discarded.
  final String status;
  final String? notes;
  const WorkoutSession({
    required this.id,
    this.routineId,
    this.dayId,
    required this.title,
    this.routineName,
    required this.startedAt,
    this.endedAt,
    required this.status,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || routineId != null) {
      map['routine_id'] = Variable<int>(routineId);
    }
    if (!nullToAbsent || dayId != null) {
      map['day_id'] = Variable<int>(dayId);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || routineName != null) {
      map['routine_name'] = Variable<String>(routineName);
    }
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  WorkoutSessionsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutSessionsCompanion(
      id: Value(id),
      routineId: routineId == null && nullToAbsent ? const Value.absent() : Value(routineId),
      dayId: dayId == null && nullToAbsent ? const Value.absent() : Value(dayId),
      title: Value(title),
      routineName: routineName == null && nullToAbsent ? const Value.absent() : Value(routineName),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent ? const Value.absent() : Value(endedAt),
      status: Value(status),
      notes: notes == null && nullToAbsent ? const Value.absent() : Value(notes),
    );
  }

  factory WorkoutSession.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutSession(
      id: serializer.fromJson<int>(json['id']),
      routineId: serializer.fromJson<int?>(json['routineId']),
      dayId: serializer.fromJson<int?>(json['dayId']),
      title: serializer.fromJson<String>(json['title']),
      routineName: serializer.fromJson<String?>(json['routineName']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      status: serializer.fromJson<String>(json['status']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'routineId': serializer.toJson<int?>(routineId),
      'dayId': serializer.toJson<int?>(dayId),
      'title': serializer.toJson<String>(title),
      'routineName': serializer.toJson<String?>(routineName),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  WorkoutSession copyWith({
    int? id,
    Value<int?> routineId = const Value.absent(),
    Value<int?> dayId = const Value.absent(),
    String? title,
    Value<String?> routineName = const Value.absent(),
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    String? status,
    Value<String?> notes = const Value.absent(),
  }) => WorkoutSession(
    id: id ?? this.id,
    routineId: routineId.present ? routineId.value : this.routineId,
    dayId: dayId.present ? dayId.value : this.dayId,
    title: title ?? this.title,
    routineName: routineName.present ? routineName.value : this.routineName,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    status: status ?? this.status,
    notes: notes.present ? notes.value : this.notes,
  );
  WorkoutSession copyWithCompanion(WorkoutSessionsCompanion data) {
    return WorkoutSession(
      id: data.id.present ? data.id.value : this.id,
      routineId: data.routineId.present ? data.routineId.value : this.routineId,
      dayId: data.dayId.present ? data.dayId.value : this.dayId,
      title: data.title.present ? data.title.value : this.title,
      routineName: data.routineName.present ? data.routineName.value : this.routineName,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSession(')
          ..write('id: $id, ')
          ..write('routineId: $routineId, ')
          ..write('dayId: $dayId, ')
          ..write('title: $title, ')
          ..write('routineName: $routineName, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('status: $status, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, routineId, dayId, title, routineName, startedAt, endedAt, status, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutSession &&
          other.id == this.id &&
          other.routineId == this.routineId &&
          other.dayId == this.dayId &&
          other.title == this.title &&
          other.routineName == this.routineName &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.status == this.status &&
          other.notes == this.notes);
}

class WorkoutSessionsCompanion extends UpdateCompanion<WorkoutSession> {
  final Value<int> id;
  final Value<int?> routineId;
  final Value<int?> dayId;
  final Value<String> title;
  final Value<String?> routineName;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<String> status;
  final Value<String?> notes;
  const WorkoutSessionsCompanion({
    this.id = const Value.absent(),
    this.routineId = const Value.absent(),
    this.dayId = const Value.absent(),
    this.title = const Value.absent(),
    this.routineName = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
  });
  WorkoutSessionsCompanion.insert({
    this.id = const Value.absent(),
    this.routineId = const Value.absent(),
    this.dayId = const Value.absent(),
    required String title,
    this.routineName = const Value.absent(),
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
  }) : title = Value(title),
       startedAt = Value(startedAt);
  static Insertable<WorkoutSession> custom({
    Expression<int>? id,
    Expression<int>? routineId,
    Expression<int>? dayId,
    Expression<String>? title,
    Expression<String>? routineName,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<String>? status,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (routineId != null) 'routine_id': routineId,
      if (dayId != null) 'day_id': dayId,
      if (title != null) 'title': title,
      if (routineName != null) 'routine_name': routineName,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
    });
  }

  WorkoutSessionsCompanion copyWith({
    Value<int>? id,
    Value<int?>? routineId,
    Value<int?>? dayId,
    Value<String>? title,
    Value<String?>? routineName,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<String>? status,
    Value<String?>? notes,
  }) {
    return WorkoutSessionsCompanion(
      id: id ?? this.id,
      routineId: routineId ?? this.routineId,
      dayId: dayId ?? this.dayId,
      title: title ?? this.title,
      routineName: routineName ?? this.routineName,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (routineId.present) {
      map['routine_id'] = Variable<int>(routineId.value);
    }
    if (dayId.present) {
      map['day_id'] = Variable<int>(dayId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (routineName.present) {
      map['routine_name'] = Variable<String>(routineName.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSessionsCompanion(')
          ..write('id: $id, ')
          ..write('routineId: $routineId, ')
          ..write('dayId: $dayId, ')
          ..write('title: $title, ')
          ..write('routineName: $routineName, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('status: $status, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $SessionExercisesTable extends SessionExercises
    with TableInfo<$SessionExercisesTable, SessionExercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workout_sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta('exerciseId');
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta('position');
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupLabelMeta = const VerificationMeta('groupLabel');
  @override
  late final GeneratedColumn<String> groupLabel = GeneratedColumn<String>(
    'group_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _restSecondsMeta = const VerificationMeta('restSeconds');
  @override
  late final GeneratedColumn<int> restSeconds = GeneratedColumn<int>(
    'rest_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tempoMeta = const VerificationMeta('tempo');
  @override
  late final GeneratedColumn<String> tempo = GeneratedColumn<String>(
    'tempo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _perSideMeta = const VerificationMeta('perSide');
  @override
  late final GeneratedColumn<bool> perSide = GeneratedColumn<bool>(
    'per_side',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("per_side" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _timedMeta = const VerificationMeta('timed');
  @override
  late final GeneratedColumn<bool> timed = GeneratedColumn<bool>(
    'timed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("timed" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _variantMeta = const VerificationMeta('variant');
  @override
  late final GeneratedColumn<String> variant = GeneratedColumn<String>(
    'variant',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _skippedMeta = const VerificationMeta('skipped');
  @override
  late final GeneratedColumn<bool> skipped = GeneratedColumn<bool>(
    'skipped',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("skipped" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    exerciseId,
    name,
    position,
    groupLabel,
    restSeconds,
    tempo,
    notes,
    perSide,
    timed,
    variant,
    skipped,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionExercise> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('group_label')) {
      context.handle(
        _groupLabelMeta,
        groupLabel.isAcceptableOrUnknown(data['group_label']!, _groupLabelMeta),
      );
    }
    if (data.containsKey('rest_seconds')) {
      context.handle(
        _restSecondsMeta,
        restSeconds.isAcceptableOrUnknown(data['rest_seconds']!, _restSecondsMeta),
      );
    }
    if (data.containsKey('tempo')) {
      context.handle(_tempoMeta, tempo.isAcceptableOrUnknown(data['tempo']!, _tempoMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(_notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('per_side')) {
      context.handle(_perSideMeta, perSide.isAcceptableOrUnknown(data['per_side']!, _perSideMeta));
    }
    if (data.containsKey('timed')) {
      context.handle(_timedMeta, timed.isAcceptableOrUnknown(data['timed']!, _timedMeta));
    }
    if (data.containsKey('variant')) {
      context.handle(_variantMeta, variant.isAcceptableOrUnknown(data['variant']!, _variantMeta));
    }
    if (data.containsKey('skipped')) {
      context.handle(_skippedMeta, skipped.isAcceptableOrUnknown(data['skipped']!, _skippedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionExercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionExercise(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      ),
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      groupLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_label'],
      ),
      restSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rest_seconds'],
      ),
      tempo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tempo'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      perSide: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}per_side'],
      )!,
      timed: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}timed'])!,
      variant: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}variant'],
      ),
      skipped: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}skipped'],
      )!,
    );
  }

  @override
  $SessionExercisesTable createAlias(String alias) {
    return $SessionExercisesTable(attachedDatabase, alias);
  }
}

class SessionExercise extends DataClass implements Insertable<SessionExercise> {
  final int id;
  final int sessionId;
  final String? exerciseId;
  final String name;
  final int position;
  final String? groupLabel;
  final int? restSeconds;
  final String? tempo;
  final String? notes;
  final bool perSide;
  final bool timed;

  /// The specific machine or setup ("Gym A cable, 2:1 pulley"). Loads are only
  /// compared between sets with the same variant.
  final String? variant;
  final bool skipped;
  const SessionExercise({
    required this.id,
    required this.sessionId,
    this.exerciseId,
    required this.name,
    required this.position,
    this.groupLabel,
    this.restSeconds,
    this.tempo,
    this.notes,
    required this.perSide,
    required this.timed,
    this.variant,
    required this.skipped,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    if (!nullToAbsent || exerciseId != null) {
      map['exercise_id'] = Variable<String>(exerciseId);
    }
    map['name'] = Variable<String>(name);
    map['position'] = Variable<int>(position);
    if (!nullToAbsent || groupLabel != null) {
      map['group_label'] = Variable<String>(groupLabel);
    }
    if (!nullToAbsent || restSeconds != null) {
      map['rest_seconds'] = Variable<int>(restSeconds);
    }
    if (!nullToAbsent || tempo != null) {
      map['tempo'] = Variable<String>(tempo);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['per_side'] = Variable<bool>(perSide);
    map['timed'] = Variable<bool>(timed);
    if (!nullToAbsent || variant != null) {
      map['variant'] = Variable<String>(variant);
    }
    map['skipped'] = Variable<bool>(skipped);
    return map;
  }

  SessionExercisesCompanion toCompanion(bool nullToAbsent) {
    return SessionExercisesCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      exerciseId: exerciseId == null && nullToAbsent ? const Value.absent() : Value(exerciseId),
      name: Value(name),
      position: Value(position),
      groupLabel: groupLabel == null && nullToAbsent ? const Value.absent() : Value(groupLabel),
      restSeconds: restSeconds == null && nullToAbsent ? const Value.absent() : Value(restSeconds),
      tempo: tempo == null && nullToAbsent ? const Value.absent() : Value(tempo),
      notes: notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      perSide: Value(perSide),
      timed: Value(timed),
      variant: variant == null && nullToAbsent ? const Value.absent() : Value(variant),
      skipped: Value(skipped),
    );
  }

  factory SessionExercise.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionExercise(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      exerciseId: serializer.fromJson<String?>(json['exerciseId']),
      name: serializer.fromJson<String>(json['name']),
      position: serializer.fromJson<int>(json['position']),
      groupLabel: serializer.fromJson<String?>(json['groupLabel']),
      restSeconds: serializer.fromJson<int?>(json['restSeconds']),
      tempo: serializer.fromJson<String?>(json['tempo']),
      notes: serializer.fromJson<String?>(json['notes']),
      perSide: serializer.fromJson<bool>(json['perSide']),
      timed: serializer.fromJson<bool>(json['timed']),
      variant: serializer.fromJson<String?>(json['variant']),
      skipped: serializer.fromJson<bool>(json['skipped']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'exerciseId': serializer.toJson<String?>(exerciseId),
      'name': serializer.toJson<String>(name),
      'position': serializer.toJson<int>(position),
      'groupLabel': serializer.toJson<String?>(groupLabel),
      'restSeconds': serializer.toJson<int?>(restSeconds),
      'tempo': serializer.toJson<String?>(tempo),
      'notes': serializer.toJson<String?>(notes),
      'perSide': serializer.toJson<bool>(perSide),
      'timed': serializer.toJson<bool>(timed),
      'variant': serializer.toJson<String?>(variant),
      'skipped': serializer.toJson<bool>(skipped),
    };
  }

  SessionExercise copyWith({
    int? id,
    int? sessionId,
    Value<String?> exerciseId = const Value.absent(),
    String? name,
    int? position,
    Value<String?> groupLabel = const Value.absent(),
    Value<int?> restSeconds = const Value.absent(),
    Value<String?> tempo = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    bool? perSide,
    bool? timed,
    Value<String?> variant = const Value.absent(),
    bool? skipped,
  }) => SessionExercise(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    exerciseId: exerciseId.present ? exerciseId.value : this.exerciseId,
    name: name ?? this.name,
    position: position ?? this.position,
    groupLabel: groupLabel.present ? groupLabel.value : this.groupLabel,
    restSeconds: restSeconds.present ? restSeconds.value : this.restSeconds,
    tempo: tempo.present ? tempo.value : this.tempo,
    notes: notes.present ? notes.value : this.notes,
    perSide: perSide ?? this.perSide,
    timed: timed ?? this.timed,
    variant: variant.present ? variant.value : this.variant,
    skipped: skipped ?? this.skipped,
  );
  SessionExercise copyWithCompanion(SessionExercisesCompanion data) {
    return SessionExercise(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      exerciseId: data.exerciseId.present ? data.exerciseId.value : this.exerciseId,
      name: data.name.present ? data.name.value : this.name,
      position: data.position.present ? data.position.value : this.position,
      groupLabel: data.groupLabel.present ? data.groupLabel.value : this.groupLabel,
      restSeconds: data.restSeconds.present ? data.restSeconds.value : this.restSeconds,
      tempo: data.tempo.present ? data.tempo.value : this.tempo,
      notes: data.notes.present ? data.notes.value : this.notes,
      perSide: data.perSide.present ? data.perSide.value : this.perSide,
      timed: data.timed.present ? data.timed.value : this.timed,
      variant: data.variant.present ? data.variant.value : this.variant,
      skipped: data.skipped.present ? data.skipped.value : this.skipped,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionExercise(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('name: $name, ')
          ..write('position: $position, ')
          ..write('groupLabel: $groupLabel, ')
          ..write('restSeconds: $restSeconds, ')
          ..write('tempo: $tempo, ')
          ..write('notes: $notes, ')
          ..write('perSide: $perSide, ')
          ..write('timed: $timed, ')
          ..write('variant: $variant, ')
          ..write('skipped: $skipped')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    exerciseId,
    name,
    position,
    groupLabel,
    restSeconds,
    tempo,
    notes,
    perSide,
    timed,
    variant,
    skipped,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionExercise &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.exerciseId == this.exerciseId &&
          other.name == this.name &&
          other.position == this.position &&
          other.groupLabel == this.groupLabel &&
          other.restSeconds == this.restSeconds &&
          other.tempo == this.tempo &&
          other.notes == this.notes &&
          other.perSide == this.perSide &&
          other.timed == this.timed &&
          other.variant == this.variant &&
          other.skipped == this.skipped);
}

class SessionExercisesCompanion extends UpdateCompanion<SessionExercise> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<String?> exerciseId;
  final Value<String> name;
  final Value<int> position;
  final Value<String?> groupLabel;
  final Value<int?> restSeconds;
  final Value<String?> tempo;
  final Value<String?> notes;
  final Value<bool> perSide;
  final Value<bool> timed;
  final Value<String?> variant;
  final Value<bool> skipped;
  const SessionExercisesCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.name = const Value.absent(),
    this.position = const Value.absent(),
    this.groupLabel = const Value.absent(),
    this.restSeconds = const Value.absent(),
    this.tempo = const Value.absent(),
    this.notes = const Value.absent(),
    this.perSide = const Value.absent(),
    this.timed = const Value.absent(),
    this.variant = const Value.absent(),
    this.skipped = const Value.absent(),
  });
  SessionExercisesCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    this.exerciseId = const Value.absent(),
    required String name,
    required int position,
    this.groupLabel = const Value.absent(),
    this.restSeconds = const Value.absent(),
    this.tempo = const Value.absent(),
    this.notes = const Value.absent(),
    this.perSide = const Value.absent(),
    this.timed = const Value.absent(),
    this.variant = const Value.absent(),
    this.skipped = const Value.absent(),
  }) : sessionId = Value(sessionId),
       name = Value(name),
       position = Value(position);
  static Insertable<SessionExercise> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<String>? exerciseId,
    Expression<String>? name,
    Expression<int>? position,
    Expression<String>? groupLabel,
    Expression<int>? restSeconds,
    Expression<String>? tempo,
    Expression<String>? notes,
    Expression<bool>? perSide,
    Expression<bool>? timed,
    Expression<String>? variant,
    Expression<bool>? skipped,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (name != null) 'name': name,
      if (position != null) 'position': position,
      if (groupLabel != null) 'group_label': groupLabel,
      if (restSeconds != null) 'rest_seconds': restSeconds,
      if (tempo != null) 'tempo': tempo,
      if (notes != null) 'notes': notes,
      if (perSide != null) 'per_side': perSide,
      if (timed != null) 'timed': timed,
      if (variant != null) 'variant': variant,
      if (skipped != null) 'skipped': skipped,
    });
  }

  SessionExercisesCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<String?>? exerciseId,
    Value<String>? name,
    Value<int>? position,
    Value<String?>? groupLabel,
    Value<int?>? restSeconds,
    Value<String?>? tempo,
    Value<String?>? notes,
    Value<bool>? perSide,
    Value<bool>? timed,
    Value<String?>? variant,
    Value<bool>? skipped,
  }) {
    return SessionExercisesCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      exerciseId: exerciseId ?? this.exerciseId,
      name: name ?? this.name,
      position: position ?? this.position,
      groupLabel: groupLabel ?? this.groupLabel,
      restSeconds: restSeconds ?? this.restSeconds,
      tempo: tempo ?? this.tempo,
      notes: notes ?? this.notes,
      perSide: perSide ?? this.perSide,
      timed: timed ?? this.timed,
      variant: variant ?? this.variant,
      skipped: skipped ?? this.skipped,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (groupLabel.present) {
      map['group_label'] = Variable<String>(groupLabel.value);
    }
    if (restSeconds.present) {
      map['rest_seconds'] = Variable<int>(restSeconds.value);
    }
    if (tempo.present) {
      map['tempo'] = Variable<String>(tempo.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (perSide.present) {
      map['per_side'] = Variable<bool>(perSide.value);
    }
    if (timed.present) {
      map['timed'] = Variable<bool>(timed.value);
    }
    if (variant.present) {
      map['variant'] = Variable<String>(variant.value);
    }
    if (skipped.present) {
      map['skipped'] = Variable<bool>(skipped.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionExercisesCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('name: $name, ')
          ..write('position: $position, ')
          ..write('groupLabel: $groupLabel, ')
          ..write('restSeconds: $restSeconds, ')
          ..write('tempo: $tempo, ')
          ..write('notes: $notes, ')
          ..write('perSide: $perSide, ')
          ..write('timed: $timed, ')
          ..write('variant: $variant, ')
          ..write('skipped: $skipped')
          ..write(')'))
        .toString();
  }
}

class $SetLogsTable extends SetLogs with TableInfo<$SetLogsTable, SetLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SetLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _sessionExerciseIdMeta = const VerificationMeta(
    'sessionExerciseId',
  );
  @override
  late final GeneratedColumn<int> sessionExerciseId = GeneratedColumn<int>(
    'session_exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES session_exercises (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta('position');
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TargetKind, int> kind = GeneratedColumn<int>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  ).withConverter<TargetKind>($SetLogsTable.$converterkind);
  static const VerificationMeta _targetRepsMinMeta = const VerificationMeta('targetRepsMin');
  @override
  late final GeneratedColumn<int> targetRepsMin = GeneratedColumn<int>(
    'target_reps_min',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetRepsMaxMeta = const VerificationMeta('targetRepsMax');
  @override
  late final GeneratedColumn<int> targetRepsMax = GeneratedColumn<int>(
    'target_reps_max',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetDurationSecondsMeta = const VerificationMeta(
    'targetDurationSeconds',
  );
  @override
  late final GeneratedColumn<int> targetDurationSeconds = GeneratedColumn<int>(
    'target_duration_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetWeightMeta = const VerificationMeta('targetWeight');
  @override
  late final GeneratedColumn<double> targetWeight = GeneratedColumn<double>(
    'target_weight',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<WeightUnit, int> unit = GeneratedColumn<int>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  ).withConverter<WeightUnit>($SetLogsTable.$converterunit);
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
    'weight',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta('durationSeconds');
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionExerciseId,
    position,
    kind,
    targetRepsMin,
    targetRepsMax,
    targetDurationSeconds,
    targetWeight,
    unit,
    reps,
    weight,
    durationSeconds,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'set_logs';
  @override
  VerificationContext validateIntegrity(Insertable<SetLog> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_exercise_id')) {
      context.handle(
        _sessionExerciseIdMeta,
        sessionExerciseId.isAcceptableOrUnknown(
          data['session_exercise_id']!,
          _sessionExerciseIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sessionExerciseIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('target_reps_min')) {
      context.handle(
        _targetRepsMinMeta,
        targetRepsMin.isAcceptableOrUnknown(data['target_reps_min']!, _targetRepsMinMeta),
      );
    }
    if (data.containsKey('target_reps_max')) {
      context.handle(
        _targetRepsMaxMeta,
        targetRepsMax.isAcceptableOrUnknown(data['target_reps_max']!, _targetRepsMaxMeta),
      );
    }
    if (data.containsKey('target_duration_seconds')) {
      context.handle(
        _targetDurationSecondsMeta,
        targetDurationSeconds.isAcceptableOrUnknown(
          data['target_duration_seconds']!,
          _targetDurationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('target_weight')) {
      context.handle(
        _targetWeightMeta,
        targetWeight.isAcceptableOrUnknown(data['target_weight']!, _targetWeightMeta),
      );
    }
    if (data.containsKey('reps')) {
      context.handle(_repsMeta, reps.isAcceptableOrUnknown(data['reps']!, _repsMeta));
    }
    if (data.containsKey('weight')) {
      context.handle(_weightMeta, weight.isAcceptableOrUnknown(data['weight']!, _weightMeta));
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(data['duration_seconds']!, _durationSecondsMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(data['completed_at']!, _completedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SetLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SetLog(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      sessionExerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_exercise_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      kind: $SetLogsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}kind'])!,
      ),
      targetRepsMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_reps_min'],
      ),
      targetRepsMax: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_reps_max'],
      ),
      targetDurationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_duration_seconds'],
      ),
      targetWeight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_weight'],
      ),
      unit: $SetLogsTable.$converterunit.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}unit'])!,
      ),
      reps: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}reps']),
      weight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight'],
      ),
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  $SetLogsTable createAlias(String alias) {
    return $SetLogsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TargetKind, int, int> $converterkind =
      const EnumIndexConverter<TargetKind>(TargetKind.values);
  static JsonTypeConverter2<WeightUnit, int, int> $converterunit =
      const EnumIndexConverter<WeightUnit>(WeightUnit.values);
}

class SetLog extends DataClass implements Insertable<SetLog> {
  final int id;
  final int sessionExerciseId;
  final int position;
  final TargetKind kind;
  final int? targetRepsMin;
  final int? targetRepsMax;
  final int? targetDurationSeconds;
  final double? targetWeight;
  final WeightUnit unit;
  final int? reps;
  final double? weight;
  final int? durationSeconds;
  final DateTime? completedAt;
  const SetLog({
    required this.id,
    required this.sessionExerciseId,
    required this.position,
    required this.kind,
    this.targetRepsMin,
    this.targetRepsMax,
    this.targetDurationSeconds,
    this.targetWeight,
    required this.unit,
    this.reps,
    this.weight,
    this.durationSeconds,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_exercise_id'] = Variable<int>(sessionExerciseId);
    map['position'] = Variable<int>(position);
    {
      map['kind'] = Variable<int>($SetLogsTable.$converterkind.toSql(kind));
    }
    if (!nullToAbsent || targetRepsMin != null) {
      map['target_reps_min'] = Variable<int>(targetRepsMin);
    }
    if (!nullToAbsent || targetRepsMax != null) {
      map['target_reps_max'] = Variable<int>(targetRepsMax);
    }
    if (!nullToAbsent || targetDurationSeconds != null) {
      map['target_duration_seconds'] = Variable<int>(targetDurationSeconds);
    }
    if (!nullToAbsent || targetWeight != null) {
      map['target_weight'] = Variable<double>(targetWeight);
    }
    {
      map['unit'] = Variable<int>($SetLogsTable.$converterunit.toSql(unit));
    }
    if (!nullToAbsent || reps != null) {
      map['reps'] = Variable<int>(reps);
    }
    if (!nullToAbsent || weight != null) {
      map['weight'] = Variable<double>(weight);
    }
    if (!nullToAbsent || durationSeconds != null) {
      map['duration_seconds'] = Variable<int>(durationSeconds);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  SetLogsCompanion toCompanion(bool nullToAbsent) {
    return SetLogsCompanion(
      id: Value(id),
      sessionExerciseId: Value(sessionExerciseId),
      position: Value(position),
      kind: Value(kind),
      targetRepsMin: targetRepsMin == null && nullToAbsent
          ? const Value.absent()
          : Value(targetRepsMin),
      targetRepsMax: targetRepsMax == null && nullToAbsent
          ? const Value.absent()
          : Value(targetRepsMax),
      targetDurationSeconds: targetDurationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(targetDurationSeconds),
      targetWeight: targetWeight == null && nullToAbsent
          ? const Value.absent()
          : Value(targetWeight),
      unit: Value(unit),
      reps: reps == null && nullToAbsent ? const Value.absent() : Value(reps),
      weight: weight == null && nullToAbsent ? const Value.absent() : Value(weight),
      durationSeconds: durationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(durationSeconds),
      completedAt: completedAt == null && nullToAbsent ? const Value.absent() : Value(completedAt),
    );
  }

  factory SetLog.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SetLog(
      id: serializer.fromJson<int>(json['id']),
      sessionExerciseId: serializer.fromJson<int>(json['sessionExerciseId']),
      position: serializer.fromJson<int>(json['position']),
      kind: $SetLogsTable.$converterkind.fromJson(serializer.fromJson<int>(json['kind'])),
      targetRepsMin: serializer.fromJson<int?>(json['targetRepsMin']),
      targetRepsMax: serializer.fromJson<int?>(json['targetRepsMax']),
      targetDurationSeconds: serializer.fromJson<int?>(json['targetDurationSeconds']),
      targetWeight: serializer.fromJson<double?>(json['targetWeight']),
      unit: $SetLogsTable.$converterunit.fromJson(serializer.fromJson<int>(json['unit'])),
      reps: serializer.fromJson<int?>(json['reps']),
      weight: serializer.fromJson<double?>(json['weight']),
      durationSeconds: serializer.fromJson<int?>(json['durationSeconds']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionExerciseId': serializer.toJson<int>(sessionExerciseId),
      'position': serializer.toJson<int>(position),
      'kind': serializer.toJson<int>($SetLogsTable.$converterkind.toJson(kind)),
      'targetRepsMin': serializer.toJson<int?>(targetRepsMin),
      'targetRepsMax': serializer.toJson<int?>(targetRepsMax),
      'targetDurationSeconds': serializer.toJson<int?>(targetDurationSeconds),
      'targetWeight': serializer.toJson<double?>(targetWeight),
      'unit': serializer.toJson<int>($SetLogsTable.$converterunit.toJson(unit)),
      'reps': serializer.toJson<int?>(reps),
      'weight': serializer.toJson<double?>(weight),
      'durationSeconds': serializer.toJson<int?>(durationSeconds),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  SetLog copyWith({
    int? id,
    int? sessionExerciseId,
    int? position,
    TargetKind? kind,
    Value<int?> targetRepsMin = const Value.absent(),
    Value<int?> targetRepsMax = const Value.absent(),
    Value<int?> targetDurationSeconds = const Value.absent(),
    Value<double?> targetWeight = const Value.absent(),
    WeightUnit? unit,
    Value<int?> reps = const Value.absent(),
    Value<double?> weight = const Value.absent(),
    Value<int?> durationSeconds = const Value.absent(),
    Value<DateTime?> completedAt = const Value.absent(),
  }) => SetLog(
    id: id ?? this.id,
    sessionExerciseId: sessionExerciseId ?? this.sessionExerciseId,
    position: position ?? this.position,
    kind: kind ?? this.kind,
    targetRepsMin: targetRepsMin.present ? targetRepsMin.value : this.targetRepsMin,
    targetRepsMax: targetRepsMax.present ? targetRepsMax.value : this.targetRepsMax,
    targetDurationSeconds: targetDurationSeconds.present
        ? targetDurationSeconds.value
        : this.targetDurationSeconds,
    targetWeight: targetWeight.present ? targetWeight.value : this.targetWeight,
    unit: unit ?? this.unit,
    reps: reps.present ? reps.value : this.reps,
    weight: weight.present ? weight.value : this.weight,
    durationSeconds: durationSeconds.present ? durationSeconds.value : this.durationSeconds,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  SetLog copyWithCompanion(SetLogsCompanion data) {
    return SetLog(
      id: data.id.present ? data.id.value : this.id,
      sessionExerciseId: data.sessionExerciseId.present
          ? data.sessionExerciseId.value
          : this.sessionExerciseId,
      position: data.position.present ? data.position.value : this.position,
      kind: data.kind.present ? data.kind.value : this.kind,
      targetRepsMin: data.targetRepsMin.present ? data.targetRepsMin.value : this.targetRepsMin,
      targetRepsMax: data.targetRepsMax.present ? data.targetRepsMax.value : this.targetRepsMax,
      targetDurationSeconds: data.targetDurationSeconds.present
          ? data.targetDurationSeconds.value
          : this.targetDurationSeconds,
      targetWeight: data.targetWeight.present ? data.targetWeight.value : this.targetWeight,
      unit: data.unit.present ? data.unit.value : this.unit,
      reps: data.reps.present ? data.reps.value : this.reps,
      weight: data.weight.present ? data.weight.value : this.weight,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      completedAt: data.completedAt.present ? data.completedAt.value : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SetLog(')
          ..write('id: $id, ')
          ..write('sessionExerciseId: $sessionExerciseId, ')
          ..write('position: $position, ')
          ..write('kind: $kind, ')
          ..write('targetRepsMin: $targetRepsMin, ')
          ..write('targetRepsMax: $targetRepsMax, ')
          ..write('targetDurationSeconds: $targetDurationSeconds, ')
          ..write('targetWeight: $targetWeight, ')
          ..write('unit: $unit, ')
          ..write('reps: $reps, ')
          ..write('weight: $weight, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionExerciseId,
    position,
    kind,
    targetRepsMin,
    targetRepsMax,
    targetDurationSeconds,
    targetWeight,
    unit,
    reps,
    weight,
    durationSeconds,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SetLog &&
          other.id == this.id &&
          other.sessionExerciseId == this.sessionExerciseId &&
          other.position == this.position &&
          other.kind == this.kind &&
          other.targetRepsMin == this.targetRepsMin &&
          other.targetRepsMax == this.targetRepsMax &&
          other.targetDurationSeconds == this.targetDurationSeconds &&
          other.targetWeight == this.targetWeight &&
          other.unit == this.unit &&
          other.reps == this.reps &&
          other.weight == this.weight &&
          other.durationSeconds == this.durationSeconds &&
          other.completedAt == this.completedAt);
}

class SetLogsCompanion extends UpdateCompanion<SetLog> {
  final Value<int> id;
  final Value<int> sessionExerciseId;
  final Value<int> position;
  final Value<TargetKind> kind;
  final Value<int?> targetRepsMin;
  final Value<int?> targetRepsMax;
  final Value<int?> targetDurationSeconds;
  final Value<double?> targetWeight;
  final Value<WeightUnit> unit;
  final Value<int?> reps;
  final Value<double?> weight;
  final Value<int?> durationSeconds;
  final Value<DateTime?> completedAt;
  const SetLogsCompanion({
    this.id = const Value.absent(),
    this.sessionExerciseId = const Value.absent(),
    this.position = const Value.absent(),
    this.kind = const Value.absent(),
    this.targetRepsMin = const Value.absent(),
    this.targetRepsMax = const Value.absent(),
    this.targetDurationSeconds = const Value.absent(),
    this.targetWeight = const Value.absent(),
    this.unit = const Value.absent(),
    this.reps = const Value.absent(),
    this.weight = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.completedAt = const Value.absent(),
  });
  SetLogsCompanion.insert({
    this.id = const Value.absent(),
    required int sessionExerciseId,
    required int position,
    required TargetKind kind,
    this.targetRepsMin = const Value.absent(),
    this.targetRepsMax = const Value.absent(),
    this.targetDurationSeconds = const Value.absent(),
    this.targetWeight = const Value.absent(),
    this.unit = const Value.absent(),
    this.reps = const Value.absent(),
    this.weight = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.completedAt = const Value.absent(),
  }) : sessionExerciseId = Value(sessionExerciseId),
       position = Value(position),
       kind = Value(kind);
  static Insertable<SetLog> custom({
    Expression<int>? id,
    Expression<int>? sessionExerciseId,
    Expression<int>? position,
    Expression<int>? kind,
    Expression<int>? targetRepsMin,
    Expression<int>? targetRepsMax,
    Expression<int>? targetDurationSeconds,
    Expression<double>? targetWeight,
    Expression<int>? unit,
    Expression<int>? reps,
    Expression<double>? weight,
    Expression<int>? durationSeconds,
    Expression<DateTime>? completedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionExerciseId != null) 'session_exercise_id': sessionExerciseId,
      if (position != null) 'position': position,
      if (kind != null) 'kind': kind,
      if (targetRepsMin != null) 'target_reps_min': targetRepsMin,
      if (targetRepsMax != null) 'target_reps_max': targetRepsMax,
      if (targetDurationSeconds != null) 'target_duration_seconds': targetDurationSeconds,
      if (targetWeight != null) 'target_weight': targetWeight,
      if (unit != null) 'unit': unit,
      if (reps != null) 'reps': reps,
      if (weight != null) 'weight': weight,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (completedAt != null) 'completed_at': completedAt,
    });
  }

  SetLogsCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionExerciseId,
    Value<int>? position,
    Value<TargetKind>? kind,
    Value<int?>? targetRepsMin,
    Value<int?>? targetRepsMax,
    Value<int?>? targetDurationSeconds,
    Value<double?>? targetWeight,
    Value<WeightUnit>? unit,
    Value<int?>? reps,
    Value<double?>? weight,
    Value<int?>? durationSeconds,
    Value<DateTime?>? completedAt,
  }) {
    return SetLogsCompanion(
      id: id ?? this.id,
      sessionExerciseId: sessionExerciseId ?? this.sessionExerciseId,
      position: position ?? this.position,
      kind: kind ?? this.kind,
      targetRepsMin: targetRepsMin ?? this.targetRepsMin,
      targetRepsMax: targetRepsMax ?? this.targetRepsMax,
      targetDurationSeconds: targetDurationSeconds ?? this.targetDurationSeconds,
      targetWeight: targetWeight ?? this.targetWeight,
      unit: unit ?? this.unit,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionExerciseId.present) {
      map['session_exercise_id'] = Variable<int>(sessionExerciseId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (kind.present) {
      map['kind'] = Variable<int>($SetLogsTable.$converterkind.toSql(kind.value));
    }
    if (targetRepsMin.present) {
      map['target_reps_min'] = Variable<int>(targetRepsMin.value);
    }
    if (targetRepsMax.present) {
      map['target_reps_max'] = Variable<int>(targetRepsMax.value);
    }
    if (targetDurationSeconds.present) {
      map['target_duration_seconds'] = Variable<int>(targetDurationSeconds.value);
    }
    if (targetWeight.present) {
      map['target_weight'] = Variable<double>(targetWeight.value);
    }
    if (unit.present) {
      map['unit'] = Variable<int>($SetLogsTable.$converterunit.toSql(unit.value));
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SetLogsCompanion(')
          ..write('id: $id, ')
          ..write('sessionExerciseId: $sessionExerciseId, ')
          ..write('position: $position, ')
          ..write('kind: $kind, ')
          ..write('targetRepsMin: $targetRepsMin, ')
          ..write('targetRepsMax: $targetRepsMax, ')
          ..write('targetDurationSeconds: $targetDurationSeconds, ')
          ..write('targetWeight: $targetWeight, ')
          ..write('unit: $unit, ')
          ..write('reps: $reps, ')
          ..write('weight: $weight, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }
}

class $ActiveTimersTable extends ActiveTimers with TableInfo<$ActiveTimersTable, ActiveTimer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActiveTimersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, sessionId, payload];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'active_timers';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActiveTimer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta, payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActiveTimer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActiveTimer(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
    );
  }

  @override
  $ActiveTimersTable createAlias(String alias) {
    return $ActiveTimersTable(attachedDatabase, alias);
  }
}

class ActiveTimer extends DataClass implements Insertable<ActiveTimer> {
  final int id;
  final int sessionId;
  final String payload;
  const ActiveTimer({required this.id, required this.sessionId, required this.payload});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['payload'] = Variable<String>(payload);
    return map;
  }

  ActiveTimersCompanion toCompanion(bool nullToAbsent) {
    return ActiveTimersCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      payload: Value(payload),
    );
  }

  factory ActiveTimer.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActiveTimer(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      payload: serializer.fromJson<String>(json['payload']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'payload': serializer.toJson<String>(payload),
    };
  }

  ActiveTimer copyWith({int? id, int? sessionId, String? payload}) => ActiveTimer(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    payload: payload ?? this.payload,
  );
  ActiveTimer copyWithCompanion(ActiveTimersCompanion data) {
    return ActiveTimer(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      payload: data.payload.present ? data.payload.value : this.payload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActiveTimer(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sessionId, payload);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActiveTimer &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.payload == this.payload);
}

class ActiveTimersCompanion extends UpdateCompanion<ActiveTimer> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<String> payload;
  const ActiveTimersCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.payload = const Value.absent(),
  });
  ActiveTimersCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required String payload,
  }) : sessionId = Value(sessionId),
       payload = Value(payload);
  static Insertable<ActiveTimer> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<String>? payload,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (payload != null) 'payload': payload,
    });
  }

  ActiveTimersCompanion copyWith({Value<int>? id, Value<int>? sessionId, Value<String>? payload}) {
    return ActiveTimersCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      payload: payload ?? this.payload,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActiveTimersCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }
}

class $PreferencesTable extends Preferences with TableInfo<$PreferencesTable, Preference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<Preference> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(_keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(_valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Preference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Preference(
      key: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $PreferencesTable createAlias(String alias) {
    return $PreferencesTable(attachedDatabase, alias);
  }
}

class Preference extends DataClass implements Insertable<Preference> {
  final String key;
  final String value;
  const Preference({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  PreferencesCompanion toCompanion(bool nullToAbsent) {
    return PreferencesCompanion(key: Value(key), value: Value(value));
  }

  factory Preference.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Preference(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  Preference copyWith({String? key, String? value}) =>
      Preference(key: key ?? this.key, value: value ?? this.value);
  Preference copyWithCompanion(PreferencesCompanion data) {
    return Preference(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Preference(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Preference && other.key == this.key && other.value == this.value);
}

class PreferencesCompanion extends UpdateCompanion<Preference> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const PreferencesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PreferencesCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<Preference> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PreferencesCompanion copyWith({Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return PreferencesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PreferencesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$NefaDatabase extends GeneratedDatabase {
  _$NefaDatabase(QueryExecutor e) : super(e);
  $NefaDatabaseManager get managers => $NefaDatabaseManager(this);
  late final $CustomExercisesTable customExercises = $CustomExercisesTable(this);
  late final $LearnedAliasesTable learnedAliases = $LearnedAliasesTable(this);
  late final $RoutinesTable routines = $RoutinesTable(this);
  late final $RoutineDaysTable routineDays = $RoutineDaysTable(this);
  late final $RoutineExercisesTable routineExercises = $RoutineExercisesTable(this);
  late final $RoutineSetsTable routineSets = $RoutineSetsTable(this);
  late final $WorkoutSessionsTable workoutSessions = $WorkoutSessionsTable(this);
  late final $SessionExercisesTable sessionExercises = $SessionExercisesTable(this);
  late final $SetLogsTable setLogs = $SetLogsTable(this);
  late final $ActiveTimersTable activeTimers = $ActiveTimersTable(this);
  late final $PreferencesTable preferences = $PreferencesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    customExercises,
    learnedAliases,
    routines,
    routineDays,
    routineExercises,
    routineSets,
    workoutSessions,
    sessionExercises,
    setLogs,
    activeTimers,
    preferences,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName('routines', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('routine_days', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('routine_days', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('routine_exercises', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('routine_exercises', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('routine_sets', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('workout_sessions', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('session_exercises', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('session_exercises', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('set_logs', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$CustomExercisesTableCreateCompanionBuilder =
    CustomExercisesCompanion Function({
      required String id,
      required String name,
      Value<String?> equipment,
      Value<bool> timed,
      Value<String?> notes,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$CustomExercisesTableUpdateCompanionBuilder =
    CustomExercisesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> equipment,
      Value<bool> timed,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$CustomExercisesTableFilterComposer extends Composer<_$NefaDatabase, $CustomExercisesTable> {
  $$CustomExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get equipment =>
      $composableBuilder(column: $table.equipment, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get timed =>
      $composableBuilder(column: $table.timed, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$CustomExercisesTableOrderingComposer
    extends Composer<_$NefaDatabase, $CustomExercisesTable> {
  $$CustomExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get equipment =>
      $composableBuilder(column: $table.equipment, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get timed =>
      $composableBuilder(column: $table.timed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$CustomExercisesTableAnnotationComposer
    extends Composer<_$NefaDatabase, $CustomExercisesTable> {
  $$CustomExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get equipment =>
      $composableBuilder(column: $table.equipment, builder: (column) => column);

  GeneratedColumn<bool> get timed =>
      $composableBuilder(column: $table.timed, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CustomExercisesTableTableManager
    extends
        RootTableManager<
          _$NefaDatabase,
          $CustomExercisesTable,
          CustomExercise,
          $$CustomExercisesTableFilterComposer,
          $$CustomExercisesTableOrderingComposer,
          $$CustomExercisesTableAnnotationComposer,
          $$CustomExercisesTableCreateCompanionBuilder,
          $$CustomExercisesTableUpdateCompanionBuilder,
          (CustomExercise, BaseReferences<_$NefaDatabase, $CustomExercisesTable, CustomExercise>),
          CustomExercise,
          PrefetchHooks Function()
        > {
  $$CustomExercisesTableTableManager(_$NefaDatabase db, $CustomExercisesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> equipment = const Value.absent(),
                Value<bool> timed = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomExercisesCompanion(
                id: id,
                name: name,
                equipment: equipment,
                timed: timed,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> equipment = const Value.absent(),
                Value<bool> timed = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CustomExercisesCompanion.insert(
                id: id,
                name: name,
                equipment: equipment,
                timed: timed,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$NefaDatabase,
      $CustomExercisesTable,
      CustomExercise,
      $$CustomExercisesTableFilterComposer,
      $$CustomExercisesTableOrderingComposer,
      $$CustomExercisesTableAnnotationComposer,
      $$CustomExercisesTableCreateCompanionBuilder,
      $$CustomExercisesTableUpdateCompanionBuilder,
      (CustomExercise, BaseReferences<_$NefaDatabase, $CustomExercisesTable, CustomExercise>),
      CustomExercise,
      PrefetchHooks Function()
    >;
typedef $$LearnedAliasesTableCreateCompanionBuilder =
    LearnedAliasesCompanion Function({
      required String alias,
      required String exerciseId,
      Value<int> rowid,
    });
typedef $$LearnedAliasesTableUpdateCompanionBuilder =
    LearnedAliasesCompanion Function({
      Value<String> alias,
      Value<String> exerciseId,
      Value<int> rowid,
    });

class $$LearnedAliasesTableFilterComposer extends Composer<_$NefaDatabase, $LearnedAliasesTable> {
  $$LearnedAliasesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get alias =>
      $composableBuilder(column: $table.alias, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get exerciseId =>
      $composableBuilder(column: $table.exerciseId, builder: (column) => ColumnFilters(column));
}

class $$LearnedAliasesTableOrderingComposer extends Composer<_$NefaDatabase, $LearnedAliasesTable> {
  $$LearnedAliasesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get alias =>
      $composableBuilder(column: $table.alias, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get exerciseId =>
      $composableBuilder(column: $table.exerciseId, builder: (column) => ColumnOrderings(column));
}

class $$LearnedAliasesTableAnnotationComposer
    extends Composer<_$NefaDatabase, $LearnedAliasesTable> {
  $$LearnedAliasesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get alias =>
      $composableBuilder(column: $table.alias, builder: (column) => column);

  GeneratedColumn<String> get exerciseId =>
      $composableBuilder(column: $table.exerciseId, builder: (column) => column);
}

class $$LearnedAliasesTableTableManager
    extends
        RootTableManager<
          _$NefaDatabase,
          $LearnedAliasesTable,
          LearnedAlias,
          $$LearnedAliasesTableFilterComposer,
          $$LearnedAliasesTableOrderingComposer,
          $$LearnedAliasesTableAnnotationComposer,
          $$LearnedAliasesTableCreateCompanionBuilder,
          $$LearnedAliasesTableUpdateCompanionBuilder,
          (LearnedAlias, BaseReferences<_$NefaDatabase, $LearnedAliasesTable, LearnedAlias>),
          LearnedAlias,
          PrefetchHooks Function()
        > {
  $$LearnedAliasesTableTableManager(_$NefaDatabase db, $LearnedAliasesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LearnedAliasesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LearnedAliasesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LearnedAliasesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> alias = const Value.absent(),
                Value<String> exerciseId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LearnedAliasesCompanion(alias: alias, exerciseId: exerciseId, rowid: rowid),
          createCompanionCallback:
              ({
                required String alias,
                required String exerciseId,
                Value<int> rowid = const Value.absent(),
              }) => LearnedAliasesCompanion.insert(
                alias: alias,
                exerciseId: exerciseId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LearnedAliasesTableProcessedTableManager =
    ProcessedTableManager<
      _$NefaDatabase,
      $LearnedAliasesTable,
      LearnedAlias,
      $$LearnedAliasesTableFilterComposer,
      $$LearnedAliasesTableOrderingComposer,
      $$LearnedAliasesTableAnnotationComposer,
      $$LearnedAliasesTableCreateCompanionBuilder,
      $$LearnedAliasesTableUpdateCompanionBuilder,
      (LearnedAlias, BaseReferences<_$NefaDatabase, $LearnedAliasesTable, LearnedAlias>),
      LearnedAlias,
      PrefetchHooks Function()
    >;
typedef $$RoutinesTableCreateCompanionBuilder =
    RoutinesCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> notes,
      Value<String?> sourceText,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<bool> archived,
    });
typedef $$RoutinesTableUpdateCompanionBuilder =
    RoutinesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> notes,
      Value<String?> sourceText,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> archived,
    });

final class $$RoutinesTableReferences
    extends BaseReferences<_$NefaDatabase, $RoutinesTable, Routine> {
  $$RoutinesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RoutineDaysTable, List<RoutineDay>> _routineDaysRefsTable(
    _$NefaDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.routineDays,
    aliasName: 'routines__id__routine_days__routine_id',
  );

  $$RoutineDaysTableProcessedTableManager get routineDaysRefs {
    final manager = $$RoutineDaysTableTableManager(
      $_db,
      $_db.routineDays,
    ).filter((f) => f.routineId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_routineDaysRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$RoutinesTableFilterComposer extends Composer<_$NefaDatabase, $RoutinesTable> {
  $$RoutinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceText =>
      $composableBuilder(column: $table.sourceText, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => ColumnFilters(column));

  Expression<bool> routineDaysRefs(
    Expression<bool> Function($$RoutineDaysTableFilterComposer f) f,
  ) {
    final $$RoutineDaysTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineDays,
      getReferencedColumn: (t) => t.routineId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$RoutineDaysTableFilterComposer(
            $db: $db,
            $table: $db.routineDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoutinesTableOrderingComposer extends Composer<_$NefaDatabase, $RoutinesTable> {
  $$RoutinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceText =>
      $composableBuilder(column: $table.sourceText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => ColumnOrderings(column));
}

class $$RoutinesTableAnnotationComposer extends Composer<_$NefaDatabase, $RoutinesTable> {
  $$RoutinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get sourceText =>
      $composableBuilder(column: $table.sourceText, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  Expression<T> routineDaysRefs<T extends Object>(
    Expression<T> Function($$RoutineDaysTableAnnotationComposer a) f,
  ) {
    final $$RoutineDaysTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineDays,
      getReferencedColumn: (t) => t.routineId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$RoutineDaysTableAnnotationComposer(
            $db: $db,
            $table: $db.routineDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoutinesTableTableManager
    extends
        RootTableManager<
          _$NefaDatabase,
          $RoutinesTable,
          Routine,
          $$RoutinesTableFilterComposer,
          $$RoutinesTableOrderingComposer,
          $$RoutinesTableAnnotationComposer,
          $$RoutinesTableCreateCompanionBuilder,
          $$RoutinesTableUpdateCompanionBuilder,
          (Routine, $$RoutinesTableReferences),
          Routine,
          PrefetchHooks Function({bool routineDaysRefs})
        > {
  $$RoutinesTableTableManager(_$NefaDatabase db, $RoutinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$RoutinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$RoutinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> sourceText = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> archived = const Value.absent(),
              }) => RoutinesCompanion(
                id: id,
                name: name,
                notes: notes,
                sourceText: sourceText,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archived: archived,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> notes = const Value.absent(),
                Value<String?> sourceText = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<bool> archived = const Value.absent(),
              }) => RoutinesCompanion.insert(
                id: id,
                name: name,
                notes: notes,
                sourceText: sourceText,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archived: archived,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), $$RoutinesTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({routineDaysRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (routineDaysRefs) db.routineDays],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (routineDaysRefs)
                    await $_getPrefetchedData<Routine, $RoutinesTable, RoutineDay>(
                      currentTable: table,
                      referencedTable: $$RoutinesTableReferences._routineDaysRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$RoutinesTableReferences(db, table, p0).routineDaysRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.routineId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$RoutinesTableProcessedTableManager =
    ProcessedTableManager<
      _$NefaDatabase,
      $RoutinesTable,
      Routine,
      $$RoutinesTableFilterComposer,
      $$RoutinesTableOrderingComposer,
      $$RoutinesTableAnnotationComposer,
      $$RoutinesTableCreateCompanionBuilder,
      $$RoutinesTableUpdateCompanionBuilder,
      (Routine, $$RoutinesTableReferences),
      Routine,
      PrefetchHooks Function({bool routineDaysRefs})
    >;
typedef $$RoutineDaysTableCreateCompanionBuilder =
    RoutineDaysCompanion Function({
      Value<int> id,
      required int routineId,
      required String name,
      required int position,
      Value<int> weekdays,
    });
typedef $$RoutineDaysTableUpdateCompanionBuilder =
    RoutineDaysCompanion Function({
      Value<int> id,
      Value<int> routineId,
      Value<String> name,
      Value<int> position,
      Value<int> weekdays,
    });

final class $$RoutineDaysTableReferences
    extends BaseReferences<_$NefaDatabase, $RoutineDaysTable, RoutineDay> {
  $$RoutineDaysTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RoutinesTable _routineIdTable(_$NefaDatabase db) =>
      db.routines.createAlias('routine_days__routine_id__routines__id');

  $$RoutinesTableProcessedTableManager get routineId {
    final $_column = $_itemColumn<int>('routine_id')!;

    final manager = $$RoutinesTableTableManager(
      $_db,
      $_db.routines,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_routineIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$RoutineExercisesTable, List<RoutineExercise>>
  _routineExercisesRefsTable(_$NefaDatabase db) => MultiTypedResultKey.fromTable(
    db.routineExercises,
    aliasName: 'routine_days__id__routine_exercises__day_id',
  );

  $$RoutineExercisesTableProcessedTableManager get routineExercisesRefs {
    final manager = $$RoutineExercisesTableTableManager(
      $_db,
      $_db.routineExercises,
    ).filter((f) => f.dayId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_routineExercisesRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$RoutineDaysTableFilterComposer extends Composer<_$NefaDatabase, $RoutineDaysTable> {
  $$RoutineDaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get weekdays =>
      $composableBuilder(column: $table.weekdays, builder: (column) => ColumnFilters(column));

  $$RoutinesTableFilterComposer get routineId {
    final $$RoutinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$RoutinesTableFilterComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> routineExercisesRefs(
    Expression<bool> Function($$RoutineExercisesTableFilterComposer f) f,
  ) {
    final $$RoutineExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineExercises,
      getReferencedColumn: (t) => t.dayId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$RoutineExercisesTableFilterComposer(
            $db: $db,
            $table: $db.routineExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoutineDaysTableOrderingComposer extends Composer<_$NefaDatabase, $RoutineDaysTable> {
  $$RoutineDaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get weekdays =>
      $composableBuilder(column: $table.weekdays, builder: (column) => ColumnOrderings(column));

  $$RoutinesTableOrderingComposer get routineId {
    final $$RoutinesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$RoutinesTableOrderingComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineDaysTableAnnotationComposer extends Composer<_$NefaDatabase, $RoutineDaysTable> {
  $$RoutineDaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get weekdays =>
      $composableBuilder(column: $table.weekdays, builder: (column) => column);

  $$RoutinesTableAnnotationComposer get routineId {
    final $$RoutinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$RoutinesTableAnnotationComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> routineExercisesRefs<T extends Object>(
    Expression<T> Function($$RoutineExercisesTableAnnotationComposer a) f,
  ) {
    final $$RoutineExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineExercises,
      getReferencedColumn: (t) => t.dayId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$RoutineExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.routineExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoutineDaysTableTableManager
    extends
        RootTableManager<
          _$NefaDatabase,
          $RoutineDaysTable,
          RoutineDay,
          $$RoutineDaysTableFilterComposer,
          $$RoutineDaysTableOrderingComposer,
          $$RoutineDaysTableAnnotationComposer,
          $$RoutineDaysTableCreateCompanionBuilder,
          $$RoutineDaysTableUpdateCompanionBuilder,
          (RoutineDay, $$RoutineDaysTableReferences),
          RoutineDay,
          PrefetchHooks Function({bool routineId, bool routineExercisesRefs})
        > {
  $$RoutineDaysTableTableManager(_$NefaDatabase db, $RoutineDaysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$RoutineDaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$RoutineDaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutineDaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> routineId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> weekdays = const Value.absent(),
              }) => RoutineDaysCompanion(
                id: id,
                routineId: routineId,
                name: name,
                position: position,
                weekdays: weekdays,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int routineId,
                required String name,
                required int position,
                Value<int> weekdays = const Value.absent(),
              }) => RoutineDaysCompanion.insert(
                id: id,
                routineId: routineId,
                name: name,
                position: position,
                weekdays: weekdays,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), $$RoutineDaysTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({routineId = false, routineExercisesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (routineExercisesRefs) db.routineExercises],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (routineId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.routineId,
                                referencedTable: $$RoutineDaysTableReferences._routineIdTable(db),
                                referencedColumn: $$RoutineDaysTableReferences
                                    ._routineIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (routineExercisesRefs)
                    await $_getPrefetchedData<RoutineDay, $RoutineDaysTable, RoutineExercise>(
                      currentTable: table,
                      referencedTable: $$RoutineDaysTableReferences._routineExercisesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$RoutineDaysTableReferences(db, table, p0).routineExercisesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.dayId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$RoutineDaysTableProcessedTableManager =
    ProcessedTableManager<
      _$NefaDatabase,
      $RoutineDaysTable,
      RoutineDay,
      $$RoutineDaysTableFilterComposer,
      $$RoutineDaysTableOrderingComposer,
      $$RoutineDaysTableAnnotationComposer,
      $$RoutineDaysTableCreateCompanionBuilder,
      $$RoutineDaysTableUpdateCompanionBuilder,
      (RoutineDay, $$RoutineDaysTableReferences),
      RoutineDay,
      PrefetchHooks Function({bool routineId, bool routineExercisesRefs})
    >;
typedef $$RoutineExercisesTableCreateCompanionBuilder =
    RoutineExercisesCompanion Function({
      Value<int> id,
      required int dayId,
      Value<String?> exerciseId,
      required String name,
      required int position,
      Value<String?> groupLabel,
      Value<int?> restSeconds,
      Value<Provenance> restFrom,
      Value<String?> tempo,
      Value<String?> notes,
      Value<bool> perSide,
      Value<bool> timed,
      Value<String?> variant,
    });
typedef $$RoutineExercisesTableUpdateCompanionBuilder =
    RoutineExercisesCompanion Function({
      Value<int> id,
      Value<int> dayId,
      Value<String?> exerciseId,
      Value<String> name,
      Value<int> position,
      Value<String?> groupLabel,
      Value<int?> restSeconds,
      Value<Provenance> restFrom,
      Value<String?> tempo,
      Value<String?> notes,
      Value<bool> perSide,
      Value<bool> timed,
      Value<String?> variant,
    });

final class $$RoutineExercisesTableReferences
    extends BaseReferences<_$NefaDatabase, $RoutineExercisesTable, RoutineExercise> {
  $$RoutineExercisesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RoutineDaysTable _dayIdTable(_$NefaDatabase db) =>
      db.routineDays.createAlias('routine_exercises__day_id__routine_days__id');

  $$RoutineDaysTableProcessedTableManager get dayId {
    final $_column = $_itemColumn<int>('day_id')!;

    final manager = $$RoutineDaysTableTableManager(
      $_db,
      $_db.routineDays,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_dayIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$RoutineSetsTable, List<RoutineSet>> _routineSetsRefsTable(
    _$NefaDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.routineSets,
    aliasName: 'routine_exercises__id__routine_sets__routine_exercise_id',
  );

  $$RoutineSetsTableProcessedTableManager get routineSetsRefs {
    final manager = $$RoutineSetsTableTableManager(
      $_db,
      $_db.routineSets,
    ).filter((f) => f.routineExerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_routineSetsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$RoutineExercisesTableFilterComposer
    extends Composer<_$NefaDatabase, $RoutineExercisesTable> {
  $$RoutineExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get exerciseId =>
      $composableBuilder(column: $table.exerciseId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get groupLabel =>
      $composableBuilder(column: $table.groupLabel, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get restSeconds =>
      $composableBuilder(column: $table.restSeconds, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<Provenance, Provenance, int> get restFrom => $composableBuilder(
    column: $table.restFrom,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get tempo =>
      $composableBuilder(column: $table.tempo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get perSide =>
      $composableBuilder(column: $table.perSide, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get timed =>
      $composableBuilder(column: $table.timed, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get variant =>
      $composableBuilder(column: $table.variant, builder: (column) => ColumnFilters(column));

  $$RoutineDaysTableFilterComposer get dayId {
    final $$RoutineDaysTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dayId,
      referencedTable: $db.routineDays,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$RoutineDaysTableFilterComposer(
            $db: $db,
            $table: $db.routineDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> routineSetsRefs(
    Expression<bool> Function($$RoutineSetsTableFilterComposer f) f,
  ) {
    final $$RoutineSetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineSets,
      getReferencedColumn: (t) => t.routineExerciseId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$RoutineSetsTableFilterComposer(
            $db: $db,
            $table: $db.routineSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoutineExercisesTableOrderingComposer
    extends Composer<_$NefaDatabase, $RoutineExercisesTable> {
  $$RoutineExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get exerciseId =>
      $composableBuilder(column: $table.exerciseId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get groupLabel =>
      $composableBuilder(column: $table.groupLabel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get restSeconds =>
      $composableBuilder(column: $table.restSeconds, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get restFrom =>
      $composableBuilder(column: $table.restFrom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tempo =>
      $composableBuilder(column: $table.tempo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get perSide =>
      $composableBuilder(column: $table.perSide, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get timed =>
      $composableBuilder(column: $table.timed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get variant =>
      $composableBuilder(column: $table.variant, builder: (column) => ColumnOrderings(column));

  $$RoutineDaysTableOrderingComposer get dayId {
    final $$RoutineDaysTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dayId,
      referencedTable: $db.routineDays,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$RoutineDaysTableOrderingComposer(
            $db: $db,
            $table: $db.routineDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineExercisesTableAnnotationComposer
    extends Composer<_$NefaDatabase, $RoutineExercisesTable> {
  $$RoutineExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get exerciseId =>
      $composableBuilder(column: $table.exerciseId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get groupLabel =>
      $composableBuilder(column: $table.groupLabel, builder: (column) => column);

  GeneratedColumn<int> get restSeconds =>
      $composableBuilder(column: $table.restSeconds, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Provenance, int> get restFrom =>
      $composableBuilder(column: $table.restFrom, builder: (column) => column);

  GeneratedColumn<String> get tempo =>
      $composableBuilder(column: $table.tempo, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get perSide =>
      $composableBuilder(column: $table.perSide, builder: (column) => column);

  GeneratedColumn<bool> get timed =>
      $composableBuilder(column: $table.timed, builder: (column) => column);

  GeneratedColumn<String> get variant =>
      $composableBuilder(column: $table.variant, builder: (column) => column);

  $$RoutineDaysTableAnnotationComposer get dayId {
    final $$RoutineDaysTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dayId,
      referencedTable: $db.routineDays,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$RoutineDaysTableAnnotationComposer(
            $db: $db,
            $table: $db.routineDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> routineSetsRefs<T extends Object>(
    Expression<T> Function($$RoutineSetsTableAnnotationComposer a) f,
  ) {
    final $$RoutineSetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineSets,
      getReferencedColumn: (t) => t.routineExerciseId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$RoutineSetsTableAnnotationComposer(
            $db: $db,
            $table: $db.routineSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoutineExercisesTableTableManager
    extends
        RootTableManager<
          _$NefaDatabase,
          $RoutineExercisesTable,
          RoutineExercise,
          $$RoutineExercisesTableFilterComposer,
          $$RoutineExercisesTableOrderingComposer,
          $$RoutineExercisesTableAnnotationComposer,
          $$RoutineExercisesTableCreateCompanionBuilder,
          $$RoutineExercisesTableUpdateCompanionBuilder,
          (RoutineExercise, $$RoutineExercisesTableReferences),
          RoutineExercise,
          PrefetchHooks Function({bool dayId, bool routineSetsRefs})
        > {
  $$RoutineExercisesTableTableManager(_$NefaDatabase db, $RoutineExercisesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutineExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutineExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutineExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> dayId = const Value.absent(),
                Value<String?> exerciseId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String?> groupLabel = const Value.absent(),
                Value<int?> restSeconds = const Value.absent(),
                Value<Provenance> restFrom = const Value.absent(),
                Value<String?> tempo = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> perSide = const Value.absent(),
                Value<bool> timed = const Value.absent(),
                Value<String?> variant = const Value.absent(),
              }) => RoutineExercisesCompanion(
                id: id,
                dayId: dayId,
                exerciseId: exerciseId,
                name: name,
                position: position,
                groupLabel: groupLabel,
                restSeconds: restSeconds,
                restFrom: restFrom,
                tempo: tempo,
                notes: notes,
                perSide: perSide,
                timed: timed,
                variant: variant,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int dayId,
                Value<String?> exerciseId = const Value.absent(),
                required String name,
                required int position,
                Value<String?> groupLabel = const Value.absent(),
                Value<int?> restSeconds = const Value.absent(),
                Value<Provenance> restFrom = const Value.absent(),
                Value<String?> tempo = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> perSide = const Value.absent(),
                Value<bool> timed = const Value.absent(),
                Value<String?> variant = const Value.absent(),
              }) => RoutineExercisesCompanion.insert(
                id: id,
                dayId: dayId,
                exerciseId: exerciseId,
                name: name,
                position: position,
                groupLabel: groupLabel,
                restSeconds: restSeconds,
                restFrom: restFrom,
                tempo: tempo,
                notes: notes,
                perSide: perSide,
                timed: timed,
                variant: variant,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), $$RoutineExercisesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({dayId = false, routineSetsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (routineSetsRefs) db.routineSets],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (dayId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.dayId,
                                referencedTable: $$RoutineExercisesTableReferences._dayIdTable(db),
                                referencedColumn: $$RoutineExercisesTableReferences
                                    ._dayIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (routineSetsRefs)
                    await $_getPrefetchedData<RoutineExercise, $RoutineExercisesTable, RoutineSet>(
                      currentTable: table,
                      referencedTable: $$RoutineExercisesTableReferences._routineSetsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$RoutineExercisesTableReferences(db, table, p0).routineSetsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.routineExerciseId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$RoutineExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$NefaDatabase,
      $RoutineExercisesTable,
      RoutineExercise,
      $$RoutineExercisesTableFilterComposer,
      $$RoutineExercisesTableOrderingComposer,
      $$RoutineExercisesTableAnnotationComposer,
      $$RoutineExercisesTableCreateCompanionBuilder,
      $$RoutineExercisesTableUpdateCompanionBuilder,
      (RoutineExercise, $$RoutineExercisesTableReferences),
      RoutineExercise,
      PrefetchHooks Function({bool dayId, bool routineSetsRefs})
    >;
typedef $$RoutineSetsTableCreateCompanionBuilder =
    RoutineSetsCompanion Function({
      Value<int> id,
      required int routineExerciseId,
      required int position,
      required TargetKind kind,
      Value<int?> repsMin,
      Value<int?> repsMax,
      Value<int?> durationSeconds,
      Value<double?> weight,
      Value<WeightUnit> unit,
      Value<Provenance> setsFrom,
      Value<Provenance> targetFrom,
    });
typedef $$RoutineSetsTableUpdateCompanionBuilder =
    RoutineSetsCompanion Function({
      Value<int> id,
      Value<int> routineExerciseId,
      Value<int> position,
      Value<TargetKind> kind,
      Value<int?> repsMin,
      Value<int?> repsMax,
      Value<int?> durationSeconds,
      Value<double?> weight,
      Value<WeightUnit> unit,
      Value<Provenance> setsFrom,
      Value<Provenance> targetFrom,
    });

final class $$RoutineSetsTableReferences
    extends BaseReferences<_$NefaDatabase, $RoutineSetsTable, RoutineSet> {
  $$RoutineSetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RoutineExercisesTable _routineExerciseIdTable(_$NefaDatabase db) =>
      db.routineExercises.createAlias('routine_sets__routine_exercise_id__routine_exercises__id');

  $$RoutineExercisesTableProcessedTableManager get routineExerciseId {
    final $_column = $_itemColumn<int>('routine_exercise_id')!;

    final manager = $$RoutineExercisesTableTableManager(
      $_db,
      $_db.routineExercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_routineExerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$RoutineSetsTableFilterComposer extends Composer<_$NefaDatabase, $RoutineSetsTable> {
  $$RoutineSetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<TargetKind, TargetKind, int> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get repsMin =>
      $composableBuilder(column: $table.repsMin, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get repsMax =>
      $composableBuilder(column: $table.repsMax, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<WeightUnit, WeightUnit, int> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<Provenance, Provenance, int> get setsFrom => $composableBuilder(
    column: $table.setsFrom,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<Provenance, Provenance, int> get targetFrom => $composableBuilder(
    column: $table.targetFrom,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  $$RoutineExercisesTableFilterComposer get routineExerciseId {
    final $$RoutineExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineExerciseId,
      referencedTable: $db.routineExercises,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$RoutineExercisesTableFilterComposer(
            $db: $db,
            $table: $db.routineExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineSetsTableOrderingComposer extends Composer<_$NefaDatabase, $RoutineSetsTable> {
  $$RoutineSetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get repsMin =>
      $composableBuilder(column: $table.repsMin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get repsMax =>
      $composableBuilder(column: $table.repsMax, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get setsFrom =>
      $composableBuilder(column: $table.setsFrom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get targetFrom =>
      $composableBuilder(column: $table.targetFrom, builder: (column) => ColumnOrderings(column));

  $$RoutineExercisesTableOrderingComposer get routineExerciseId {
    final $$RoutineExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineExerciseId,
      referencedTable: $db.routineExercises,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$RoutineExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.routineExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineSetsTableAnnotationComposer extends Composer<_$NefaDatabase, $RoutineSetsTable> {
  $$RoutineSetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TargetKind, int> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get repsMin =>
      $composableBuilder(column: $table.repsMin, builder: (column) => column);

  GeneratedColumn<int> get repsMax =>
      $composableBuilder(column: $table.repsMax, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds =>
      $composableBuilder(column: $table.durationSeconds, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumnWithTypeConverter<WeightUnit, int> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Provenance, int> get setsFrom =>
      $composableBuilder(column: $table.setsFrom, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Provenance, int> get targetFrom =>
      $composableBuilder(column: $table.targetFrom, builder: (column) => column);

  $$RoutineExercisesTableAnnotationComposer get routineExerciseId {
    final $$RoutineExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineExerciseId,
      referencedTable: $db.routineExercises,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$RoutineExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.routineExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineSetsTableTableManager
    extends
        RootTableManager<
          _$NefaDatabase,
          $RoutineSetsTable,
          RoutineSet,
          $$RoutineSetsTableFilterComposer,
          $$RoutineSetsTableOrderingComposer,
          $$RoutineSetsTableAnnotationComposer,
          $$RoutineSetsTableCreateCompanionBuilder,
          $$RoutineSetsTableUpdateCompanionBuilder,
          (RoutineSet, $$RoutineSetsTableReferences),
          RoutineSet,
          PrefetchHooks Function({bool routineExerciseId})
        > {
  $$RoutineSetsTableTableManager(_$NefaDatabase db, $RoutineSetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$RoutineSetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$RoutineSetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutineSetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> routineExerciseId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<TargetKind> kind = const Value.absent(),
                Value<int?> repsMin = const Value.absent(),
                Value<int?> repsMax = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                Value<double?> weight = const Value.absent(),
                Value<WeightUnit> unit = const Value.absent(),
                Value<Provenance> setsFrom = const Value.absent(),
                Value<Provenance> targetFrom = const Value.absent(),
              }) => RoutineSetsCompanion(
                id: id,
                routineExerciseId: routineExerciseId,
                position: position,
                kind: kind,
                repsMin: repsMin,
                repsMax: repsMax,
                durationSeconds: durationSeconds,
                weight: weight,
                unit: unit,
                setsFrom: setsFrom,
                targetFrom: targetFrom,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int routineExerciseId,
                required int position,
                required TargetKind kind,
                Value<int?> repsMin = const Value.absent(),
                Value<int?> repsMax = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                Value<double?> weight = const Value.absent(),
                Value<WeightUnit> unit = const Value.absent(),
                Value<Provenance> setsFrom = const Value.absent(),
                Value<Provenance> targetFrom = const Value.absent(),
              }) => RoutineSetsCompanion.insert(
                id: id,
                routineExerciseId: routineExerciseId,
                position: position,
                kind: kind,
                repsMin: repsMin,
                repsMax: repsMax,
                durationSeconds: durationSeconds,
                weight: weight,
                unit: unit,
                setsFrom: setsFrom,
                targetFrom: targetFrom,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), $$RoutineSetsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({routineExerciseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (routineExerciseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.routineExerciseId,
                                referencedTable: $$RoutineSetsTableReferences
                                    ._routineExerciseIdTable(db),
                                referencedColumn: $$RoutineSetsTableReferences
                                    ._routineExerciseIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RoutineSetsTableProcessedTableManager =
    ProcessedTableManager<
      _$NefaDatabase,
      $RoutineSetsTable,
      RoutineSet,
      $$RoutineSetsTableFilterComposer,
      $$RoutineSetsTableOrderingComposer,
      $$RoutineSetsTableAnnotationComposer,
      $$RoutineSetsTableCreateCompanionBuilder,
      $$RoutineSetsTableUpdateCompanionBuilder,
      (RoutineSet, $$RoutineSetsTableReferences),
      RoutineSet,
      PrefetchHooks Function({bool routineExerciseId})
    >;
typedef $$WorkoutSessionsTableCreateCompanionBuilder =
    WorkoutSessionsCompanion Function({
      Value<int> id,
      Value<int?> routineId,
      Value<int?> dayId,
      required String title,
      Value<String?> routineName,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
      Value<String> status,
      Value<String?> notes,
    });
typedef $$WorkoutSessionsTableUpdateCompanionBuilder =
    WorkoutSessionsCompanion Function({
      Value<int> id,
      Value<int?> routineId,
      Value<int?> dayId,
      Value<String> title,
      Value<String?> routineName,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<String> status,
      Value<String?> notes,
    });

final class $$WorkoutSessionsTableReferences
    extends BaseReferences<_$NefaDatabase, $WorkoutSessionsTable, WorkoutSession> {
  $$WorkoutSessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SessionExercisesTable, List<SessionExercise>>
  _sessionExercisesRefsTable(_$NefaDatabase db) => MultiTypedResultKey.fromTable(
    db.sessionExercises,
    aliasName: 'workout_sessions__id__session_exercises__session_id',
  );

  $$SessionExercisesTableProcessedTableManager get sessionExercisesRefs {
    final manager = $$SessionExercisesTableTableManager(
      $_db,
      $_db.sessionExercises,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessionExercisesRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$WorkoutSessionsTableFilterComposer extends Composer<_$NefaDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get routineId =>
      $composableBuilder(column: $table.routineId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dayId =>
      $composableBuilder(column: $table.dayId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get routineName =>
      $composableBuilder(column: $table.routineName, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnFilters(column));

  Expression<bool> sessionExercisesRefs(
    Expression<bool> Function($$SessionExercisesTableFilterComposer f) f,
  ) {
    final $$SessionExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionExercises,
      getReferencedColumn: (t) => t.sessionId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$SessionExercisesTableFilterComposer(
            $db: $db,
            $table: $db.sessionExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutSessionsTableOrderingComposer
    extends Composer<_$NefaDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get routineId =>
      $composableBuilder(column: $table.routineId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dayId =>
      $composableBuilder(column: $table.dayId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get routineName =>
      $composableBuilder(column: $table.routineName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnOrderings(column));
}

class $$WorkoutSessionsTableAnnotationComposer
    extends Composer<_$NefaDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get routineId =>
      $composableBuilder(column: $table.routineId, builder: (column) => column);

  GeneratedColumn<int> get dayId =>
      $composableBuilder(column: $table.dayId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get routineName =>
      $composableBuilder(column: $table.routineName, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  Expression<T> sessionExercisesRefs<T extends Object>(
    Expression<T> Function($$SessionExercisesTableAnnotationComposer a) f,
  ) {
    final $$SessionExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionExercises,
      getReferencedColumn: (t) => t.sessionId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$SessionExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.sessionExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutSessionsTableTableManager
    extends
        RootTableManager<
          _$NefaDatabase,
          $WorkoutSessionsTable,
          WorkoutSession,
          $$WorkoutSessionsTableFilterComposer,
          $$WorkoutSessionsTableOrderingComposer,
          $$WorkoutSessionsTableAnnotationComposer,
          $$WorkoutSessionsTableCreateCompanionBuilder,
          $$WorkoutSessionsTableUpdateCompanionBuilder,
          (WorkoutSession, $$WorkoutSessionsTableReferences),
          WorkoutSession,
          PrefetchHooks Function({bool sessionExercisesRefs})
        > {
  $$WorkoutSessionsTableTableManager(_$NefaDatabase db, $WorkoutSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> routineId = const Value.absent(),
                Value<int?> dayId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> routineName = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => WorkoutSessionsCompanion(
                id: id,
                routineId: routineId,
                dayId: dayId,
                title: title,
                routineName: routineName,
                startedAt: startedAt,
                endedAt: endedAt,
                status: status,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> routineId = const Value.absent(),
                Value<int?> dayId = const Value.absent(),
                required String title,
                Value<String?> routineName = const Value.absent(),
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => WorkoutSessionsCompanion.insert(
                id: id,
                routineId: routineId,
                dayId: dayId,
                title: title,
                routineName: routineName,
                startedAt: startedAt,
                endedAt: endedAt,
                status: status,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), $$WorkoutSessionsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({sessionExercisesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (sessionExercisesRefs) db.sessionExercises],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (sessionExercisesRefs)
                    await $_getPrefetchedData<
                      WorkoutSession,
                      $WorkoutSessionsTable,
                      SessionExercise
                    >(
                      currentTable: table,
                      referencedTable: $$WorkoutSessionsTableReferences._sessionExercisesRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$WorkoutSessionsTableReferences(db, table, p0).sessionExercisesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.sessionId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$WorkoutSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$NefaDatabase,
      $WorkoutSessionsTable,
      WorkoutSession,
      $$WorkoutSessionsTableFilterComposer,
      $$WorkoutSessionsTableOrderingComposer,
      $$WorkoutSessionsTableAnnotationComposer,
      $$WorkoutSessionsTableCreateCompanionBuilder,
      $$WorkoutSessionsTableUpdateCompanionBuilder,
      (WorkoutSession, $$WorkoutSessionsTableReferences),
      WorkoutSession,
      PrefetchHooks Function({bool sessionExercisesRefs})
    >;
typedef $$SessionExercisesTableCreateCompanionBuilder =
    SessionExercisesCompanion Function({
      Value<int> id,
      required int sessionId,
      Value<String?> exerciseId,
      required String name,
      required int position,
      Value<String?> groupLabel,
      Value<int?> restSeconds,
      Value<String?> tempo,
      Value<String?> notes,
      Value<bool> perSide,
      Value<bool> timed,
      Value<String?> variant,
      Value<bool> skipped,
    });
typedef $$SessionExercisesTableUpdateCompanionBuilder =
    SessionExercisesCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<String?> exerciseId,
      Value<String> name,
      Value<int> position,
      Value<String?> groupLabel,
      Value<int?> restSeconds,
      Value<String?> tempo,
      Value<String?> notes,
      Value<bool> perSide,
      Value<bool> timed,
      Value<String?> variant,
      Value<bool> skipped,
    });

final class $$SessionExercisesTableReferences
    extends BaseReferences<_$NefaDatabase, $SessionExercisesTable, SessionExercise> {
  $$SessionExercisesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WorkoutSessionsTable _sessionIdTable(_$NefaDatabase db) =>
      db.workoutSessions.createAlias('session_exercises__session_id__workout_sessions__id');

  $$WorkoutSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$WorkoutSessionsTableTableManager(
      $_db,
      $_db.workoutSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$SetLogsTable, List<SetLog>> _setLogsRefsTable(_$NefaDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.setLogs,
        aliasName: 'session_exercises__id__set_logs__session_exercise_id',
      );

  $$SetLogsTableProcessedTableManager get setLogsRefs {
    final manager = $$SetLogsTableTableManager(
      $_db,
      $_db.setLogs,
    ).filter((f) => f.sessionExerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_setLogsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SessionExercisesTableFilterComposer
    extends Composer<_$NefaDatabase, $SessionExercisesTable> {
  $$SessionExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get exerciseId =>
      $composableBuilder(column: $table.exerciseId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get groupLabel =>
      $composableBuilder(column: $table.groupLabel, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get restSeconds =>
      $composableBuilder(column: $table.restSeconds, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tempo =>
      $composableBuilder(column: $table.tempo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get perSide =>
      $composableBuilder(column: $table.perSide, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get timed =>
      $composableBuilder(column: $table.timed, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get variant =>
      $composableBuilder(column: $table.variant, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get skipped =>
      $composableBuilder(column: $table.skipped, builder: (column) => ColumnFilters(column));

  $$WorkoutSessionsTableFilterComposer get sessionId {
    final $$WorkoutSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workoutSessions,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$WorkoutSessionsTableFilterComposer(
            $db: $db,
            $table: $db.workoutSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> setLogsRefs(Expression<bool> Function($$SetLogsTableFilterComposer f) f) {
    final $$SetLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.setLogs,
      getReferencedColumn: (t) => t.sessionExerciseId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$SetLogsTableFilterComposer(
            $db: $db,
            $table: $db.setLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionExercisesTableOrderingComposer
    extends Composer<_$NefaDatabase, $SessionExercisesTable> {
  $$SessionExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get exerciseId =>
      $composableBuilder(column: $table.exerciseId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get groupLabel =>
      $composableBuilder(column: $table.groupLabel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get restSeconds =>
      $composableBuilder(column: $table.restSeconds, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tempo =>
      $composableBuilder(column: $table.tempo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get perSide =>
      $composableBuilder(column: $table.perSide, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get timed =>
      $composableBuilder(column: $table.timed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get variant =>
      $composableBuilder(column: $table.variant, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get skipped =>
      $composableBuilder(column: $table.skipped, builder: (column) => ColumnOrderings(column));

  $$WorkoutSessionsTableOrderingComposer get sessionId {
    final $$WorkoutSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workoutSessions,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$WorkoutSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.workoutSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionExercisesTableAnnotationComposer
    extends Composer<_$NefaDatabase, $SessionExercisesTable> {
  $$SessionExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get exerciseId =>
      $composableBuilder(column: $table.exerciseId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get groupLabel =>
      $composableBuilder(column: $table.groupLabel, builder: (column) => column);

  GeneratedColumn<int> get restSeconds =>
      $composableBuilder(column: $table.restSeconds, builder: (column) => column);

  GeneratedColumn<String> get tempo =>
      $composableBuilder(column: $table.tempo, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get perSide =>
      $composableBuilder(column: $table.perSide, builder: (column) => column);

  GeneratedColumn<bool> get timed =>
      $composableBuilder(column: $table.timed, builder: (column) => column);

  GeneratedColumn<String> get variant =>
      $composableBuilder(column: $table.variant, builder: (column) => column);

  GeneratedColumn<bool> get skipped =>
      $composableBuilder(column: $table.skipped, builder: (column) => column);

  $$WorkoutSessionsTableAnnotationComposer get sessionId {
    final $$WorkoutSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workoutSessions,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$WorkoutSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> setLogsRefs<T extends Object>(
    Expression<T> Function($$SetLogsTableAnnotationComposer a) f,
  ) {
    final $$SetLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.setLogs,
      getReferencedColumn: (t) => t.sessionExerciseId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$SetLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.setLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionExercisesTableTableManager
    extends
        RootTableManager<
          _$NefaDatabase,
          $SessionExercisesTable,
          SessionExercise,
          $$SessionExercisesTableFilterComposer,
          $$SessionExercisesTableOrderingComposer,
          $$SessionExercisesTableAnnotationComposer,
          $$SessionExercisesTableCreateCompanionBuilder,
          $$SessionExercisesTableUpdateCompanionBuilder,
          (SessionExercise, $$SessionExercisesTableReferences),
          SessionExercise,
          PrefetchHooks Function({bool sessionId, bool setLogsRefs})
        > {
  $$SessionExercisesTableTableManager(_$NefaDatabase db, $SessionExercisesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<String?> exerciseId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String?> groupLabel = const Value.absent(),
                Value<int?> restSeconds = const Value.absent(),
                Value<String?> tempo = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> perSide = const Value.absent(),
                Value<bool> timed = const Value.absent(),
                Value<String?> variant = const Value.absent(),
                Value<bool> skipped = const Value.absent(),
              }) => SessionExercisesCompanion(
                id: id,
                sessionId: sessionId,
                exerciseId: exerciseId,
                name: name,
                position: position,
                groupLabel: groupLabel,
                restSeconds: restSeconds,
                tempo: tempo,
                notes: notes,
                perSide: perSide,
                timed: timed,
                variant: variant,
                skipped: skipped,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                Value<String?> exerciseId = const Value.absent(),
                required String name,
                required int position,
                Value<String?> groupLabel = const Value.absent(),
                Value<int?> restSeconds = const Value.absent(),
                Value<String?> tempo = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> perSide = const Value.absent(),
                Value<bool> timed = const Value.absent(),
                Value<String?> variant = const Value.absent(),
                Value<bool> skipped = const Value.absent(),
              }) => SessionExercisesCompanion.insert(
                id: id,
                sessionId: sessionId,
                exerciseId: exerciseId,
                name: name,
                position: position,
                groupLabel: groupLabel,
                restSeconds: restSeconds,
                tempo: tempo,
                notes: notes,
                perSide: perSide,
                timed: timed,
                variant: variant,
                skipped: skipped,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), $$SessionExercisesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({sessionId = false, setLogsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (setLogsRefs) db.setLogs],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable: $$SessionExercisesTableReferences._sessionIdTable(
                                  db,
                                ),
                                referencedColumn: $$SessionExercisesTableReferences
                                    ._sessionIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (setLogsRefs)
                    await $_getPrefetchedData<SessionExercise, $SessionExercisesTable, SetLog>(
                      currentTable: table,
                      referencedTable: $$SessionExercisesTableReferences._setLogsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SessionExercisesTableReferences(db, table, p0).setLogsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.sessionExerciseId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SessionExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$NefaDatabase,
      $SessionExercisesTable,
      SessionExercise,
      $$SessionExercisesTableFilterComposer,
      $$SessionExercisesTableOrderingComposer,
      $$SessionExercisesTableAnnotationComposer,
      $$SessionExercisesTableCreateCompanionBuilder,
      $$SessionExercisesTableUpdateCompanionBuilder,
      (SessionExercise, $$SessionExercisesTableReferences),
      SessionExercise,
      PrefetchHooks Function({bool sessionId, bool setLogsRefs})
    >;
typedef $$SetLogsTableCreateCompanionBuilder =
    SetLogsCompanion Function({
      Value<int> id,
      required int sessionExerciseId,
      required int position,
      required TargetKind kind,
      Value<int?> targetRepsMin,
      Value<int?> targetRepsMax,
      Value<int?> targetDurationSeconds,
      Value<double?> targetWeight,
      Value<WeightUnit> unit,
      Value<int?> reps,
      Value<double?> weight,
      Value<int?> durationSeconds,
      Value<DateTime?> completedAt,
    });
typedef $$SetLogsTableUpdateCompanionBuilder =
    SetLogsCompanion Function({
      Value<int> id,
      Value<int> sessionExerciseId,
      Value<int> position,
      Value<TargetKind> kind,
      Value<int?> targetRepsMin,
      Value<int?> targetRepsMax,
      Value<int?> targetDurationSeconds,
      Value<double?> targetWeight,
      Value<WeightUnit> unit,
      Value<int?> reps,
      Value<double?> weight,
      Value<int?> durationSeconds,
      Value<DateTime?> completedAt,
    });

final class $$SetLogsTableReferences extends BaseReferences<_$NefaDatabase, $SetLogsTable, SetLog> {
  $$SetLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionExercisesTable _sessionExerciseIdTable(_$NefaDatabase db) =>
      db.sessionExercises.createAlias('set_logs__session_exercise_id__session_exercises__id');

  $$SessionExercisesTableProcessedTableManager get sessionExerciseId {
    final $_column = $_itemColumn<int>('session_exercise_id')!;

    final manager = $$SessionExercisesTableTableManager(
      $_db,
      $_db.sessionExercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionExerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$SetLogsTableFilterComposer extends Composer<_$NefaDatabase, $SetLogsTable> {
  $$SetLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<TargetKind, TargetKind, int> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get targetRepsMin =>
      $composableBuilder(column: $table.targetRepsMin, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get targetRepsMax =>
      $composableBuilder(column: $table.targetRepsMax, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get targetDurationSeconds => $composableBuilder(
    column: $table.targetDurationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetWeight =>
      $composableBuilder(column: $table.targetWeight, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<WeightUnit, WeightUnit, int> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt =>
      $composableBuilder(column: $table.completedAt, builder: (column) => ColumnFilters(column));

  $$SessionExercisesTableFilterComposer get sessionExerciseId {
    final $$SessionExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionExerciseId,
      referencedTable: $db.sessionExercises,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$SessionExercisesTableFilterComposer(
            $db: $db,
            $table: $db.sessionExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SetLogsTableOrderingComposer extends Composer<_$NefaDatabase, $SetLogsTable> {
  $$SetLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get targetRepsMin => $composableBuilder(
    column: $table.targetRepsMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetRepsMax => $composableBuilder(
    column: $table.targetRepsMax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetDurationSeconds => $composableBuilder(
    column: $table.targetDurationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetWeight =>
      $composableBuilder(column: $table.targetWeight, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt =>
      $composableBuilder(column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  $$SessionExercisesTableOrderingComposer get sessionExerciseId {
    final $$SessionExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionExerciseId,
      referencedTable: $db.sessionExercises,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$SessionExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.sessionExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SetLogsTableAnnotationComposer extends Composer<_$NefaDatabase, $SetLogsTable> {
  $$SetLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TargetKind, int> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get targetRepsMin =>
      $composableBuilder(column: $table.targetRepsMin, builder: (column) => column);

  GeneratedColumn<int> get targetRepsMax =>
      $composableBuilder(column: $table.targetRepsMax, builder: (column) => column);

  GeneratedColumn<int> get targetDurationSeconds =>
      $composableBuilder(column: $table.targetDurationSeconds, builder: (column) => column);

  GeneratedColumn<double> get targetWeight =>
      $composableBuilder(column: $table.targetWeight, builder: (column) => column);

  GeneratedColumnWithTypeConverter<WeightUnit, int> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds =>
      $composableBuilder(column: $table.durationSeconds, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt =>
      $composableBuilder(column: $table.completedAt, builder: (column) => column);

  $$SessionExercisesTableAnnotationComposer get sessionExerciseId {
    final $$SessionExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionExerciseId,
      referencedTable: $db.sessionExercises,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$SessionExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.sessionExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SetLogsTableTableManager
    extends
        RootTableManager<
          _$NefaDatabase,
          $SetLogsTable,
          SetLog,
          $$SetLogsTableFilterComposer,
          $$SetLogsTableOrderingComposer,
          $$SetLogsTableAnnotationComposer,
          $$SetLogsTableCreateCompanionBuilder,
          $$SetLogsTableUpdateCompanionBuilder,
          (SetLog, $$SetLogsTableReferences),
          SetLog,
          PrefetchHooks Function({bool sessionExerciseId})
        > {
  $$SetLogsTableTableManager(_$NefaDatabase db, $SetLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$SetLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SetLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SetLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionExerciseId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<TargetKind> kind = const Value.absent(),
                Value<int?> targetRepsMin = const Value.absent(),
                Value<int?> targetRepsMax = const Value.absent(),
                Value<int?> targetDurationSeconds = const Value.absent(),
                Value<double?> targetWeight = const Value.absent(),
                Value<WeightUnit> unit = const Value.absent(),
                Value<int?> reps = const Value.absent(),
                Value<double?> weight = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
              }) => SetLogsCompanion(
                id: id,
                sessionExerciseId: sessionExerciseId,
                position: position,
                kind: kind,
                targetRepsMin: targetRepsMin,
                targetRepsMax: targetRepsMax,
                targetDurationSeconds: targetDurationSeconds,
                targetWeight: targetWeight,
                unit: unit,
                reps: reps,
                weight: weight,
                durationSeconds: durationSeconds,
                completedAt: completedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionExerciseId,
                required int position,
                required TargetKind kind,
                Value<int?> targetRepsMin = const Value.absent(),
                Value<int?> targetRepsMax = const Value.absent(),
                Value<int?> targetDurationSeconds = const Value.absent(),
                Value<double?> targetWeight = const Value.absent(),
                Value<WeightUnit> unit = const Value.absent(),
                Value<int?> reps = const Value.absent(),
                Value<double?> weight = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
              }) => SetLogsCompanion.insert(
                id: id,
                sessionExerciseId: sessionExerciseId,
                position: position,
                kind: kind,
                targetRepsMin: targetRepsMin,
                targetRepsMax: targetRepsMax,
                targetDurationSeconds: targetDurationSeconds,
                targetWeight: targetWeight,
                unit: unit,
                reps: reps,
                weight: weight,
                durationSeconds: durationSeconds,
                completedAt: completedAt,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), $$SetLogsTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({sessionExerciseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionExerciseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionExerciseId,
                                referencedTable: $$SetLogsTableReferences._sessionExerciseIdTable(
                                  db,
                                ),
                                referencedColumn: $$SetLogsTableReferences
                                    ._sessionExerciseIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SetLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$NefaDatabase,
      $SetLogsTable,
      SetLog,
      $$SetLogsTableFilterComposer,
      $$SetLogsTableOrderingComposer,
      $$SetLogsTableAnnotationComposer,
      $$SetLogsTableCreateCompanionBuilder,
      $$SetLogsTableUpdateCompanionBuilder,
      (SetLog, $$SetLogsTableReferences),
      SetLog,
      PrefetchHooks Function({bool sessionExerciseId})
    >;
typedef $$ActiveTimersTableCreateCompanionBuilder =
    ActiveTimersCompanion Function({
      Value<int> id,
      required int sessionId,
      required String payload,
    });
typedef $$ActiveTimersTableUpdateCompanionBuilder =
    ActiveTimersCompanion Function({Value<int> id, Value<int> sessionId, Value<String> payload});

class $$ActiveTimersTableFilterComposer extends Composer<_$NefaDatabase, $ActiveTimersTable> {
  $$ActiveTimersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => ColumnFilters(column));
}

class $$ActiveTimersTableOrderingComposer extends Composer<_$NefaDatabase, $ActiveTimersTable> {
  $$ActiveTimersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => ColumnOrderings(column));
}

class $$ActiveTimersTableAnnotationComposer extends Composer<_$NefaDatabase, $ActiveTimersTable> {
  $$ActiveTimersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);
}

class $$ActiveTimersTableTableManager
    extends
        RootTableManager<
          _$NefaDatabase,
          $ActiveTimersTable,
          ActiveTimer,
          $$ActiveTimersTableFilterComposer,
          $$ActiveTimersTableOrderingComposer,
          $$ActiveTimersTableAnnotationComposer,
          $$ActiveTimersTableCreateCompanionBuilder,
          $$ActiveTimersTableUpdateCompanionBuilder,
          (ActiveTimer, BaseReferences<_$NefaDatabase, $ActiveTimersTable, ActiveTimer>),
          ActiveTimer,
          PrefetchHooks Function()
        > {
  $$ActiveTimersTableTableManager(_$NefaDatabase db, $ActiveTimersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ActiveTimersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ActiveTimersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActiveTimersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<String> payload = const Value.absent(),
              }) => ActiveTimersCompanion(id: id, sessionId: sessionId, payload: payload),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required String payload,
              }) => ActiveTimersCompanion.insert(id: id, sessionId: sessionId, payload: payload),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ActiveTimersTableProcessedTableManager =
    ProcessedTableManager<
      _$NefaDatabase,
      $ActiveTimersTable,
      ActiveTimer,
      $$ActiveTimersTableFilterComposer,
      $$ActiveTimersTableOrderingComposer,
      $$ActiveTimersTableAnnotationComposer,
      $$ActiveTimersTableCreateCompanionBuilder,
      $$ActiveTimersTableUpdateCompanionBuilder,
      (ActiveTimer, BaseReferences<_$NefaDatabase, $ActiveTimersTable, ActiveTimer>),
      ActiveTimer,
      PrefetchHooks Function()
    >;
typedef $$PreferencesTableCreateCompanionBuilder =
    PreferencesCompanion Function({required String key, required String value, Value<int> rowid});
typedef $$PreferencesTableUpdateCompanionBuilder =
    PreferencesCompanion Function({Value<String> key, Value<String> value, Value<int> rowid});

class $$PreferencesTableFilterComposer extends Composer<_$NefaDatabase, $PreferencesTable> {
  $$PreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$PreferencesTableOrderingComposer extends Composer<_$NefaDatabase, $PreferencesTable> {
  $$PreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$PreferencesTableAnnotationComposer extends Composer<_$NefaDatabase, $PreferencesTable> {
  $$PreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$PreferencesTableTableManager
    extends
        RootTableManager<
          _$NefaDatabase,
          $PreferencesTable,
          Preference,
          $$PreferencesTableFilterComposer,
          $$PreferencesTableOrderingComposer,
          $$PreferencesTableAnnotationComposer,
          $$PreferencesTableCreateCompanionBuilder,
          $$PreferencesTableUpdateCompanionBuilder,
          (Preference, BaseReferences<_$NefaDatabase, $PreferencesTable, Preference>),
          Preference,
          PrefetchHooks Function()
        > {
  $$PreferencesTableTableManager(_$NefaDatabase db, $PreferencesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$PreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$PreferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PreferencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PreferencesCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => PreferencesCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$NefaDatabase,
      $PreferencesTable,
      Preference,
      $$PreferencesTableFilterComposer,
      $$PreferencesTableOrderingComposer,
      $$PreferencesTableAnnotationComposer,
      $$PreferencesTableCreateCompanionBuilder,
      $$PreferencesTableUpdateCompanionBuilder,
      (Preference, BaseReferences<_$NefaDatabase, $PreferencesTable, Preference>),
      Preference,
      PrefetchHooks Function()
    >;

class $NefaDatabaseManager {
  final _$NefaDatabase _db;
  $NefaDatabaseManager(this._db);
  $$CustomExercisesTableTableManager get customExercises =>
      $$CustomExercisesTableTableManager(_db, _db.customExercises);
  $$LearnedAliasesTableTableManager get learnedAliases =>
      $$LearnedAliasesTableTableManager(_db, _db.learnedAliases);
  $$RoutinesTableTableManager get routines => $$RoutinesTableTableManager(_db, _db.routines);
  $$RoutineDaysTableTableManager get routineDays =>
      $$RoutineDaysTableTableManager(_db, _db.routineDays);
  $$RoutineExercisesTableTableManager get routineExercises =>
      $$RoutineExercisesTableTableManager(_db, _db.routineExercises);
  $$RoutineSetsTableTableManager get routineSets =>
      $$RoutineSetsTableTableManager(_db, _db.routineSets);
  $$WorkoutSessionsTableTableManager get workoutSessions =>
      $$WorkoutSessionsTableTableManager(_db, _db.workoutSessions);
  $$SessionExercisesTableTableManager get sessionExercises =>
      $$SessionExercisesTableTableManager(_db, _db.sessionExercises);
  $$SetLogsTableTableManager get setLogs => $$SetLogsTableTableManager(_db, _db.setLogs);
  $$ActiveTimersTableTableManager get activeTimers =>
      $$ActiveTimersTableTableManager(_db, _db.activeTimers);
  $$PreferencesTableTableManager get preferences =>
      $$PreferencesTableTableManager(_db, _db.preferences);
}
