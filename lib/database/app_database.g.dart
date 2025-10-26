// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CountriesTable extends Countries
    with TableInfo<$CountriesTable, Country> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CountriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  static const VerificationMeta _shortNameMeta = const VerificationMeta(
    'shortName',
  );
  @override
  late final GeneratedColumn<String> shortName = GeneratedColumn<String>(
    'short_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, shortName];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'countries';
  @override
  VerificationContext validateIntegrity(
    Insertable<Country> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('short_name')) {
      context.handle(
        _shortNameMeta,
        shortName.isAcceptableOrUnknown(data['short_name']!, _shortNameMeta),
      );
    } else if (isInserting) {
      context.missing(_shortNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Country map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Country(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      shortName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}short_name'],
      )!,
    );
  }

  @override
  $CountriesTable createAlias(String alias) {
    return $CountriesTable(attachedDatabase, alias);
  }
}

class Country extends DataClass implements Insertable<Country> {
  final int id;
  final String name;
  final String shortName;
  const Country({
    required this.id,
    required this.name,
    required this.shortName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['short_name'] = Variable<String>(shortName);
    return map;
  }

  CountriesCompanion toCompanion(bool nullToAbsent) {
    return CountriesCompanion(
      id: Value(id),
      name: Value(name),
      shortName: Value(shortName),
    );
  }

  factory Country.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Country(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      shortName: serializer.fromJson<String>(json['shortName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'shortName': serializer.toJson<String>(shortName),
    };
  }

  Country copyWith({int? id, String? name, String? shortName}) => Country(
    id: id ?? this.id,
    name: name ?? this.name,
    shortName: shortName ?? this.shortName,
  );
  Country copyWithCompanion(CountriesCompanion data) {
    return Country(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      shortName: data.shortName.present ? data.shortName.value : this.shortName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Country(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('shortName: $shortName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, shortName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Country &&
          other.id == this.id &&
          other.name == this.name &&
          other.shortName == this.shortName);
}

class CountriesCompanion extends UpdateCompanion<Country> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> shortName;
  const CountriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.shortName = const Value.absent(),
  });
  CountriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String shortName,
  }) : name = Value(name),
       shortName = Value(shortName);
  static Insertable<Country> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? shortName,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (shortName != null) 'short_name': shortName,
    });
  }

  CountriesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? shortName,
  }) {
    return CountriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
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
    if (shortName.present) {
      map['short_name'] = Variable<String>(shortName.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CountriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('shortName: $shortName')
          ..write(')'))
        .toString();
  }
}

class $RegionsTable extends Regions with TableInfo<$RegionsTable, Region> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RegionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  static const VerificationMeta _countryIdMeta = const VerificationMeta(
    'countryId',
  );
  @override
  late final GeneratedColumn<int> countryId = GeneratedColumn<int>(
    'country_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES countries (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, countryId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'regions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Region> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('country_id')) {
      context.handle(
        _countryIdMeta,
        countryId.isAcceptableOrUnknown(data['country_id']!, _countryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_countryIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Region map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Region(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      countryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}country_id'],
      )!,
    );
  }

  @override
  $RegionsTable createAlias(String alias) {
    return $RegionsTable(attachedDatabase, alias);
  }
}

class Region extends DataClass implements Insertable<Region> {
  final int id;
  final String name;
  final int countryId;
  const Region({required this.id, required this.name, required this.countryId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['country_id'] = Variable<int>(countryId);
    return map;
  }

  RegionsCompanion toCompanion(bool nullToAbsent) {
    return RegionsCompanion(
      id: Value(id),
      name: Value(name),
      countryId: Value(countryId),
    );
  }

  factory Region.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Region(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      countryId: serializer.fromJson<int>(json['countryId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'countryId': serializer.toJson<int>(countryId),
    };
  }

  Region copyWith({int? id, String? name, int? countryId}) => Region(
    id: id ?? this.id,
    name: name ?? this.name,
    countryId: countryId ?? this.countryId,
  );
  Region copyWithCompanion(RegionsCompanion data) {
    return Region(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      countryId: data.countryId.present ? data.countryId.value : this.countryId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Region(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('countryId: $countryId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, countryId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Region &&
          other.id == this.id &&
          other.name == this.name &&
          other.countryId == this.countryId);
}

class RegionsCompanion extends UpdateCompanion<Region> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> countryId;
  const RegionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.countryId = const Value.absent(),
  });
  RegionsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int countryId,
  }) : name = Value(name),
       countryId = Value(countryId);
  static Insertable<Region> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? countryId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (countryId != null) 'country_id': countryId,
    });
  }

  RegionsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? countryId,
  }) {
    return RegionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      countryId: countryId ?? this.countryId,
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
    if (countryId.present) {
      map['country_id'] = Variable<int>(countryId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RegionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('countryId: $countryId')
          ..write(')'))
        .toString();
  }
}

class $DistrictsTable extends Districts
    with TableInfo<$DistrictsTable, District> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DistrictsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  static const VerificationMeta _regionIdMeta = const VerificationMeta(
    'regionId',
  );
  @override
  late final GeneratedColumn<int> regionId = GeneratedColumn<int>(
    'region_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES regions (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, regionId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'districts';
  @override
  VerificationContext validateIntegrity(
    Insertable<District> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('region_id')) {
      context.handle(
        _regionIdMeta,
        regionId.isAcceptableOrUnknown(data['region_id']!, _regionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_regionIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  District map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return District(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      regionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}region_id'],
      )!,
    );
  }

  @override
  $DistrictsTable createAlias(String alias) {
    return $DistrictsTable(attachedDatabase, alias);
  }
}

class District extends DataClass implements Insertable<District> {
  final int id;
  final String name;
  final int regionId;
  const District({
    required this.id,
    required this.name,
    required this.regionId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['region_id'] = Variable<int>(regionId);
    return map;
  }

  DistrictsCompanion toCompanion(bool nullToAbsent) {
    return DistrictsCompanion(
      id: Value(id),
      name: Value(name),
      regionId: Value(regionId),
    );
  }

  factory District.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return District(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      regionId: serializer.fromJson<int>(json['regionId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'regionId': serializer.toJson<int>(regionId),
    };
  }

  District copyWith({int? id, String? name, int? regionId}) => District(
    id: id ?? this.id,
    name: name ?? this.name,
    regionId: regionId ?? this.regionId,
  );
  District copyWithCompanion(DistrictsCompanion data) {
    return District(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      regionId: data.regionId.present ? data.regionId.value : this.regionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('District(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('regionId: $regionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, regionId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is District &&
          other.id == this.id &&
          other.name == this.name &&
          other.regionId == this.regionId);
}

class DistrictsCompanion extends UpdateCompanion<District> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> regionId;
  const DistrictsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.regionId = const Value.absent(),
  });
  DistrictsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int regionId,
  }) : name = Value(name),
       regionId = Value(regionId);
  static Insertable<District> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? regionId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (regionId != null) 'region_id': regionId,
    });
  }

  DistrictsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? regionId,
  }) {
    return DistrictsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      regionId: regionId ?? this.regionId,
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
    if (regionId.present) {
      map['region_id'] = Variable<int>(regionId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DistrictsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('regionId: $regionId')
          ..write(')'))
        .toString();
  }
}

class $DivisionsTable extends Divisions
    with TableInfo<$DivisionsTable, Division> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DivisionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  static const VerificationMeta _districtIdMeta = const VerificationMeta(
    'districtId',
  );
  @override
  late final GeneratedColumn<int> districtId = GeneratedColumn<int>(
    'district_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES districts (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, districtId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'divisions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Division> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('district_id')) {
      context.handle(
        _districtIdMeta,
        districtId.isAcceptableOrUnknown(data['district_id']!, _districtIdMeta),
      );
    } else if (isInserting) {
      context.missing(_districtIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Division map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Division(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      districtId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}district_id'],
      )!,
    );
  }

  @override
  $DivisionsTable createAlias(String alias) {
    return $DivisionsTable(attachedDatabase, alias);
  }
}

class Division extends DataClass implements Insertable<Division> {
  final int id;
  final String name;
  final int districtId;
  const Division({
    required this.id,
    required this.name,
    required this.districtId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['district_id'] = Variable<int>(districtId);
    return map;
  }

  DivisionsCompanion toCompanion(bool nullToAbsent) {
    return DivisionsCompanion(
      id: Value(id),
      name: Value(name),
      districtId: Value(districtId),
    );
  }

  factory Division.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Division(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      districtId: serializer.fromJson<int>(json['districtId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'districtId': serializer.toJson<int>(districtId),
    };
  }

  Division copyWith({int? id, String? name, int? districtId}) => Division(
    id: id ?? this.id,
    name: name ?? this.name,
    districtId: districtId ?? this.districtId,
  );
  Division copyWithCompanion(DivisionsCompanion data) {
    return Division(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      districtId: data.districtId.present
          ? data.districtId.value
          : this.districtId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Division(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('districtId: $districtId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, districtId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Division &&
          other.id == this.id &&
          other.name == this.name &&
          other.districtId == this.districtId);
}

class DivisionsCompanion extends UpdateCompanion<Division> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> districtId;
  const DivisionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.districtId = const Value.absent(),
  });
  DivisionsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int districtId,
  }) : name = Value(name),
       districtId = Value(districtId);
  static Insertable<Division> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? districtId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (districtId != null) 'district_id': districtId,
    });
  }

  DivisionsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? districtId,
  }) {
    return DivisionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      districtId: districtId ?? this.districtId,
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
    if (districtId.present) {
      map['district_id'] = Variable<int>(districtId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DivisionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('districtId: $districtId')
          ..write(')'))
        .toString();
  }
}

class $WardsTable extends Wards with TableInfo<$WardsTable, Ward> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  static const VerificationMeta _districtIdMeta = const VerificationMeta(
    'districtId',
  );
  @override
  late final GeneratedColumn<int> districtId = GeneratedColumn<int>(
    'district_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES districts (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, districtId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wards';
  @override
  VerificationContext validateIntegrity(
    Insertable<Ward> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('district_id')) {
      context.handle(
        _districtIdMeta,
        districtId.isAcceptableOrUnknown(data['district_id']!, _districtIdMeta),
      );
    } else if (isInserting) {
      context.missing(_districtIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Ward map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Ward(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      districtId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}district_id'],
      )!,
    );
  }

  @override
  $WardsTable createAlias(String alias) {
    return $WardsTable(attachedDatabase, alias);
  }
}

class Ward extends DataClass implements Insertable<Ward> {
  final int id;
  final String name;
  final int districtId;
  const Ward({required this.id, required this.name, required this.districtId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['district_id'] = Variable<int>(districtId);
    return map;
  }

  WardsCompanion toCompanion(bool nullToAbsent) {
    return WardsCompanion(
      id: Value(id),
      name: Value(name),
      districtId: Value(districtId),
    );
  }

  factory Ward.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Ward(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      districtId: serializer.fromJson<int>(json['districtId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'districtId': serializer.toJson<int>(districtId),
    };
  }

  Ward copyWith({int? id, String? name, int? districtId}) => Ward(
    id: id ?? this.id,
    name: name ?? this.name,
    districtId: districtId ?? this.districtId,
  );
  Ward copyWithCompanion(WardsCompanion data) {
    return Ward(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      districtId: data.districtId.present
          ? data.districtId.value
          : this.districtId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Ward(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('districtId: $districtId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, districtId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Ward &&
          other.id == this.id &&
          other.name == this.name &&
          other.districtId == this.districtId);
}

class WardsCompanion extends UpdateCompanion<Ward> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> districtId;
  const WardsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.districtId = const Value.absent(),
  });
  WardsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int districtId,
  }) : name = Value(name),
       districtId = Value(districtId);
  static Insertable<Ward> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? districtId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (districtId != null) 'district_id': districtId,
    });
  }

  WardsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? districtId,
  }) {
    return WardsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      districtId: districtId ?? this.districtId,
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
    if (districtId.present) {
      map['district_id'] = Variable<int>(districtId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WardsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('districtId: $districtId')
          ..write(')'))
        .toString();
  }
}

class $VillagesTable extends Villages with TableInfo<$VillagesTable, Village> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VillagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  static const VerificationMeta _wardIdMeta = const VerificationMeta('wardId');
  @override
  late final GeneratedColumn<int> wardId = GeneratedColumn<int>(
    'ward_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES wards (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, wardId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'villages';
  @override
  VerificationContext validateIntegrity(
    Insertable<Village> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('ward_id')) {
      context.handle(
        _wardIdMeta,
        wardId.isAcceptableOrUnknown(data['ward_id']!, _wardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_wardIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Village map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Village(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      wardId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ward_id'],
      )!,
    );
  }

  @override
  $VillagesTable createAlias(String alias) {
    return $VillagesTable(attachedDatabase, alias);
  }
}

class Village extends DataClass implements Insertable<Village> {
  final int id;
  final String name;
  final int wardId;
  const Village({required this.id, required this.name, required this.wardId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['ward_id'] = Variable<int>(wardId);
    return map;
  }

  VillagesCompanion toCompanion(bool nullToAbsent) {
    return VillagesCompanion(
      id: Value(id),
      name: Value(name),
      wardId: Value(wardId),
    );
  }

  factory Village.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Village(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      wardId: serializer.fromJson<int>(json['wardId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'wardId': serializer.toJson<int>(wardId),
    };
  }

  Village copyWith({int? id, String? name, int? wardId}) => Village(
    id: id ?? this.id,
    name: name ?? this.name,
    wardId: wardId ?? this.wardId,
  );
  Village copyWithCompanion(VillagesCompanion data) {
    return Village(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      wardId: data.wardId.present ? data.wardId.value : this.wardId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Village(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('wardId: $wardId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, wardId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Village &&
          other.id == this.id &&
          other.name == this.name &&
          other.wardId == this.wardId);
}

class VillagesCompanion extends UpdateCompanion<Village> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> wardId;
  const VillagesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.wardId = const Value.absent(),
  });
  VillagesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int wardId,
  }) : name = Value(name),
       wardId = Value(wardId);
  static Insertable<Village> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? wardId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (wardId != null) 'ward_id': wardId,
    });
  }

  VillagesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? wardId,
  }) {
    return VillagesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      wardId: wardId ?? this.wardId,
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
    if (wardId.present) {
      map['ward_id'] = Variable<int>(wardId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VillagesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('wardId: $wardId')
          ..write(')'))
        .toString();
  }
}

class $StreetsTable extends Streets with TableInfo<$StreetsTable, Street> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StreetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  static const VerificationMeta _wardIdMeta = const VerificationMeta('wardId');
  @override
  late final GeneratedColumn<int> wardId = GeneratedColumn<int>(
    'ward_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES wards (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, wardId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'streets';
  @override
  VerificationContext validateIntegrity(
    Insertable<Street> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('ward_id')) {
      context.handle(
        _wardIdMeta,
        wardId.isAcceptableOrUnknown(data['ward_id']!, _wardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_wardIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Street map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Street(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      wardId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ward_id'],
      )!,
    );
  }

  @override
  $StreetsTable createAlias(String alias) {
    return $StreetsTable(attachedDatabase, alias);
  }
}

class Street extends DataClass implements Insertable<Street> {
  final int id;
  final String name;
  final int wardId;
  const Street({required this.id, required this.name, required this.wardId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['ward_id'] = Variable<int>(wardId);
    return map;
  }

  StreetsCompanion toCompanion(bool nullToAbsent) {
    return StreetsCompanion(
      id: Value(id),
      name: Value(name),
      wardId: Value(wardId),
    );
  }

  factory Street.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Street(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      wardId: serializer.fromJson<int>(json['wardId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'wardId': serializer.toJson<int>(wardId),
    };
  }

  Street copyWith({int? id, String? name, int? wardId}) => Street(
    id: id ?? this.id,
    name: name ?? this.name,
    wardId: wardId ?? this.wardId,
  );
  Street copyWithCompanion(StreetsCompanion data) {
    return Street(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      wardId: data.wardId.present ? data.wardId.value : this.wardId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Street(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('wardId: $wardId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, wardId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Street &&
          other.id == this.id &&
          other.name == this.name &&
          other.wardId == this.wardId);
}

class StreetsCompanion extends UpdateCompanion<Street> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> wardId;
  const StreetsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.wardId = const Value.absent(),
  });
  StreetsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int wardId,
  }) : name = Value(name),
       wardId = Value(wardId);
  static Insertable<Street> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? wardId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (wardId != null) 'ward_id': wardId,
    });
  }

  StreetsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? wardId,
  }) {
    return StreetsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      wardId: wardId ?? this.wardId,
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
    if (wardId.present) {
      map['ward_id'] = Variable<int>(wardId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StreetsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('wardId: $wardId')
          ..write(')'))
        .toString();
  }
}

class $SchoolLevelsTable extends SchoolLevels
    with TableInfo<$SchoolLevelsTable, SchoolLevel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SchoolLevelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'school_levels';
  @override
  VerificationContext validateIntegrity(
    Insertable<SchoolLevel> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SchoolLevel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SchoolLevel(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $SchoolLevelsTable createAlias(String alias) {
    return $SchoolLevelsTable(attachedDatabase, alias);
  }
}

class SchoolLevel extends DataClass implements Insertable<SchoolLevel> {
  final int id;
  final String name;
  const SchoolLevel({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  SchoolLevelsCompanion toCompanion(bool nullToAbsent) {
    return SchoolLevelsCompanion(id: Value(id), name: Value(name));
  }

  factory SchoolLevel.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SchoolLevel(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  SchoolLevel copyWith({int? id, String? name}) =>
      SchoolLevel(id: id ?? this.id, name: name ?? this.name);
  SchoolLevel copyWithCompanion(SchoolLevelsCompanion data) {
    return SchoolLevel(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SchoolLevel(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SchoolLevel && other.id == this.id && other.name == this.name);
}

class SchoolLevelsCompanion extends UpdateCompanion<SchoolLevel> {
  final Value<int> id;
  final Value<String> name;
  const SchoolLevelsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  SchoolLevelsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<SchoolLevel> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  SchoolLevelsCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return SchoolLevelsCompanion(id: id ?? this.id, name: name ?? this.name);
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SchoolLevelsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $IdentityCardTypesTable extends IdentityCardTypes
    with TableInfo<$IdentityCardTypesTable, IdentityCardType> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IdentityCardTypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'identity_card_types';
  @override
  VerificationContext validateIntegrity(
    Insertable<IdentityCardType> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IdentityCardType map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IdentityCardType(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $IdentityCardTypesTable createAlias(String alias) {
    return $IdentityCardTypesTable(attachedDatabase, alias);
  }
}

class IdentityCardType extends DataClass
    implements Insertable<IdentityCardType> {
  final int id;
  final String name;
  const IdentityCardType({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  IdentityCardTypesCompanion toCompanion(bool nullToAbsent) {
    return IdentityCardTypesCompanion(id: Value(id), name: Value(name));
  }

  factory IdentityCardType.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IdentityCardType(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  IdentityCardType copyWith({int? id, String? name}) =>
      IdentityCardType(id: id ?? this.id, name: name ?? this.name);
  IdentityCardType copyWithCompanion(IdentityCardTypesCompanion data) {
    return IdentityCardType(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IdentityCardType(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IdentityCardType &&
          other.id == this.id &&
          other.name == this.name);
}

class IdentityCardTypesCompanion extends UpdateCompanion<IdentityCardType> {
  final Value<int> id;
  final Value<String> name;
  const IdentityCardTypesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  IdentityCardTypesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<IdentityCardType> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  IdentityCardTypesCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return IdentityCardTypesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IdentityCardTypesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $LegalStatusesTable extends LegalStatuses
    with TableInfo<$LegalStatusesTable, LegalStatus> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LegalStatusesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'legal_statuses';
  @override
  VerificationContext validateIntegrity(
    Insertable<LegalStatus> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LegalStatus map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LegalStatus(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $LegalStatusesTable createAlias(String alias) {
    return $LegalStatusesTable(attachedDatabase, alias);
  }
}

class LegalStatus extends DataClass implements Insertable<LegalStatus> {
  final int id;
  final String name;
  const LegalStatus({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  LegalStatusesCompanion toCompanion(bool nullToAbsent) {
    return LegalStatusesCompanion(id: Value(id), name: Value(name));
  }

  factory LegalStatus.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LegalStatus(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  LegalStatus copyWith({int? id, String? name}) =>
      LegalStatus(id: id ?? this.id, name: name ?? this.name);
  LegalStatus copyWithCompanion(LegalStatusesCompanion data) {
    return LegalStatus(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LegalStatus(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LegalStatus && other.id == this.id && other.name == this.name);
}

class LegalStatusesCompanion extends UpdateCompanion<LegalStatus> {
  final Value<int> id;
  final Value<String> name;
  const LegalStatusesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  LegalStatusesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<LegalStatus> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  LegalStatusesCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return LegalStatusesCompanion(id: id ?? this.id, name: name ?? this.name);
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LegalStatusesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $FarmsTable extends Farms with TableInfo<$FarmsTable, Farm> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FarmsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _farmerIdMeta = const VerificationMeta(
    'farmerId',
  );
  @override
  late final GeneratedColumn<int> farmerId = GeneratedColumn<int>(
    'farmer_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _referenceNoMeta = const VerificationMeta(
    'referenceNo',
  );
  @override
  late final GeneratedColumn<String> referenceNo = GeneratedColumn<String>(
    'reference_no',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _regionalRegNoMeta = const VerificationMeta(
    'regionalRegNo',
  );
  @override
  late final GeneratedColumn<String> regionalRegNo = GeneratedColumn<String>(
    'regional_reg_no',
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
  static const VerificationMeta _sizeMeta = const VerificationMeta('size');
  @override
  late final GeneratedColumn<String> size = GeneratedColumn<String>(
    'size',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeUnitMeta = const VerificationMeta(
    'sizeUnit',
  );
  @override
  late final GeneratedColumn<String> sizeUnit = GeneratedColumn<String>(
    'size_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudesMeta = const VerificationMeta(
    'latitudes',
  );
  @override
  late final GeneratedColumn<String> latitudes = GeneratedColumn<String>(
    'latitudes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudesMeta = const VerificationMeta(
    'longitudes',
  );
  @override
  late final GeneratedColumn<String> longitudes = GeneratedColumn<String>(
    'longitudes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _physicalAddressMeta = const VerificationMeta(
    'physicalAddress',
  );
  @override
  late final GeneratedColumn<String> physicalAddress = GeneratedColumn<String>(
    'physical_address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _villageIdMeta = const VerificationMeta(
    'villageId',
  );
  @override
  late final GeneratedColumn<int> villageId = GeneratedColumn<int>(
    'village_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _wardIdMeta = const VerificationMeta('wardId');
  @override
  late final GeneratedColumn<int> wardId = GeneratedColumn<int>(
    'ward_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES wards (id)',
    ),
  );
  static const VerificationMeta _districtIdMeta = const VerificationMeta(
    'districtId',
  );
  @override
  late final GeneratedColumn<int> districtId = GeneratedColumn<int>(
    'district_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES districts (id)',
    ),
  );
  static const VerificationMeta _regionIdMeta = const VerificationMeta(
    'regionId',
  );
  @override
  late final GeneratedColumn<int> regionId = GeneratedColumn<int>(
    'region_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES regions (id)',
    ),
  );
  static const VerificationMeta _countryIdMeta = const VerificationMeta(
    'countryId',
  );
  @override
  late final GeneratedColumn<int> countryId = GeneratedColumn<int>(
    'country_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES countries (id)',
    ),
  );
  static const VerificationMeta _legalStatusIdMeta = const VerificationMeta(
    'legalStatusId',
  );
  @override
  late final GeneratedColumn<int> legalStatusId = GeneratedColumn<int>(
    'legal_status_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES legal_statuses (id)',
    ),
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
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncActionMeta = const VerificationMeta(
    'syncAction',
  );
  @override
  late final GeneratedColumn<String> syncAction = GeneratedColumn<String>(
    'sync_action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('create'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    farmerId,
    uuid,
    referenceNo,
    regionalRegNo,
    name,
    size,
    sizeUnit,
    latitudes,
    longitudes,
    physicalAddress,
    villageId,
    wardId,
    districtId,
    regionId,
    countryId,
    legalStatusId,
    status,
    synced,
    syncAction,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'farms';
  @override
  VerificationContext validateIntegrity(
    Insertable<Farm> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('farmer_id')) {
      context.handle(
        _farmerIdMeta,
        farmerId.isAcceptableOrUnknown(data['farmer_id']!, _farmerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmerIdMeta);
    }
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('reference_no')) {
      context.handle(
        _referenceNoMeta,
        referenceNo.isAcceptableOrUnknown(
          data['reference_no']!,
          _referenceNoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_referenceNoMeta);
    }
    if (data.containsKey('regional_reg_no')) {
      context.handle(
        _regionalRegNoMeta,
        regionalRegNo.isAcceptableOrUnknown(
          data['regional_reg_no']!,
          _regionalRegNoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_regionalRegNoMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('size')) {
      context.handle(
        _sizeMeta,
        size.isAcceptableOrUnknown(data['size']!, _sizeMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeMeta);
    }
    if (data.containsKey('size_unit')) {
      context.handle(
        _sizeUnitMeta,
        sizeUnit.isAcceptableOrUnknown(data['size_unit']!, _sizeUnitMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeUnitMeta);
    }
    if (data.containsKey('latitudes')) {
      context.handle(
        _latitudesMeta,
        latitudes.isAcceptableOrUnknown(data['latitudes']!, _latitudesMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudesMeta);
    }
    if (data.containsKey('longitudes')) {
      context.handle(
        _longitudesMeta,
        longitudes.isAcceptableOrUnknown(data['longitudes']!, _longitudesMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudesMeta);
    }
    if (data.containsKey('physical_address')) {
      context.handle(
        _physicalAddressMeta,
        physicalAddress.isAcceptableOrUnknown(
          data['physical_address']!,
          _physicalAddressMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_physicalAddressMeta);
    }
    if (data.containsKey('village_id')) {
      context.handle(
        _villageIdMeta,
        villageId.isAcceptableOrUnknown(data['village_id']!, _villageIdMeta),
      );
    }
    if (data.containsKey('ward_id')) {
      context.handle(
        _wardIdMeta,
        wardId.isAcceptableOrUnknown(data['ward_id']!, _wardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_wardIdMeta);
    }
    if (data.containsKey('district_id')) {
      context.handle(
        _districtIdMeta,
        districtId.isAcceptableOrUnknown(data['district_id']!, _districtIdMeta),
      );
    } else if (isInserting) {
      context.missing(_districtIdMeta);
    }
    if (data.containsKey('region_id')) {
      context.handle(
        _regionIdMeta,
        regionId.isAcceptableOrUnknown(data['region_id']!, _regionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_regionIdMeta);
    }
    if (data.containsKey('country_id')) {
      context.handle(
        _countryIdMeta,
        countryId.isAcceptableOrUnknown(data['country_id']!, _countryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_countryIdMeta);
    }
    if (data.containsKey('legal_status_id')) {
      context.handle(
        _legalStatusIdMeta,
        legalStatusId.isAcceptableOrUnknown(
          data['legal_status_id']!,
          _legalStatusIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_legalStatusIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    if (data.containsKey('sync_action')) {
      context.handle(
        _syncActionMeta,
        syncAction.isAcceptableOrUnknown(data['sync_action']!, _syncActionMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Farm map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Farm(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      farmerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}farmer_id'],
      )!,
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      referenceNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_no'],
      )!,
      regionalRegNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}regional_reg_no'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      size: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}size'],
      )!,
      sizeUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}size_unit'],
      )!,
      latitudes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}latitudes'],
      )!,
      longitudes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}longitudes'],
      )!,
      physicalAddress: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}physical_address'],
      )!,
      villageId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}village_id'],
      ),
      wardId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ward_id'],
      )!,
      districtId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}district_id'],
      )!,
      regionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}region_id'],
      )!,
      countryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}country_id'],
      )!,
      legalStatusId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}legal_status_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
      syncAction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_action'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FarmsTable createAlias(String alias) {
    return $FarmsTable(attachedDatabase, alias);
  }
}

class Farm extends DataClass implements Insertable<Farm> {
  final int id;
  final int farmerId;
  final String uuid;
  final String referenceNo;
  final String regionalRegNo;
  final String name;
  final String size;
  final String sizeUnit;
  final String latitudes;
  final String longitudes;
  final String physicalAddress;
  final int? villageId;
  final int wardId;
  final int districtId;
  final int regionId;
  final int countryId;
  final int legalStatusId;
  final String status;
  final bool synced;
  final String syncAction;
  final String createdAt;
  final String updatedAt;
  const Farm({
    required this.id,
    required this.farmerId,
    required this.uuid,
    required this.referenceNo,
    required this.regionalRegNo,
    required this.name,
    required this.size,
    required this.sizeUnit,
    required this.latitudes,
    required this.longitudes,
    required this.physicalAddress,
    this.villageId,
    required this.wardId,
    required this.districtId,
    required this.regionId,
    required this.countryId,
    required this.legalStatusId,
    required this.status,
    required this.synced,
    required this.syncAction,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['farmer_id'] = Variable<int>(farmerId);
    map['uuid'] = Variable<String>(uuid);
    map['reference_no'] = Variable<String>(referenceNo);
    map['regional_reg_no'] = Variable<String>(regionalRegNo);
    map['name'] = Variable<String>(name);
    map['size'] = Variable<String>(size);
    map['size_unit'] = Variable<String>(sizeUnit);
    map['latitudes'] = Variable<String>(latitudes);
    map['longitudes'] = Variable<String>(longitudes);
    map['physical_address'] = Variable<String>(physicalAddress);
    if (!nullToAbsent || villageId != null) {
      map['village_id'] = Variable<int>(villageId);
    }
    map['ward_id'] = Variable<int>(wardId);
    map['district_id'] = Variable<int>(districtId);
    map['region_id'] = Variable<int>(regionId);
    map['country_id'] = Variable<int>(countryId);
    map['legal_status_id'] = Variable<int>(legalStatusId);
    map['status'] = Variable<String>(status);
    map['synced'] = Variable<bool>(synced);
    map['sync_action'] = Variable<String>(syncAction);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  FarmsCompanion toCompanion(bool nullToAbsent) {
    return FarmsCompanion(
      id: Value(id),
      farmerId: Value(farmerId),
      uuid: Value(uuid),
      referenceNo: Value(referenceNo),
      regionalRegNo: Value(regionalRegNo),
      name: Value(name),
      size: Value(size),
      sizeUnit: Value(sizeUnit),
      latitudes: Value(latitudes),
      longitudes: Value(longitudes),
      physicalAddress: Value(physicalAddress),
      villageId: villageId == null && nullToAbsent
          ? const Value.absent()
          : Value(villageId),
      wardId: Value(wardId),
      districtId: Value(districtId),
      regionId: Value(regionId),
      countryId: Value(countryId),
      legalStatusId: Value(legalStatusId),
      status: Value(status),
      synced: Value(synced),
      syncAction: Value(syncAction),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Farm.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Farm(
      id: serializer.fromJson<int>(json['id']),
      farmerId: serializer.fromJson<int>(json['farmerId']),
      uuid: serializer.fromJson<String>(json['uuid']),
      referenceNo: serializer.fromJson<String>(json['referenceNo']),
      regionalRegNo: serializer.fromJson<String>(json['regionalRegNo']),
      name: serializer.fromJson<String>(json['name']),
      size: serializer.fromJson<String>(json['size']),
      sizeUnit: serializer.fromJson<String>(json['sizeUnit']),
      latitudes: serializer.fromJson<String>(json['latitudes']),
      longitudes: serializer.fromJson<String>(json['longitudes']),
      physicalAddress: serializer.fromJson<String>(json['physicalAddress']),
      villageId: serializer.fromJson<int?>(json['villageId']),
      wardId: serializer.fromJson<int>(json['wardId']),
      districtId: serializer.fromJson<int>(json['districtId']),
      regionId: serializer.fromJson<int>(json['regionId']),
      countryId: serializer.fromJson<int>(json['countryId']),
      legalStatusId: serializer.fromJson<int>(json['legalStatusId']),
      status: serializer.fromJson<String>(json['status']),
      synced: serializer.fromJson<bool>(json['synced']),
      syncAction: serializer.fromJson<String>(json['syncAction']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'farmerId': serializer.toJson<int>(farmerId),
      'uuid': serializer.toJson<String>(uuid),
      'referenceNo': serializer.toJson<String>(referenceNo),
      'regionalRegNo': serializer.toJson<String>(regionalRegNo),
      'name': serializer.toJson<String>(name),
      'size': serializer.toJson<String>(size),
      'sizeUnit': serializer.toJson<String>(sizeUnit),
      'latitudes': serializer.toJson<String>(latitudes),
      'longitudes': serializer.toJson<String>(longitudes),
      'physicalAddress': serializer.toJson<String>(physicalAddress),
      'villageId': serializer.toJson<int?>(villageId),
      'wardId': serializer.toJson<int>(wardId),
      'districtId': serializer.toJson<int>(districtId),
      'regionId': serializer.toJson<int>(regionId),
      'countryId': serializer.toJson<int>(countryId),
      'legalStatusId': serializer.toJson<int>(legalStatusId),
      'status': serializer.toJson<String>(status),
      'synced': serializer.toJson<bool>(synced),
      'syncAction': serializer.toJson<String>(syncAction),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  Farm copyWith({
    int? id,
    int? farmerId,
    String? uuid,
    String? referenceNo,
    String? regionalRegNo,
    String? name,
    String? size,
    String? sizeUnit,
    String? latitudes,
    String? longitudes,
    String? physicalAddress,
    Value<int?> villageId = const Value.absent(),
    int? wardId,
    int? districtId,
    int? regionId,
    int? countryId,
    int? legalStatusId,
    String? status,
    bool? synced,
    String? syncAction,
    String? createdAt,
    String? updatedAt,
  }) => Farm(
    id: id ?? this.id,
    farmerId: farmerId ?? this.farmerId,
    uuid: uuid ?? this.uuid,
    referenceNo: referenceNo ?? this.referenceNo,
    regionalRegNo: regionalRegNo ?? this.regionalRegNo,
    name: name ?? this.name,
    size: size ?? this.size,
    sizeUnit: sizeUnit ?? this.sizeUnit,
    latitudes: latitudes ?? this.latitudes,
    longitudes: longitudes ?? this.longitudes,
    physicalAddress: physicalAddress ?? this.physicalAddress,
    villageId: villageId.present ? villageId.value : this.villageId,
    wardId: wardId ?? this.wardId,
    districtId: districtId ?? this.districtId,
    regionId: regionId ?? this.regionId,
    countryId: countryId ?? this.countryId,
    legalStatusId: legalStatusId ?? this.legalStatusId,
    status: status ?? this.status,
    synced: synced ?? this.synced,
    syncAction: syncAction ?? this.syncAction,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Farm copyWithCompanion(FarmsCompanion data) {
    return Farm(
      id: data.id.present ? data.id.value : this.id,
      farmerId: data.farmerId.present ? data.farmerId.value : this.farmerId,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      referenceNo: data.referenceNo.present
          ? data.referenceNo.value
          : this.referenceNo,
      regionalRegNo: data.regionalRegNo.present
          ? data.regionalRegNo.value
          : this.regionalRegNo,
      name: data.name.present ? data.name.value : this.name,
      size: data.size.present ? data.size.value : this.size,
      sizeUnit: data.sizeUnit.present ? data.sizeUnit.value : this.sizeUnit,
      latitudes: data.latitudes.present ? data.latitudes.value : this.latitudes,
      longitudes: data.longitudes.present
          ? data.longitudes.value
          : this.longitudes,
      physicalAddress: data.physicalAddress.present
          ? data.physicalAddress.value
          : this.physicalAddress,
      villageId: data.villageId.present ? data.villageId.value : this.villageId,
      wardId: data.wardId.present ? data.wardId.value : this.wardId,
      districtId: data.districtId.present
          ? data.districtId.value
          : this.districtId,
      regionId: data.regionId.present ? data.regionId.value : this.regionId,
      countryId: data.countryId.present ? data.countryId.value : this.countryId,
      legalStatusId: data.legalStatusId.present
          ? data.legalStatusId.value
          : this.legalStatusId,
      status: data.status.present ? data.status.value : this.status,
      synced: data.synced.present ? data.synced.value : this.synced,
      syncAction: data.syncAction.present
          ? data.syncAction.value
          : this.syncAction,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Farm(')
          ..write('id: $id, ')
          ..write('farmerId: $farmerId, ')
          ..write('uuid: $uuid, ')
          ..write('referenceNo: $referenceNo, ')
          ..write('regionalRegNo: $regionalRegNo, ')
          ..write('name: $name, ')
          ..write('size: $size, ')
          ..write('sizeUnit: $sizeUnit, ')
          ..write('latitudes: $latitudes, ')
          ..write('longitudes: $longitudes, ')
          ..write('physicalAddress: $physicalAddress, ')
          ..write('villageId: $villageId, ')
          ..write('wardId: $wardId, ')
          ..write('districtId: $districtId, ')
          ..write('regionId: $regionId, ')
          ..write('countryId: $countryId, ')
          ..write('legalStatusId: $legalStatusId, ')
          ..write('status: $status, ')
          ..write('synced: $synced, ')
          ..write('syncAction: $syncAction, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    farmerId,
    uuid,
    referenceNo,
    regionalRegNo,
    name,
    size,
    sizeUnit,
    latitudes,
    longitudes,
    physicalAddress,
    villageId,
    wardId,
    districtId,
    regionId,
    countryId,
    legalStatusId,
    status,
    synced,
    syncAction,
    createdAt,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Farm &&
          other.id == this.id &&
          other.farmerId == this.farmerId &&
          other.uuid == this.uuid &&
          other.referenceNo == this.referenceNo &&
          other.regionalRegNo == this.regionalRegNo &&
          other.name == this.name &&
          other.size == this.size &&
          other.sizeUnit == this.sizeUnit &&
          other.latitudes == this.latitudes &&
          other.longitudes == this.longitudes &&
          other.physicalAddress == this.physicalAddress &&
          other.villageId == this.villageId &&
          other.wardId == this.wardId &&
          other.districtId == this.districtId &&
          other.regionId == this.regionId &&
          other.countryId == this.countryId &&
          other.legalStatusId == this.legalStatusId &&
          other.status == this.status &&
          other.synced == this.synced &&
          other.syncAction == this.syncAction &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FarmsCompanion extends UpdateCompanion<Farm> {
  final Value<int> id;
  final Value<int> farmerId;
  final Value<String> uuid;
  final Value<String> referenceNo;
  final Value<String> regionalRegNo;
  final Value<String> name;
  final Value<String> size;
  final Value<String> sizeUnit;
  final Value<String> latitudes;
  final Value<String> longitudes;
  final Value<String> physicalAddress;
  final Value<int?> villageId;
  final Value<int> wardId;
  final Value<int> districtId;
  final Value<int> regionId;
  final Value<int> countryId;
  final Value<int> legalStatusId;
  final Value<String> status;
  final Value<bool> synced;
  final Value<String> syncAction;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  const FarmsCompanion({
    this.id = const Value.absent(),
    this.farmerId = const Value.absent(),
    this.uuid = const Value.absent(),
    this.referenceNo = const Value.absent(),
    this.regionalRegNo = const Value.absent(),
    this.name = const Value.absent(),
    this.size = const Value.absent(),
    this.sizeUnit = const Value.absent(),
    this.latitudes = const Value.absent(),
    this.longitudes = const Value.absent(),
    this.physicalAddress = const Value.absent(),
    this.villageId = const Value.absent(),
    this.wardId = const Value.absent(),
    this.districtId = const Value.absent(),
    this.regionId = const Value.absent(),
    this.countryId = const Value.absent(),
    this.legalStatusId = const Value.absent(),
    this.status = const Value.absent(),
    this.synced = const Value.absent(),
    this.syncAction = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  FarmsCompanion.insert({
    this.id = const Value.absent(),
    required int farmerId,
    required String uuid,
    required String referenceNo,
    required String regionalRegNo,
    required String name,
    required String size,
    required String sizeUnit,
    required String latitudes,
    required String longitudes,
    required String physicalAddress,
    this.villageId = const Value.absent(),
    required int wardId,
    required int districtId,
    required int regionId,
    required int countryId,
    required int legalStatusId,
    this.status = const Value.absent(),
    this.synced = const Value.absent(),
    this.syncAction = const Value.absent(),
    required String createdAt,
    required String updatedAt,
  }) : farmerId = Value(farmerId),
       uuid = Value(uuid),
       referenceNo = Value(referenceNo),
       regionalRegNo = Value(regionalRegNo),
       name = Value(name),
       size = Value(size),
       sizeUnit = Value(sizeUnit),
       latitudes = Value(latitudes),
       longitudes = Value(longitudes),
       physicalAddress = Value(physicalAddress),
       wardId = Value(wardId),
       districtId = Value(districtId),
       regionId = Value(regionId),
       countryId = Value(countryId),
       legalStatusId = Value(legalStatusId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Farm> custom({
    Expression<int>? id,
    Expression<int>? farmerId,
    Expression<String>? uuid,
    Expression<String>? referenceNo,
    Expression<String>? regionalRegNo,
    Expression<String>? name,
    Expression<String>? size,
    Expression<String>? sizeUnit,
    Expression<String>? latitudes,
    Expression<String>? longitudes,
    Expression<String>? physicalAddress,
    Expression<int>? villageId,
    Expression<int>? wardId,
    Expression<int>? districtId,
    Expression<int>? regionId,
    Expression<int>? countryId,
    Expression<int>? legalStatusId,
    Expression<String>? status,
    Expression<bool>? synced,
    Expression<String>? syncAction,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmerId != null) 'farmer_id': farmerId,
      if (uuid != null) 'uuid': uuid,
      if (referenceNo != null) 'reference_no': referenceNo,
      if (regionalRegNo != null) 'regional_reg_no': regionalRegNo,
      if (name != null) 'name': name,
      if (size != null) 'size': size,
      if (sizeUnit != null) 'size_unit': sizeUnit,
      if (latitudes != null) 'latitudes': latitudes,
      if (longitudes != null) 'longitudes': longitudes,
      if (physicalAddress != null) 'physical_address': physicalAddress,
      if (villageId != null) 'village_id': villageId,
      if (wardId != null) 'ward_id': wardId,
      if (districtId != null) 'district_id': districtId,
      if (regionId != null) 'region_id': regionId,
      if (countryId != null) 'country_id': countryId,
      if (legalStatusId != null) 'legal_status_id': legalStatusId,
      if (status != null) 'status': status,
      if (synced != null) 'synced': synced,
      if (syncAction != null) 'sync_action': syncAction,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  FarmsCompanion copyWith({
    Value<int>? id,
    Value<int>? farmerId,
    Value<String>? uuid,
    Value<String>? referenceNo,
    Value<String>? regionalRegNo,
    Value<String>? name,
    Value<String>? size,
    Value<String>? sizeUnit,
    Value<String>? latitudes,
    Value<String>? longitudes,
    Value<String>? physicalAddress,
    Value<int?>? villageId,
    Value<int>? wardId,
    Value<int>? districtId,
    Value<int>? regionId,
    Value<int>? countryId,
    Value<int>? legalStatusId,
    Value<String>? status,
    Value<bool>? synced,
    Value<String>? syncAction,
    Value<String>? createdAt,
    Value<String>? updatedAt,
  }) {
    return FarmsCompanion(
      id: id ?? this.id,
      farmerId: farmerId ?? this.farmerId,
      uuid: uuid ?? this.uuid,
      referenceNo: referenceNo ?? this.referenceNo,
      regionalRegNo: regionalRegNo ?? this.regionalRegNo,
      name: name ?? this.name,
      size: size ?? this.size,
      sizeUnit: sizeUnit ?? this.sizeUnit,
      latitudes: latitudes ?? this.latitudes,
      longitudes: longitudes ?? this.longitudes,
      physicalAddress: physicalAddress ?? this.physicalAddress,
      villageId: villageId ?? this.villageId,
      wardId: wardId ?? this.wardId,
      districtId: districtId ?? this.districtId,
      regionId: regionId ?? this.regionId,
      countryId: countryId ?? this.countryId,
      legalStatusId: legalStatusId ?? this.legalStatusId,
      status: status ?? this.status,
      synced: synced ?? this.synced,
      syncAction: syncAction ?? this.syncAction,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (farmerId.present) {
      map['farmer_id'] = Variable<int>(farmerId.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (referenceNo.present) {
      map['reference_no'] = Variable<String>(referenceNo.value);
    }
    if (regionalRegNo.present) {
      map['regional_reg_no'] = Variable<String>(regionalRegNo.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (size.present) {
      map['size'] = Variable<String>(size.value);
    }
    if (sizeUnit.present) {
      map['size_unit'] = Variable<String>(sizeUnit.value);
    }
    if (latitudes.present) {
      map['latitudes'] = Variable<String>(latitudes.value);
    }
    if (longitudes.present) {
      map['longitudes'] = Variable<String>(longitudes.value);
    }
    if (physicalAddress.present) {
      map['physical_address'] = Variable<String>(physicalAddress.value);
    }
    if (villageId.present) {
      map['village_id'] = Variable<int>(villageId.value);
    }
    if (wardId.present) {
      map['ward_id'] = Variable<int>(wardId.value);
    }
    if (districtId.present) {
      map['district_id'] = Variable<int>(districtId.value);
    }
    if (regionId.present) {
      map['region_id'] = Variable<int>(regionId.value);
    }
    if (countryId.present) {
      map['country_id'] = Variable<int>(countryId.value);
    }
    if (legalStatusId.present) {
      map['legal_status_id'] = Variable<int>(legalStatusId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (syncAction.present) {
      map['sync_action'] = Variable<String>(syncAction.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FarmsCompanion(')
          ..write('id: $id, ')
          ..write('farmerId: $farmerId, ')
          ..write('uuid: $uuid, ')
          ..write('referenceNo: $referenceNo, ')
          ..write('regionalRegNo: $regionalRegNo, ')
          ..write('name: $name, ')
          ..write('size: $size, ')
          ..write('sizeUnit: $sizeUnit, ')
          ..write('latitudes: $latitudes, ')
          ..write('longitudes: $longitudes, ')
          ..write('physicalAddress: $physicalAddress, ')
          ..write('villageId: $villageId, ')
          ..write('wardId: $wardId, ')
          ..write('districtId: $districtId, ')
          ..write('regionId: $regionId, ')
          ..write('countryId: $countryId, ')
          ..write('legalStatusId: $legalStatusId, ')
          ..write('status: $status, ')
          ..write('synced: $synced, ')
          ..write('syncAction: $syncAction, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $LivestocksTable extends Livestocks
    with TableInfo<$LivestocksTable, Livestock> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LivestocksTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _farmUuidMeta = const VerificationMeta(
    'farmUuid',
  );
  @override
  late final GeneratedColumn<String> farmUuid = GeneratedColumn<String>(
    'farm_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _identificationNumberMeta =
      const VerificationMeta('identificationNumber');
  @override
  late final GeneratedColumn<String> identificationNumber =
      GeneratedColumn<String>(
        'identification_number',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _dummyTagIdMeta = const VerificationMeta(
    'dummyTagId',
  );
  @override
  late final GeneratedColumn<String> dummyTagId = GeneratedColumn<String>(
    'dummy_tag_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _barcodeTagIdMeta = const VerificationMeta(
    'barcodeTagId',
  );
  @override
  late final GeneratedColumn<String> barcodeTagId = GeneratedColumn<String>(
    'barcode_tag_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _rfidTagIdMeta = const VerificationMeta(
    'rfidTagId',
  );
  @override
  late final GeneratedColumn<String> rfidTagId = GeneratedColumn<String>(
    'rfid_tag_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _livestockTypeIdMeta = const VerificationMeta(
    'livestockTypeId',
  );
  @override
  late final GeneratedColumn<int> livestockTypeId = GeneratedColumn<int>(
    'livestock_type_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  static const VerificationMeta _dateOfBirthMeta = const VerificationMeta(
    'dateOfBirth',
  );
  @override
  late final GeneratedColumn<String> dateOfBirth = GeneratedColumn<String>(
    'date_of_birth',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _motherUuidMeta = const VerificationMeta(
    'motherUuid',
  );
  @override
  late final GeneratedColumn<String> motherUuid = GeneratedColumn<String>(
    'mother_uuid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fatherUuidMeta = const VerificationMeta(
    'fatherUuid',
  );
  @override
  late final GeneratedColumn<String> fatherUuid = GeneratedColumn<String>(
    'father_uuid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
    'gender',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _breedIdMeta = const VerificationMeta(
    'breedId',
  );
  @override
  late final GeneratedColumn<int> breedId = GeneratedColumn<int>(
    'breed_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _speciesIdMeta = const VerificationMeta(
    'speciesId',
  );
  @override
  late final GeneratedColumn<int> speciesId = GeneratedColumn<int>(
    'species_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
  static const VerificationMeta _livestockObtainedMethodIdMeta =
      const VerificationMeta('livestockObtainedMethodId');
  @override
  late final GeneratedColumn<int> livestockObtainedMethodId =
      GeneratedColumn<int>(
        'livestock_obtained_method_id',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _dateFirstEnteredToFarmMeta =
      const VerificationMeta('dateFirstEnteredToFarm');
  @override
  late final GeneratedColumn<DateTime> dateFirstEnteredToFarm =
      GeneratedColumn<DateTime>(
        'date_first_entered_to_farm',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _weightAsOnRegistrationMeta =
      const VerificationMeta('weightAsOnRegistration');
  @override
  late final GeneratedColumn<double> weightAsOnRegistration =
      GeneratedColumn<double>(
        'weight_as_on_registration',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncActionMeta = const VerificationMeta(
    'syncAction',
  );
  @override
  late final GeneratedColumn<String> syncAction = GeneratedColumn<String>(
    'sync_action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('create'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    farmUuid,
    uuid,
    identificationNumber,
    dummyTagId,
    barcodeTagId,
    rfidTagId,
    livestockTypeId,
    name,
    dateOfBirth,
    motherUuid,
    fatherUuid,
    gender,
    breedId,
    speciesId,
    status,
    livestockObtainedMethodId,
    dateFirstEnteredToFarm,
    weightAsOnRegistration,
    synced,
    syncAction,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'livestocks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Livestock> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('farm_uuid')) {
      context.handle(
        _farmUuidMeta,
        farmUuid.isAcceptableOrUnknown(data['farm_uuid']!, _farmUuidMeta),
      );
    } else if (isInserting) {
      context.missing(_farmUuidMeta);
    }
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('identification_number')) {
      context.handle(
        _identificationNumberMeta,
        identificationNumber.isAcceptableOrUnknown(
          data['identification_number']!,
          _identificationNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_identificationNumberMeta);
    }
    if (data.containsKey('dummy_tag_id')) {
      context.handle(
        _dummyTagIdMeta,
        dummyTagId.isAcceptableOrUnknown(
          data['dummy_tag_id']!,
          _dummyTagIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dummyTagIdMeta);
    }
    if (data.containsKey('barcode_tag_id')) {
      context.handle(
        _barcodeTagIdMeta,
        barcodeTagId.isAcceptableOrUnknown(
          data['barcode_tag_id']!,
          _barcodeTagIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_barcodeTagIdMeta);
    }
    if (data.containsKey('rfid_tag_id')) {
      context.handle(
        _rfidTagIdMeta,
        rfidTagId.isAcceptableOrUnknown(data['rfid_tag_id']!, _rfidTagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rfidTagIdMeta);
    }
    if (data.containsKey('livestock_type_id')) {
      context.handle(
        _livestockTypeIdMeta,
        livestockTypeId.isAcceptableOrUnknown(
          data['livestock_type_id']!,
          _livestockTypeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_livestockTypeIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('date_of_birth')) {
      context.handle(
        _dateOfBirthMeta,
        dateOfBirth.isAcceptableOrUnknown(
          data['date_of_birth']!,
          _dateOfBirthMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dateOfBirthMeta);
    }
    if (data.containsKey('mother_uuid')) {
      context.handle(
        _motherUuidMeta,
        motherUuid.isAcceptableOrUnknown(data['mother_uuid']!, _motherUuidMeta),
      );
    }
    if (data.containsKey('father_uuid')) {
      context.handle(
        _fatherUuidMeta,
        fatherUuid.isAcceptableOrUnknown(data['father_uuid']!, _fatherUuidMeta),
      );
    }
    if (data.containsKey('gender')) {
      context.handle(
        _genderMeta,
        gender.isAcceptableOrUnknown(data['gender']!, _genderMeta),
      );
    } else if (isInserting) {
      context.missing(_genderMeta);
    }
    if (data.containsKey('breed_id')) {
      context.handle(
        _breedIdMeta,
        breedId.isAcceptableOrUnknown(data['breed_id']!, _breedIdMeta),
      );
    } else if (isInserting) {
      context.missing(_breedIdMeta);
    }
    if (data.containsKey('species_id')) {
      context.handle(
        _speciesIdMeta,
        speciesId.isAcceptableOrUnknown(data['species_id']!, _speciesIdMeta),
      );
    } else if (isInserting) {
      context.missing(_speciesIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('livestock_obtained_method_id')) {
      context.handle(
        _livestockObtainedMethodIdMeta,
        livestockObtainedMethodId.isAcceptableOrUnknown(
          data['livestock_obtained_method_id']!,
          _livestockObtainedMethodIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_livestockObtainedMethodIdMeta);
    }
    if (data.containsKey('date_first_entered_to_farm')) {
      context.handle(
        _dateFirstEnteredToFarmMeta,
        dateFirstEnteredToFarm.isAcceptableOrUnknown(
          data['date_first_entered_to_farm']!,
          _dateFirstEnteredToFarmMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dateFirstEnteredToFarmMeta);
    }
    if (data.containsKey('weight_as_on_registration')) {
      context.handle(
        _weightAsOnRegistrationMeta,
        weightAsOnRegistration.isAcceptableOrUnknown(
          data['weight_as_on_registration']!,
          _weightAsOnRegistrationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_weightAsOnRegistrationMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    if (data.containsKey('sync_action')) {
      context.handle(
        _syncActionMeta,
        syncAction.isAcceptableOrUnknown(data['sync_action']!, _syncActionMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Livestock map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Livestock(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      farmUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_uuid'],
      )!,
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      identificationNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}identification_number'],
      )!,
      dummyTagId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dummy_tag_id'],
      )!,
      barcodeTagId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode_tag_id'],
      )!,
      rfidTagId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rfid_tag_id'],
      )!,
      livestockTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}livestock_type_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      dateOfBirth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_of_birth'],
      )!,
      motherUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mother_uuid'],
      ),
      fatherUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}father_uuid'],
      ),
      gender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gender'],
      )!,
      breedId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}breed_id'],
      )!,
      speciesId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}species_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      livestockObtainedMethodId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}livestock_obtained_method_id'],
      )!,
      dateFirstEnteredToFarm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_first_entered_to_farm'],
      )!,
      weightAsOnRegistration: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_as_on_registration'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
      syncAction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_action'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LivestocksTable createAlias(String alias) {
    return $LivestocksTable(attachedDatabase, alias);
  }
}

class Livestock extends DataClass implements Insertable<Livestock> {
  final int id;
  final String farmUuid;
  final String uuid;
  final String identificationNumber;
  final String dummyTagId;
  final String barcodeTagId;
  final String rfidTagId;
  final int livestockTypeId;
  final String name;
  final String dateOfBirth;
  final String? motherUuid;
  final String? fatherUuid;
  final String gender;
  final int breedId;
  final int speciesId;
  final String status;
  final int livestockObtainedMethodId;
  final DateTime dateFirstEnteredToFarm;
  final double weightAsOnRegistration;
  final bool synced;
  final String syncAction;
  final String createdAt;
  final String updatedAt;
  const Livestock({
    required this.id,
    required this.farmUuid,
    required this.uuid,
    required this.identificationNumber,
    required this.dummyTagId,
    required this.barcodeTagId,
    required this.rfidTagId,
    required this.livestockTypeId,
    required this.name,
    required this.dateOfBirth,
    this.motherUuid,
    this.fatherUuid,
    required this.gender,
    required this.breedId,
    required this.speciesId,
    required this.status,
    required this.livestockObtainedMethodId,
    required this.dateFirstEnteredToFarm,
    required this.weightAsOnRegistration,
    required this.synced,
    required this.syncAction,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['farm_uuid'] = Variable<String>(farmUuid);
    map['uuid'] = Variable<String>(uuid);
    map['identification_number'] = Variable<String>(identificationNumber);
    map['dummy_tag_id'] = Variable<String>(dummyTagId);
    map['barcode_tag_id'] = Variable<String>(barcodeTagId);
    map['rfid_tag_id'] = Variable<String>(rfidTagId);
    map['livestock_type_id'] = Variable<int>(livestockTypeId);
    map['name'] = Variable<String>(name);
    map['date_of_birth'] = Variable<String>(dateOfBirth);
    if (!nullToAbsent || motherUuid != null) {
      map['mother_uuid'] = Variable<String>(motherUuid);
    }
    if (!nullToAbsent || fatherUuid != null) {
      map['father_uuid'] = Variable<String>(fatherUuid);
    }
    map['gender'] = Variable<String>(gender);
    map['breed_id'] = Variable<int>(breedId);
    map['species_id'] = Variable<int>(speciesId);
    map['status'] = Variable<String>(status);
    map['livestock_obtained_method_id'] = Variable<int>(
      livestockObtainedMethodId,
    );
    map['date_first_entered_to_farm'] = Variable<DateTime>(
      dateFirstEnteredToFarm,
    );
    map['weight_as_on_registration'] = Variable<double>(weightAsOnRegistration);
    map['synced'] = Variable<bool>(synced);
    map['sync_action'] = Variable<String>(syncAction);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  LivestocksCompanion toCompanion(bool nullToAbsent) {
    return LivestocksCompanion(
      id: Value(id),
      farmUuid: Value(farmUuid),
      uuid: Value(uuid),
      identificationNumber: Value(identificationNumber),
      dummyTagId: Value(dummyTagId),
      barcodeTagId: Value(barcodeTagId),
      rfidTagId: Value(rfidTagId),
      livestockTypeId: Value(livestockTypeId),
      name: Value(name),
      dateOfBirth: Value(dateOfBirth),
      motherUuid: motherUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(motherUuid),
      fatherUuid: fatherUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(fatherUuid),
      gender: Value(gender),
      breedId: Value(breedId),
      speciesId: Value(speciesId),
      status: Value(status),
      livestockObtainedMethodId: Value(livestockObtainedMethodId),
      dateFirstEnteredToFarm: Value(dateFirstEnteredToFarm),
      weightAsOnRegistration: Value(weightAsOnRegistration),
      synced: Value(synced),
      syncAction: Value(syncAction),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Livestock.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Livestock(
      id: serializer.fromJson<int>(json['id']),
      farmUuid: serializer.fromJson<String>(json['farmUuid']),
      uuid: serializer.fromJson<String>(json['uuid']),
      identificationNumber: serializer.fromJson<String>(
        json['identificationNumber'],
      ),
      dummyTagId: serializer.fromJson<String>(json['dummyTagId']),
      barcodeTagId: serializer.fromJson<String>(json['barcodeTagId']),
      rfidTagId: serializer.fromJson<String>(json['rfidTagId']),
      livestockTypeId: serializer.fromJson<int>(json['livestockTypeId']),
      name: serializer.fromJson<String>(json['name']),
      dateOfBirth: serializer.fromJson<String>(json['dateOfBirth']),
      motherUuid: serializer.fromJson<String?>(json['motherUuid']),
      fatherUuid: serializer.fromJson<String?>(json['fatherUuid']),
      gender: serializer.fromJson<String>(json['gender']),
      breedId: serializer.fromJson<int>(json['breedId']),
      speciesId: serializer.fromJson<int>(json['speciesId']),
      status: serializer.fromJson<String>(json['status']),
      livestockObtainedMethodId: serializer.fromJson<int>(
        json['livestockObtainedMethodId'],
      ),
      dateFirstEnteredToFarm: serializer.fromJson<DateTime>(
        json['dateFirstEnteredToFarm'],
      ),
      weightAsOnRegistration: serializer.fromJson<double>(
        json['weightAsOnRegistration'],
      ),
      synced: serializer.fromJson<bool>(json['synced']),
      syncAction: serializer.fromJson<String>(json['syncAction']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'farmUuid': serializer.toJson<String>(farmUuid),
      'uuid': serializer.toJson<String>(uuid),
      'identificationNumber': serializer.toJson<String>(identificationNumber),
      'dummyTagId': serializer.toJson<String>(dummyTagId),
      'barcodeTagId': serializer.toJson<String>(barcodeTagId),
      'rfidTagId': serializer.toJson<String>(rfidTagId),
      'livestockTypeId': serializer.toJson<int>(livestockTypeId),
      'name': serializer.toJson<String>(name),
      'dateOfBirth': serializer.toJson<String>(dateOfBirth),
      'motherUuid': serializer.toJson<String?>(motherUuid),
      'fatherUuid': serializer.toJson<String?>(fatherUuid),
      'gender': serializer.toJson<String>(gender),
      'breedId': serializer.toJson<int>(breedId),
      'speciesId': serializer.toJson<int>(speciesId),
      'status': serializer.toJson<String>(status),
      'livestockObtainedMethodId': serializer.toJson<int>(
        livestockObtainedMethodId,
      ),
      'dateFirstEnteredToFarm': serializer.toJson<DateTime>(
        dateFirstEnteredToFarm,
      ),
      'weightAsOnRegistration': serializer.toJson<double>(
        weightAsOnRegistration,
      ),
      'synced': serializer.toJson<bool>(synced),
      'syncAction': serializer.toJson<String>(syncAction),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  Livestock copyWith({
    int? id,
    String? farmUuid,
    String? uuid,
    String? identificationNumber,
    String? dummyTagId,
    String? barcodeTagId,
    String? rfidTagId,
    int? livestockTypeId,
    String? name,
    String? dateOfBirth,
    Value<String?> motherUuid = const Value.absent(),
    Value<String?> fatherUuid = const Value.absent(),
    String? gender,
    int? breedId,
    int? speciesId,
    String? status,
    int? livestockObtainedMethodId,
    DateTime? dateFirstEnteredToFarm,
    double? weightAsOnRegistration,
    bool? synced,
    String? syncAction,
    String? createdAt,
    String? updatedAt,
  }) => Livestock(
    id: id ?? this.id,
    farmUuid: farmUuid ?? this.farmUuid,
    uuid: uuid ?? this.uuid,
    identificationNumber: identificationNumber ?? this.identificationNumber,
    dummyTagId: dummyTagId ?? this.dummyTagId,
    barcodeTagId: barcodeTagId ?? this.barcodeTagId,
    rfidTagId: rfidTagId ?? this.rfidTagId,
    livestockTypeId: livestockTypeId ?? this.livestockTypeId,
    name: name ?? this.name,
    dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    motherUuid: motherUuid.present ? motherUuid.value : this.motherUuid,
    fatherUuid: fatherUuid.present ? fatherUuid.value : this.fatherUuid,
    gender: gender ?? this.gender,
    breedId: breedId ?? this.breedId,
    speciesId: speciesId ?? this.speciesId,
    status: status ?? this.status,
    livestockObtainedMethodId:
        livestockObtainedMethodId ?? this.livestockObtainedMethodId,
    dateFirstEnteredToFarm:
        dateFirstEnteredToFarm ?? this.dateFirstEnteredToFarm,
    weightAsOnRegistration:
        weightAsOnRegistration ?? this.weightAsOnRegistration,
    synced: synced ?? this.synced,
    syncAction: syncAction ?? this.syncAction,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Livestock copyWithCompanion(LivestocksCompanion data) {
    return Livestock(
      id: data.id.present ? data.id.value : this.id,
      farmUuid: data.farmUuid.present ? data.farmUuid.value : this.farmUuid,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      identificationNumber: data.identificationNumber.present
          ? data.identificationNumber.value
          : this.identificationNumber,
      dummyTagId: data.dummyTagId.present
          ? data.dummyTagId.value
          : this.dummyTagId,
      barcodeTagId: data.barcodeTagId.present
          ? data.barcodeTagId.value
          : this.barcodeTagId,
      rfidTagId: data.rfidTagId.present ? data.rfidTagId.value : this.rfidTagId,
      livestockTypeId: data.livestockTypeId.present
          ? data.livestockTypeId.value
          : this.livestockTypeId,
      name: data.name.present ? data.name.value : this.name,
      dateOfBirth: data.dateOfBirth.present
          ? data.dateOfBirth.value
          : this.dateOfBirth,
      motherUuid: data.motherUuid.present
          ? data.motherUuid.value
          : this.motherUuid,
      fatherUuid: data.fatherUuid.present
          ? data.fatherUuid.value
          : this.fatherUuid,
      gender: data.gender.present ? data.gender.value : this.gender,
      breedId: data.breedId.present ? data.breedId.value : this.breedId,
      speciesId: data.speciesId.present ? data.speciesId.value : this.speciesId,
      status: data.status.present ? data.status.value : this.status,
      livestockObtainedMethodId: data.livestockObtainedMethodId.present
          ? data.livestockObtainedMethodId.value
          : this.livestockObtainedMethodId,
      dateFirstEnteredToFarm: data.dateFirstEnteredToFarm.present
          ? data.dateFirstEnteredToFarm.value
          : this.dateFirstEnteredToFarm,
      weightAsOnRegistration: data.weightAsOnRegistration.present
          ? data.weightAsOnRegistration.value
          : this.weightAsOnRegistration,
      synced: data.synced.present ? data.synced.value : this.synced,
      syncAction: data.syncAction.present
          ? data.syncAction.value
          : this.syncAction,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Livestock(')
          ..write('id: $id, ')
          ..write('farmUuid: $farmUuid, ')
          ..write('uuid: $uuid, ')
          ..write('identificationNumber: $identificationNumber, ')
          ..write('dummyTagId: $dummyTagId, ')
          ..write('barcodeTagId: $barcodeTagId, ')
          ..write('rfidTagId: $rfidTagId, ')
          ..write('livestockTypeId: $livestockTypeId, ')
          ..write('name: $name, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('motherUuid: $motherUuid, ')
          ..write('fatherUuid: $fatherUuid, ')
          ..write('gender: $gender, ')
          ..write('breedId: $breedId, ')
          ..write('speciesId: $speciesId, ')
          ..write('status: $status, ')
          ..write('livestockObtainedMethodId: $livestockObtainedMethodId, ')
          ..write('dateFirstEnteredToFarm: $dateFirstEnteredToFarm, ')
          ..write('weightAsOnRegistration: $weightAsOnRegistration, ')
          ..write('synced: $synced, ')
          ..write('syncAction: $syncAction, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    farmUuid,
    uuid,
    identificationNumber,
    dummyTagId,
    barcodeTagId,
    rfidTagId,
    livestockTypeId,
    name,
    dateOfBirth,
    motherUuid,
    fatherUuid,
    gender,
    breedId,
    speciesId,
    status,
    livestockObtainedMethodId,
    dateFirstEnteredToFarm,
    weightAsOnRegistration,
    synced,
    syncAction,
    createdAt,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Livestock &&
          other.id == this.id &&
          other.farmUuid == this.farmUuid &&
          other.uuid == this.uuid &&
          other.identificationNumber == this.identificationNumber &&
          other.dummyTagId == this.dummyTagId &&
          other.barcodeTagId == this.barcodeTagId &&
          other.rfidTagId == this.rfidTagId &&
          other.livestockTypeId == this.livestockTypeId &&
          other.name == this.name &&
          other.dateOfBirth == this.dateOfBirth &&
          other.motherUuid == this.motherUuid &&
          other.fatherUuid == this.fatherUuid &&
          other.gender == this.gender &&
          other.breedId == this.breedId &&
          other.speciesId == this.speciesId &&
          other.status == this.status &&
          other.livestockObtainedMethodId == this.livestockObtainedMethodId &&
          other.dateFirstEnteredToFarm == this.dateFirstEnteredToFarm &&
          other.weightAsOnRegistration == this.weightAsOnRegistration &&
          other.synced == this.synced &&
          other.syncAction == this.syncAction &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LivestocksCompanion extends UpdateCompanion<Livestock> {
  final Value<int> id;
  final Value<String> farmUuid;
  final Value<String> uuid;
  final Value<String> identificationNumber;
  final Value<String> dummyTagId;
  final Value<String> barcodeTagId;
  final Value<String> rfidTagId;
  final Value<int> livestockTypeId;
  final Value<String> name;
  final Value<String> dateOfBirth;
  final Value<String?> motherUuid;
  final Value<String?> fatherUuid;
  final Value<String> gender;
  final Value<int> breedId;
  final Value<int> speciesId;
  final Value<String> status;
  final Value<int> livestockObtainedMethodId;
  final Value<DateTime> dateFirstEnteredToFarm;
  final Value<double> weightAsOnRegistration;
  final Value<bool> synced;
  final Value<String> syncAction;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  const LivestocksCompanion({
    this.id = const Value.absent(),
    this.farmUuid = const Value.absent(),
    this.uuid = const Value.absent(),
    this.identificationNumber = const Value.absent(),
    this.dummyTagId = const Value.absent(),
    this.barcodeTagId = const Value.absent(),
    this.rfidTagId = const Value.absent(),
    this.livestockTypeId = const Value.absent(),
    this.name = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.motherUuid = const Value.absent(),
    this.fatherUuid = const Value.absent(),
    this.gender = const Value.absent(),
    this.breedId = const Value.absent(),
    this.speciesId = const Value.absent(),
    this.status = const Value.absent(),
    this.livestockObtainedMethodId = const Value.absent(),
    this.dateFirstEnteredToFarm = const Value.absent(),
    this.weightAsOnRegistration = const Value.absent(),
    this.synced = const Value.absent(),
    this.syncAction = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  LivestocksCompanion.insert({
    this.id = const Value.absent(),
    required String farmUuid,
    required String uuid,
    required String identificationNumber,
    required String dummyTagId,
    required String barcodeTagId,
    required String rfidTagId,
    required int livestockTypeId,
    required String name,
    required String dateOfBirth,
    this.motherUuid = const Value.absent(),
    this.fatherUuid = const Value.absent(),
    required String gender,
    required int breedId,
    required int speciesId,
    this.status = const Value.absent(),
    required int livestockObtainedMethodId,
    required DateTime dateFirstEnteredToFarm,
    required double weightAsOnRegistration,
    this.synced = const Value.absent(),
    this.syncAction = const Value.absent(),
    required String createdAt,
    required String updatedAt,
  }) : farmUuid = Value(farmUuid),
       uuid = Value(uuid),
       identificationNumber = Value(identificationNumber),
       dummyTagId = Value(dummyTagId),
       barcodeTagId = Value(barcodeTagId),
       rfidTagId = Value(rfidTagId),
       livestockTypeId = Value(livestockTypeId),
       name = Value(name),
       dateOfBirth = Value(dateOfBirth),
       gender = Value(gender),
       breedId = Value(breedId),
       speciesId = Value(speciesId),
       livestockObtainedMethodId = Value(livestockObtainedMethodId),
       dateFirstEnteredToFarm = Value(dateFirstEnteredToFarm),
       weightAsOnRegistration = Value(weightAsOnRegistration),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Livestock> custom({
    Expression<int>? id,
    Expression<String>? farmUuid,
    Expression<String>? uuid,
    Expression<String>? identificationNumber,
    Expression<String>? dummyTagId,
    Expression<String>? barcodeTagId,
    Expression<String>? rfidTagId,
    Expression<int>? livestockTypeId,
    Expression<String>? name,
    Expression<String>? dateOfBirth,
    Expression<String>? motherUuid,
    Expression<String>? fatherUuid,
    Expression<String>? gender,
    Expression<int>? breedId,
    Expression<int>? speciesId,
    Expression<String>? status,
    Expression<int>? livestockObtainedMethodId,
    Expression<DateTime>? dateFirstEnteredToFarm,
    Expression<double>? weightAsOnRegistration,
    Expression<bool>? synced,
    Expression<String>? syncAction,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmUuid != null) 'farm_uuid': farmUuid,
      if (uuid != null) 'uuid': uuid,
      if (identificationNumber != null)
        'identification_number': identificationNumber,
      if (dummyTagId != null) 'dummy_tag_id': dummyTagId,
      if (barcodeTagId != null) 'barcode_tag_id': barcodeTagId,
      if (rfidTagId != null) 'rfid_tag_id': rfidTagId,
      if (livestockTypeId != null) 'livestock_type_id': livestockTypeId,
      if (name != null) 'name': name,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (motherUuid != null) 'mother_uuid': motherUuid,
      if (fatherUuid != null) 'father_uuid': fatherUuid,
      if (gender != null) 'gender': gender,
      if (breedId != null) 'breed_id': breedId,
      if (speciesId != null) 'species_id': speciesId,
      if (status != null) 'status': status,
      if (livestockObtainedMethodId != null)
        'livestock_obtained_method_id': livestockObtainedMethodId,
      if (dateFirstEnteredToFarm != null)
        'date_first_entered_to_farm': dateFirstEnteredToFarm,
      if (weightAsOnRegistration != null)
        'weight_as_on_registration': weightAsOnRegistration,
      if (synced != null) 'synced': synced,
      if (syncAction != null) 'sync_action': syncAction,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  LivestocksCompanion copyWith({
    Value<int>? id,
    Value<String>? farmUuid,
    Value<String>? uuid,
    Value<String>? identificationNumber,
    Value<String>? dummyTagId,
    Value<String>? barcodeTagId,
    Value<String>? rfidTagId,
    Value<int>? livestockTypeId,
    Value<String>? name,
    Value<String>? dateOfBirth,
    Value<String?>? motherUuid,
    Value<String?>? fatherUuid,
    Value<String>? gender,
    Value<int>? breedId,
    Value<int>? speciesId,
    Value<String>? status,
    Value<int>? livestockObtainedMethodId,
    Value<DateTime>? dateFirstEnteredToFarm,
    Value<double>? weightAsOnRegistration,
    Value<bool>? synced,
    Value<String>? syncAction,
    Value<String>? createdAt,
    Value<String>? updatedAt,
  }) {
    return LivestocksCompanion(
      id: id ?? this.id,
      farmUuid: farmUuid ?? this.farmUuid,
      uuid: uuid ?? this.uuid,
      identificationNumber: identificationNumber ?? this.identificationNumber,
      dummyTagId: dummyTagId ?? this.dummyTagId,
      barcodeTagId: barcodeTagId ?? this.barcodeTagId,
      rfidTagId: rfidTagId ?? this.rfidTagId,
      livestockTypeId: livestockTypeId ?? this.livestockTypeId,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      motherUuid: motherUuid ?? this.motherUuid,
      fatherUuid: fatherUuid ?? this.fatherUuid,
      gender: gender ?? this.gender,
      breedId: breedId ?? this.breedId,
      speciesId: speciesId ?? this.speciesId,
      status: status ?? this.status,
      livestockObtainedMethodId:
          livestockObtainedMethodId ?? this.livestockObtainedMethodId,
      dateFirstEnteredToFarm:
          dateFirstEnteredToFarm ?? this.dateFirstEnteredToFarm,
      weightAsOnRegistration:
          weightAsOnRegistration ?? this.weightAsOnRegistration,
      synced: synced ?? this.synced,
      syncAction: syncAction ?? this.syncAction,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (farmUuid.present) {
      map['farm_uuid'] = Variable<String>(farmUuid.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (identificationNumber.present) {
      map['identification_number'] = Variable<String>(
        identificationNumber.value,
      );
    }
    if (dummyTagId.present) {
      map['dummy_tag_id'] = Variable<String>(dummyTagId.value);
    }
    if (barcodeTagId.present) {
      map['barcode_tag_id'] = Variable<String>(barcodeTagId.value);
    }
    if (rfidTagId.present) {
      map['rfid_tag_id'] = Variable<String>(rfidTagId.value);
    }
    if (livestockTypeId.present) {
      map['livestock_type_id'] = Variable<int>(livestockTypeId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (dateOfBirth.present) {
      map['date_of_birth'] = Variable<String>(dateOfBirth.value);
    }
    if (motherUuid.present) {
      map['mother_uuid'] = Variable<String>(motherUuid.value);
    }
    if (fatherUuid.present) {
      map['father_uuid'] = Variable<String>(fatherUuid.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (breedId.present) {
      map['breed_id'] = Variable<int>(breedId.value);
    }
    if (speciesId.present) {
      map['species_id'] = Variable<int>(speciesId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (livestockObtainedMethodId.present) {
      map['livestock_obtained_method_id'] = Variable<int>(
        livestockObtainedMethodId.value,
      );
    }
    if (dateFirstEnteredToFarm.present) {
      map['date_first_entered_to_farm'] = Variable<DateTime>(
        dateFirstEnteredToFarm.value,
      );
    }
    if (weightAsOnRegistration.present) {
      map['weight_as_on_registration'] = Variable<double>(
        weightAsOnRegistration.value,
      );
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (syncAction.present) {
      map['sync_action'] = Variable<String>(syncAction.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LivestocksCompanion(')
          ..write('id: $id, ')
          ..write('farmUuid: $farmUuid, ')
          ..write('uuid: $uuid, ')
          ..write('identificationNumber: $identificationNumber, ')
          ..write('dummyTagId: $dummyTagId, ')
          ..write('barcodeTagId: $barcodeTagId, ')
          ..write('rfidTagId: $rfidTagId, ')
          ..write('livestockTypeId: $livestockTypeId, ')
          ..write('name: $name, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('motherUuid: $motherUuid, ')
          ..write('fatherUuid: $fatherUuid, ')
          ..write('gender: $gender, ')
          ..write('breedId: $breedId, ')
          ..write('speciesId: $speciesId, ')
          ..write('status: $status, ')
          ..write('livestockObtainedMethodId: $livestockObtainedMethodId, ')
          ..write('dateFirstEnteredToFarm: $dateFirstEnteredToFarm, ')
          ..write('weightAsOnRegistration: $weightAsOnRegistration, ')
          ..write('synced: $synced, ')
          ..write('syncAction: $syncAction, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $SpeciesTable extends Species with TableInfo<$SpeciesTable, Specie> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SpeciesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'species';
  @override
  VerificationContext validateIntegrity(
    Insertable<Specie> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Specie map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Specie(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $SpeciesTable createAlias(String alias) {
    return $SpeciesTable(attachedDatabase, alias);
  }
}

class Specie extends DataClass implements Insertable<Specie> {
  final int id;
  final String name;
  const Specie({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  SpeciesCompanion toCompanion(bool nullToAbsent) {
    return SpeciesCompanion(id: Value(id), name: Value(name));
  }

  factory Specie.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Specie(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  Specie copyWith({int? id, String? name}) =>
      Specie(id: id ?? this.id, name: name ?? this.name);
  Specie copyWithCompanion(SpeciesCompanion data) {
    return Specie(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Specie(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Specie && other.id == this.id && other.name == this.name);
}

class SpeciesCompanion extends UpdateCompanion<Specie> {
  final Value<int> id;
  final Value<String> name;
  const SpeciesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  SpeciesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<Specie> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  SpeciesCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return SpeciesCompanion(id: id ?? this.id, name: name ?? this.name);
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SpeciesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $LivestockTypesTable extends LivestockTypes
    with TableInfo<$LivestockTypesTable, LivestockType> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LivestockTypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'livestock_types';
  @override
  VerificationContext validateIntegrity(
    Insertable<LivestockType> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LivestockType map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LivestockType(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $LivestockTypesTable createAlias(String alias) {
    return $LivestockTypesTable(attachedDatabase, alias);
  }
}

class LivestockType extends DataClass implements Insertable<LivestockType> {
  final int id;
  final String name;
  const LivestockType({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  LivestockTypesCompanion toCompanion(bool nullToAbsent) {
    return LivestockTypesCompanion(id: Value(id), name: Value(name));
  }

  factory LivestockType.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LivestockType(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  LivestockType copyWith({int? id, String? name}) =>
      LivestockType(id: id ?? this.id, name: name ?? this.name);
  LivestockType copyWithCompanion(LivestockTypesCompanion data) {
    return LivestockType(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LivestockType(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LivestockType &&
          other.id == this.id &&
          other.name == this.name);
}

class LivestockTypesCompanion extends UpdateCompanion<LivestockType> {
  final Value<int> id;
  final Value<String> name;
  const LivestockTypesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  LivestockTypesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<LivestockType> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  LivestockTypesCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return LivestockTypesCompanion(id: id ?? this.id, name: name ?? this.name);
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LivestockTypesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $BreedsTable extends Breeds with TableInfo<$BreedsTable, Breed> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BreedsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  static const VerificationMeta _groupMeta = const VerificationMeta('group');
  @override
  late final GeneratedColumn<String> group = GeneratedColumn<String>(
    'group',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _livestockTypeIdMeta = const VerificationMeta(
    'livestockTypeId',
  );
  @override
  late final GeneratedColumn<int> livestockTypeId = GeneratedColumn<int>(
    'livestock_type_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES livestock_types (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, group, livestockTypeId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'breeds';
  @override
  VerificationContext validateIntegrity(
    Insertable<Breed> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('group')) {
      context.handle(
        _groupMeta,
        group.isAcceptableOrUnknown(data['group']!, _groupMeta),
      );
    } else if (isInserting) {
      context.missing(_groupMeta);
    }
    if (data.containsKey('livestock_type_id')) {
      context.handle(
        _livestockTypeIdMeta,
        livestockTypeId.isAcceptableOrUnknown(
          data['livestock_type_id']!,
          _livestockTypeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_livestockTypeIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Breed map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Breed(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      group: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group'],
      )!,
      livestockTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}livestock_type_id'],
      )!,
    );
  }

  @override
  $BreedsTable createAlias(String alias) {
    return $BreedsTable(attachedDatabase, alias);
  }
}

class Breed extends DataClass implements Insertable<Breed> {
  final int id;
  final String name;
  final String group;
  final int livestockTypeId;
  const Breed({
    required this.id,
    required this.name,
    required this.group,
    required this.livestockTypeId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['group'] = Variable<String>(group);
    map['livestock_type_id'] = Variable<int>(livestockTypeId);
    return map;
  }

  BreedsCompanion toCompanion(bool nullToAbsent) {
    return BreedsCompanion(
      id: Value(id),
      name: Value(name),
      group: Value(group),
      livestockTypeId: Value(livestockTypeId),
    );
  }

  factory Breed.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Breed(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      group: serializer.fromJson<String>(json['group']),
      livestockTypeId: serializer.fromJson<int>(json['livestockTypeId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'group': serializer.toJson<String>(group),
      'livestockTypeId': serializer.toJson<int>(livestockTypeId),
    };
  }

  Breed copyWith({
    int? id,
    String? name,
    String? group,
    int? livestockTypeId,
  }) => Breed(
    id: id ?? this.id,
    name: name ?? this.name,
    group: group ?? this.group,
    livestockTypeId: livestockTypeId ?? this.livestockTypeId,
  );
  Breed copyWithCompanion(BreedsCompanion data) {
    return Breed(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      group: data.group.present ? data.group.value : this.group,
      livestockTypeId: data.livestockTypeId.present
          ? data.livestockTypeId.value
          : this.livestockTypeId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Breed(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('group: $group, ')
          ..write('livestockTypeId: $livestockTypeId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, group, livestockTypeId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Breed &&
          other.id == this.id &&
          other.name == this.name &&
          other.group == this.group &&
          other.livestockTypeId == this.livestockTypeId);
}

class BreedsCompanion extends UpdateCompanion<Breed> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> group;
  final Value<int> livestockTypeId;
  const BreedsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.group = const Value.absent(),
    this.livestockTypeId = const Value.absent(),
  });
  BreedsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String group,
    required int livestockTypeId,
  }) : name = Value(name),
       group = Value(group),
       livestockTypeId = Value(livestockTypeId);
  static Insertable<Breed> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? group,
    Expression<int>? livestockTypeId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (group != null) 'group': group,
      if (livestockTypeId != null) 'livestock_type_id': livestockTypeId,
    });
  }

  BreedsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? group,
    Value<int>? livestockTypeId,
  }) {
    return BreedsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      group: group ?? this.group,
      livestockTypeId: livestockTypeId ?? this.livestockTypeId,
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
    if (group.present) {
      map['group'] = Variable<String>(group.value);
    }
    if (livestockTypeId.present) {
      map['livestock_type_id'] = Variable<int>(livestockTypeId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BreedsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('group: $group, ')
          ..write('livestockTypeId: $livestockTypeId')
          ..write(')'))
        .toString();
  }
}

class $LivestockObtainedMethodsTable extends LivestockObtainedMethods
    with TableInfo<$LivestockObtainedMethodsTable, LivestockObtainedMethod> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LivestockObtainedMethodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'livestock_obtained_methods';
  @override
  VerificationContext validateIntegrity(
    Insertable<LivestockObtainedMethod> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LivestockObtainedMethod map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LivestockObtainedMethod(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $LivestockObtainedMethodsTable createAlias(String alias) {
    return $LivestockObtainedMethodsTable(attachedDatabase, alias);
  }
}

class LivestockObtainedMethod extends DataClass
    implements Insertable<LivestockObtainedMethod> {
  final int id;
  final String name;
  const LivestockObtainedMethod({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  LivestockObtainedMethodsCompanion toCompanion(bool nullToAbsent) {
    return LivestockObtainedMethodsCompanion(id: Value(id), name: Value(name));
  }

  factory LivestockObtainedMethod.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LivestockObtainedMethod(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  LivestockObtainedMethod copyWith({int? id, String? name}) =>
      LivestockObtainedMethod(id: id ?? this.id, name: name ?? this.name);
  LivestockObtainedMethod copyWithCompanion(
    LivestockObtainedMethodsCompanion data,
  ) {
    return LivestockObtainedMethod(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LivestockObtainedMethod(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LivestockObtainedMethod &&
          other.id == this.id &&
          other.name == this.name);
}

class LivestockObtainedMethodsCompanion
    extends UpdateCompanion<LivestockObtainedMethod> {
  final Value<int> id;
  final Value<String> name;
  const LivestockObtainedMethodsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  LivestockObtainedMethodsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<LivestockObtainedMethod> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  LivestockObtainedMethodsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
  }) {
    return LivestockObtainedMethodsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LivestockObtainedMethodsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CountriesTable countries = $CountriesTable(this);
  late final $RegionsTable regions = $RegionsTable(this);
  late final $DistrictsTable districts = $DistrictsTable(this);
  late final $DivisionsTable divisions = $DivisionsTable(this);
  late final $WardsTable wards = $WardsTable(this);
  late final $VillagesTable villages = $VillagesTable(this);
  late final $StreetsTable streets = $StreetsTable(this);
  late final $SchoolLevelsTable schoolLevels = $SchoolLevelsTable(this);
  late final $IdentityCardTypesTable identityCardTypes =
      $IdentityCardTypesTable(this);
  late final $LegalStatusesTable legalStatuses = $LegalStatusesTable(this);
  late final $FarmsTable farms = $FarmsTable(this);
  late final $LivestocksTable livestocks = $LivestocksTable(this);
  late final $SpeciesTable species = $SpeciesTable(this);
  late final $LivestockTypesTable livestockTypes = $LivestockTypesTable(this);
  late final $BreedsTable breeds = $BreedsTable(this);
  late final $LivestockObtainedMethodsTable livestockObtainedMethods =
      $LivestockObtainedMethodsTable(this);
  late final LocationDao locationDao = LocationDao(this as AppDatabase);
  late final ReferenceDataDao referenceDataDao = ReferenceDataDao(
    this as AppDatabase,
  );
  late final LivestockManagementDao livestockManagementDao =
      LivestockManagementDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    countries,
    regions,
    districts,
    divisions,
    wards,
    villages,
    streets,
    schoolLevels,
    identityCardTypes,
    legalStatuses,
    farms,
    livestocks,
    species,
    livestockTypes,
    breeds,
    livestockObtainedMethods,
  ];
}

typedef $$CountriesTableCreateCompanionBuilder =
    CountriesCompanion Function({
      Value<int> id,
      required String name,
      required String shortName,
    });
typedef $$CountriesTableUpdateCompanionBuilder =
    CountriesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> shortName,
    });

final class $$CountriesTableReferences
    extends BaseReferences<_$AppDatabase, $CountriesTable, Country> {
  $$CountriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RegionsTable, List<Region>> _regionsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.regions,
    aliasName: $_aliasNameGenerator(db.countries.id, db.regions.countryId),
  );

  $$RegionsTableProcessedTableManager get regionsRefs {
    final manager = $$RegionsTableTableManager(
      $_db,
      $_db.regions,
    ).filter((f) => f.countryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_regionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FarmsTable, List<Farm>> _farmsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.farms,
    aliasName: $_aliasNameGenerator(db.countries.id, db.farms.countryId),
  );

  $$FarmsTableProcessedTableManager get farmsRefs {
    final manager = $$FarmsTableTableManager(
      $_db,
      $_db.farms,
    ).filter((f) => f.countryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_farmsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CountriesTableFilterComposer
    extends Composer<_$AppDatabase, $CountriesTable> {
  $$CountriesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shortName => $composableBuilder(
    column: $table.shortName,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> regionsRefs(
    Expression<bool> Function($$RegionsTableFilterComposer f) f,
  ) {
    final $$RegionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.regions,
      getReferencedColumn: (t) => t.countryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RegionsTableFilterComposer(
            $db: $db,
            $table: $db.regions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> farmsRefs(
    Expression<bool> Function($$FarmsTableFilterComposer f) f,
  ) {
    final $$FarmsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.farms,
      getReferencedColumn: (t) => t.countryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FarmsTableFilterComposer(
            $db: $db,
            $table: $db.farms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CountriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CountriesTable> {
  $$CountriesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shortName => $composableBuilder(
    column: $table.shortName,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CountriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CountriesTable> {
  $$CountriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get shortName =>
      $composableBuilder(column: $table.shortName, builder: (column) => column);

  Expression<T> regionsRefs<T extends Object>(
    Expression<T> Function($$RegionsTableAnnotationComposer a) f,
  ) {
    final $$RegionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.regions,
      getReferencedColumn: (t) => t.countryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RegionsTableAnnotationComposer(
            $db: $db,
            $table: $db.regions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> farmsRefs<T extends Object>(
    Expression<T> Function($$FarmsTableAnnotationComposer a) f,
  ) {
    final $$FarmsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.farms,
      getReferencedColumn: (t) => t.countryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FarmsTableAnnotationComposer(
            $db: $db,
            $table: $db.farms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CountriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CountriesTable,
          Country,
          $$CountriesTableFilterComposer,
          $$CountriesTableOrderingComposer,
          $$CountriesTableAnnotationComposer,
          $$CountriesTableCreateCompanionBuilder,
          $$CountriesTableUpdateCompanionBuilder,
          (Country, $$CountriesTableReferences),
          Country,
          PrefetchHooks Function({bool regionsRefs, bool farmsRefs})
        > {
  $$CountriesTableTableManager(_$AppDatabase db, $CountriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CountriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CountriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CountriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> shortName = const Value.absent(),
              }) =>
                  CountriesCompanion(id: id, name: name, shortName: shortName),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String shortName,
              }) => CountriesCompanion.insert(
                id: id,
                name: name,
                shortName: shortName,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CountriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({regionsRefs = false, farmsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (regionsRefs) db.regions,
                if (farmsRefs) db.farms,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (regionsRefs)
                    await $_getPrefetchedData<Country, $CountriesTable, Region>(
                      currentTable: table,
                      referencedTable: $$CountriesTableReferences
                          ._regionsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CountriesTableReferences(db, table, p0).regionsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.countryId == item.id),
                      typedResults: items,
                    ),
                  if (farmsRefs)
                    await $_getPrefetchedData<Country, $CountriesTable, Farm>(
                      currentTable: table,
                      referencedTable: $$CountriesTableReferences
                          ._farmsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CountriesTableReferences(db, table, p0).farmsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.countryId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CountriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CountriesTable,
      Country,
      $$CountriesTableFilterComposer,
      $$CountriesTableOrderingComposer,
      $$CountriesTableAnnotationComposer,
      $$CountriesTableCreateCompanionBuilder,
      $$CountriesTableUpdateCompanionBuilder,
      (Country, $$CountriesTableReferences),
      Country,
      PrefetchHooks Function({bool regionsRefs, bool farmsRefs})
    >;
typedef $$RegionsTableCreateCompanionBuilder =
    RegionsCompanion Function({
      Value<int> id,
      required String name,
      required int countryId,
    });
typedef $$RegionsTableUpdateCompanionBuilder =
    RegionsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> countryId,
    });

final class $$RegionsTableReferences
    extends BaseReferences<_$AppDatabase, $RegionsTable, Region> {
  $$RegionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CountriesTable _countryIdTable(_$AppDatabase db) => db.countries
      .createAlias($_aliasNameGenerator(db.regions.countryId, db.countries.id));

  $$CountriesTableProcessedTableManager get countryId {
    final $_column = $_itemColumn<int>('country_id')!;

    final manager = $$CountriesTableTableManager(
      $_db,
      $_db.countries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_countryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$DistrictsTable, List<District>>
  _districtsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.districts,
    aliasName: $_aliasNameGenerator(db.regions.id, db.districts.regionId),
  );

  $$DistrictsTableProcessedTableManager get districtsRefs {
    final manager = $$DistrictsTableTableManager(
      $_db,
      $_db.districts,
    ).filter((f) => f.regionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_districtsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FarmsTable, List<Farm>> _farmsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.farms,
    aliasName: $_aliasNameGenerator(db.regions.id, db.farms.regionId),
  );

  $$FarmsTableProcessedTableManager get farmsRefs {
    final manager = $$FarmsTableTableManager(
      $_db,
      $_db.farms,
    ).filter((f) => f.regionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_farmsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RegionsTableFilterComposer
    extends Composer<_$AppDatabase, $RegionsTable> {
  $$RegionsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  $$CountriesTableFilterComposer get countryId {
    final $$CountriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.countryId,
      referencedTable: $db.countries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CountriesTableFilterComposer(
            $db: $db,
            $table: $db.countries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> districtsRefs(
    Expression<bool> Function($$DistrictsTableFilterComposer f) f,
  ) {
    final $$DistrictsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.districts,
      getReferencedColumn: (t) => t.regionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DistrictsTableFilterComposer(
            $db: $db,
            $table: $db.districts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> farmsRefs(
    Expression<bool> Function($$FarmsTableFilterComposer f) f,
  ) {
    final $$FarmsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.farms,
      getReferencedColumn: (t) => t.regionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FarmsTableFilterComposer(
            $db: $db,
            $table: $db.farms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RegionsTableOrderingComposer
    extends Composer<_$AppDatabase, $RegionsTable> {
  $$RegionsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  $$CountriesTableOrderingComposer get countryId {
    final $$CountriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.countryId,
      referencedTable: $db.countries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CountriesTableOrderingComposer(
            $db: $db,
            $table: $db.countries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RegionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RegionsTable> {
  $$RegionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  $$CountriesTableAnnotationComposer get countryId {
    final $$CountriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.countryId,
      referencedTable: $db.countries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CountriesTableAnnotationComposer(
            $db: $db,
            $table: $db.countries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> districtsRefs<T extends Object>(
    Expression<T> Function($$DistrictsTableAnnotationComposer a) f,
  ) {
    final $$DistrictsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.districts,
      getReferencedColumn: (t) => t.regionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DistrictsTableAnnotationComposer(
            $db: $db,
            $table: $db.districts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> farmsRefs<T extends Object>(
    Expression<T> Function($$FarmsTableAnnotationComposer a) f,
  ) {
    final $$FarmsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.farms,
      getReferencedColumn: (t) => t.regionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FarmsTableAnnotationComposer(
            $db: $db,
            $table: $db.farms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RegionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RegionsTable,
          Region,
          $$RegionsTableFilterComposer,
          $$RegionsTableOrderingComposer,
          $$RegionsTableAnnotationComposer,
          $$RegionsTableCreateCompanionBuilder,
          $$RegionsTableUpdateCompanionBuilder,
          (Region, $$RegionsTableReferences),
          Region,
          PrefetchHooks Function({
            bool countryId,
            bool districtsRefs,
            bool farmsRefs,
          })
        > {
  $$RegionsTableTableManager(_$AppDatabase db, $RegionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RegionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RegionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RegionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> countryId = const Value.absent(),
              }) => RegionsCompanion(id: id, name: name, countryId: countryId),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int countryId,
              }) => RegionsCompanion.insert(
                id: id,
                name: name,
                countryId: countryId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RegionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({countryId = false, districtsRefs = false, farmsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (districtsRefs) db.districts,
                    if (farmsRefs) db.farms,
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
                        if (countryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.countryId,
                                    referencedTable: $$RegionsTableReferences
                                        ._countryIdTable(db),
                                    referencedColumn: $$RegionsTableReferences
                                        ._countryIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (districtsRefs)
                        await $_getPrefetchedData<
                          Region,
                          $RegionsTable,
                          District
                        >(
                          currentTable: table,
                          referencedTable: $$RegionsTableReferences
                              ._districtsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RegionsTableReferences(
                                db,
                                table,
                                p0,
                              ).districtsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.regionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (farmsRefs)
                        await $_getPrefetchedData<Region, $RegionsTable, Farm>(
                          currentTable: table,
                          referencedTable: $$RegionsTableReferences
                              ._farmsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RegionsTableReferences(db, table, p0).farmsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.regionId == item.id,
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

typedef $$RegionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RegionsTable,
      Region,
      $$RegionsTableFilterComposer,
      $$RegionsTableOrderingComposer,
      $$RegionsTableAnnotationComposer,
      $$RegionsTableCreateCompanionBuilder,
      $$RegionsTableUpdateCompanionBuilder,
      (Region, $$RegionsTableReferences),
      Region,
      PrefetchHooks Function({
        bool countryId,
        bool districtsRefs,
        bool farmsRefs,
      })
    >;
typedef $$DistrictsTableCreateCompanionBuilder =
    DistrictsCompanion Function({
      Value<int> id,
      required String name,
      required int regionId,
    });
typedef $$DistrictsTableUpdateCompanionBuilder =
    DistrictsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> regionId,
    });

final class $$DistrictsTableReferences
    extends BaseReferences<_$AppDatabase, $DistrictsTable, District> {
  $$DistrictsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RegionsTable _regionIdTable(_$AppDatabase db) => db.regions
      .createAlias($_aliasNameGenerator(db.districts.regionId, db.regions.id));

  $$RegionsTableProcessedTableManager get regionId {
    final $_column = $_itemColumn<int>('region_id')!;

    final manager = $$RegionsTableTableManager(
      $_db,
      $_db.regions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_regionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$DivisionsTable, List<Division>>
  _divisionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.divisions,
    aliasName: $_aliasNameGenerator(db.districts.id, db.divisions.districtId),
  );

  $$DivisionsTableProcessedTableManager get divisionsRefs {
    final manager = $$DivisionsTableTableManager(
      $_db,
      $_db.divisions,
    ).filter((f) => f.districtId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_divisionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WardsTable, List<Ward>> _wardsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.wards,
    aliasName: $_aliasNameGenerator(db.districts.id, db.wards.districtId),
  );

  $$WardsTableProcessedTableManager get wardsRefs {
    final manager = $$WardsTableTableManager(
      $_db,
      $_db.wards,
    ).filter((f) => f.districtId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_wardsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FarmsTable, List<Farm>> _farmsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.farms,
    aliasName: $_aliasNameGenerator(db.districts.id, db.farms.districtId),
  );

  $$FarmsTableProcessedTableManager get farmsRefs {
    final manager = $$FarmsTableTableManager(
      $_db,
      $_db.farms,
    ).filter((f) => f.districtId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_farmsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DistrictsTableFilterComposer
    extends Composer<_$AppDatabase, $DistrictsTable> {
  $$DistrictsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  $$RegionsTableFilterComposer get regionId {
    final $$RegionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.regionId,
      referencedTable: $db.regions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RegionsTableFilterComposer(
            $db: $db,
            $table: $db.regions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> divisionsRefs(
    Expression<bool> Function($$DivisionsTableFilterComposer f) f,
  ) {
    final $$DivisionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.divisions,
      getReferencedColumn: (t) => t.districtId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DivisionsTableFilterComposer(
            $db: $db,
            $table: $db.divisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> wardsRefs(
    Expression<bool> Function($$WardsTableFilterComposer f) f,
  ) {
    final $$WardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wards,
      getReferencedColumn: (t) => t.districtId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WardsTableFilterComposer(
            $db: $db,
            $table: $db.wards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> farmsRefs(
    Expression<bool> Function($$FarmsTableFilterComposer f) f,
  ) {
    final $$FarmsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.farms,
      getReferencedColumn: (t) => t.districtId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FarmsTableFilterComposer(
            $db: $db,
            $table: $db.farms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DistrictsTableOrderingComposer
    extends Composer<_$AppDatabase, $DistrictsTable> {
  $$DistrictsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  $$RegionsTableOrderingComposer get regionId {
    final $$RegionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.regionId,
      referencedTable: $db.regions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RegionsTableOrderingComposer(
            $db: $db,
            $table: $db.regions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DistrictsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DistrictsTable> {
  $$DistrictsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  $$RegionsTableAnnotationComposer get regionId {
    final $$RegionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.regionId,
      referencedTable: $db.regions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RegionsTableAnnotationComposer(
            $db: $db,
            $table: $db.regions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> divisionsRefs<T extends Object>(
    Expression<T> Function($$DivisionsTableAnnotationComposer a) f,
  ) {
    final $$DivisionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.divisions,
      getReferencedColumn: (t) => t.districtId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DivisionsTableAnnotationComposer(
            $db: $db,
            $table: $db.divisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> wardsRefs<T extends Object>(
    Expression<T> Function($$WardsTableAnnotationComposer a) f,
  ) {
    final $$WardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wards,
      getReferencedColumn: (t) => t.districtId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WardsTableAnnotationComposer(
            $db: $db,
            $table: $db.wards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> farmsRefs<T extends Object>(
    Expression<T> Function($$FarmsTableAnnotationComposer a) f,
  ) {
    final $$FarmsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.farms,
      getReferencedColumn: (t) => t.districtId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FarmsTableAnnotationComposer(
            $db: $db,
            $table: $db.farms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DistrictsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DistrictsTable,
          District,
          $$DistrictsTableFilterComposer,
          $$DistrictsTableOrderingComposer,
          $$DistrictsTableAnnotationComposer,
          $$DistrictsTableCreateCompanionBuilder,
          $$DistrictsTableUpdateCompanionBuilder,
          (District, $$DistrictsTableReferences),
          District,
          PrefetchHooks Function({
            bool regionId,
            bool divisionsRefs,
            bool wardsRefs,
            bool farmsRefs,
          })
        > {
  $$DistrictsTableTableManager(_$AppDatabase db, $DistrictsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DistrictsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DistrictsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DistrictsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> regionId = const Value.absent(),
              }) => DistrictsCompanion(id: id, name: name, regionId: regionId),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int regionId,
              }) => DistrictsCompanion.insert(
                id: id,
                name: name,
                regionId: regionId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DistrictsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                regionId = false,
                divisionsRefs = false,
                wardsRefs = false,
                farmsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (divisionsRefs) db.divisions,
                    if (wardsRefs) db.wards,
                    if (farmsRefs) db.farms,
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
                        if (regionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.regionId,
                                    referencedTable: $$DistrictsTableReferences
                                        ._regionIdTable(db),
                                    referencedColumn: $$DistrictsTableReferences
                                        ._regionIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (divisionsRefs)
                        await $_getPrefetchedData<
                          District,
                          $DistrictsTable,
                          Division
                        >(
                          currentTable: table,
                          referencedTable: $$DistrictsTableReferences
                              ._divisionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DistrictsTableReferences(
                                db,
                                table,
                                p0,
                              ).divisionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.districtId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (wardsRefs)
                        await $_getPrefetchedData<
                          District,
                          $DistrictsTable,
                          Ward
                        >(
                          currentTable: table,
                          referencedTable: $$DistrictsTableReferences
                              ._wardsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DistrictsTableReferences(
                                db,
                                table,
                                p0,
                              ).wardsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.districtId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (farmsRefs)
                        await $_getPrefetchedData<
                          District,
                          $DistrictsTable,
                          Farm
                        >(
                          currentTable: table,
                          referencedTable: $$DistrictsTableReferences
                              ._farmsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DistrictsTableReferences(
                                db,
                                table,
                                p0,
                              ).farmsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.districtId == item.id,
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

typedef $$DistrictsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DistrictsTable,
      District,
      $$DistrictsTableFilterComposer,
      $$DistrictsTableOrderingComposer,
      $$DistrictsTableAnnotationComposer,
      $$DistrictsTableCreateCompanionBuilder,
      $$DistrictsTableUpdateCompanionBuilder,
      (District, $$DistrictsTableReferences),
      District,
      PrefetchHooks Function({
        bool regionId,
        bool divisionsRefs,
        bool wardsRefs,
        bool farmsRefs,
      })
    >;
typedef $$DivisionsTableCreateCompanionBuilder =
    DivisionsCompanion Function({
      Value<int> id,
      required String name,
      required int districtId,
    });
typedef $$DivisionsTableUpdateCompanionBuilder =
    DivisionsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> districtId,
    });

final class $$DivisionsTableReferences
    extends BaseReferences<_$AppDatabase, $DivisionsTable, Division> {
  $$DivisionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DistrictsTable _districtIdTable(_$AppDatabase db) =>
      db.districts.createAlias(
        $_aliasNameGenerator(db.divisions.districtId, db.districts.id),
      );

  $$DistrictsTableProcessedTableManager get districtId {
    final $_column = $_itemColumn<int>('district_id')!;

    final manager = $$DistrictsTableTableManager(
      $_db,
      $_db.districts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_districtIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DivisionsTableFilterComposer
    extends Composer<_$AppDatabase, $DivisionsTable> {
  $$DivisionsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  $$DistrictsTableFilterComposer get districtId {
    final $$DistrictsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.districtId,
      referencedTable: $db.districts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DistrictsTableFilterComposer(
            $db: $db,
            $table: $db.districts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DivisionsTableOrderingComposer
    extends Composer<_$AppDatabase, $DivisionsTable> {
  $$DivisionsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  $$DistrictsTableOrderingComposer get districtId {
    final $$DistrictsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.districtId,
      referencedTable: $db.districts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DistrictsTableOrderingComposer(
            $db: $db,
            $table: $db.districts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DivisionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DivisionsTable> {
  $$DivisionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  $$DistrictsTableAnnotationComposer get districtId {
    final $$DistrictsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.districtId,
      referencedTable: $db.districts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DistrictsTableAnnotationComposer(
            $db: $db,
            $table: $db.districts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DivisionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DivisionsTable,
          Division,
          $$DivisionsTableFilterComposer,
          $$DivisionsTableOrderingComposer,
          $$DivisionsTableAnnotationComposer,
          $$DivisionsTableCreateCompanionBuilder,
          $$DivisionsTableUpdateCompanionBuilder,
          (Division, $$DivisionsTableReferences),
          Division,
          PrefetchHooks Function({bool districtId})
        > {
  $$DivisionsTableTableManager(_$AppDatabase db, $DivisionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DivisionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DivisionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DivisionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> districtId = const Value.absent(),
              }) => DivisionsCompanion(
                id: id,
                name: name,
                districtId: districtId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int districtId,
              }) => DivisionsCompanion.insert(
                id: id,
                name: name,
                districtId: districtId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DivisionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({districtId = false}) {
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
                    if (districtId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.districtId,
                                referencedTable: $$DivisionsTableReferences
                                    ._districtIdTable(db),
                                referencedColumn: $$DivisionsTableReferences
                                    ._districtIdTable(db)
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

typedef $$DivisionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DivisionsTable,
      Division,
      $$DivisionsTableFilterComposer,
      $$DivisionsTableOrderingComposer,
      $$DivisionsTableAnnotationComposer,
      $$DivisionsTableCreateCompanionBuilder,
      $$DivisionsTableUpdateCompanionBuilder,
      (Division, $$DivisionsTableReferences),
      Division,
      PrefetchHooks Function({bool districtId})
    >;
typedef $$WardsTableCreateCompanionBuilder =
    WardsCompanion Function({
      Value<int> id,
      required String name,
      required int districtId,
    });
typedef $$WardsTableUpdateCompanionBuilder =
    WardsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> districtId,
    });

final class $$WardsTableReferences
    extends BaseReferences<_$AppDatabase, $WardsTable, Ward> {
  $$WardsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DistrictsTable _districtIdTable(_$AppDatabase db) => db.districts
      .createAlias($_aliasNameGenerator(db.wards.districtId, db.districts.id));

  $$DistrictsTableProcessedTableManager get districtId {
    final $_column = $_itemColumn<int>('district_id')!;

    final manager = $$DistrictsTableTableManager(
      $_db,
      $_db.districts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_districtIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$VillagesTable, List<Village>> _villagesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.villages,
    aliasName: $_aliasNameGenerator(db.wards.id, db.villages.wardId),
  );

  $$VillagesTableProcessedTableManager get villagesRefs {
    final manager = $$VillagesTableTableManager(
      $_db,
      $_db.villages,
    ).filter((f) => f.wardId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_villagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$StreetsTable, List<Street>> _streetsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.streets,
    aliasName: $_aliasNameGenerator(db.wards.id, db.streets.wardId),
  );

  $$StreetsTableProcessedTableManager get streetsRefs {
    final manager = $$StreetsTableTableManager(
      $_db,
      $_db.streets,
    ).filter((f) => f.wardId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_streetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FarmsTable, List<Farm>> _farmsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.farms,
    aliasName: $_aliasNameGenerator(db.wards.id, db.farms.wardId),
  );

  $$FarmsTableProcessedTableManager get farmsRefs {
    final manager = $$FarmsTableTableManager(
      $_db,
      $_db.farms,
    ).filter((f) => f.wardId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_farmsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WardsTableFilterComposer extends Composer<_$AppDatabase, $WardsTable> {
  $$WardsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  $$DistrictsTableFilterComposer get districtId {
    final $$DistrictsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.districtId,
      referencedTable: $db.districts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DistrictsTableFilterComposer(
            $db: $db,
            $table: $db.districts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> villagesRefs(
    Expression<bool> Function($$VillagesTableFilterComposer f) f,
  ) {
    final $$VillagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.villages,
      getReferencedColumn: (t) => t.wardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VillagesTableFilterComposer(
            $db: $db,
            $table: $db.villages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> streetsRefs(
    Expression<bool> Function($$StreetsTableFilterComposer f) f,
  ) {
    final $$StreetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.streets,
      getReferencedColumn: (t) => t.wardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StreetsTableFilterComposer(
            $db: $db,
            $table: $db.streets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> farmsRefs(
    Expression<bool> Function($$FarmsTableFilterComposer f) f,
  ) {
    final $$FarmsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.farms,
      getReferencedColumn: (t) => t.wardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FarmsTableFilterComposer(
            $db: $db,
            $table: $db.farms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WardsTableOrderingComposer
    extends Composer<_$AppDatabase, $WardsTable> {
  $$WardsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  $$DistrictsTableOrderingComposer get districtId {
    final $$DistrictsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.districtId,
      referencedTable: $db.districts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DistrictsTableOrderingComposer(
            $db: $db,
            $table: $db.districts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WardsTable> {
  $$WardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  $$DistrictsTableAnnotationComposer get districtId {
    final $$DistrictsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.districtId,
      referencedTable: $db.districts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DistrictsTableAnnotationComposer(
            $db: $db,
            $table: $db.districts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> villagesRefs<T extends Object>(
    Expression<T> Function($$VillagesTableAnnotationComposer a) f,
  ) {
    final $$VillagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.villages,
      getReferencedColumn: (t) => t.wardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VillagesTableAnnotationComposer(
            $db: $db,
            $table: $db.villages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> streetsRefs<T extends Object>(
    Expression<T> Function($$StreetsTableAnnotationComposer a) f,
  ) {
    final $$StreetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.streets,
      getReferencedColumn: (t) => t.wardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StreetsTableAnnotationComposer(
            $db: $db,
            $table: $db.streets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> farmsRefs<T extends Object>(
    Expression<T> Function($$FarmsTableAnnotationComposer a) f,
  ) {
    final $$FarmsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.farms,
      getReferencedColumn: (t) => t.wardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FarmsTableAnnotationComposer(
            $db: $db,
            $table: $db.farms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WardsTable,
          Ward,
          $$WardsTableFilterComposer,
          $$WardsTableOrderingComposer,
          $$WardsTableAnnotationComposer,
          $$WardsTableCreateCompanionBuilder,
          $$WardsTableUpdateCompanionBuilder,
          (Ward, $$WardsTableReferences),
          Ward,
          PrefetchHooks Function({
            bool districtId,
            bool villagesRefs,
            bool streetsRefs,
            bool farmsRefs,
          })
        > {
  $$WardsTableTableManager(_$AppDatabase db, $WardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> districtId = const Value.absent(),
              }) => WardsCompanion(id: id, name: name, districtId: districtId),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int districtId,
              }) => WardsCompanion.insert(
                id: id,
                name: name,
                districtId: districtId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$WardsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                districtId = false,
                villagesRefs = false,
                streetsRefs = false,
                farmsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (villagesRefs) db.villages,
                    if (streetsRefs) db.streets,
                    if (farmsRefs) db.farms,
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
                        if (districtId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.districtId,
                                    referencedTable: $$WardsTableReferences
                                        ._districtIdTable(db),
                                    referencedColumn: $$WardsTableReferences
                                        ._districtIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (villagesRefs)
                        await $_getPrefetchedData<Ward, $WardsTable, Village>(
                          currentTable: table,
                          referencedTable: $$WardsTableReferences
                              ._villagesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WardsTableReferences(
                                db,
                                table,
                                p0,
                              ).villagesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.wardId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (streetsRefs)
                        await $_getPrefetchedData<Ward, $WardsTable, Street>(
                          currentTable: table,
                          referencedTable: $$WardsTableReferences
                              ._streetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WardsTableReferences(db, table, p0).streetsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.wardId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (farmsRefs)
                        await $_getPrefetchedData<Ward, $WardsTable, Farm>(
                          currentTable: table,
                          referencedTable: $$WardsTableReferences
                              ._farmsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WardsTableReferences(db, table, p0).farmsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.wardId == item.id,
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

typedef $$WardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WardsTable,
      Ward,
      $$WardsTableFilterComposer,
      $$WardsTableOrderingComposer,
      $$WardsTableAnnotationComposer,
      $$WardsTableCreateCompanionBuilder,
      $$WardsTableUpdateCompanionBuilder,
      (Ward, $$WardsTableReferences),
      Ward,
      PrefetchHooks Function({
        bool districtId,
        bool villagesRefs,
        bool streetsRefs,
        bool farmsRefs,
      })
    >;
typedef $$VillagesTableCreateCompanionBuilder =
    VillagesCompanion Function({
      Value<int> id,
      required String name,
      required int wardId,
    });
typedef $$VillagesTableUpdateCompanionBuilder =
    VillagesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> wardId,
    });

final class $$VillagesTableReferences
    extends BaseReferences<_$AppDatabase, $VillagesTable, Village> {
  $$VillagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WardsTable _wardIdTable(_$AppDatabase db) => db.wards.createAlias(
    $_aliasNameGenerator(db.villages.wardId, db.wards.id),
  );

  $$WardsTableProcessedTableManager get wardId {
    final $_column = $_itemColumn<int>('ward_id')!;

    final manager = $$WardsTableTableManager(
      $_db,
      $_db.wards,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_wardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$VillagesTableFilterComposer
    extends Composer<_$AppDatabase, $VillagesTable> {
  $$VillagesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  $$WardsTableFilterComposer get wardId {
    final $$WardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wardId,
      referencedTable: $db.wards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WardsTableFilterComposer(
            $db: $db,
            $table: $db.wards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VillagesTableOrderingComposer
    extends Composer<_$AppDatabase, $VillagesTable> {
  $$VillagesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  $$WardsTableOrderingComposer get wardId {
    final $$WardsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wardId,
      referencedTable: $db.wards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WardsTableOrderingComposer(
            $db: $db,
            $table: $db.wards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VillagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VillagesTable> {
  $$VillagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  $$WardsTableAnnotationComposer get wardId {
    final $$WardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wardId,
      referencedTable: $db.wards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WardsTableAnnotationComposer(
            $db: $db,
            $table: $db.wards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VillagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VillagesTable,
          Village,
          $$VillagesTableFilterComposer,
          $$VillagesTableOrderingComposer,
          $$VillagesTableAnnotationComposer,
          $$VillagesTableCreateCompanionBuilder,
          $$VillagesTableUpdateCompanionBuilder,
          (Village, $$VillagesTableReferences),
          Village,
          PrefetchHooks Function({bool wardId})
        > {
  $$VillagesTableTableManager(_$AppDatabase db, $VillagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VillagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VillagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VillagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> wardId = const Value.absent(),
              }) => VillagesCompanion(id: id, name: name, wardId: wardId),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int wardId,
              }) =>
                  VillagesCompanion.insert(id: id, name: name, wardId: wardId),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$VillagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({wardId = false}) {
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
                    if (wardId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.wardId,
                                referencedTable: $$VillagesTableReferences
                                    ._wardIdTable(db),
                                referencedColumn: $$VillagesTableReferences
                                    ._wardIdTable(db)
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

typedef $$VillagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VillagesTable,
      Village,
      $$VillagesTableFilterComposer,
      $$VillagesTableOrderingComposer,
      $$VillagesTableAnnotationComposer,
      $$VillagesTableCreateCompanionBuilder,
      $$VillagesTableUpdateCompanionBuilder,
      (Village, $$VillagesTableReferences),
      Village,
      PrefetchHooks Function({bool wardId})
    >;
typedef $$StreetsTableCreateCompanionBuilder =
    StreetsCompanion Function({
      Value<int> id,
      required String name,
      required int wardId,
    });
typedef $$StreetsTableUpdateCompanionBuilder =
    StreetsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> wardId,
    });

final class $$StreetsTableReferences
    extends BaseReferences<_$AppDatabase, $StreetsTable, Street> {
  $$StreetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WardsTable _wardIdTable(_$AppDatabase db) => db.wards.createAlias(
    $_aliasNameGenerator(db.streets.wardId, db.wards.id),
  );

  $$WardsTableProcessedTableManager get wardId {
    final $_column = $_itemColumn<int>('ward_id')!;

    final manager = $$WardsTableTableManager(
      $_db,
      $_db.wards,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_wardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$StreetsTableFilterComposer
    extends Composer<_$AppDatabase, $StreetsTable> {
  $$StreetsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  $$WardsTableFilterComposer get wardId {
    final $$WardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wardId,
      referencedTable: $db.wards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WardsTableFilterComposer(
            $db: $db,
            $table: $db.wards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StreetsTableOrderingComposer
    extends Composer<_$AppDatabase, $StreetsTable> {
  $$StreetsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  $$WardsTableOrderingComposer get wardId {
    final $$WardsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wardId,
      referencedTable: $db.wards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WardsTableOrderingComposer(
            $db: $db,
            $table: $db.wards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StreetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StreetsTable> {
  $$StreetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  $$WardsTableAnnotationComposer get wardId {
    final $$WardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wardId,
      referencedTable: $db.wards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WardsTableAnnotationComposer(
            $db: $db,
            $table: $db.wards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StreetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StreetsTable,
          Street,
          $$StreetsTableFilterComposer,
          $$StreetsTableOrderingComposer,
          $$StreetsTableAnnotationComposer,
          $$StreetsTableCreateCompanionBuilder,
          $$StreetsTableUpdateCompanionBuilder,
          (Street, $$StreetsTableReferences),
          Street,
          PrefetchHooks Function({bool wardId})
        > {
  $$StreetsTableTableManager(_$AppDatabase db, $StreetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StreetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StreetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StreetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> wardId = const Value.absent(),
              }) => StreetsCompanion(id: id, name: name, wardId: wardId),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int wardId,
              }) => StreetsCompanion.insert(id: id, name: name, wardId: wardId),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StreetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({wardId = false}) {
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
                    if (wardId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.wardId,
                                referencedTable: $$StreetsTableReferences
                                    ._wardIdTable(db),
                                referencedColumn: $$StreetsTableReferences
                                    ._wardIdTable(db)
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

typedef $$StreetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StreetsTable,
      Street,
      $$StreetsTableFilterComposer,
      $$StreetsTableOrderingComposer,
      $$StreetsTableAnnotationComposer,
      $$StreetsTableCreateCompanionBuilder,
      $$StreetsTableUpdateCompanionBuilder,
      (Street, $$StreetsTableReferences),
      Street,
      PrefetchHooks Function({bool wardId})
    >;
typedef $$SchoolLevelsTableCreateCompanionBuilder =
    SchoolLevelsCompanion Function({Value<int> id, required String name});
typedef $$SchoolLevelsTableUpdateCompanionBuilder =
    SchoolLevelsCompanion Function({Value<int> id, Value<String> name});

class $$SchoolLevelsTableFilterComposer
    extends Composer<_$AppDatabase, $SchoolLevelsTable> {
  $$SchoolLevelsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SchoolLevelsTableOrderingComposer
    extends Composer<_$AppDatabase, $SchoolLevelsTable> {
  $$SchoolLevelsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SchoolLevelsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SchoolLevelsTable> {
  $$SchoolLevelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$SchoolLevelsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SchoolLevelsTable,
          SchoolLevel,
          $$SchoolLevelsTableFilterComposer,
          $$SchoolLevelsTableOrderingComposer,
          $$SchoolLevelsTableAnnotationComposer,
          $$SchoolLevelsTableCreateCompanionBuilder,
          $$SchoolLevelsTableUpdateCompanionBuilder,
          (
            SchoolLevel,
            BaseReferences<_$AppDatabase, $SchoolLevelsTable, SchoolLevel>,
          ),
          SchoolLevel,
          PrefetchHooks Function()
        > {
  $$SchoolLevelsTableTableManager(_$AppDatabase db, $SchoolLevelsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SchoolLevelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SchoolLevelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SchoolLevelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
              }) => SchoolLevelsCompanion(id: id, name: name),
          createCompanionCallback:
              ({Value<int> id = const Value.absent(), required String name}) =>
                  SchoolLevelsCompanion.insert(id: id, name: name),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SchoolLevelsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SchoolLevelsTable,
      SchoolLevel,
      $$SchoolLevelsTableFilterComposer,
      $$SchoolLevelsTableOrderingComposer,
      $$SchoolLevelsTableAnnotationComposer,
      $$SchoolLevelsTableCreateCompanionBuilder,
      $$SchoolLevelsTableUpdateCompanionBuilder,
      (
        SchoolLevel,
        BaseReferences<_$AppDatabase, $SchoolLevelsTable, SchoolLevel>,
      ),
      SchoolLevel,
      PrefetchHooks Function()
    >;
typedef $$IdentityCardTypesTableCreateCompanionBuilder =
    IdentityCardTypesCompanion Function({Value<int> id, required String name});
typedef $$IdentityCardTypesTableUpdateCompanionBuilder =
    IdentityCardTypesCompanion Function({Value<int> id, Value<String> name});

class $$IdentityCardTypesTableFilterComposer
    extends Composer<_$AppDatabase, $IdentityCardTypesTable> {
  $$IdentityCardTypesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $$IdentityCardTypesTableOrderingComposer
    extends Composer<_$AppDatabase, $IdentityCardTypesTable> {
  $$IdentityCardTypesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IdentityCardTypesTableAnnotationComposer
    extends Composer<_$AppDatabase, $IdentityCardTypesTable> {
  $$IdentityCardTypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$IdentityCardTypesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IdentityCardTypesTable,
          IdentityCardType,
          $$IdentityCardTypesTableFilterComposer,
          $$IdentityCardTypesTableOrderingComposer,
          $$IdentityCardTypesTableAnnotationComposer,
          $$IdentityCardTypesTableCreateCompanionBuilder,
          $$IdentityCardTypesTableUpdateCompanionBuilder,
          (
            IdentityCardType,
            BaseReferences<
              _$AppDatabase,
              $IdentityCardTypesTable,
              IdentityCardType
            >,
          ),
          IdentityCardType,
          PrefetchHooks Function()
        > {
  $$IdentityCardTypesTableTableManager(
    _$AppDatabase db,
    $IdentityCardTypesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IdentityCardTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IdentityCardTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IdentityCardTypesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
              }) => IdentityCardTypesCompanion(id: id, name: name),
          createCompanionCallback:
              ({Value<int> id = const Value.absent(), required String name}) =>
                  IdentityCardTypesCompanion.insert(id: id, name: name),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IdentityCardTypesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IdentityCardTypesTable,
      IdentityCardType,
      $$IdentityCardTypesTableFilterComposer,
      $$IdentityCardTypesTableOrderingComposer,
      $$IdentityCardTypesTableAnnotationComposer,
      $$IdentityCardTypesTableCreateCompanionBuilder,
      $$IdentityCardTypesTableUpdateCompanionBuilder,
      (
        IdentityCardType,
        BaseReferences<
          _$AppDatabase,
          $IdentityCardTypesTable,
          IdentityCardType
        >,
      ),
      IdentityCardType,
      PrefetchHooks Function()
    >;
typedef $$LegalStatusesTableCreateCompanionBuilder =
    LegalStatusesCompanion Function({Value<int> id, required String name});
typedef $$LegalStatusesTableUpdateCompanionBuilder =
    LegalStatusesCompanion Function({Value<int> id, Value<String> name});

final class $$LegalStatusesTableReferences
    extends BaseReferences<_$AppDatabase, $LegalStatusesTable, LegalStatus> {
  $$LegalStatusesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$FarmsTable, List<Farm>> _farmsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.farms,
    aliasName: $_aliasNameGenerator(
      db.legalStatuses.id,
      db.farms.legalStatusId,
    ),
  );

  $$FarmsTableProcessedTableManager get farmsRefs {
    final manager = $$FarmsTableTableManager(
      $_db,
      $_db.farms,
    ).filter((f) => f.legalStatusId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_farmsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LegalStatusesTableFilterComposer
    extends Composer<_$AppDatabase, $LegalStatusesTable> {
  $$LegalStatusesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> farmsRefs(
    Expression<bool> Function($$FarmsTableFilterComposer f) f,
  ) {
    final $$FarmsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.farms,
      getReferencedColumn: (t) => t.legalStatusId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FarmsTableFilterComposer(
            $db: $db,
            $table: $db.farms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LegalStatusesTableOrderingComposer
    extends Composer<_$AppDatabase, $LegalStatusesTable> {
  $$LegalStatusesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LegalStatusesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LegalStatusesTable> {
  $$LegalStatusesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  Expression<T> farmsRefs<T extends Object>(
    Expression<T> Function($$FarmsTableAnnotationComposer a) f,
  ) {
    final $$FarmsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.farms,
      getReferencedColumn: (t) => t.legalStatusId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FarmsTableAnnotationComposer(
            $db: $db,
            $table: $db.farms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LegalStatusesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LegalStatusesTable,
          LegalStatus,
          $$LegalStatusesTableFilterComposer,
          $$LegalStatusesTableOrderingComposer,
          $$LegalStatusesTableAnnotationComposer,
          $$LegalStatusesTableCreateCompanionBuilder,
          $$LegalStatusesTableUpdateCompanionBuilder,
          (LegalStatus, $$LegalStatusesTableReferences),
          LegalStatus,
          PrefetchHooks Function({bool farmsRefs})
        > {
  $$LegalStatusesTableTableManager(_$AppDatabase db, $LegalStatusesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LegalStatusesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LegalStatusesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LegalStatusesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
              }) => LegalStatusesCompanion(id: id, name: name),
          createCompanionCallback:
              ({Value<int> id = const Value.absent(), required String name}) =>
                  LegalStatusesCompanion.insert(id: id, name: name),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LegalStatusesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({farmsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (farmsRefs) db.farms],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (farmsRefs)
                    await $_getPrefetchedData<
                      LegalStatus,
                      $LegalStatusesTable,
                      Farm
                    >(
                      currentTable: table,
                      referencedTable: $$LegalStatusesTableReferences
                          ._farmsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$LegalStatusesTableReferences(
                            db,
                            table,
                            p0,
                          ).farmsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.legalStatusId == item.id,
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

typedef $$LegalStatusesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LegalStatusesTable,
      LegalStatus,
      $$LegalStatusesTableFilterComposer,
      $$LegalStatusesTableOrderingComposer,
      $$LegalStatusesTableAnnotationComposer,
      $$LegalStatusesTableCreateCompanionBuilder,
      $$LegalStatusesTableUpdateCompanionBuilder,
      (LegalStatus, $$LegalStatusesTableReferences),
      LegalStatus,
      PrefetchHooks Function({bool farmsRefs})
    >;
typedef $$FarmsTableCreateCompanionBuilder =
    FarmsCompanion Function({
      Value<int> id,
      required int farmerId,
      required String uuid,
      required String referenceNo,
      required String regionalRegNo,
      required String name,
      required String size,
      required String sizeUnit,
      required String latitudes,
      required String longitudes,
      required String physicalAddress,
      Value<int?> villageId,
      required int wardId,
      required int districtId,
      required int regionId,
      required int countryId,
      required int legalStatusId,
      Value<String> status,
      Value<bool> synced,
      Value<String> syncAction,
      required String createdAt,
      required String updatedAt,
    });
typedef $$FarmsTableUpdateCompanionBuilder =
    FarmsCompanion Function({
      Value<int> id,
      Value<int> farmerId,
      Value<String> uuid,
      Value<String> referenceNo,
      Value<String> regionalRegNo,
      Value<String> name,
      Value<String> size,
      Value<String> sizeUnit,
      Value<String> latitudes,
      Value<String> longitudes,
      Value<String> physicalAddress,
      Value<int?> villageId,
      Value<int> wardId,
      Value<int> districtId,
      Value<int> regionId,
      Value<int> countryId,
      Value<int> legalStatusId,
      Value<String> status,
      Value<bool> synced,
      Value<String> syncAction,
      Value<String> createdAt,
      Value<String> updatedAt,
    });

final class $$FarmsTableReferences
    extends BaseReferences<_$AppDatabase, $FarmsTable, Farm> {
  $$FarmsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WardsTable _wardIdTable(_$AppDatabase db) =>
      db.wards.createAlias($_aliasNameGenerator(db.farms.wardId, db.wards.id));

  $$WardsTableProcessedTableManager get wardId {
    final $_column = $_itemColumn<int>('ward_id')!;

    final manager = $$WardsTableTableManager(
      $_db,
      $_db.wards,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_wardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $DistrictsTable _districtIdTable(_$AppDatabase db) => db.districts
      .createAlias($_aliasNameGenerator(db.farms.districtId, db.districts.id));

  $$DistrictsTableProcessedTableManager get districtId {
    final $_column = $_itemColumn<int>('district_id')!;

    final manager = $$DistrictsTableTableManager(
      $_db,
      $_db.districts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_districtIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $RegionsTable _regionIdTable(_$AppDatabase db) => db.regions
      .createAlias($_aliasNameGenerator(db.farms.regionId, db.regions.id));

  $$RegionsTableProcessedTableManager get regionId {
    final $_column = $_itemColumn<int>('region_id')!;

    final manager = $$RegionsTableTableManager(
      $_db,
      $_db.regions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_regionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CountriesTable _countryIdTable(_$AppDatabase db) => db.countries
      .createAlias($_aliasNameGenerator(db.farms.countryId, db.countries.id));

  $$CountriesTableProcessedTableManager get countryId {
    final $_column = $_itemColumn<int>('country_id')!;

    final manager = $$CountriesTableTableManager(
      $_db,
      $_db.countries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_countryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $LegalStatusesTable _legalStatusIdTable(_$AppDatabase db) =>
      db.legalStatuses.createAlias(
        $_aliasNameGenerator(db.farms.legalStatusId, db.legalStatuses.id),
      );

  $$LegalStatusesTableProcessedTableManager get legalStatusId {
    final $_column = $_itemColumn<int>('legal_status_id')!;

    final manager = $$LegalStatusesTableTableManager(
      $_db,
      $_db.legalStatuses,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_legalStatusIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FarmsTableFilterComposer extends Composer<_$AppDatabase, $FarmsTable> {
  $$FarmsTableFilterComposer({
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

  ColumnFilters<int> get farmerId => $composableBuilder(
    column: $table.farmerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referenceNo => $composableBuilder(
    column: $table.referenceNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get regionalRegNo => $composableBuilder(
    column: $table.regionalRegNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sizeUnit => $composableBuilder(
    column: $table.sizeUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get latitudes => $composableBuilder(
    column: $table.latitudes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get longitudes => $composableBuilder(
    column: $table.longitudes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get physicalAddress => $composableBuilder(
    column: $table.physicalAddress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get villageId => $composableBuilder(
    column: $table.villageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncAction => $composableBuilder(
    column: $table.syncAction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WardsTableFilterComposer get wardId {
    final $$WardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wardId,
      referencedTable: $db.wards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WardsTableFilterComposer(
            $db: $db,
            $table: $db.wards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DistrictsTableFilterComposer get districtId {
    final $$DistrictsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.districtId,
      referencedTable: $db.districts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DistrictsTableFilterComposer(
            $db: $db,
            $table: $db.districts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RegionsTableFilterComposer get regionId {
    final $$RegionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.regionId,
      referencedTable: $db.regions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RegionsTableFilterComposer(
            $db: $db,
            $table: $db.regions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CountriesTableFilterComposer get countryId {
    final $$CountriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.countryId,
      referencedTable: $db.countries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CountriesTableFilterComposer(
            $db: $db,
            $table: $db.countries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LegalStatusesTableFilterComposer get legalStatusId {
    final $$LegalStatusesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.legalStatusId,
      referencedTable: $db.legalStatuses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LegalStatusesTableFilterComposer(
            $db: $db,
            $table: $db.legalStatuses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FarmsTableOrderingComposer
    extends Composer<_$AppDatabase, $FarmsTable> {
  $$FarmsTableOrderingComposer({
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

  ColumnOrderings<int> get farmerId => $composableBuilder(
    column: $table.farmerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referenceNo => $composableBuilder(
    column: $table.referenceNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get regionalRegNo => $composableBuilder(
    column: $table.regionalRegNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sizeUnit => $composableBuilder(
    column: $table.sizeUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get latitudes => $composableBuilder(
    column: $table.latitudes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get longitudes => $composableBuilder(
    column: $table.longitudes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get physicalAddress => $composableBuilder(
    column: $table.physicalAddress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get villageId => $composableBuilder(
    column: $table.villageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncAction => $composableBuilder(
    column: $table.syncAction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WardsTableOrderingComposer get wardId {
    final $$WardsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wardId,
      referencedTable: $db.wards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WardsTableOrderingComposer(
            $db: $db,
            $table: $db.wards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DistrictsTableOrderingComposer get districtId {
    final $$DistrictsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.districtId,
      referencedTable: $db.districts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DistrictsTableOrderingComposer(
            $db: $db,
            $table: $db.districts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RegionsTableOrderingComposer get regionId {
    final $$RegionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.regionId,
      referencedTable: $db.regions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RegionsTableOrderingComposer(
            $db: $db,
            $table: $db.regions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CountriesTableOrderingComposer get countryId {
    final $$CountriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.countryId,
      referencedTable: $db.countries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CountriesTableOrderingComposer(
            $db: $db,
            $table: $db.countries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LegalStatusesTableOrderingComposer get legalStatusId {
    final $$LegalStatusesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.legalStatusId,
      referencedTable: $db.legalStatuses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LegalStatusesTableOrderingComposer(
            $db: $db,
            $table: $db.legalStatuses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FarmsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FarmsTable> {
  $$FarmsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get farmerId =>
      $composableBuilder(column: $table.farmerId, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get referenceNo => $composableBuilder(
    column: $table.referenceNo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get regionalRegNo => $composableBuilder(
    column: $table.regionalRegNo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get size =>
      $composableBuilder(column: $table.size, builder: (column) => column);

  GeneratedColumn<String> get sizeUnit =>
      $composableBuilder(column: $table.sizeUnit, builder: (column) => column);

  GeneratedColumn<String> get latitudes =>
      $composableBuilder(column: $table.latitudes, builder: (column) => column);

  GeneratedColumn<String> get longitudes => $composableBuilder(
    column: $table.longitudes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get physicalAddress => $composableBuilder(
    column: $table.physicalAddress,
    builder: (column) => column,
  );

  GeneratedColumn<int> get villageId =>
      $composableBuilder(column: $table.villageId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<String> get syncAction => $composableBuilder(
    column: $table.syncAction,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$WardsTableAnnotationComposer get wardId {
    final $$WardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wardId,
      referencedTable: $db.wards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WardsTableAnnotationComposer(
            $db: $db,
            $table: $db.wards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DistrictsTableAnnotationComposer get districtId {
    final $$DistrictsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.districtId,
      referencedTable: $db.districts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DistrictsTableAnnotationComposer(
            $db: $db,
            $table: $db.districts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RegionsTableAnnotationComposer get regionId {
    final $$RegionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.regionId,
      referencedTable: $db.regions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RegionsTableAnnotationComposer(
            $db: $db,
            $table: $db.regions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CountriesTableAnnotationComposer get countryId {
    final $$CountriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.countryId,
      referencedTable: $db.countries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CountriesTableAnnotationComposer(
            $db: $db,
            $table: $db.countries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LegalStatusesTableAnnotationComposer get legalStatusId {
    final $$LegalStatusesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.legalStatusId,
      referencedTable: $db.legalStatuses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LegalStatusesTableAnnotationComposer(
            $db: $db,
            $table: $db.legalStatuses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FarmsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FarmsTable,
          Farm,
          $$FarmsTableFilterComposer,
          $$FarmsTableOrderingComposer,
          $$FarmsTableAnnotationComposer,
          $$FarmsTableCreateCompanionBuilder,
          $$FarmsTableUpdateCompanionBuilder,
          (Farm, $$FarmsTableReferences),
          Farm,
          PrefetchHooks Function({
            bool wardId,
            bool districtId,
            bool regionId,
            bool countryId,
            bool legalStatusId,
          })
        > {
  $$FarmsTableTableManager(_$AppDatabase db, $FarmsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FarmsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FarmsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FarmsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> farmerId = const Value.absent(),
                Value<String> uuid = const Value.absent(),
                Value<String> referenceNo = const Value.absent(),
                Value<String> regionalRegNo = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> size = const Value.absent(),
                Value<String> sizeUnit = const Value.absent(),
                Value<String> latitudes = const Value.absent(),
                Value<String> longitudes = const Value.absent(),
                Value<String> physicalAddress = const Value.absent(),
                Value<int?> villageId = const Value.absent(),
                Value<int> wardId = const Value.absent(),
                Value<int> districtId = const Value.absent(),
                Value<int> regionId = const Value.absent(),
                Value<int> countryId = const Value.absent(),
                Value<int> legalStatusId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<String> syncAction = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
              }) => FarmsCompanion(
                id: id,
                farmerId: farmerId,
                uuid: uuid,
                referenceNo: referenceNo,
                regionalRegNo: regionalRegNo,
                name: name,
                size: size,
                sizeUnit: sizeUnit,
                latitudes: latitudes,
                longitudes: longitudes,
                physicalAddress: physicalAddress,
                villageId: villageId,
                wardId: wardId,
                districtId: districtId,
                regionId: regionId,
                countryId: countryId,
                legalStatusId: legalStatusId,
                status: status,
                synced: synced,
                syncAction: syncAction,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int farmerId,
                required String uuid,
                required String referenceNo,
                required String regionalRegNo,
                required String name,
                required String size,
                required String sizeUnit,
                required String latitudes,
                required String longitudes,
                required String physicalAddress,
                Value<int?> villageId = const Value.absent(),
                required int wardId,
                required int districtId,
                required int regionId,
                required int countryId,
                required int legalStatusId,
                Value<String> status = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<String> syncAction = const Value.absent(),
                required String createdAt,
                required String updatedAt,
              }) => FarmsCompanion.insert(
                id: id,
                farmerId: farmerId,
                uuid: uuid,
                referenceNo: referenceNo,
                regionalRegNo: regionalRegNo,
                name: name,
                size: size,
                sizeUnit: sizeUnit,
                latitudes: latitudes,
                longitudes: longitudes,
                physicalAddress: physicalAddress,
                villageId: villageId,
                wardId: wardId,
                districtId: districtId,
                regionId: regionId,
                countryId: countryId,
                legalStatusId: legalStatusId,
                status: status,
                synced: synced,
                syncAction: syncAction,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$FarmsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                wardId = false,
                districtId = false,
                regionId = false,
                countryId = false,
                legalStatusId = false,
              }) {
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
                        if (wardId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.wardId,
                                    referencedTable: $$FarmsTableReferences
                                        ._wardIdTable(db),
                                    referencedColumn: $$FarmsTableReferences
                                        ._wardIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (districtId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.districtId,
                                    referencedTable: $$FarmsTableReferences
                                        ._districtIdTable(db),
                                    referencedColumn: $$FarmsTableReferences
                                        ._districtIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (regionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.regionId,
                                    referencedTable: $$FarmsTableReferences
                                        ._regionIdTable(db),
                                    referencedColumn: $$FarmsTableReferences
                                        ._regionIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (countryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.countryId,
                                    referencedTable: $$FarmsTableReferences
                                        ._countryIdTable(db),
                                    referencedColumn: $$FarmsTableReferences
                                        ._countryIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (legalStatusId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.legalStatusId,
                                    referencedTable: $$FarmsTableReferences
                                        ._legalStatusIdTable(db),
                                    referencedColumn: $$FarmsTableReferences
                                        ._legalStatusIdTable(db)
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

typedef $$FarmsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FarmsTable,
      Farm,
      $$FarmsTableFilterComposer,
      $$FarmsTableOrderingComposer,
      $$FarmsTableAnnotationComposer,
      $$FarmsTableCreateCompanionBuilder,
      $$FarmsTableUpdateCompanionBuilder,
      (Farm, $$FarmsTableReferences),
      Farm,
      PrefetchHooks Function({
        bool wardId,
        bool districtId,
        bool regionId,
        bool countryId,
        bool legalStatusId,
      })
    >;
typedef $$LivestocksTableCreateCompanionBuilder =
    LivestocksCompanion Function({
      Value<int> id,
      required String farmUuid,
      required String uuid,
      required String identificationNumber,
      required String dummyTagId,
      required String barcodeTagId,
      required String rfidTagId,
      required int livestockTypeId,
      required String name,
      required String dateOfBirth,
      Value<String?> motherUuid,
      Value<String?> fatherUuid,
      required String gender,
      required int breedId,
      required int speciesId,
      Value<String> status,
      required int livestockObtainedMethodId,
      required DateTime dateFirstEnteredToFarm,
      required double weightAsOnRegistration,
      Value<bool> synced,
      Value<String> syncAction,
      required String createdAt,
      required String updatedAt,
    });
typedef $$LivestocksTableUpdateCompanionBuilder =
    LivestocksCompanion Function({
      Value<int> id,
      Value<String> farmUuid,
      Value<String> uuid,
      Value<String> identificationNumber,
      Value<String> dummyTagId,
      Value<String> barcodeTagId,
      Value<String> rfidTagId,
      Value<int> livestockTypeId,
      Value<String> name,
      Value<String> dateOfBirth,
      Value<String?> motherUuid,
      Value<String?> fatherUuid,
      Value<String> gender,
      Value<int> breedId,
      Value<int> speciesId,
      Value<String> status,
      Value<int> livestockObtainedMethodId,
      Value<DateTime> dateFirstEnteredToFarm,
      Value<double> weightAsOnRegistration,
      Value<bool> synced,
      Value<String> syncAction,
      Value<String> createdAt,
      Value<String> updatedAt,
    });

class $$LivestocksTableFilterComposer
    extends Composer<_$AppDatabase, $LivestocksTable> {
  $$LivestocksTableFilterComposer({
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

  ColumnFilters<String> get farmUuid => $composableBuilder(
    column: $table.farmUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get identificationNumber => $composableBuilder(
    column: $table.identificationNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dummyTagId => $composableBuilder(
    column: $table.dummyTagId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcodeTagId => $composableBuilder(
    column: $table.barcodeTagId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rfidTagId => $composableBuilder(
    column: $table.rfidTagId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get livestockTypeId => $composableBuilder(
    column: $table.livestockTypeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get motherUuid => $composableBuilder(
    column: $table.motherUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fatherUuid => $composableBuilder(
    column: $table.fatherUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get breedId => $composableBuilder(
    column: $table.breedId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get speciesId => $composableBuilder(
    column: $table.speciesId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get livestockObtainedMethodId => $composableBuilder(
    column: $table.livestockObtainedMethodId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateFirstEnteredToFarm => $composableBuilder(
    column: $table.dateFirstEnteredToFarm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightAsOnRegistration => $composableBuilder(
    column: $table.weightAsOnRegistration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncAction => $composableBuilder(
    column: $table.syncAction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LivestocksTableOrderingComposer
    extends Composer<_$AppDatabase, $LivestocksTable> {
  $$LivestocksTableOrderingComposer({
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

  ColumnOrderings<String> get farmUuid => $composableBuilder(
    column: $table.farmUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get identificationNumber => $composableBuilder(
    column: $table.identificationNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dummyTagId => $composableBuilder(
    column: $table.dummyTagId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcodeTagId => $composableBuilder(
    column: $table.barcodeTagId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rfidTagId => $composableBuilder(
    column: $table.rfidTagId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get livestockTypeId => $composableBuilder(
    column: $table.livestockTypeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get motherUuid => $composableBuilder(
    column: $table.motherUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fatherUuid => $composableBuilder(
    column: $table.fatherUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get breedId => $composableBuilder(
    column: $table.breedId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get speciesId => $composableBuilder(
    column: $table.speciesId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get livestockObtainedMethodId => $composableBuilder(
    column: $table.livestockObtainedMethodId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateFirstEnteredToFarm => $composableBuilder(
    column: $table.dateFirstEnteredToFarm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightAsOnRegistration => $composableBuilder(
    column: $table.weightAsOnRegistration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncAction => $composableBuilder(
    column: $table.syncAction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LivestocksTableAnnotationComposer
    extends Composer<_$AppDatabase, $LivestocksTable> {
  $$LivestocksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get farmUuid =>
      $composableBuilder(column: $table.farmUuid, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get identificationNumber => $composableBuilder(
    column: $table.identificationNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dummyTagId => $composableBuilder(
    column: $table.dummyTagId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get barcodeTagId => $composableBuilder(
    column: $table.barcodeTagId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rfidTagId =>
      $composableBuilder(column: $table.rfidTagId, builder: (column) => column);

  GeneratedColumn<int> get livestockTypeId => $composableBuilder(
    column: $table.livestockTypeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => column,
  );

  GeneratedColumn<String> get motherUuid => $composableBuilder(
    column: $table.motherUuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fatherUuid => $composableBuilder(
    column: $table.fatherUuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<int> get breedId =>
      $composableBuilder(column: $table.breedId, builder: (column) => column);

  GeneratedColumn<int> get speciesId =>
      $composableBuilder(column: $table.speciesId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get livestockObtainedMethodId => $composableBuilder(
    column: $table.livestockObtainedMethodId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateFirstEnteredToFarm => $composableBuilder(
    column: $table.dateFirstEnteredToFarm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get weightAsOnRegistration => $composableBuilder(
    column: $table.weightAsOnRegistration,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<String> get syncAction => $composableBuilder(
    column: $table.syncAction,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LivestocksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LivestocksTable,
          Livestock,
          $$LivestocksTableFilterComposer,
          $$LivestocksTableOrderingComposer,
          $$LivestocksTableAnnotationComposer,
          $$LivestocksTableCreateCompanionBuilder,
          $$LivestocksTableUpdateCompanionBuilder,
          (
            Livestock,
            BaseReferences<_$AppDatabase, $LivestocksTable, Livestock>,
          ),
          Livestock,
          PrefetchHooks Function()
        > {
  $$LivestocksTableTableManager(_$AppDatabase db, $LivestocksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LivestocksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LivestocksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LivestocksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> farmUuid = const Value.absent(),
                Value<String> uuid = const Value.absent(),
                Value<String> identificationNumber = const Value.absent(),
                Value<String> dummyTagId = const Value.absent(),
                Value<String> barcodeTagId = const Value.absent(),
                Value<String> rfidTagId = const Value.absent(),
                Value<int> livestockTypeId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> dateOfBirth = const Value.absent(),
                Value<String?> motherUuid = const Value.absent(),
                Value<String?> fatherUuid = const Value.absent(),
                Value<String> gender = const Value.absent(),
                Value<int> breedId = const Value.absent(),
                Value<int> speciesId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> livestockObtainedMethodId = const Value.absent(),
                Value<DateTime> dateFirstEnteredToFarm = const Value.absent(),
                Value<double> weightAsOnRegistration = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<String> syncAction = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
              }) => LivestocksCompanion(
                id: id,
                farmUuid: farmUuid,
                uuid: uuid,
                identificationNumber: identificationNumber,
                dummyTagId: dummyTagId,
                barcodeTagId: barcodeTagId,
                rfidTagId: rfidTagId,
                livestockTypeId: livestockTypeId,
                name: name,
                dateOfBirth: dateOfBirth,
                motherUuid: motherUuid,
                fatherUuid: fatherUuid,
                gender: gender,
                breedId: breedId,
                speciesId: speciesId,
                status: status,
                livestockObtainedMethodId: livestockObtainedMethodId,
                dateFirstEnteredToFarm: dateFirstEnteredToFarm,
                weightAsOnRegistration: weightAsOnRegistration,
                synced: synced,
                syncAction: syncAction,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String farmUuid,
                required String uuid,
                required String identificationNumber,
                required String dummyTagId,
                required String barcodeTagId,
                required String rfidTagId,
                required int livestockTypeId,
                required String name,
                required String dateOfBirth,
                Value<String?> motherUuid = const Value.absent(),
                Value<String?> fatherUuid = const Value.absent(),
                required String gender,
                required int breedId,
                required int speciesId,
                Value<String> status = const Value.absent(),
                required int livestockObtainedMethodId,
                required DateTime dateFirstEnteredToFarm,
                required double weightAsOnRegistration,
                Value<bool> synced = const Value.absent(),
                Value<String> syncAction = const Value.absent(),
                required String createdAt,
                required String updatedAt,
              }) => LivestocksCompanion.insert(
                id: id,
                farmUuid: farmUuid,
                uuid: uuid,
                identificationNumber: identificationNumber,
                dummyTagId: dummyTagId,
                barcodeTagId: barcodeTagId,
                rfidTagId: rfidTagId,
                livestockTypeId: livestockTypeId,
                name: name,
                dateOfBirth: dateOfBirth,
                motherUuid: motherUuid,
                fatherUuid: fatherUuid,
                gender: gender,
                breedId: breedId,
                speciesId: speciesId,
                status: status,
                livestockObtainedMethodId: livestockObtainedMethodId,
                dateFirstEnteredToFarm: dateFirstEnteredToFarm,
                weightAsOnRegistration: weightAsOnRegistration,
                synced: synced,
                syncAction: syncAction,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LivestocksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LivestocksTable,
      Livestock,
      $$LivestocksTableFilterComposer,
      $$LivestocksTableOrderingComposer,
      $$LivestocksTableAnnotationComposer,
      $$LivestocksTableCreateCompanionBuilder,
      $$LivestocksTableUpdateCompanionBuilder,
      (Livestock, BaseReferences<_$AppDatabase, $LivestocksTable, Livestock>),
      Livestock,
      PrefetchHooks Function()
    >;
typedef $$SpeciesTableCreateCompanionBuilder =
    SpeciesCompanion Function({Value<int> id, required String name});
typedef $$SpeciesTableUpdateCompanionBuilder =
    SpeciesCompanion Function({Value<int> id, Value<String> name});

class $$SpeciesTableFilterComposer
    extends Composer<_$AppDatabase, $SpeciesTable> {
  $$SpeciesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SpeciesTableOrderingComposer
    extends Composer<_$AppDatabase, $SpeciesTable> {
  $$SpeciesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SpeciesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SpeciesTable> {
  $$SpeciesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$SpeciesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SpeciesTable,
          Specie,
          $$SpeciesTableFilterComposer,
          $$SpeciesTableOrderingComposer,
          $$SpeciesTableAnnotationComposer,
          $$SpeciesTableCreateCompanionBuilder,
          $$SpeciesTableUpdateCompanionBuilder,
          (Specie, BaseReferences<_$AppDatabase, $SpeciesTable, Specie>),
          Specie,
          PrefetchHooks Function()
        > {
  $$SpeciesTableTableManager(_$AppDatabase db, $SpeciesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SpeciesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SpeciesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SpeciesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
              }) => SpeciesCompanion(id: id, name: name),
          createCompanionCallback:
              ({Value<int> id = const Value.absent(), required String name}) =>
                  SpeciesCompanion.insert(id: id, name: name),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SpeciesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SpeciesTable,
      Specie,
      $$SpeciesTableFilterComposer,
      $$SpeciesTableOrderingComposer,
      $$SpeciesTableAnnotationComposer,
      $$SpeciesTableCreateCompanionBuilder,
      $$SpeciesTableUpdateCompanionBuilder,
      (Specie, BaseReferences<_$AppDatabase, $SpeciesTable, Specie>),
      Specie,
      PrefetchHooks Function()
    >;
typedef $$LivestockTypesTableCreateCompanionBuilder =
    LivestockTypesCompanion Function({Value<int> id, required String name});
typedef $$LivestockTypesTableUpdateCompanionBuilder =
    LivestockTypesCompanion Function({Value<int> id, Value<String> name});

final class $$LivestockTypesTableReferences
    extends BaseReferences<_$AppDatabase, $LivestockTypesTable, LivestockType> {
  $$LivestockTypesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$BreedsTable, List<Breed>> _breedsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.breeds,
    aliasName: $_aliasNameGenerator(
      db.livestockTypes.id,
      db.breeds.livestockTypeId,
    ),
  );

  $$BreedsTableProcessedTableManager get breedsRefs {
    final manager = $$BreedsTableTableManager(
      $_db,
      $_db.breeds,
    ).filter((f) => f.livestockTypeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_breedsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LivestockTypesTableFilterComposer
    extends Composer<_$AppDatabase, $LivestockTypesTable> {
  $$LivestockTypesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> breedsRefs(
    Expression<bool> Function($$BreedsTableFilterComposer f) f,
  ) {
    final $$BreedsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.breeds,
      getReferencedColumn: (t) => t.livestockTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BreedsTableFilterComposer(
            $db: $db,
            $table: $db.breeds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LivestockTypesTableOrderingComposer
    extends Composer<_$AppDatabase, $LivestockTypesTable> {
  $$LivestockTypesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LivestockTypesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LivestockTypesTable> {
  $$LivestockTypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  Expression<T> breedsRefs<T extends Object>(
    Expression<T> Function($$BreedsTableAnnotationComposer a) f,
  ) {
    final $$BreedsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.breeds,
      getReferencedColumn: (t) => t.livestockTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BreedsTableAnnotationComposer(
            $db: $db,
            $table: $db.breeds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LivestockTypesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LivestockTypesTable,
          LivestockType,
          $$LivestockTypesTableFilterComposer,
          $$LivestockTypesTableOrderingComposer,
          $$LivestockTypesTableAnnotationComposer,
          $$LivestockTypesTableCreateCompanionBuilder,
          $$LivestockTypesTableUpdateCompanionBuilder,
          (LivestockType, $$LivestockTypesTableReferences),
          LivestockType,
          PrefetchHooks Function({bool breedsRefs})
        > {
  $$LivestockTypesTableTableManager(
    _$AppDatabase db,
    $LivestockTypesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LivestockTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LivestockTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LivestockTypesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
              }) => LivestockTypesCompanion(id: id, name: name),
          createCompanionCallback:
              ({Value<int> id = const Value.absent(), required String name}) =>
                  LivestockTypesCompanion.insert(id: id, name: name),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LivestockTypesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({breedsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (breedsRefs) db.breeds],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (breedsRefs)
                    await $_getPrefetchedData<
                      LivestockType,
                      $LivestockTypesTable,
                      Breed
                    >(
                      currentTable: table,
                      referencedTable: $$LivestockTypesTableReferences
                          ._breedsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$LivestockTypesTableReferences(
                            db,
                            table,
                            p0,
                          ).breedsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.livestockTypeId == item.id,
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

typedef $$LivestockTypesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LivestockTypesTable,
      LivestockType,
      $$LivestockTypesTableFilterComposer,
      $$LivestockTypesTableOrderingComposer,
      $$LivestockTypesTableAnnotationComposer,
      $$LivestockTypesTableCreateCompanionBuilder,
      $$LivestockTypesTableUpdateCompanionBuilder,
      (LivestockType, $$LivestockTypesTableReferences),
      LivestockType,
      PrefetchHooks Function({bool breedsRefs})
    >;
typedef $$BreedsTableCreateCompanionBuilder =
    BreedsCompanion Function({
      Value<int> id,
      required String name,
      required String group,
      required int livestockTypeId,
    });
typedef $$BreedsTableUpdateCompanionBuilder =
    BreedsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> group,
      Value<int> livestockTypeId,
    });

final class $$BreedsTableReferences
    extends BaseReferences<_$AppDatabase, $BreedsTable, Breed> {
  $$BreedsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LivestockTypesTable _livestockTypeIdTable(_$AppDatabase db) =>
      db.livestockTypes.createAlias(
        $_aliasNameGenerator(db.breeds.livestockTypeId, db.livestockTypes.id),
      );

  $$LivestockTypesTableProcessedTableManager get livestockTypeId {
    final $_column = $_itemColumn<int>('livestock_type_id')!;

    final manager = $$LivestockTypesTableTableManager(
      $_db,
      $_db.livestockTypes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_livestockTypeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BreedsTableFilterComposer
    extends Composer<_$AppDatabase, $BreedsTable> {
  $$BreedsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get group => $composableBuilder(
    column: $table.group,
    builder: (column) => ColumnFilters(column),
  );

  $$LivestockTypesTableFilterComposer get livestockTypeId {
    final $$LivestockTypesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.livestockTypeId,
      referencedTable: $db.livestockTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LivestockTypesTableFilterComposer(
            $db: $db,
            $table: $db.livestockTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BreedsTableOrderingComposer
    extends Composer<_$AppDatabase, $BreedsTable> {
  $$BreedsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get group => $composableBuilder(
    column: $table.group,
    builder: (column) => ColumnOrderings(column),
  );

  $$LivestockTypesTableOrderingComposer get livestockTypeId {
    final $$LivestockTypesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.livestockTypeId,
      referencedTable: $db.livestockTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LivestockTypesTableOrderingComposer(
            $db: $db,
            $table: $db.livestockTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BreedsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BreedsTable> {
  $$BreedsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get group =>
      $composableBuilder(column: $table.group, builder: (column) => column);

  $$LivestockTypesTableAnnotationComposer get livestockTypeId {
    final $$LivestockTypesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.livestockTypeId,
      referencedTable: $db.livestockTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LivestockTypesTableAnnotationComposer(
            $db: $db,
            $table: $db.livestockTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BreedsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BreedsTable,
          Breed,
          $$BreedsTableFilterComposer,
          $$BreedsTableOrderingComposer,
          $$BreedsTableAnnotationComposer,
          $$BreedsTableCreateCompanionBuilder,
          $$BreedsTableUpdateCompanionBuilder,
          (Breed, $$BreedsTableReferences),
          Breed,
          PrefetchHooks Function({bool livestockTypeId})
        > {
  $$BreedsTableTableManager(_$AppDatabase db, $BreedsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BreedsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BreedsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BreedsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> group = const Value.absent(),
                Value<int> livestockTypeId = const Value.absent(),
              }) => BreedsCompanion(
                id: id,
                name: name,
                group: group,
                livestockTypeId: livestockTypeId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String group,
                required int livestockTypeId,
              }) => BreedsCompanion.insert(
                id: id,
                name: name,
                group: group,
                livestockTypeId: livestockTypeId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$BreedsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({livestockTypeId = false}) {
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
                    if (livestockTypeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.livestockTypeId,
                                referencedTable: $$BreedsTableReferences
                                    ._livestockTypeIdTable(db),
                                referencedColumn: $$BreedsTableReferences
                                    ._livestockTypeIdTable(db)
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

typedef $$BreedsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BreedsTable,
      Breed,
      $$BreedsTableFilterComposer,
      $$BreedsTableOrderingComposer,
      $$BreedsTableAnnotationComposer,
      $$BreedsTableCreateCompanionBuilder,
      $$BreedsTableUpdateCompanionBuilder,
      (Breed, $$BreedsTableReferences),
      Breed,
      PrefetchHooks Function({bool livestockTypeId})
    >;
typedef $$LivestockObtainedMethodsTableCreateCompanionBuilder =
    LivestockObtainedMethodsCompanion Function({
      Value<int> id,
      required String name,
    });
typedef $$LivestockObtainedMethodsTableUpdateCompanionBuilder =
    LivestockObtainedMethodsCompanion Function({
      Value<int> id,
      Value<String> name,
    });

class $$LivestockObtainedMethodsTableFilterComposer
    extends Composer<_$AppDatabase, $LivestockObtainedMethodsTable> {
  $$LivestockObtainedMethodsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LivestockObtainedMethodsTableOrderingComposer
    extends Composer<_$AppDatabase, $LivestockObtainedMethodsTable> {
  $$LivestockObtainedMethodsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LivestockObtainedMethodsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LivestockObtainedMethodsTable> {
  $$LivestockObtainedMethodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$LivestockObtainedMethodsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LivestockObtainedMethodsTable,
          LivestockObtainedMethod,
          $$LivestockObtainedMethodsTableFilterComposer,
          $$LivestockObtainedMethodsTableOrderingComposer,
          $$LivestockObtainedMethodsTableAnnotationComposer,
          $$LivestockObtainedMethodsTableCreateCompanionBuilder,
          $$LivestockObtainedMethodsTableUpdateCompanionBuilder,
          (
            LivestockObtainedMethod,
            BaseReferences<
              _$AppDatabase,
              $LivestockObtainedMethodsTable,
              LivestockObtainedMethod
            >,
          ),
          LivestockObtainedMethod,
          PrefetchHooks Function()
        > {
  $$LivestockObtainedMethodsTableTableManager(
    _$AppDatabase db,
    $LivestockObtainedMethodsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LivestockObtainedMethodsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LivestockObtainedMethodsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LivestockObtainedMethodsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
              }) => LivestockObtainedMethodsCompanion(id: id, name: name),
          createCompanionCallback:
              ({Value<int> id = const Value.absent(), required String name}) =>
                  LivestockObtainedMethodsCompanion.insert(id: id, name: name),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LivestockObtainedMethodsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LivestockObtainedMethodsTable,
      LivestockObtainedMethod,
      $$LivestockObtainedMethodsTableFilterComposer,
      $$LivestockObtainedMethodsTableOrderingComposer,
      $$LivestockObtainedMethodsTableAnnotationComposer,
      $$LivestockObtainedMethodsTableCreateCompanionBuilder,
      $$LivestockObtainedMethodsTableUpdateCompanionBuilder,
      (
        LivestockObtainedMethod,
        BaseReferences<
          _$AppDatabase,
          $LivestockObtainedMethodsTable,
          LivestockObtainedMethod
        >,
      ),
      LivestockObtainedMethod,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CountriesTableTableManager get countries =>
      $$CountriesTableTableManager(_db, _db.countries);
  $$RegionsTableTableManager get regions =>
      $$RegionsTableTableManager(_db, _db.regions);
  $$DistrictsTableTableManager get districts =>
      $$DistrictsTableTableManager(_db, _db.districts);
  $$DivisionsTableTableManager get divisions =>
      $$DivisionsTableTableManager(_db, _db.divisions);
  $$WardsTableTableManager get wards =>
      $$WardsTableTableManager(_db, _db.wards);
  $$VillagesTableTableManager get villages =>
      $$VillagesTableTableManager(_db, _db.villages);
  $$StreetsTableTableManager get streets =>
      $$StreetsTableTableManager(_db, _db.streets);
  $$SchoolLevelsTableTableManager get schoolLevels =>
      $$SchoolLevelsTableTableManager(_db, _db.schoolLevels);
  $$IdentityCardTypesTableTableManager get identityCardTypes =>
      $$IdentityCardTypesTableTableManager(_db, _db.identityCardTypes);
  $$LegalStatusesTableTableManager get legalStatuses =>
      $$LegalStatusesTableTableManager(_db, _db.legalStatuses);
  $$FarmsTableTableManager get farms =>
      $$FarmsTableTableManager(_db, _db.farms);
  $$LivestocksTableTableManager get livestocks =>
      $$LivestocksTableTableManager(_db, _db.livestocks);
  $$SpeciesTableTableManager get species =>
      $$SpeciesTableTableManager(_db, _db.species);
  $$LivestockTypesTableTableManager get livestockTypes =>
      $$LivestockTypesTableTableManager(_db, _db.livestockTypes);
  $$BreedsTableTableManager get breeds =>
      $$BreedsTableTableManager(_db, _db.breeds);
  $$LivestockObtainedMethodsTableTableManager get livestockObtainedMethods =>
      $$LivestockObtainedMethodsTableTableManager(
        _db,
        _db.livestockObtainedMethods,
      );
}
