// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PersonsTable extends Persons with TableInfo<$PersonsTable, PersonRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersonsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
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
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    name,
    color,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'persons';
  @override
  VerificationContext validateIntegrity(
    Insertable<PersonRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PersonRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
    );
  }

  @override
  $PersonsTable createAlias(String alias) {
    return $PersonsTable(attachedDatabase, alias);
  }
}

class PersonRow extends DataClass implements Insertable<PersonRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String name;
  final int color;
  const PersonRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.name,
    required this.color,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['name'] = Variable<String>(name);
    map['color'] = Variable<int>(color);
    return map;
  }

  PersonsCompanion toCompanion(bool nullToAbsent) {
    return PersonsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      name: Value(name),
      color: Value(color),
    );
  }

  factory PersonRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<int>(json['color']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<int>(color),
    };
  }

  PersonRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? name,
    int? color,
  }) => PersonRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    name: name ?? this.name,
    color: color ?? this.color,
  );
  PersonRow copyWithCompanion(PersonsCompanion data) {
    return PersonRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, createdAt, updatedAt, deletedAt, name, color);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.name == this.name &&
          other.color == this.color);
}

class PersonsCompanion extends UpdateCompanion<PersonRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> name;
  final Value<int> color;
  final Value<int> rowid;
  const PersonsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PersonsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String name,
    required int color,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       name = Value(name),
       color = Value(color);
  static Insertable<PersonRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? name,
    Expression<int>? color,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PersonsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? name,
    Value<int>? color,
    Value<int>? rowid,
  }) {
    return PersonsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      name: name ?? this.name,
      color: color ?? this.color,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ItemsTable extends Items with TableInfo<$ItemsTable, ItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _personIdMeta = const VerificationMeta(
    'personId',
  );
  @override
  late final GeneratedColumn<String> personId = GeneratedColumn<String>(
    'person_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES persons (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _kategorieMeta = const VerificationMeta(
    'kategorie',
  );
  @override
  late final GeneratedColumn<String> kategorie = GeneratedColumn<String>(
    'kategorie',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _farbenMeta = const VerificationMeta('farben');
  @override
  late final GeneratedColumn<String> farben = GeneratedColumn<String>(
    'farben',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _musterMeta = const VerificationMeta('muster');
  @override
  late final GeneratedColumn<String> muster = GeneratedColumn<String>(
    'muster',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _materialOptikMeta = const VerificationMeta(
    'materialOptik',
  );
  @override
  late final GeneratedColumn<String> materialOptik = GeneratedColumn<String>(
    'material_optik',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _laengeSchnittMeta = const VerificationMeta(
    'laengeSchnitt',
  );
  @override
  late final GeneratedColumn<String> laengeSchnitt = GeneratedColumn<String>(
    'laenge_schnitt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _logoMarkeMeta = const VerificationMeta(
    'logoMarke',
  );
  @override
  late final GeneratedColumn<String> logoMarke = GeneratedColumn<String>(
    'logo_marke',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _aufdruckTextMeta = const VerificationMeta(
    'aufdruckText',
  );
  @override
  late final GeneratedColumn<String> aufdruckText = GeneratedColumn<String>(
    'aufdruck_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _besondereMerkmaleMeta = const VerificationMeta(
    'besondereMerkmale',
  );
  @override
  late final GeneratedColumn<String> besondereMerkmale =
      GeneratedColumn<String>(
        'besondere_merkmale',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _markierungMeta = const VerificationMeta(
    'markierung',
  );
  @override
  late final GeneratedColumn<String> markierung = GeneratedColumn<String>(
    'markierung',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _vlmRawMeta = const VerificationMeta('vlmRaw');
  @override
  late final GeneratedColumn<String> vlmRaw = GeneratedColumn<String>(
    'vlm_raw',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    personId,
    name,
    kategorie,
    farben,
    muster,
    materialOptik,
    laengeSchnitt,
    logoMarke,
    aufdruckText,
    besondereMerkmale,
    markierung,
    vlmRaw,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'items';
  @override
  VerificationContext validateIntegrity(
    Insertable<ItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('person_id')) {
      context.handle(
        _personIdMeta,
        personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta),
      );
    } else if (isInserting) {
      context.missing(_personIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('kategorie')) {
      context.handle(
        _kategorieMeta,
        kategorie.isAcceptableOrUnknown(data['kategorie']!, _kategorieMeta),
      );
    } else if (isInserting) {
      context.missing(_kategorieMeta);
    }
    if (data.containsKey('farben')) {
      context.handle(
        _farbenMeta,
        farben.isAcceptableOrUnknown(data['farben']!, _farbenMeta),
      );
    }
    if (data.containsKey('muster')) {
      context.handle(
        _musterMeta,
        muster.isAcceptableOrUnknown(data['muster']!, _musterMeta),
      );
    } else if (isInserting) {
      context.missing(_musterMeta);
    }
    if (data.containsKey('material_optik')) {
      context.handle(
        _materialOptikMeta,
        materialOptik.isAcceptableOrUnknown(
          data['material_optik']!,
          _materialOptikMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_materialOptikMeta);
    }
    if (data.containsKey('laenge_schnitt')) {
      context.handle(
        _laengeSchnittMeta,
        laengeSchnitt.isAcceptableOrUnknown(
          data['laenge_schnitt']!,
          _laengeSchnittMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_laengeSchnittMeta);
    }
    if (data.containsKey('logo_marke')) {
      context.handle(
        _logoMarkeMeta,
        logoMarke.isAcceptableOrUnknown(data['logo_marke']!, _logoMarkeMeta),
      );
    }
    if (data.containsKey('aufdruck_text')) {
      context.handle(
        _aufdruckTextMeta,
        aufdruckText.isAcceptableOrUnknown(
          data['aufdruck_text']!,
          _aufdruckTextMeta,
        ),
      );
    }
    if (data.containsKey('besondere_merkmale')) {
      context.handle(
        _besondereMerkmaleMeta,
        besondereMerkmale.isAcceptableOrUnknown(
          data['besondere_merkmale']!,
          _besondereMerkmaleMeta,
        ),
      );
    }
    if (data.containsKey('markierung')) {
      context.handle(
        _markierungMeta,
        markierung.isAcceptableOrUnknown(data['markierung']!, _markierungMeta),
      );
    }
    if (data.containsKey('vlm_raw')) {
      context.handle(
        _vlmRawMeta,
        vlmRaw.isAcceptableOrUnknown(data['vlm_raw']!, _vlmRawMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      personId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}person_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kategorie: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kategorie'],
      )!,
      farben: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farben'],
      )!,
      muster: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}muster'],
      )!,
      materialOptik: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}material_optik'],
      )!,
      laengeSchnitt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}laenge_schnitt'],
      )!,
      logoMarke: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}logo_marke'],
      )!,
      aufdruckText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}aufdruck_text'],
      )!,
      besondereMerkmale: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}besondere_merkmale'],
      )!,
      markierung: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}markierung'],
      )!,
      vlmRaw: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vlm_raw'],
      )!,
    );
  }

  @override
  $ItemsTable createAlias(String alias) {
    return $ItemsTable(attachedDatabase, alias);
  }
}

class ItemRow extends DataClass implements Insertable<ItemRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String personId;
  final String name;
  final String kategorie;
  final String farben;
  final String muster;
  final String materialOptik;
  final String laengeSchnitt;
  final String logoMarke;
  final String aufdruckText;
  final String besondereMerkmale;
  final String markierung;
  final String vlmRaw;
  const ItemRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.personId,
    required this.name,
    required this.kategorie,
    required this.farben,
    required this.muster,
    required this.materialOptik,
    required this.laengeSchnitt,
    required this.logoMarke,
    required this.aufdruckText,
    required this.besondereMerkmale,
    required this.markierung,
    required this.vlmRaw,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['person_id'] = Variable<String>(personId);
    map['name'] = Variable<String>(name);
    map['kategorie'] = Variable<String>(kategorie);
    map['farben'] = Variable<String>(farben);
    map['muster'] = Variable<String>(muster);
    map['material_optik'] = Variable<String>(materialOptik);
    map['laenge_schnitt'] = Variable<String>(laengeSchnitt);
    map['logo_marke'] = Variable<String>(logoMarke);
    map['aufdruck_text'] = Variable<String>(aufdruckText);
    map['besondere_merkmale'] = Variable<String>(besondereMerkmale);
    map['markierung'] = Variable<String>(markierung);
    map['vlm_raw'] = Variable<String>(vlmRaw);
    return map;
  }

  ItemsCompanion toCompanion(bool nullToAbsent) {
    return ItemsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      personId: Value(personId),
      name: Value(name),
      kategorie: Value(kategorie),
      farben: Value(farben),
      muster: Value(muster),
      materialOptik: Value(materialOptik),
      laengeSchnitt: Value(laengeSchnitt),
      logoMarke: Value(logoMarke),
      aufdruckText: Value(aufdruckText),
      besondereMerkmale: Value(besondereMerkmale),
      markierung: Value(markierung),
      vlmRaw: Value(vlmRaw),
    );
  }

  factory ItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      personId: serializer.fromJson<String>(json['personId']),
      name: serializer.fromJson<String>(json['name']),
      kategorie: serializer.fromJson<String>(json['kategorie']),
      farben: serializer.fromJson<String>(json['farben']),
      muster: serializer.fromJson<String>(json['muster']),
      materialOptik: serializer.fromJson<String>(json['materialOptik']),
      laengeSchnitt: serializer.fromJson<String>(json['laengeSchnitt']),
      logoMarke: serializer.fromJson<String>(json['logoMarke']),
      aufdruckText: serializer.fromJson<String>(json['aufdruckText']),
      besondereMerkmale: serializer.fromJson<String>(json['besondereMerkmale']),
      markierung: serializer.fromJson<String>(json['markierung']),
      vlmRaw: serializer.fromJson<String>(json['vlmRaw']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'personId': serializer.toJson<String>(personId),
      'name': serializer.toJson<String>(name),
      'kategorie': serializer.toJson<String>(kategorie),
      'farben': serializer.toJson<String>(farben),
      'muster': serializer.toJson<String>(muster),
      'materialOptik': serializer.toJson<String>(materialOptik),
      'laengeSchnitt': serializer.toJson<String>(laengeSchnitt),
      'logoMarke': serializer.toJson<String>(logoMarke),
      'aufdruckText': serializer.toJson<String>(aufdruckText),
      'besondereMerkmale': serializer.toJson<String>(besondereMerkmale),
      'markierung': serializer.toJson<String>(markierung),
      'vlmRaw': serializer.toJson<String>(vlmRaw),
    };
  }

  ItemRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? personId,
    String? name,
    String? kategorie,
    String? farben,
    String? muster,
    String? materialOptik,
    String? laengeSchnitt,
    String? logoMarke,
    String? aufdruckText,
    String? besondereMerkmale,
    String? markierung,
    String? vlmRaw,
  }) => ItemRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    personId: personId ?? this.personId,
    name: name ?? this.name,
    kategorie: kategorie ?? this.kategorie,
    farben: farben ?? this.farben,
    muster: muster ?? this.muster,
    materialOptik: materialOptik ?? this.materialOptik,
    laengeSchnitt: laengeSchnitt ?? this.laengeSchnitt,
    logoMarke: logoMarke ?? this.logoMarke,
    aufdruckText: aufdruckText ?? this.aufdruckText,
    besondereMerkmale: besondereMerkmale ?? this.besondereMerkmale,
    markierung: markierung ?? this.markierung,
    vlmRaw: vlmRaw ?? this.vlmRaw,
  );
  ItemRow copyWithCompanion(ItemsCompanion data) {
    return ItemRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      personId: data.personId.present ? data.personId.value : this.personId,
      name: data.name.present ? data.name.value : this.name,
      kategorie: data.kategorie.present ? data.kategorie.value : this.kategorie,
      farben: data.farben.present ? data.farben.value : this.farben,
      muster: data.muster.present ? data.muster.value : this.muster,
      materialOptik: data.materialOptik.present
          ? data.materialOptik.value
          : this.materialOptik,
      laengeSchnitt: data.laengeSchnitt.present
          ? data.laengeSchnitt.value
          : this.laengeSchnitt,
      logoMarke: data.logoMarke.present ? data.logoMarke.value : this.logoMarke,
      aufdruckText: data.aufdruckText.present
          ? data.aufdruckText.value
          : this.aufdruckText,
      besondereMerkmale: data.besondereMerkmale.present
          ? data.besondereMerkmale.value
          : this.besondereMerkmale,
      markierung: data.markierung.present
          ? data.markierung.value
          : this.markierung,
      vlmRaw: data.vlmRaw.present ? data.vlmRaw.value : this.vlmRaw,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItemRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('personId: $personId, ')
          ..write('name: $name, ')
          ..write('kategorie: $kategorie, ')
          ..write('farben: $farben, ')
          ..write('muster: $muster, ')
          ..write('materialOptik: $materialOptik, ')
          ..write('laengeSchnitt: $laengeSchnitt, ')
          ..write('logoMarke: $logoMarke, ')
          ..write('aufdruckText: $aufdruckText, ')
          ..write('besondereMerkmale: $besondereMerkmale, ')
          ..write('markierung: $markierung, ')
          ..write('vlmRaw: $vlmRaw')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    personId,
    name,
    kategorie,
    farben,
    muster,
    materialOptik,
    laengeSchnitt,
    logoMarke,
    aufdruckText,
    besondereMerkmale,
    markierung,
    vlmRaw,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.personId == this.personId &&
          other.name == this.name &&
          other.kategorie == this.kategorie &&
          other.farben == this.farben &&
          other.muster == this.muster &&
          other.materialOptik == this.materialOptik &&
          other.laengeSchnitt == this.laengeSchnitt &&
          other.logoMarke == this.logoMarke &&
          other.aufdruckText == this.aufdruckText &&
          other.besondereMerkmale == this.besondereMerkmale &&
          other.markierung == this.markierung &&
          other.vlmRaw == this.vlmRaw);
}

class ItemsCompanion extends UpdateCompanion<ItemRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> personId;
  final Value<String> name;
  final Value<String> kategorie;
  final Value<String> farben;
  final Value<String> muster;
  final Value<String> materialOptik;
  final Value<String> laengeSchnitt;
  final Value<String> logoMarke;
  final Value<String> aufdruckText;
  final Value<String> besondereMerkmale;
  final Value<String> markierung;
  final Value<String> vlmRaw;
  final Value<int> rowid;
  const ItemsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.personId = const Value.absent(),
    this.name = const Value.absent(),
    this.kategorie = const Value.absent(),
    this.farben = const Value.absent(),
    this.muster = const Value.absent(),
    this.materialOptik = const Value.absent(),
    this.laengeSchnitt = const Value.absent(),
    this.logoMarke = const Value.absent(),
    this.aufdruckText = const Value.absent(),
    this.besondereMerkmale = const Value.absent(),
    this.markierung = const Value.absent(),
    this.vlmRaw = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String personId,
    this.name = const Value.absent(),
    required String kategorie,
    this.farben = const Value.absent(),
    required String muster,
    required String materialOptik,
    required String laengeSchnitt,
    this.logoMarke = const Value.absent(),
    this.aufdruckText = const Value.absent(),
    this.besondereMerkmale = const Value.absent(),
    this.markierung = const Value.absent(),
    this.vlmRaw = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       personId = Value(personId),
       kategorie = Value(kategorie),
       muster = Value(muster),
       materialOptik = Value(materialOptik),
       laengeSchnitt = Value(laengeSchnitt);
  static Insertable<ItemRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? personId,
    Expression<String>? name,
    Expression<String>? kategorie,
    Expression<String>? farben,
    Expression<String>? muster,
    Expression<String>? materialOptik,
    Expression<String>? laengeSchnitt,
    Expression<String>? logoMarke,
    Expression<String>? aufdruckText,
    Expression<String>? besondereMerkmale,
    Expression<String>? markierung,
    Expression<String>? vlmRaw,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (personId != null) 'person_id': personId,
      if (name != null) 'name': name,
      if (kategorie != null) 'kategorie': kategorie,
      if (farben != null) 'farben': farben,
      if (muster != null) 'muster': muster,
      if (materialOptik != null) 'material_optik': materialOptik,
      if (laengeSchnitt != null) 'laenge_schnitt': laengeSchnitt,
      if (logoMarke != null) 'logo_marke': logoMarke,
      if (aufdruckText != null) 'aufdruck_text': aufdruckText,
      if (besondereMerkmale != null) 'besondere_merkmale': besondereMerkmale,
      if (markierung != null) 'markierung': markierung,
      if (vlmRaw != null) 'vlm_raw': vlmRaw,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? personId,
    Value<String>? name,
    Value<String>? kategorie,
    Value<String>? farben,
    Value<String>? muster,
    Value<String>? materialOptik,
    Value<String>? laengeSchnitt,
    Value<String>? logoMarke,
    Value<String>? aufdruckText,
    Value<String>? besondereMerkmale,
    Value<String>? markierung,
    Value<String>? vlmRaw,
    Value<int>? rowid,
  }) {
    return ItemsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      personId: personId ?? this.personId,
      name: name ?? this.name,
      kategorie: kategorie ?? this.kategorie,
      farben: farben ?? this.farben,
      muster: muster ?? this.muster,
      materialOptik: materialOptik ?? this.materialOptik,
      laengeSchnitt: laengeSchnitt ?? this.laengeSchnitt,
      logoMarke: logoMarke ?? this.logoMarke,
      aufdruckText: aufdruckText ?? this.aufdruckText,
      besondereMerkmale: besondereMerkmale ?? this.besondereMerkmale,
      markierung: markierung ?? this.markierung,
      vlmRaw: vlmRaw ?? this.vlmRaw,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (personId.present) {
      map['person_id'] = Variable<String>(personId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kategorie.present) {
      map['kategorie'] = Variable<String>(kategorie.value);
    }
    if (farben.present) {
      map['farben'] = Variable<String>(farben.value);
    }
    if (muster.present) {
      map['muster'] = Variable<String>(muster.value);
    }
    if (materialOptik.present) {
      map['material_optik'] = Variable<String>(materialOptik.value);
    }
    if (laengeSchnitt.present) {
      map['laenge_schnitt'] = Variable<String>(laengeSchnitt.value);
    }
    if (logoMarke.present) {
      map['logo_marke'] = Variable<String>(logoMarke.value);
    }
    if (aufdruckText.present) {
      map['aufdruck_text'] = Variable<String>(aufdruckText.value);
    }
    if (besondereMerkmale.present) {
      map['besondere_merkmale'] = Variable<String>(besondereMerkmale.value);
    }
    if (markierung.present) {
      map['markierung'] = Variable<String>(markierung.value);
    }
    if (vlmRaw.present) {
      map['vlm_raw'] = Variable<String>(vlmRaw.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('personId: $personId, ')
          ..write('name: $name, ')
          ..write('kategorie: $kategorie, ')
          ..write('farben: $farben, ')
          ..write('muster: $muster, ')
          ..write('materialOptik: $materialOptik, ')
          ..write('laengeSchnitt: $laengeSchnitt, ')
          ..write('logoMarke: $logoMarke, ')
          ..write('aufdruckText: $aufdruckText, ')
          ..write('besondereMerkmale: $besondereMerkmale, ')
          ..write('markierung: $markierung, ')
          ..write('vlmRaw: $vlmRaw, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ItemPhotosTable extends ItemPhotos
    with TableInfo<$ItemPhotosTable, PhotoRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemPhotosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES items (id)',
    ),
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artMeta = const VerificationMeta('art');
  @override
  late final GeneratedColumn<String> art = GeneratedColumn<String>(
    'art',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    itemId,
    fileName,
    art,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'item_photos';
  @override
  VerificationContext validateIntegrity(
    Insertable<PhotoRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('art')) {
      context.handle(
        _artMeta,
        art.isAcceptableOrUnknown(data['art']!, _artMeta),
      );
    } else if (isInserting) {
      context.missing(_artMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PhotoRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PhotoRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      art: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}art'],
      )!,
    );
  }

  @override
  $ItemPhotosTable createAlias(String alias) {
    return $ItemPhotosTable(attachedDatabase, alias);
  }
}

class PhotoRow extends DataClass implements Insertable<PhotoRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String itemId;

  /// Dateiname im Foto-Verzeichnis (relativ, da sich der App-Pfad ändern kann).
  final String fileName;

  /// vorne / hinten / detail / etikett / scan
  final String art;
  const PhotoRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.itemId,
    required this.fileName,
    required this.art,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['item_id'] = Variable<String>(itemId);
    map['file_name'] = Variable<String>(fileName);
    map['art'] = Variable<String>(art);
    return map;
  }

  ItemPhotosCompanion toCompanion(bool nullToAbsent) {
    return ItemPhotosCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      itemId: Value(itemId),
      fileName: Value(fileName),
      art: Value(art),
    );
  }

  factory PhotoRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PhotoRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      itemId: serializer.fromJson<String>(json['itemId']),
      fileName: serializer.fromJson<String>(json['fileName']),
      art: serializer.fromJson<String>(json['art']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'itemId': serializer.toJson<String>(itemId),
      'fileName': serializer.toJson<String>(fileName),
      'art': serializer.toJson<String>(art),
    };
  }

  PhotoRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? itemId,
    String? fileName,
    String? art,
  }) => PhotoRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    itemId: itemId ?? this.itemId,
    fileName: fileName ?? this.fileName,
    art: art ?? this.art,
  );
  PhotoRow copyWithCompanion(ItemPhotosCompanion data) {
    return PhotoRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      art: data.art.present ? data.art.value : this.art,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PhotoRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('itemId: $itemId, ')
          ..write('fileName: $fileName, ')
          ..write('art: $art')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, createdAt, updatedAt, deletedAt, itemId, fileName, art);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PhotoRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.itemId == this.itemId &&
          other.fileName == this.fileName &&
          other.art == this.art);
}

class ItemPhotosCompanion extends UpdateCompanion<PhotoRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> itemId;
  final Value<String> fileName;
  final Value<String> art;
  final Value<int> rowid;
  const ItemPhotosCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.itemId = const Value.absent(),
    this.fileName = const Value.absent(),
    this.art = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemPhotosCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String itemId,
    required String fileName,
    required String art,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       itemId = Value(itemId),
       fileName = Value(fileName),
       art = Value(art);
  static Insertable<PhotoRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? itemId,
    Expression<String>? fileName,
    Expression<String>? art,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (itemId != null) 'item_id': itemId,
      if (fileName != null) 'file_name': fileName,
      if (art != null) 'art': art,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemPhotosCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? itemId,
    Value<String>? fileName,
    Value<String>? art,
    Value<int>? rowid,
  }) {
    return ItemPhotosCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      itemId: itemId ?? this.itemId,
      fileName: fileName ?? this.fileName,
      art: art ?? this.art,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (art.present) {
      map['art'] = Variable<String>(art.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemPhotosCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('itemId: $itemId, ')
          ..write('fileName: $fileName, ')
          ..write('art: $art, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PhotoEmbeddingsTable extends PhotoEmbeddings
    with TableInfo<$PhotoEmbeddingsTable, EmbeddingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhotoEmbeddingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _photoIdMeta = const VerificationMeta(
    'photoId',
  );
  @override
  late final GeneratedColumn<String> photoId = GeneratedColumn<String>(
    'photo_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES item_photos (id)',
    ),
  );
  static const VerificationMeta _modelIdMeta = const VerificationMeta(
    'modelId',
  );
  @override
  late final GeneratedColumn<String> modelId = GeneratedColumn<String>(
    'model_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _variantMeta = const VerificationMeta(
    'variant',
  );
  @override
  late final GeneratedColumn<int> variant = GeneratedColumn<int>(
    'variant',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vectorMeta = const VerificationMeta('vector');
  @override
  late final GeneratedColumn<Uint8List> vector = GeneratedColumn<Uint8List>(
    'vector',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [photoId, modelId, variant, vector];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'photo_embeddings';
  @override
  VerificationContext validateIntegrity(
    Insertable<EmbeddingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('photo_id')) {
      context.handle(
        _photoIdMeta,
        photoId.isAcceptableOrUnknown(data['photo_id']!, _photoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_photoIdMeta);
    }
    if (data.containsKey('model_id')) {
      context.handle(
        _modelIdMeta,
        modelId.isAcceptableOrUnknown(data['model_id']!, _modelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_modelIdMeta);
    }
    if (data.containsKey('variant')) {
      context.handle(
        _variantMeta,
        variant.isAcceptableOrUnknown(data['variant']!, _variantMeta),
      );
    } else if (isInserting) {
      context.missing(_variantMeta);
    }
    if (data.containsKey('vector')) {
      context.handle(
        _vectorMeta,
        vector.isAcceptableOrUnknown(data['vector']!, _vectorMeta),
      );
    } else if (isInserting) {
      context.missing(_vectorMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {photoId, modelId, variant};
  @override
  EmbeddingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EmbeddingRow(
      photoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_id'],
      )!,
      modelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_id'],
      )!,
      variant: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}variant'],
      )!,
      vector: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}vector'],
      )!,
    );
  }

  @override
  $PhotoEmbeddingsTable createAlias(String alias) {
    return $PhotoEmbeddingsTable(attachedDatabase, alias);
  }
}

class EmbeddingRow extends DataClass implements Insertable<EmbeddingRow> {
  final String photoId;
  final String modelId;
  final int variant;
  final Uint8List vector;
  const EmbeddingRow({
    required this.photoId,
    required this.modelId,
    required this.variant,
    required this.vector,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['photo_id'] = Variable<String>(photoId);
    map['model_id'] = Variable<String>(modelId);
    map['variant'] = Variable<int>(variant);
    map['vector'] = Variable<Uint8List>(vector);
    return map;
  }

  PhotoEmbeddingsCompanion toCompanion(bool nullToAbsent) {
    return PhotoEmbeddingsCompanion(
      photoId: Value(photoId),
      modelId: Value(modelId),
      variant: Value(variant),
      vector: Value(vector),
    );
  }

  factory EmbeddingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EmbeddingRow(
      photoId: serializer.fromJson<String>(json['photoId']),
      modelId: serializer.fromJson<String>(json['modelId']),
      variant: serializer.fromJson<int>(json['variant']),
      vector: serializer.fromJson<Uint8List>(json['vector']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'photoId': serializer.toJson<String>(photoId),
      'modelId': serializer.toJson<String>(modelId),
      'variant': serializer.toJson<int>(variant),
      'vector': serializer.toJson<Uint8List>(vector),
    };
  }

  EmbeddingRow copyWith({
    String? photoId,
    String? modelId,
    int? variant,
    Uint8List? vector,
  }) => EmbeddingRow(
    photoId: photoId ?? this.photoId,
    modelId: modelId ?? this.modelId,
    variant: variant ?? this.variant,
    vector: vector ?? this.vector,
  );
  EmbeddingRow copyWithCompanion(PhotoEmbeddingsCompanion data) {
    return EmbeddingRow(
      photoId: data.photoId.present ? data.photoId.value : this.photoId,
      modelId: data.modelId.present ? data.modelId.value : this.modelId,
      variant: data.variant.present ? data.variant.value : this.variant,
      vector: data.vector.present ? data.vector.value : this.vector,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EmbeddingRow(')
          ..write('photoId: $photoId, ')
          ..write('modelId: $modelId, ')
          ..write('variant: $variant, ')
          ..write('vector: $vector')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(photoId, modelId, variant, $driftBlobEquality.hash(vector));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EmbeddingRow &&
          other.photoId == this.photoId &&
          other.modelId == this.modelId &&
          other.variant == this.variant &&
          $driftBlobEquality.equals(other.vector, this.vector));
}

class PhotoEmbeddingsCompanion extends UpdateCompanion<EmbeddingRow> {
  final Value<String> photoId;
  final Value<String> modelId;
  final Value<int> variant;
  final Value<Uint8List> vector;
  final Value<int> rowid;
  const PhotoEmbeddingsCompanion({
    this.photoId = const Value.absent(),
    this.modelId = const Value.absent(),
    this.variant = const Value.absent(),
    this.vector = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PhotoEmbeddingsCompanion.insert({
    required String photoId,
    required String modelId,
    required int variant,
    required Uint8List vector,
    this.rowid = const Value.absent(),
  }) : photoId = Value(photoId),
       modelId = Value(modelId),
       variant = Value(variant),
       vector = Value(vector);
  static Insertable<EmbeddingRow> custom({
    Expression<String>? photoId,
    Expression<String>? modelId,
    Expression<int>? variant,
    Expression<Uint8List>? vector,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (photoId != null) 'photo_id': photoId,
      if (modelId != null) 'model_id': modelId,
      if (variant != null) 'variant': variant,
      if (vector != null) 'vector': vector,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PhotoEmbeddingsCompanion copyWith({
    Value<String>? photoId,
    Value<String>? modelId,
    Value<int>? variant,
    Value<Uint8List>? vector,
    Value<int>? rowid,
  }) {
    return PhotoEmbeddingsCompanion(
      photoId: photoId ?? this.photoId,
      modelId: modelId ?? this.modelId,
      variant: variant ?? this.variant,
      vector: vector ?? this.vector,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (photoId.present) {
      map['photo_id'] = Variable<String>(photoId.value);
    }
    if (modelId.present) {
      map['model_id'] = Variable<String>(modelId.value);
    }
    if (variant.present) {
      map['variant'] = Variable<int>(variant.value);
    }
    if (vector.present) {
      map['vector'] = Variable<Uint8List>(vector.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PhotoEmbeddingsCompanion(')
          ..write('photoId: $photoId, ')
          ..write('modelId: $modelId, ')
          ..write('variant: $variant, ')
          ..write('vector: $vector, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScanLogsTable extends ScanLogs
    with TableInfo<$ScanLogsTable, ScanLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScanLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<DateTime> time = GeneratedColumn<DateTime>(
    'time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stageMeta = const VerificationMeta('stage');
  @override
  late final GeneratedColumn<String> stage = GeneratedColumn<String>(
    'stage',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roundsMeta = const VerificationMeta('rounds');
  @override
  late final GeneratedColumn<int> rounds = GeneratedColumn<int>(
    'rounds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _confirmedMeta = const VerificationMeta(
    'confirmed',
  );
  @override
  late final GeneratedColumn<bool> confirmed = GeneratedColumn<bool>(
    'confirmed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("confirmed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _deviceMeta = const VerificationMeta('device');
  @override
  late final GeneratedColumn<String> device = GeneratedColumn<String>(
    'device',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _backendMeta = const VerificationMeta(
    'backend',
  );
  @override
  late final GeneratedColumn<String> backend = GeneratedColumn<String>(
    'backend',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _detailMeta = const VerificationMeta('detail');
  @override
  late final GeneratedColumn<String> detail = GeneratedColumn<String>(
    'detail',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    time,
    itemId,
    stage,
    rounds,
    durationMs,
    confirmed,
    device,
    backend,
    detail,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scan_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScanLogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('time')) {
      context.handle(
        _timeMeta,
        time.isAcceptableOrUnknown(data['time']!, _timeMeta),
      );
    } else if (isInserting) {
      context.missing(_timeMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    }
    if (data.containsKey('stage')) {
      context.handle(
        _stageMeta,
        stage.isAcceptableOrUnknown(data['stage']!, _stageMeta),
      );
    } else if (isInserting) {
      context.missing(_stageMeta);
    }
    if (data.containsKey('rounds')) {
      context.handle(
        _roundsMeta,
        rounds.isAcceptableOrUnknown(data['rounds']!, _roundsMeta),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMsMeta);
    }
    if (data.containsKey('confirmed')) {
      context.handle(
        _confirmedMeta,
        confirmed.isAcceptableOrUnknown(data['confirmed']!, _confirmedMeta),
      );
    }
    if (data.containsKey('device')) {
      context.handle(
        _deviceMeta,
        device.isAcceptableOrUnknown(data['device']!, _deviceMeta),
      );
    }
    if (data.containsKey('backend')) {
      context.handle(
        _backendMeta,
        backend.isAcceptableOrUnknown(data['backend']!, _backendMeta),
      );
    }
    if (data.containsKey('detail')) {
      context.handle(
        _detailMeta,
        detail.isAcceptableOrUnknown(data['detail']!, _detailMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScanLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScanLogRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      time: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}time'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      ),
      stage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stage'],
      )!,
      rounds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rounds'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      confirmed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}confirmed'],
      )!,
      device: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device'],
      )!,
      backend: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}backend'],
      )!,
      detail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detail'],
      )!,
    );
  }

  @override
  $ScanLogsTable createAlias(String alias) {
    return $ScanLogsTable(attachedDatabase, alias);
  }
}

class ScanLogRow extends DataClass implements Insertable<ScanLogRow> {
  final int id;
  final DateTime time;
  final String? itemId;
  final String stage;
  final int rounds;
  final int durationMs;
  final bool confirmed;
  final String device;
  final String backend;
  final String detail;
  const ScanLogRow({
    required this.id,
    required this.time,
    this.itemId,
    required this.stage,
    required this.rounds,
    required this.durationMs,
    required this.confirmed,
    required this.device,
    required this.backend,
    required this.detail,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['time'] = Variable<DateTime>(time);
    if (!nullToAbsent || itemId != null) {
      map['item_id'] = Variable<String>(itemId);
    }
    map['stage'] = Variable<String>(stage);
    map['rounds'] = Variable<int>(rounds);
    map['duration_ms'] = Variable<int>(durationMs);
    map['confirmed'] = Variable<bool>(confirmed);
    map['device'] = Variable<String>(device);
    map['backend'] = Variable<String>(backend);
    map['detail'] = Variable<String>(detail);
    return map;
  }

  ScanLogsCompanion toCompanion(bool nullToAbsent) {
    return ScanLogsCompanion(
      id: Value(id),
      time: Value(time),
      itemId: itemId == null && nullToAbsent
          ? const Value.absent()
          : Value(itemId),
      stage: Value(stage),
      rounds: Value(rounds),
      durationMs: Value(durationMs),
      confirmed: Value(confirmed),
      device: Value(device),
      backend: Value(backend),
      detail: Value(detail),
    );
  }

  factory ScanLogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScanLogRow(
      id: serializer.fromJson<int>(json['id']),
      time: serializer.fromJson<DateTime>(json['time']),
      itemId: serializer.fromJson<String?>(json['itemId']),
      stage: serializer.fromJson<String>(json['stage']),
      rounds: serializer.fromJson<int>(json['rounds']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      confirmed: serializer.fromJson<bool>(json['confirmed']),
      device: serializer.fromJson<String>(json['device']),
      backend: serializer.fromJson<String>(json['backend']),
      detail: serializer.fromJson<String>(json['detail']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'time': serializer.toJson<DateTime>(time),
      'itemId': serializer.toJson<String?>(itemId),
      'stage': serializer.toJson<String>(stage),
      'rounds': serializer.toJson<int>(rounds),
      'durationMs': serializer.toJson<int>(durationMs),
      'confirmed': serializer.toJson<bool>(confirmed),
      'device': serializer.toJson<String>(device),
      'backend': serializer.toJson<String>(backend),
      'detail': serializer.toJson<String>(detail),
    };
  }

  ScanLogRow copyWith({
    int? id,
    DateTime? time,
    Value<String?> itemId = const Value.absent(),
    String? stage,
    int? rounds,
    int? durationMs,
    bool? confirmed,
    String? device,
    String? backend,
    String? detail,
  }) => ScanLogRow(
    id: id ?? this.id,
    time: time ?? this.time,
    itemId: itemId.present ? itemId.value : this.itemId,
    stage: stage ?? this.stage,
    rounds: rounds ?? this.rounds,
    durationMs: durationMs ?? this.durationMs,
    confirmed: confirmed ?? this.confirmed,
    device: device ?? this.device,
    backend: backend ?? this.backend,
    detail: detail ?? this.detail,
  );
  ScanLogRow copyWithCompanion(ScanLogsCompanion data) {
    return ScanLogRow(
      id: data.id.present ? data.id.value : this.id,
      time: data.time.present ? data.time.value : this.time,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      stage: data.stage.present ? data.stage.value : this.stage,
      rounds: data.rounds.present ? data.rounds.value : this.rounds,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      confirmed: data.confirmed.present ? data.confirmed.value : this.confirmed,
      device: data.device.present ? data.device.value : this.device,
      backend: data.backend.present ? data.backend.value : this.backend,
      detail: data.detail.present ? data.detail.value : this.detail,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScanLogRow(')
          ..write('id: $id, ')
          ..write('time: $time, ')
          ..write('itemId: $itemId, ')
          ..write('stage: $stage, ')
          ..write('rounds: $rounds, ')
          ..write('durationMs: $durationMs, ')
          ..write('confirmed: $confirmed, ')
          ..write('device: $device, ')
          ..write('backend: $backend, ')
          ..write('detail: $detail')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    time,
    itemId,
    stage,
    rounds,
    durationMs,
    confirmed,
    device,
    backend,
    detail,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScanLogRow &&
          other.id == this.id &&
          other.time == this.time &&
          other.itemId == this.itemId &&
          other.stage == this.stage &&
          other.rounds == this.rounds &&
          other.durationMs == this.durationMs &&
          other.confirmed == this.confirmed &&
          other.device == this.device &&
          other.backend == this.backend &&
          other.detail == this.detail);
}

class ScanLogsCompanion extends UpdateCompanion<ScanLogRow> {
  final Value<int> id;
  final Value<DateTime> time;
  final Value<String?> itemId;
  final Value<String> stage;
  final Value<int> rounds;
  final Value<int> durationMs;
  final Value<bool> confirmed;
  final Value<String> device;
  final Value<String> backend;
  final Value<String> detail;
  const ScanLogsCompanion({
    this.id = const Value.absent(),
    this.time = const Value.absent(),
    this.itemId = const Value.absent(),
    this.stage = const Value.absent(),
    this.rounds = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.confirmed = const Value.absent(),
    this.device = const Value.absent(),
    this.backend = const Value.absent(),
    this.detail = const Value.absent(),
  });
  ScanLogsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime time,
    this.itemId = const Value.absent(),
    required String stage,
    this.rounds = const Value.absent(),
    required int durationMs,
    this.confirmed = const Value.absent(),
    this.device = const Value.absent(),
    this.backend = const Value.absent(),
    this.detail = const Value.absent(),
  }) : time = Value(time),
       stage = Value(stage),
       durationMs = Value(durationMs);
  static Insertable<ScanLogRow> custom({
    Expression<int>? id,
    Expression<DateTime>? time,
    Expression<String>? itemId,
    Expression<String>? stage,
    Expression<int>? rounds,
    Expression<int>? durationMs,
    Expression<bool>? confirmed,
    Expression<String>? device,
    Expression<String>? backend,
    Expression<String>? detail,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (time != null) 'time': time,
      if (itemId != null) 'item_id': itemId,
      if (stage != null) 'stage': stage,
      if (rounds != null) 'rounds': rounds,
      if (durationMs != null) 'duration_ms': durationMs,
      if (confirmed != null) 'confirmed': confirmed,
      if (device != null) 'device': device,
      if (backend != null) 'backend': backend,
      if (detail != null) 'detail': detail,
    });
  }

  ScanLogsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? time,
    Value<String?>? itemId,
    Value<String>? stage,
    Value<int>? rounds,
    Value<int>? durationMs,
    Value<bool>? confirmed,
    Value<String>? device,
    Value<String>? backend,
    Value<String>? detail,
  }) {
    return ScanLogsCompanion(
      id: id ?? this.id,
      time: time ?? this.time,
      itemId: itemId ?? this.itemId,
      stage: stage ?? this.stage,
      rounds: rounds ?? this.rounds,
      durationMs: durationMs ?? this.durationMs,
      confirmed: confirmed ?? this.confirmed,
      device: device ?? this.device,
      backend: backend ?? this.backend,
      detail: detail ?? this.detail,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (time.present) {
      map['time'] = Variable<DateTime>(time.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (stage.present) {
      map['stage'] = Variable<String>(stage.value);
    }
    if (rounds.present) {
      map['rounds'] = Variable<int>(rounds.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (confirmed.present) {
      map['confirmed'] = Variable<bool>(confirmed.value);
    }
    if (device.present) {
      map['device'] = Variable<String>(device.value);
    }
    if (backend.present) {
      map['backend'] = Variable<String>(backend.value);
    }
    if (detail.present) {
      map['detail'] = Variable<String>(detail.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScanLogsCompanion(')
          ..write('id: $id, ')
          ..write('time: $time, ')
          ..write('itemId: $itemId, ')
          ..write('stage: $stage, ')
          ..write('rounds: $rounds, ')
          ..write('durationMs: $durationMs, ')
          ..write('confirmed: $confirmed, ')
          ..write('device: $device, ')
          ..write('backend: $backend, ')
          ..write('detail: $detail')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, SettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class SettingRow extends DataClass implements Insertable<SettingRow> {
  final String key;
  final String value;
  const SettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory SettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingRow(
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

  SettingRow copyWith({String? key, String? value}) =>
      SettingRow(key: key ?? this.key, value: value ?? this.value);
  SettingRow copyWithCompanion(AppSettingsCompanion data) {
    return SettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingRow(')
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
      (other is SettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<SettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SettingRow> custom({
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

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
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
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PersonsTable persons = $PersonsTable(this);
  late final $ItemsTable items = $ItemsTable(this);
  late final $ItemPhotosTable itemPhotos = $ItemPhotosTable(this);
  late final $PhotoEmbeddingsTable photoEmbeddings = $PhotoEmbeddingsTable(
    this,
  );
  late final $ScanLogsTable scanLogs = $ScanLogsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    persons,
    items,
    itemPhotos,
    photoEmbeddings,
    scanLogs,
    appSettings,
  ];
}

typedef $$PersonsTableCreateCompanionBuilder = PersonsCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  required String name,
  required int color,
  Value<int> rowid,
});
typedef $$PersonsTableUpdateCompanionBuilder = PersonsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> name,
  Value<int> color,
  Value<int> rowid,
});

final class $$PersonsTableReferences
    extends BaseReferences<_$AppDatabase, $PersonsTable, PersonRow> {
  $$PersonsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ItemsTable, List<ItemRow>> _itemsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.items,
    aliasName: 'persons__id__items__person_id',
  );

  $$ItemsTableProcessedTableManager get itemsRefs {
    final manager = $$ItemsTableTableManager(
      $_db,
      $_db.items,
    ).filter((f) => f.personId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_itemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PersonsTableFilterComposer
    extends Composer<_$AppDatabase, $PersonsTable> {
  $$PersonsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> itemsRefs(
    Expression<bool> Function($$ItemsTableFilterComposer f) f,
  ) {
    final $$ItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.personId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableFilterComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PersonsTableOrderingComposer
    extends Composer<_$AppDatabase, $PersonsTable> {
  $$PersonsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PersonsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PersonsTable> {
  $$PersonsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  Expression<T> itemsRefs<T extends Object>(
    Expression<T> Function($$ItemsTableAnnotationComposer a) f,
  ) {
    final $$ItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.personId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PersonsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PersonsTable,
          PersonRow,
          $$PersonsTableFilterComposer,
          $$PersonsTableOrderingComposer,
          $$PersonsTableAnnotationComposer,
          $$PersonsTableCreateCompanionBuilder,
          $$PersonsTableUpdateCompanionBuilder,
          (PersonRow, $$PersonsTableReferences),
          PersonRow,
          PrefetchHooks Function({bool itemsRefs})
        > {
  $$PersonsTableTableManager(_$AppDatabase db, $PersonsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PersonsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PersonsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PersonsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PersonsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                name: name,
                color: color,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String name,
                required int color,
                Value<int> rowid = const Value.absent(),
              }) => PersonsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                name: name,
                color: color,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PersonsTable, PersonRow>(table),
                  $$PersonsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({itemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (itemsRefs) db.items],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (itemsRefs)
                    await $_getPrefetchedData<
                      PersonRow,
                      $PersonsTable,
                      ItemRow
                    >(
                      currentTable: table,
                      referencedTable: $$PersonsTableReferences._itemsRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$PersonsTableReferences(db, table, p0).itemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.personId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PersonsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PersonsTable,
      PersonRow,
      $$PersonsTableFilterComposer,
      $$PersonsTableOrderingComposer,
      $$PersonsTableAnnotationComposer,
      $$PersonsTableCreateCompanionBuilder,
      $$PersonsTableUpdateCompanionBuilder,
      (PersonRow, $$PersonsTableReferences),
      PersonRow,
      PrefetchHooks Function({bool itemsRefs})
    >;
typedef $$ItemsTableCreateCompanionBuilder = ItemsCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  required String personId,
  Value<String> name,
  required String kategorie,
  Value<String> farben,
  required String muster,
  required String materialOptik,
  required String laengeSchnitt,
  Value<String> logoMarke,
  Value<String> aufdruckText,
  Value<String> besondereMerkmale,
  Value<String> markierung,
  Value<String> vlmRaw,
  Value<int> rowid,
});
typedef $$ItemsTableUpdateCompanionBuilder = ItemsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> personId,
  Value<String> name,
  Value<String> kategorie,
  Value<String> farben,
  Value<String> muster,
  Value<String> materialOptik,
  Value<String> laengeSchnitt,
  Value<String> logoMarke,
  Value<String> aufdruckText,
  Value<String> besondereMerkmale,
  Value<String> markierung,
  Value<String> vlmRaw,
  Value<int> rowid,
});

final class $$ItemsTableReferences
    extends BaseReferences<_$AppDatabase, $ItemsTable, ItemRow> {
  $$ItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PersonsTable _personIdTable(_$AppDatabase db) =>
      db.persons.createAlias('items__person_id__persons__id');

  $$PersonsTableProcessedTableManager get personId {
    final $_column = $_itemColumn<String>('person_id')!;

    final manager = $$PersonsTableTableManager(
      $_db,
      $_db.persons,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_personIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ItemPhotosTable, List<PhotoRow>>
  _itemPhotosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.itemPhotos,
    aliasName: 'items__id__item_photos__item_id',
  );

  $$ItemPhotosTableProcessedTableManager get itemPhotosRefs {
    final manager = $$ItemPhotosTableTableManager(
      $_db,
      $_db.itemPhotos,
    ).filter((f) => f.itemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_itemPhotosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ItemsTableFilterComposer extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kategorie => $composableBuilder(
    column: $table.kategorie,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get farben => $composableBuilder(
    column: $table.farben,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get muster => $composableBuilder(
    column: $table.muster,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get materialOptik => $composableBuilder(
    column: $table.materialOptik,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get laengeSchnitt => $composableBuilder(
    column: $table.laengeSchnitt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get logoMarke => $composableBuilder(
    column: $table.logoMarke,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aufdruckText => $composableBuilder(
    column: $table.aufdruckText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get besondereMerkmale => $composableBuilder(
    column: $table.besondereMerkmale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get markierung => $composableBuilder(
    column: $table.markierung,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vlmRaw => $composableBuilder(
    column: $table.vlmRaw,
    builder: (column) => ColumnFilters(column),
  );

  $$PersonsTableFilterComposer get personId {
    final $$PersonsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.persons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonsTableFilterComposer(
            $db: $db,
            $table: $db.persons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> itemPhotosRefs(
    Expression<bool> Function($$ItemPhotosTableFilterComposer f) f,
  ) {
    final $$ItemPhotosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.itemPhotos,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemPhotosTableFilterComposer(
            $db: $db,
            $table: $db.itemPhotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kategorie => $composableBuilder(
    column: $table.kategorie,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get farben => $composableBuilder(
    column: $table.farben,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get muster => $composableBuilder(
    column: $table.muster,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get materialOptik => $composableBuilder(
    column: $table.materialOptik,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get laengeSchnitt => $composableBuilder(
    column: $table.laengeSchnitt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get logoMarke => $composableBuilder(
    column: $table.logoMarke,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aufdruckText => $composableBuilder(
    column: $table.aufdruckText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get besondereMerkmale => $composableBuilder(
    column: $table.besondereMerkmale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get markierung => $composableBuilder(
    column: $table.markierung,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vlmRaw => $composableBuilder(
    column: $table.vlmRaw,
    builder: (column) => ColumnOrderings(column),
  );

  $$PersonsTableOrderingComposer get personId {
    final $$PersonsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.persons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonsTableOrderingComposer(
            $db: $db,
            $table: $db.persons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get kategorie =>
      $composableBuilder(column: $table.kategorie, builder: (column) => column);

  GeneratedColumn<String> get farben =>
      $composableBuilder(column: $table.farben, builder: (column) => column);

  GeneratedColumn<String> get muster =>
      $composableBuilder(column: $table.muster, builder: (column) => column);

  GeneratedColumn<String> get materialOptik => $composableBuilder(
    column: $table.materialOptik,
    builder: (column) => column,
  );

  GeneratedColumn<String> get laengeSchnitt => $composableBuilder(
    column: $table.laengeSchnitt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get logoMarke =>
      $composableBuilder(column: $table.logoMarke, builder: (column) => column);

  GeneratedColumn<String> get aufdruckText => $composableBuilder(
    column: $table.aufdruckText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get besondereMerkmale => $composableBuilder(
    column: $table.besondereMerkmale,
    builder: (column) => column,
  );

  GeneratedColumn<String> get markierung => $composableBuilder(
    column: $table.markierung,
    builder: (column) => column,
  );

  GeneratedColumn<String> get vlmRaw =>
      $composableBuilder(column: $table.vlmRaw, builder: (column) => column);

  $$PersonsTableAnnotationComposer get personId {
    final $$PersonsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.persons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonsTableAnnotationComposer(
            $db: $db,
            $table: $db.persons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> itemPhotosRefs<T extends Object>(
    Expression<T> Function($$ItemPhotosTableAnnotationComposer a) f,
  ) {
    final $$ItemPhotosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.itemPhotos,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemPhotosTableAnnotationComposer(
            $db: $db,
            $table: $db.itemPhotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ItemsTable,
          ItemRow,
          $$ItemsTableFilterComposer,
          $$ItemsTableOrderingComposer,
          $$ItemsTableAnnotationComposer,
          $$ItemsTableCreateCompanionBuilder,
          $$ItemsTableUpdateCompanionBuilder,
          (ItemRow, $$ItemsTableReferences),
          ItemRow,
          PrefetchHooks Function({bool personId, bool itemPhotosRefs})
        > {
  $$ItemsTableTableManager(_$AppDatabase db, $ItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> personId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> kategorie = const Value.absent(),
                Value<String> farben = const Value.absent(),
                Value<String> muster = const Value.absent(),
                Value<String> materialOptik = const Value.absent(),
                Value<String> laengeSchnitt = const Value.absent(),
                Value<String> logoMarke = const Value.absent(),
                Value<String> aufdruckText = const Value.absent(),
                Value<String> besondereMerkmale = const Value.absent(),
                Value<String> markierung = const Value.absent(),
                Value<String> vlmRaw = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItemsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                personId: personId,
                name: name,
                kategorie: kategorie,
                farben: farben,
                muster: muster,
                materialOptik: materialOptik,
                laengeSchnitt: laengeSchnitt,
                logoMarke: logoMarke,
                aufdruckText: aufdruckText,
                besondereMerkmale: besondereMerkmale,
                markierung: markierung,
                vlmRaw: vlmRaw,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String personId,
                Value<String> name = const Value.absent(),
                required String kategorie,
                Value<String> farben = const Value.absent(),
                required String muster,
                required String materialOptik,
                required String laengeSchnitt,
                Value<String> logoMarke = const Value.absent(),
                Value<String> aufdruckText = const Value.absent(),
                Value<String> besondereMerkmale = const Value.absent(),
                Value<String> markierung = const Value.absent(),
                Value<String> vlmRaw = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItemsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                personId: personId,
                name: name,
                kategorie: kategorie,
                farben: farben,
                muster: muster,
                materialOptik: materialOptik,
                laengeSchnitt: laengeSchnitt,
                logoMarke: logoMarke,
                aufdruckText: aufdruckText,
                besondereMerkmale: besondereMerkmale,
                markierung: markierung,
                vlmRaw: vlmRaw,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ItemsTable, ItemRow>(table),
                  $$ItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({personId = false, itemPhotosRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (itemPhotosRefs) db.itemPhotos],
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
                    if (personId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.personId,
                        referencedTable: $$ItemsTableReferences._personIdTable(
                          db,
                        ),
                        referencedColumn: $$ItemsTableReferences
                            ._personIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (itemPhotosRefs)
                    await $_getPrefetchedData<ItemRow, $ItemsTable, PhotoRow>(
                      currentTable: table,
                      referencedTable: $$ItemsTableReferences
                          ._itemPhotosRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ItemsTableReferences(db, table, p0).itemPhotosRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.itemId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ItemsTable,
      ItemRow,
      $$ItemsTableFilterComposer,
      $$ItemsTableOrderingComposer,
      $$ItemsTableAnnotationComposer,
      $$ItemsTableCreateCompanionBuilder,
      $$ItemsTableUpdateCompanionBuilder,
      (ItemRow, $$ItemsTableReferences),
      ItemRow,
      PrefetchHooks Function({bool personId, bool itemPhotosRefs})
    >;
typedef $$ItemPhotosTableCreateCompanionBuilder = ItemPhotosCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  required String itemId,
  required String fileName,
  required String art,
  Value<int> rowid,
});
typedef $$ItemPhotosTableUpdateCompanionBuilder = ItemPhotosCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> itemId,
  Value<String> fileName,
  Value<String> art,
  Value<int> rowid,
});

final class $$ItemPhotosTableReferences
    extends BaseReferences<_$AppDatabase, $ItemPhotosTable, PhotoRow> {
  $$ItemPhotosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ItemsTable _itemIdTable(_$AppDatabase db) =>
      db.items.createAlias('item_photos__item_id__items__id');

  $$ItemsTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<String>('item_id')!;

    final manager = $$ItemsTableTableManager(
      $_db,
      $_db.items,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PhotoEmbeddingsTable, List<EmbeddingRow>>
  _photoEmbeddingsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.photoEmbeddings,
    aliasName: 'item_photos__id__photo_embeddings__photo_id',
  );

  $$PhotoEmbeddingsTableProcessedTableManager get photoEmbeddingsRefs {
    final manager = $$PhotoEmbeddingsTableTableManager(
      $_db,
      $_db.photoEmbeddings,
    ).filter((f) => f.photoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _photoEmbeddingsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ItemPhotosTableFilterComposer
    extends Composer<_$AppDatabase, $ItemPhotosTable> {
  $$ItemPhotosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get art => $composableBuilder(
    column: $table.art,
    builder: (column) => ColumnFilters(column),
  );

  $$ItemsTableFilterComposer get itemId {
    final $$ItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableFilterComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> photoEmbeddingsRefs(
    Expression<bool> Function($$PhotoEmbeddingsTableFilterComposer f) f,
  ) {
    final $$PhotoEmbeddingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.photoEmbeddings,
      getReferencedColumn: (t) => t.photoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhotoEmbeddingsTableFilterComposer(
            $db: $db,
            $table: $db.photoEmbeddings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ItemPhotosTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemPhotosTable> {
  $$ItemPhotosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get art => $composableBuilder(
    column: $table.art,
    builder: (column) => ColumnOrderings(column),
  );

  $$ItemsTableOrderingComposer get itemId {
    final $$ItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableOrderingComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ItemPhotosTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemPhotosTable> {
  $$ItemPhotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get art =>
      $composableBuilder(column: $table.art, builder: (column) => column);

  $$ItemsTableAnnotationComposer get itemId {
    final $$ItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> photoEmbeddingsRefs<T extends Object>(
    Expression<T> Function($$PhotoEmbeddingsTableAnnotationComposer a) f,
  ) {
    final $$PhotoEmbeddingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.photoEmbeddings,
      getReferencedColumn: (t) => t.photoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhotoEmbeddingsTableAnnotationComposer(
            $db: $db,
            $table: $db.photoEmbeddings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ItemPhotosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ItemPhotosTable,
          PhotoRow,
          $$ItemPhotosTableFilterComposer,
          $$ItemPhotosTableOrderingComposer,
          $$ItemPhotosTableAnnotationComposer,
          $$ItemPhotosTableCreateCompanionBuilder,
          $$ItemPhotosTableUpdateCompanionBuilder,
          (PhotoRow, $$ItemPhotosTableReferences),
          PhotoRow,
          PrefetchHooks Function({bool itemId, bool photoEmbeddingsRefs})
        > {
  $$ItemPhotosTableTableManager(_$AppDatabase db, $ItemPhotosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemPhotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemPhotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemPhotosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<String> art = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItemPhotosCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                itemId: itemId,
                fileName: fileName,
                art: art,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String itemId,
                required String fileName,
                required String art,
                Value<int> rowid = const Value.absent(),
              }) => ItemPhotosCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                itemId: itemId,
                fileName: fileName,
                art: art,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ItemPhotosTable, PhotoRow>(table),
                  $$ItemPhotosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({itemId = false, photoEmbeddingsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (photoEmbeddingsRefs) db.photoEmbeddings,
                  ],
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
                        if (itemId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.itemId,
                            referencedTable: $$ItemPhotosTableReferences
                                ._itemIdTable(db),
                            referencedColumn: $$ItemPhotosTableReferences
                                ._itemIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (photoEmbeddingsRefs)
                        await $_getPrefetchedData<
                          PhotoRow,
                          $ItemPhotosTable,
                          EmbeddingRow
                        >(
                          currentTable: table,
                          referencedTable: $$ItemPhotosTableReferences
                              ._photoEmbeddingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ItemPhotosTableReferences(
                                db,
                                table,
                                p0,
                              ).photoEmbeddingsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.photoId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ItemPhotosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ItemPhotosTable,
      PhotoRow,
      $$ItemPhotosTableFilterComposer,
      $$ItemPhotosTableOrderingComposer,
      $$ItemPhotosTableAnnotationComposer,
      $$ItemPhotosTableCreateCompanionBuilder,
      $$ItemPhotosTableUpdateCompanionBuilder,
      (PhotoRow, $$ItemPhotosTableReferences),
      PhotoRow,
      PrefetchHooks Function({bool itemId, bool photoEmbeddingsRefs})
    >;
typedef $$PhotoEmbeddingsTableCreateCompanionBuilder =
    PhotoEmbeddingsCompanion Function({
      required String photoId,
      required String modelId,
      required int variant,
      required Uint8List vector,
      Value<int> rowid,
    });
typedef $$PhotoEmbeddingsTableUpdateCompanionBuilder =
    PhotoEmbeddingsCompanion Function({
      Value<String> photoId,
      Value<String> modelId,
      Value<int> variant,
      Value<Uint8List> vector,
      Value<int> rowid,
    });

final class $$PhotoEmbeddingsTableReferences
    extends BaseReferences<_$AppDatabase, $PhotoEmbeddingsTable, EmbeddingRow> {
  $$PhotoEmbeddingsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ItemPhotosTable _photoIdTable(_$AppDatabase db) =>
      db.itemPhotos.createAlias('photo_embeddings__photo_id__item_photos__id');

  $$ItemPhotosTableProcessedTableManager get photoId {
    final $_column = $_itemColumn<String>('photo_id')!;

    final manager = $$ItemPhotosTableTableManager(
      $_db,
      $_db.itemPhotos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_photoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PhotoEmbeddingsTableFilterComposer
    extends Composer<_$AppDatabase, $PhotoEmbeddingsTable> {
  $$PhotoEmbeddingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get variant => $composableBuilder(
    column: $table.variant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get vector => $composableBuilder(
    column: $table.vector,
    builder: (column) => ColumnFilters(column),
  );

  $$ItemPhotosTableFilterComposer get photoId {
    final $$ItemPhotosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.photoId,
      referencedTable: $db.itemPhotos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemPhotosTableFilterComposer(
            $db: $db,
            $table: $db.itemPhotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PhotoEmbeddingsTableOrderingComposer
    extends Composer<_$AppDatabase, $PhotoEmbeddingsTable> {
  $$PhotoEmbeddingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get variant => $composableBuilder(
    column: $table.variant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get vector => $composableBuilder(
    column: $table.vector,
    builder: (column) => ColumnOrderings(column),
  );

  $$ItemPhotosTableOrderingComposer get photoId {
    final $$ItemPhotosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.photoId,
      referencedTable: $db.itemPhotos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemPhotosTableOrderingComposer(
            $db: $db,
            $table: $db.itemPhotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PhotoEmbeddingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PhotoEmbeddingsTable> {
  $$PhotoEmbeddingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get modelId =>
      $composableBuilder(column: $table.modelId, builder: (column) => column);

  GeneratedColumn<int> get variant =>
      $composableBuilder(column: $table.variant, builder: (column) => column);

  GeneratedColumn<Uint8List> get vector =>
      $composableBuilder(column: $table.vector, builder: (column) => column);

  $$ItemPhotosTableAnnotationComposer get photoId {
    final $$ItemPhotosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.photoId,
      referencedTable: $db.itemPhotos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemPhotosTableAnnotationComposer(
            $db: $db,
            $table: $db.itemPhotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PhotoEmbeddingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PhotoEmbeddingsTable,
          EmbeddingRow,
          $$PhotoEmbeddingsTableFilterComposer,
          $$PhotoEmbeddingsTableOrderingComposer,
          $$PhotoEmbeddingsTableAnnotationComposer,
          $$PhotoEmbeddingsTableCreateCompanionBuilder,
          $$PhotoEmbeddingsTableUpdateCompanionBuilder,
          (EmbeddingRow, $$PhotoEmbeddingsTableReferences),
          EmbeddingRow,
          PrefetchHooks Function({bool photoId})
        > {
  $$PhotoEmbeddingsTableTableManager(
    _$AppDatabase db,
    $PhotoEmbeddingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PhotoEmbeddingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PhotoEmbeddingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PhotoEmbeddingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> photoId = const Value.absent(),
                Value<String> modelId = const Value.absent(),
                Value<int> variant = const Value.absent(),
                Value<Uint8List> vector = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PhotoEmbeddingsCompanion(
                photoId: photoId,
                modelId: modelId,
                variant: variant,
                vector: vector,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String photoId,
                required String modelId,
                required int variant,
                required Uint8List vector,
                Value<int> rowid = const Value.absent(),
              }) => PhotoEmbeddingsCompanion.insert(
                photoId: photoId,
                modelId: modelId,
                variant: variant,
                vector: vector,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PhotoEmbeddingsTable, EmbeddingRow>(table),
                  $$PhotoEmbeddingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({photoId = false}) {
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
                    if (photoId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.photoId,
                        referencedTable: $$PhotoEmbeddingsTableReferences
                            ._photoIdTable(db),
                        referencedColumn: $$PhotoEmbeddingsTableReferences
                            ._photoIdTable(db)
                            .id,
                      ) as T;
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

typedef $$PhotoEmbeddingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PhotoEmbeddingsTable,
      EmbeddingRow,
      $$PhotoEmbeddingsTableFilterComposer,
      $$PhotoEmbeddingsTableOrderingComposer,
      $$PhotoEmbeddingsTableAnnotationComposer,
      $$PhotoEmbeddingsTableCreateCompanionBuilder,
      $$PhotoEmbeddingsTableUpdateCompanionBuilder,
      (EmbeddingRow, $$PhotoEmbeddingsTableReferences),
      EmbeddingRow,
      PrefetchHooks Function({bool photoId})
    >;
typedef $$ScanLogsTableCreateCompanionBuilder = ScanLogsCompanion Function({
  Value<int> id,
  required DateTime time,
  Value<String?> itemId,
  required String stage,
  Value<int> rounds,
  required int durationMs,
  Value<bool> confirmed,
  Value<String> device,
  Value<String> backend,
  Value<String> detail,
});
typedef $$ScanLogsTableUpdateCompanionBuilder = ScanLogsCompanion Function({
  Value<int> id,
  Value<DateTime> time,
  Value<String?> itemId,
  Value<String> stage,
  Value<int> rounds,
  Value<int> durationMs,
  Value<bool> confirmed,
  Value<String> device,
  Value<String> backend,
  Value<String> detail,
});

class $$ScanLogsTableFilterComposer
    extends Composer<_$AppDatabase, $ScanLogsTable> {
  $$ScanLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get time => $composableBuilder(
    column: $table.time,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stage => $composableBuilder(
    column: $table.stage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rounds => $composableBuilder(
    column: $table.rounds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get confirmed => $composableBuilder(
    column: $table.confirmed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get device => $composableBuilder(
    column: $table.device,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get backend => $composableBuilder(
    column: $table.backend,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detail => $composableBuilder(
    column: $table.detail,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ScanLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $ScanLogsTable> {
  $$ScanLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get time => $composableBuilder(
    column: $table.time,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stage => $composableBuilder(
    column: $table.stage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rounds => $composableBuilder(
    column: $table.rounds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get confirmed => $composableBuilder(
    column: $table.confirmed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get device => $composableBuilder(
    column: $table.device,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get backend => $composableBuilder(
    column: $table.backend,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detail => $composableBuilder(
    column: $table.detail,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScanLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScanLogsTable> {
  $$ScanLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get time =>
      $composableBuilder(column: $table.time, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get stage =>
      $composableBuilder(column: $table.stage, builder: (column) => column);

  GeneratedColumn<int> get rounds =>
      $composableBuilder(column: $table.rounds, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get confirmed =>
      $composableBuilder(column: $table.confirmed, builder: (column) => column);

  GeneratedColumn<String> get device =>
      $composableBuilder(column: $table.device, builder: (column) => column);

  GeneratedColumn<String> get backend =>
      $composableBuilder(column: $table.backend, builder: (column) => column);

  GeneratedColumn<String> get detail =>
      $composableBuilder(column: $table.detail, builder: (column) => column);
}

class $$ScanLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScanLogsTable,
          ScanLogRow,
          $$ScanLogsTableFilterComposer,
          $$ScanLogsTableOrderingComposer,
          $$ScanLogsTableAnnotationComposer,
          $$ScanLogsTableCreateCompanionBuilder,
          $$ScanLogsTableUpdateCompanionBuilder,
          (
            ScanLogRow,
            BaseReferences<_$AppDatabase, $ScanLogsTable, ScanLogRow>,
          ),
          ScanLogRow,
          PrefetchHooks Function()
        > {
  $$ScanLogsTableTableManager(_$AppDatabase db, $ScanLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScanLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScanLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScanLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> time = const Value.absent(),
                Value<String?> itemId = const Value.absent(),
                Value<String> stage = const Value.absent(),
                Value<int> rounds = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<bool> confirmed = const Value.absent(),
                Value<String> device = const Value.absent(),
                Value<String> backend = const Value.absent(),
                Value<String> detail = const Value.absent(),
              }) => ScanLogsCompanion(
                id: id,
                time: time,
                itemId: itemId,
                stage: stage,
                rounds: rounds,
                durationMs: durationMs,
                confirmed: confirmed,
                device: device,
                backend: backend,
                detail: detail,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime time,
                Value<String?> itemId = const Value.absent(),
                required String stage,
                Value<int> rounds = const Value.absent(),
                required int durationMs,
                Value<bool> confirmed = const Value.absent(),
                Value<String> device = const Value.absent(),
                Value<String> backend = const Value.absent(),
                Value<String> detail = const Value.absent(),
              }) => ScanLogsCompanion.insert(
                id: id,
                time: time,
                itemId: itemId,
                stage: stage,
                rounds: rounds,
                durationMs: durationMs,
                confirmed: confirmed,
                device: device,
                backend: backend,
                detail: detail,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ScanLogsTable, ScanLogRow>(table),
                  BaseReferences<_$AppDatabase, $ScanLogsTable, ScanLogRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ScanLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScanLogsTable,
      ScanLogRow,
      $$ScanLogsTableFilterComposer,
      $$ScanLogsTableOrderingComposer,
      $$ScanLogsTableAnnotationComposer,
      $$ScanLogsTableCreateCompanionBuilder,
      $$ScanLogsTableUpdateCompanionBuilder,
      (ScanLogRow, BaseReferences<_$AppDatabase, $ScanLogsTable, ScanLogRow>),
      ScanLogRow,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
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

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          SettingRow,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            SettingRow,
            BaseReferences<_$AppDatabase, $AppSettingsTable, SettingRow>,
          ),
          SettingRow,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, SettingRow>(table),
                  BaseReferences<_$AppDatabase, $AppSettingsTable, SettingRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      SettingRow,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        SettingRow,
        BaseReferences<_$AppDatabase, $AppSettingsTable, SettingRow>,
      ),
      SettingRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PersonsTableTableManager get persons =>
      $$PersonsTableTableManager(_db, _db.persons);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db, _db.items);
  $$ItemPhotosTableTableManager get itemPhotos =>
      $$ItemPhotosTableTableManager(_db, _db.itemPhotos);
  $$PhotoEmbeddingsTableTableManager get photoEmbeddings =>
      $$PhotoEmbeddingsTableTableManager(_db, _db.photoEmbeddings);
  $$ScanLogsTableTableManager get scanLogs =>
      $$ScanLogsTableTableManager(_db, _db.scanLogs);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
