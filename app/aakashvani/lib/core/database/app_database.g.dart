// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ZoneCacheEntriesTable extends ZoneCacheEntries
    with TableInfo<$ZoneCacheEntriesTable, ZoneCacheEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ZoneCacheEntriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _deviceIdsJsonMeta = const VerificationMeta(
    'deviceIdsJson',
  );
  @override
  late final GeneratedColumn<String> deviceIdsJson = GeneratedColumn<String>(
    'device_ids_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _defaultVolumeMeta = const VerificationMeta(
    'defaultVolume',
  );
  @override
  late final GeneratedColumn<int> defaultVolume = GeneratedColumn<int>(
    'default_volume',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    deviceIdsJson,
    defaultVolume,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'zone_cache_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<ZoneCacheEntry> instance, {
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
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('device_ids_json')) {
      context.handle(
        _deviceIdsJsonMeta,
        deviceIdsJson.isAcceptableOrUnknown(
          data['device_ids_json']!,
          _deviceIdsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_deviceIdsJsonMeta);
    }
    if (data.containsKey('default_volume')) {
      context.handle(
        _defaultVolumeMeta,
        defaultVolume.isAcceptableOrUnknown(
          data['default_volume']!,
          _defaultVolumeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_defaultVolumeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ZoneCacheEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ZoneCacheEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      deviceIdsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_ids_json'],
      )!,
      defaultVolume: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_volume'],
      )!,
    );
  }

  @override
  $ZoneCacheEntriesTable createAlias(String alias) {
    return $ZoneCacheEntriesTable(attachedDatabase, alias);
  }
}

class ZoneCacheEntry extends DataClass implements Insertable<ZoneCacheEntry> {
  final String id;
  final String name;
  final String deviceIdsJson;
  final int defaultVolume;
  const ZoneCacheEntry({
    required this.id,
    required this.name,
    required this.deviceIdsJson,
    required this.defaultVolume,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['device_ids_json'] = Variable<String>(deviceIdsJson);
    map['default_volume'] = Variable<int>(defaultVolume);
    return map;
  }

  ZoneCacheEntriesCompanion toCompanion(bool nullToAbsent) {
    return ZoneCacheEntriesCompanion(
      id: Value(id),
      name: Value(name),
      deviceIdsJson: Value(deviceIdsJson),
      defaultVolume: Value(defaultVolume),
    );
  }

  factory ZoneCacheEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ZoneCacheEntry(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      deviceIdsJson: serializer.fromJson<String>(json['deviceIdsJson']),
      defaultVolume: serializer.fromJson<int>(json['defaultVolume']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'deviceIdsJson': serializer.toJson<String>(deviceIdsJson),
      'defaultVolume': serializer.toJson<int>(defaultVolume),
    };
  }

  ZoneCacheEntry copyWith({
    String? id,
    String? name,
    String? deviceIdsJson,
    int? defaultVolume,
  }) => ZoneCacheEntry(
    id: id ?? this.id,
    name: name ?? this.name,
    deviceIdsJson: deviceIdsJson ?? this.deviceIdsJson,
    defaultVolume: defaultVolume ?? this.defaultVolume,
  );
  ZoneCacheEntry copyWithCompanion(ZoneCacheEntriesCompanion data) {
    return ZoneCacheEntry(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      deviceIdsJson: data.deviceIdsJson.present
          ? data.deviceIdsJson.value
          : this.deviceIdsJson,
      defaultVolume: data.defaultVolume.present
          ? data.defaultVolume.value
          : this.defaultVolume,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ZoneCacheEntry(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('deviceIdsJson: $deviceIdsJson, ')
          ..write('defaultVolume: $defaultVolume')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, deviceIdsJson, defaultVolume);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ZoneCacheEntry &&
          other.id == this.id &&
          other.name == this.name &&
          other.deviceIdsJson == this.deviceIdsJson &&
          other.defaultVolume == this.defaultVolume);
}

class ZoneCacheEntriesCompanion extends UpdateCompanion<ZoneCacheEntry> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> deviceIdsJson;
  final Value<int> defaultVolume;
  final Value<int> rowid;
  const ZoneCacheEntriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.deviceIdsJson = const Value.absent(),
    this.defaultVolume = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ZoneCacheEntriesCompanion.insert({
    required String id,
    required String name,
    required String deviceIdsJson,
    required int defaultVolume,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       deviceIdsJson = Value(deviceIdsJson),
       defaultVolume = Value(defaultVolume);
  static Insertable<ZoneCacheEntry> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? deviceIdsJson,
    Expression<int>? defaultVolume,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (deviceIdsJson != null) 'device_ids_json': deviceIdsJson,
      if (defaultVolume != null) 'default_volume': defaultVolume,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ZoneCacheEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? deviceIdsJson,
    Value<int>? defaultVolume,
    Value<int>? rowid,
  }) {
    return ZoneCacheEntriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      deviceIdsJson: deviceIdsJson ?? this.deviceIdsJson,
      defaultVolume: defaultVolume ?? this.defaultVolume,
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
    if (deviceIdsJson.present) {
      map['device_ids_json'] = Variable<String>(deviceIdsJson.value);
    }
    if (defaultVolume.present) {
      map['default_volume'] = Variable<int>(defaultVolume.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ZoneCacheEntriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('deviceIdsJson: $deviceIdsJson, ')
          ..write('defaultVolume: $defaultVolume, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DeviceCacheEntriesTable extends DeviceCacheEntries
    with TableInfo<$DeviceCacheEntriesTable, DeviceCacheEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeviceCacheEntriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _zoneIdMeta = const VerificationMeta('zoneId');
  @override
  late final GeneratedColumn<String> zoneId = GeneratedColumn<String>(
    'zone_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _onlineMeta = const VerificationMeta('online');
  @override
  late final GeneratedColumn<bool> online = GeneratedColumn<bool>(
    'online',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("online" IN (0, 1))',
    ),
  );
  static const VerificationMeta _playingMeta = const VerificationMeta(
    'playing',
  );
  @override
  late final GeneratedColumn<bool> playing = GeneratedColumn<bool>(
    'playing',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("playing" IN (0, 1))',
    ),
  );
  static const VerificationMeta _volumeMeta = const VerificationMeta('volume');
  @override
  late final GeneratedColumn<int> volume = GeneratedColumn<int>(
    'volume',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSeenMsMeta = const VerificationMeta(
    'lastSeenMs',
  );
  @override
  late final GeneratedColumn<int> lastSeenMs = GeneratedColumn<int>(
    'last_seen_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firmwareVersionMeta = const VerificationMeta(
    'firmwareVersion',
  );
  @override
  late final GeneratedColumn<String> firmwareVersion = GeneratedColumn<String>(
    'firmware_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    zoneId,
    online,
    playing,
    volume,
    lastSeenMs,
    firmwareVersion,
    model,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'device_cache_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeviceCacheEntry> instance, {
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
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('zone_id')) {
      context.handle(
        _zoneIdMeta,
        zoneId.isAcceptableOrUnknown(data['zone_id']!, _zoneIdMeta),
      );
    } else if (isInserting) {
      context.missing(_zoneIdMeta);
    }
    if (data.containsKey('online')) {
      context.handle(
        _onlineMeta,
        online.isAcceptableOrUnknown(data['online']!, _onlineMeta),
      );
    } else if (isInserting) {
      context.missing(_onlineMeta);
    }
    if (data.containsKey('playing')) {
      context.handle(
        _playingMeta,
        playing.isAcceptableOrUnknown(data['playing']!, _playingMeta),
      );
    } else if (isInserting) {
      context.missing(_playingMeta);
    }
    if (data.containsKey('volume')) {
      context.handle(
        _volumeMeta,
        volume.isAcceptableOrUnknown(data['volume']!, _volumeMeta),
      );
    } else if (isInserting) {
      context.missing(_volumeMeta);
    }
    if (data.containsKey('last_seen_ms')) {
      context.handle(
        _lastSeenMsMeta,
        lastSeenMs.isAcceptableOrUnknown(
          data['last_seen_ms']!,
          _lastSeenMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastSeenMsMeta);
    }
    if (data.containsKey('firmware_version')) {
      context.handle(
        _firmwareVersionMeta,
        firmwareVersion.isAcceptableOrUnknown(
          data['firmware_version']!,
          _firmwareVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_firmwareVersionMeta);
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    } else if (isInserting) {
      context.missing(_modelMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DeviceCacheEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeviceCacheEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      zoneId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}zone_id'],
      )!,
      online: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}online'],
      )!,
      playing: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}playing'],
      )!,
      volume: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}volume'],
      )!,
      lastSeenMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_seen_ms'],
      )!,
      firmwareVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}firmware_version'],
      )!,
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      )!,
    );
  }

  @override
  $DeviceCacheEntriesTable createAlias(String alias) {
    return $DeviceCacheEntriesTable(attachedDatabase, alias);
  }
}

class DeviceCacheEntry extends DataClass
    implements Insertable<DeviceCacheEntry> {
  final String id;
  final String name;
  final String zoneId;
  final bool online;
  final bool playing;
  final int volume;
  final int lastSeenMs;
  final String firmwareVersion;
  final String model;
  const DeviceCacheEntry({
    required this.id,
    required this.name,
    required this.zoneId,
    required this.online,
    required this.playing,
    required this.volume,
    required this.lastSeenMs,
    required this.firmwareVersion,
    required this.model,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['zone_id'] = Variable<String>(zoneId);
    map['online'] = Variable<bool>(online);
    map['playing'] = Variable<bool>(playing);
    map['volume'] = Variable<int>(volume);
    map['last_seen_ms'] = Variable<int>(lastSeenMs);
    map['firmware_version'] = Variable<String>(firmwareVersion);
    map['model'] = Variable<String>(model);
    return map;
  }

  DeviceCacheEntriesCompanion toCompanion(bool nullToAbsent) {
    return DeviceCacheEntriesCompanion(
      id: Value(id),
      name: Value(name),
      zoneId: Value(zoneId),
      online: Value(online),
      playing: Value(playing),
      volume: Value(volume),
      lastSeenMs: Value(lastSeenMs),
      firmwareVersion: Value(firmwareVersion),
      model: Value(model),
    );
  }

  factory DeviceCacheEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeviceCacheEntry(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      zoneId: serializer.fromJson<String>(json['zoneId']),
      online: serializer.fromJson<bool>(json['online']),
      playing: serializer.fromJson<bool>(json['playing']),
      volume: serializer.fromJson<int>(json['volume']),
      lastSeenMs: serializer.fromJson<int>(json['lastSeenMs']),
      firmwareVersion: serializer.fromJson<String>(json['firmwareVersion']),
      model: serializer.fromJson<String>(json['model']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'zoneId': serializer.toJson<String>(zoneId),
      'online': serializer.toJson<bool>(online),
      'playing': serializer.toJson<bool>(playing),
      'volume': serializer.toJson<int>(volume),
      'lastSeenMs': serializer.toJson<int>(lastSeenMs),
      'firmwareVersion': serializer.toJson<String>(firmwareVersion),
      'model': serializer.toJson<String>(model),
    };
  }

  DeviceCacheEntry copyWith({
    String? id,
    String? name,
    String? zoneId,
    bool? online,
    bool? playing,
    int? volume,
    int? lastSeenMs,
    String? firmwareVersion,
    String? model,
  }) => DeviceCacheEntry(
    id: id ?? this.id,
    name: name ?? this.name,
    zoneId: zoneId ?? this.zoneId,
    online: online ?? this.online,
    playing: playing ?? this.playing,
    volume: volume ?? this.volume,
    lastSeenMs: lastSeenMs ?? this.lastSeenMs,
    firmwareVersion: firmwareVersion ?? this.firmwareVersion,
    model: model ?? this.model,
  );
  DeviceCacheEntry copyWithCompanion(DeviceCacheEntriesCompanion data) {
    return DeviceCacheEntry(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      zoneId: data.zoneId.present ? data.zoneId.value : this.zoneId,
      online: data.online.present ? data.online.value : this.online,
      playing: data.playing.present ? data.playing.value : this.playing,
      volume: data.volume.present ? data.volume.value : this.volume,
      lastSeenMs: data.lastSeenMs.present
          ? data.lastSeenMs.value
          : this.lastSeenMs,
      firmwareVersion: data.firmwareVersion.present
          ? data.firmwareVersion.value
          : this.firmwareVersion,
      model: data.model.present ? data.model.value : this.model,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeviceCacheEntry(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('zoneId: $zoneId, ')
          ..write('online: $online, ')
          ..write('playing: $playing, ')
          ..write('volume: $volume, ')
          ..write('lastSeenMs: $lastSeenMs, ')
          ..write('firmwareVersion: $firmwareVersion, ')
          ..write('model: $model')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    zoneId,
    online,
    playing,
    volume,
    lastSeenMs,
    firmwareVersion,
    model,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeviceCacheEntry &&
          other.id == this.id &&
          other.name == this.name &&
          other.zoneId == this.zoneId &&
          other.online == this.online &&
          other.playing == this.playing &&
          other.volume == this.volume &&
          other.lastSeenMs == this.lastSeenMs &&
          other.firmwareVersion == this.firmwareVersion &&
          other.model == this.model);
}

class DeviceCacheEntriesCompanion extends UpdateCompanion<DeviceCacheEntry> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> zoneId;
  final Value<bool> online;
  final Value<bool> playing;
  final Value<int> volume;
  final Value<int> lastSeenMs;
  final Value<String> firmwareVersion;
  final Value<String> model;
  final Value<int> rowid;
  const DeviceCacheEntriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.zoneId = const Value.absent(),
    this.online = const Value.absent(),
    this.playing = const Value.absent(),
    this.volume = const Value.absent(),
    this.lastSeenMs = const Value.absent(),
    this.firmwareVersion = const Value.absent(),
    this.model = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DeviceCacheEntriesCompanion.insert({
    required String id,
    required String name,
    required String zoneId,
    required bool online,
    required bool playing,
    required int volume,
    required int lastSeenMs,
    required String firmwareVersion,
    required String model,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       zoneId = Value(zoneId),
       online = Value(online),
       playing = Value(playing),
       volume = Value(volume),
       lastSeenMs = Value(lastSeenMs),
       firmwareVersion = Value(firmwareVersion),
       model = Value(model);
  static Insertable<DeviceCacheEntry> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? zoneId,
    Expression<bool>? online,
    Expression<bool>? playing,
    Expression<int>? volume,
    Expression<int>? lastSeenMs,
    Expression<String>? firmwareVersion,
    Expression<String>? model,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (zoneId != null) 'zone_id': zoneId,
      if (online != null) 'online': online,
      if (playing != null) 'playing': playing,
      if (volume != null) 'volume': volume,
      if (lastSeenMs != null) 'last_seen_ms': lastSeenMs,
      if (firmwareVersion != null) 'firmware_version': firmwareVersion,
      if (model != null) 'model': model,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DeviceCacheEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? zoneId,
    Value<bool>? online,
    Value<bool>? playing,
    Value<int>? volume,
    Value<int>? lastSeenMs,
    Value<String>? firmwareVersion,
    Value<String>? model,
    Value<int>? rowid,
  }) {
    return DeviceCacheEntriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      zoneId: zoneId ?? this.zoneId,
      online: online ?? this.online,
      playing: playing ?? this.playing,
      volume: volume ?? this.volume,
      lastSeenMs: lastSeenMs ?? this.lastSeenMs,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      model: model ?? this.model,
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
    if (zoneId.present) {
      map['zone_id'] = Variable<String>(zoneId.value);
    }
    if (online.present) {
      map['online'] = Variable<bool>(online.value);
    }
    if (playing.present) {
      map['playing'] = Variable<bool>(playing.value);
    }
    if (volume.present) {
      map['volume'] = Variable<int>(volume.value);
    }
    if (lastSeenMs.present) {
      map['last_seen_ms'] = Variable<int>(lastSeenMs.value);
    }
    if (firmwareVersion.present) {
      map['firmware_version'] = Variable<String>(firmwareVersion.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeviceCacheEntriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('zoneId: $zoneId, ')
          ..write('online: $online, ')
          ..write('playing: $playing, ')
          ..write('volume: $volume, ')
          ..write('lastSeenMs: $lastSeenMs, ')
          ..write('firmwareVersion: $firmwareVersion, ')
          ..write('model: $model, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ClipCacheEntriesTable extends ClipCacheEntries
    with TableInfo<$ClipCacheEntriesTable, ClipCacheEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClipCacheEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    category,
    durationMs,
    source,
    url,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clip_cache_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<ClipCacheEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMsMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ClipCacheEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClipCacheEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
    );
  }

  @override
  $ClipCacheEntriesTable createAlias(String alias) {
    return $ClipCacheEntriesTable(attachedDatabase, alias);
  }
}

class ClipCacheEntry extends DataClass implements Insertable<ClipCacheEntry> {
  final String id;
  final String title;
  final String category;
  final int durationMs;
  final String source;
  final String url;
  const ClipCacheEntry({
    required this.id,
    required this.title,
    required this.category,
    required this.durationMs,
    required this.source,
    required this.url,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['category'] = Variable<String>(category);
    map['duration_ms'] = Variable<int>(durationMs);
    map['source'] = Variable<String>(source);
    map['url'] = Variable<String>(url);
    return map;
  }

  ClipCacheEntriesCompanion toCompanion(bool nullToAbsent) {
    return ClipCacheEntriesCompanion(
      id: Value(id),
      title: Value(title),
      category: Value(category),
      durationMs: Value(durationMs),
      source: Value(source),
      url: Value(url),
    );
  }

  factory ClipCacheEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClipCacheEntry(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      category: serializer.fromJson<String>(json['category']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      source: serializer.fromJson<String>(json['source']),
      url: serializer.fromJson<String>(json['url']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'category': serializer.toJson<String>(category),
      'durationMs': serializer.toJson<int>(durationMs),
      'source': serializer.toJson<String>(source),
      'url': serializer.toJson<String>(url),
    };
  }

  ClipCacheEntry copyWith({
    String? id,
    String? title,
    String? category,
    int? durationMs,
    String? source,
    String? url,
  }) => ClipCacheEntry(
    id: id ?? this.id,
    title: title ?? this.title,
    category: category ?? this.category,
    durationMs: durationMs ?? this.durationMs,
    source: source ?? this.source,
    url: url ?? this.url,
  );
  ClipCacheEntry copyWithCompanion(ClipCacheEntriesCompanion data) {
    return ClipCacheEntry(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      category: data.category.present ? data.category.value : this.category,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      source: data.source.present ? data.source.value : this.source,
      url: data.url.present ? data.url.value : this.url,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClipCacheEntry(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('durationMs: $durationMs, ')
          ..write('source: $source, ')
          ..write('url: $url')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, category, durationMs, source, url);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClipCacheEntry &&
          other.id == this.id &&
          other.title == this.title &&
          other.category == this.category &&
          other.durationMs == this.durationMs &&
          other.source == this.source &&
          other.url == this.url);
}

class ClipCacheEntriesCompanion extends UpdateCompanion<ClipCacheEntry> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> category;
  final Value<int> durationMs;
  final Value<String> source;
  final Value<String> url;
  final Value<int> rowid;
  const ClipCacheEntriesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.category = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.source = const Value.absent(),
    this.url = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClipCacheEntriesCompanion.insert({
    required String id,
    required String title,
    required String category,
    required int durationMs,
    required String source,
    required String url,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       category = Value(category),
       durationMs = Value(durationMs),
       source = Value(source),
       url = Value(url);
  static Insertable<ClipCacheEntry> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? category,
    Expression<int>? durationMs,
    Expression<String>? source,
    Expression<String>? url,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (category != null) 'category': category,
      if (durationMs != null) 'duration_ms': durationMs,
      if (source != null) 'source': source,
      if (url != null) 'url': url,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClipCacheEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? category,
    Value<int>? durationMs,
    Value<String>? source,
    Value<String>? url,
    Value<int>? rowid,
  }) {
    return ClipCacheEntriesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      durationMs: durationMs ?? this.durationMs,
      source: source ?? this.source,
      url: url ?? this.url,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClipCacheEntriesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('durationMs: $durationMs, ')
          ..write('source: $source, ')
          ..write('url: $url, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BroadcastOutboxTable extends BroadcastOutbox
    with TableInfo<$BroadcastOutboxTable, BroadcastOutboxData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BroadcastOutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _specJsonMeta = const VerificationMeta(
    'specJson',
  );
  @override
  late final GeneratedColumn<String> specJson = GeneratedColumn<String>(
    'spec_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  @override
  List<GeneratedColumn> get $columns => [id, specJson, createdAtMs, synced];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'broadcast_outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<BroadcastOutboxData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('spec_json')) {
      context.handle(
        _specJsonMeta,
        specJson.isAcceptableOrUnknown(data['spec_json']!, _specJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_specJsonMeta);
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BroadcastOutboxData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BroadcastOutboxData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      specJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}spec_json'],
      )!,
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $BroadcastOutboxTable createAlias(String alias) {
    return $BroadcastOutboxTable(attachedDatabase, alias);
  }
}

class BroadcastOutboxData extends DataClass
    implements Insertable<BroadcastOutboxData> {
  final String id;
  final String specJson;
  final int createdAtMs;
  final bool synced;
  const BroadcastOutboxData({
    required this.id,
    required this.specJson,
    required this.createdAtMs,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['spec_json'] = Variable<String>(specJson);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  BroadcastOutboxCompanion toCompanion(bool nullToAbsent) {
    return BroadcastOutboxCompanion(
      id: Value(id),
      specJson: Value(specJson),
      createdAtMs: Value(createdAtMs),
      synced: Value(synced),
    );
  }

  factory BroadcastOutboxData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BroadcastOutboxData(
      id: serializer.fromJson<String>(json['id']),
      specJson: serializer.fromJson<String>(json['specJson']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'specJson': serializer.toJson<String>(specJson),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  BroadcastOutboxData copyWith({
    String? id,
    String? specJson,
    int? createdAtMs,
    bool? synced,
  }) => BroadcastOutboxData(
    id: id ?? this.id,
    specJson: specJson ?? this.specJson,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    synced: synced ?? this.synced,
  );
  BroadcastOutboxData copyWithCompanion(BroadcastOutboxCompanion data) {
    return BroadcastOutboxData(
      id: data.id.present ? data.id.value : this.id,
      specJson: data.specJson.present ? data.specJson.value : this.specJson,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BroadcastOutboxData(')
          ..write('id: $id, ')
          ..write('specJson: $specJson, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, specJson, createdAtMs, synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BroadcastOutboxData &&
          other.id == this.id &&
          other.specJson == this.specJson &&
          other.createdAtMs == this.createdAtMs &&
          other.synced == this.synced);
}

class BroadcastOutboxCompanion extends UpdateCompanion<BroadcastOutboxData> {
  final Value<String> id;
  final Value<String> specJson;
  final Value<int> createdAtMs;
  final Value<bool> synced;
  final Value<int> rowid;
  const BroadcastOutboxCompanion({
    this.id = const Value.absent(),
    this.specJson = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BroadcastOutboxCompanion.insert({
    required String id,
    required String specJson,
    required int createdAtMs,
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       specJson = Value(specJson),
       createdAtMs = Value(createdAtMs);
  static Insertable<BroadcastOutboxData> custom({
    Expression<String>? id,
    Expression<String>? specJson,
    Expression<int>? createdAtMs,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (specJson != null) 'spec_json': specJson,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BroadcastOutboxCompanion copyWith({
    Value<String>? id,
    Value<String>? specJson,
    Value<int>? createdAtMs,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return BroadcastOutboxCompanion(
      id: id ?? this.id,
      specJson: specJson ?? this.specJson,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (specJson.present) {
      map['spec_json'] = Variable<String>(specJson.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BroadcastOutboxCompanion(')
          ..write('id: $id, ')
          ..write('specJson: $specJson, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScheduleOutboxTable extends ScheduleOutbox
    with TableInfo<$ScheduleOutboxTable, ScheduleOutboxData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScheduleOutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _specJsonMeta = const VerificationMeta(
    'specJson',
  );
  @override
  late final GeneratedColumn<String> specJson = GeneratedColumn<String>(
    'spec_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  @override
  List<GeneratedColumn> get $columns => [id, specJson, createdAtMs, synced];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schedule_outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScheduleOutboxData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('spec_json')) {
      context.handle(
        _specJsonMeta,
        specJson.isAcceptableOrUnknown(data['spec_json']!, _specJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_specJsonMeta);
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScheduleOutboxData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScheduleOutboxData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      specJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}spec_json'],
      )!,
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $ScheduleOutboxTable createAlias(String alias) {
    return $ScheduleOutboxTable(attachedDatabase, alias);
  }
}

class ScheduleOutboxData extends DataClass
    implements Insertable<ScheduleOutboxData> {
  final String id;
  final String specJson;
  final int createdAtMs;
  final bool synced;
  const ScheduleOutboxData({
    required this.id,
    required this.specJson,
    required this.createdAtMs,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['spec_json'] = Variable<String>(specJson);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  ScheduleOutboxCompanion toCompanion(bool nullToAbsent) {
    return ScheduleOutboxCompanion(
      id: Value(id),
      specJson: Value(specJson),
      createdAtMs: Value(createdAtMs),
      synced: Value(synced),
    );
  }

  factory ScheduleOutboxData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScheduleOutboxData(
      id: serializer.fromJson<String>(json['id']),
      specJson: serializer.fromJson<String>(json['specJson']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'specJson': serializer.toJson<String>(specJson),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  ScheduleOutboxData copyWith({
    String? id,
    String? specJson,
    int? createdAtMs,
    bool? synced,
  }) => ScheduleOutboxData(
    id: id ?? this.id,
    specJson: specJson ?? this.specJson,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    synced: synced ?? this.synced,
  );
  ScheduleOutboxData copyWithCompanion(ScheduleOutboxCompanion data) {
    return ScheduleOutboxData(
      id: data.id.present ? data.id.value : this.id,
      specJson: data.specJson.present ? data.specJson.value : this.specJson,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleOutboxData(')
          ..write('id: $id, ')
          ..write('specJson: $specJson, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, specJson, createdAtMs, synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScheduleOutboxData &&
          other.id == this.id &&
          other.specJson == this.specJson &&
          other.createdAtMs == this.createdAtMs &&
          other.synced == this.synced);
}

class ScheduleOutboxCompanion extends UpdateCompanion<ScheduleOutboxData> {
  final Value<String> id;
  final Value<String> specJson;
  final Value<int> createdAtMs;
  final Value<bool> synced;
  final Value<int> rowid;
  const ScheduleOutboxCompanion({
    this.id = const Value.absent(),
    this.specJson = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScheduleOutboxCompanion.insert({
    required String id,
    required String specJson,
    required int createdAtMs,
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       specJson = Value(specJson),
       createdAtMs = Value(createdAtMs);
  static Insertable<ScheduleOutboxData> custom({
    Expression<String>? id,
    Expression<String>? specJson,
    Expression<int>? createdAtMs,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (specJson != null) 'spec_json': specJson,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScheduleOutboxCompanion copyWith({
    Value<String>? id,
    Value<String>? specJson,
    Value<int>? createdAtMs,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return ScheduleOutboxCompanion(
      id: id ?? this.id,
      specJson: specJson ?? this.specJson,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (specJson.present) {
      map['spec_json'] = Variable<String>(specJson.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleOutboxCompanion(')
          ..write('id: $id, ')
          ..write('specJson: $specJson, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ZoneCacheEntriesTable zoneCacheEntries = $ZoneCacheEntriesTable(
    this,
  );
  late final $DeviceCacheEntriesTable deviceCacheEntries =
      $DeviceCacheEntriesTable(this);
  late final $ClipCacheEntriesTable clipCacheEntries = $ClipCacheEntriesTable(
    this,
  );
  late final $BroadcastOutboxTable broadcastOutbox = $BroadcastOutboxTable(
    this,
  );
  late final $ScheduleOutboxTable scheduleOutbox = $ScheduleOutboxTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    zoneCacheEntries,
    deviceCacheEntries,
    clipCacheEntries,
    broadcastOutbox,
    scheduleOutbox,
  ];
}

typedef $$ZoneCacheEntriesTableCreateCompanionBuilder =
    ZoneCacheEntriesCompanion Function({
      required String id,
      required String name,
      required String deviceIdsJson,
      required int defaultVolume,
      Value<int> rowid,
    });
typedef $$ZoneCacheEntriesTableUpdateCompanionBuilder =
    ZoneCacheEntriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> deviceIdsJson,
      Value<int> defaultVolume,
      Value<int> rowid,
    });

class $$ZoneCacheEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $ZoneCacheEntriesTable> {
  $$ZoneCacheEntriesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceIdsJson => $composableBuilder(
    column: $table.deviceIdsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultVolume => $composableBuilder(
    column: $table.defaultVolume,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ZoneCacheEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ZoneCacheEntriesTable> {
  $$ZoneCacheEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceIdsJson => $composableBuilder(
    column: $table.deviceIdsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultVolume => $composableBuilder(
    column: $table.defaultVolume,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ZoneCacheEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ZoneCacheEntriesTable> {
  $$ZoneCacheEntriesTableAnnotationComposer({
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

  GeneratedColumn<String> get deviceIdsJson => $composableBuilder(
    column: $table.deviceIdsJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get defaultVolume => $composableBuilder(
    column: $table.defaultVolume,
    builder: (column) => column,
  );
}

class $$ZoneCacheEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ZoneCacheEntriesTable,
          ZoneCacheEntry,
          $$ZoneCacheEntriesTableFilterComposer,
          $$ZoneCacheEntriesTableOrderingComposer,
          $$ZoneCacheEntriesTableAnnotationComposer,
          $$ZoneCacheEntriesTableCreateCompanionBuilder,
          $$ZoneCacheEntriesTableUpdateCompanionBuilder,
          (
            ZoneCacheEntry,
            BaseReferences<
              _$AppDatabase,
              $ZoneCacheEntriesTable,
              ZoneCacheEntry
            >,
          ),
          ZoneCacheEntry,
          PrefetchHooks Function()
        > {
  $$ZoneCacheEntriesTableTableManager(
    _$AppDatabase db,
    $ZoneCacheEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ZoneCacheEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ZoneCacheEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ZoneCacheEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> deviceIdsJson = const Value.absent(),
                Value<int> defaultVolume = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ZoneCacheEntriesCompanion(
                id: id,
                name: name,
                deviceIdsJson: deviceIdsJson,
                defaultVolume: defaultVolume,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String deviceIdsJson,
                required int defaultVolume,
                Value<int> rowid = const Value.absent(),
              }) => ZoneCacheEntriesCompanion.insert(
                id: id,
                name: name,
                deviceIdsJson: deviceIdsJson,
                defaultVolume: defaultVolume,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ZoneCacheEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ZoneCacheEntriesTable,
      ZoneCacheEntry,
      $$ZoneCacheEntriesTableFilterComposer,
      $$ZoneCacheEntriesTableOrderingComposer,
      $$ZoneCacheEntriesTableAnnotationComposer,
      $$ZoneCacheEntriesTableCreateCompanionBuilder,
      $$ZoneCacheEntriesTableUpdateCompanionBuilder,
      (
        ZoneCacheEntry,
        BaseReferences<_$AppDatabase, $ZoneCacheEntriesTable, ZoneCacheEntry>,
      ),
      ZoneCacheEntry,
      PrefetchHooks Function()
    >;
typedef $$DeviceCacheEntriesTableCreateCompanionBuilder =
    DeviceCacheEntriesCompanion Function({
      required String id,
      required String name,
      required String zoneId,
      required bool online,
      required bool playing,
      required int volume,
      required int lastSeenMs,
      required String firmwareVersion,
      required String model,
      Value<int> rowid,
    });
typedef $$DeviceCacheEntriesTableUpdateCompanionBuilder =
    DeviceCacheEntriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> zoneId,
      Value<bool> online,
      Value<bool> playing,
      Value<int> volume,
      Value<int> lastSeenMs,
      Value<String> firmwareVersion,
      Value<String> model,
      Value<int> rowid,
    });

class $$DeviceCacheEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $DeviceCacheEntriesTable> {
  $$DeviceCacheEntriesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get zoneId => $composableBuilder(
    column: $table.zoneId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get online => $composableBuilder(
    column: $table.online,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get playing => $composableBuilder(
    column: $table.playing,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get volume => $composableBuilder(
    column: $table.volume,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSeenMs => $composableBuilder(
    column: $table.lastSeenMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firmwareVersion => $composableBuilder(
    column: $table.firmwareVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DeviceCacheEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $DeviceCacheEntriesTable> {
  $$DeviceCacheEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get zoneId => $composableBuilder(
    column: $table.zoneId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get online => $composableBuilder(
    column: $table.online,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get playing => $composableBuilder(
    column: $table.playing,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get volume => $composableBuilder(
    column: $table.volume,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSeenMs => $composableBuilder(
    column: $table.lastSeenMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firmwareVersion => $composableBuilder(
    column: $table.firmwareVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DeviceCacheEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DeviceCacheEntriesTable> {
  $$DeviceCacheEntriesTableAnnotationComposer({
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

  GeneratedColumn<String> get zoneId =>
      $composableBuilder(column: $table.zoneId, builder: (column) => column);

  GeneratedColumn<bool> get online =>
      $composableBuilder(column: $table.online, builder: (column) => column);

  GeneratedColumn<bool> get playing =>
      $composableBuilder(column: $table.playing, builder: (column) => column);

  GeneratedColumn<int> get volume =>
      $composableBuilder(column: $table.volume, builder: (column) => column);

  GeneratedColumn<int> get lastSeenMs => $composableBuilder(
    column: $table.lastSeenMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get firmwareVersion => $composableBuilder(
    column: $table.firmwareVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);
}

class $$DeviceCacheEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DeviceCacheEntriesTable,
          DeviceCacheEntry,
          $$DeviceCacheEntriesTableFilterComposer,
          $$DeviceCacheEntriesTableOrderingComposer,
          $$DeviceCacheEntriesTableAnnotationComposer,
          $$DeviceCacheEntriesTableCreateCompanionBuilder,
          $$DeviceCacheEntriesTableUpdateCompanionBuilder,
          (
            DeviceCacheEntry,
            BaseReferences<
              _$AppDatabase,
              $DeviceCacheEntriesTable,
              DeviceCacheEntry
            >,
          ),
          DeviceCacheEntry,
          PrefetchHooks Function()
        > {
  $$DeviceCacheEntriesTableTableManager(
    _$AppDatabase db,
    $DeviceCacheEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeviceCacheEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeviceCacheEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DeviceCacheEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> zoneId = const Value.absent(),
                Value<bool> online = const Value.absent(),
                Value<bool> playing = const Value.absent(),
                Value<int> volume = const Value.absent(),
                Value<int> lastSeenMs = const Value.absent(),
                Value<String> firmwareVersion = const Value.absent(),
                Value<String> model = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DeviceCacheEntriesCompanion(
                id: id,
                name: name,
                zoneId: zoneId,
                online: online,
                playing: playing,
                volume: volume,
                lastSeenMs: lastSeenMs,
                firmwareVersion: firmwareVersion,
                model: model,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String zoneId,
                required bool online,
                required bool playing,
                required int volume,
                required int lastSeenMs,
                required String firmwareVersion,
                required String model,
                Value<int> rowid = const Value.absent(),
              }) => DeviceCacheEntriesCompanion.insert(
                id: id,
                name: name,
                zoneId: zoneId,
                online: online,
                playing: playing,
                volume: volume,
                lastSeenMs: lastSeenMs,
                firmwareVersion: firmwareVersion,
                model: model,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DeviceCacheEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DeviceCacheEntriesTable,
      DeviceCacheEntry,
      $$DeviceCacheEntriesTableFilterComposer,
      $$DeviceCacheEntriesTableOrderingComposer,
      $$DeviceCacheEntriesTableAnnotationComposer,
      $$DeviceCacheEntriesTableCreateCompanionBuilder,
      $$DeviceCacheEntriesTableUpdateCompanionBuilder,
      (
        DeviceCacheEntry,
        BaseReferences<
          _$AppDatabase,
          $DeviceCacheEntriesTable,
          DeviceCacheEntry
        >,
      ),
      DeviceCacheEntry,
      PrefetchHooks Function()
    >;
typedef $$ClipCacheEntriesTableCreateCompanionBuilder =
    ClipCacheEntriesCompanion Function({
      required String id,
      required String title,
      required String category,
      required int durationMs,
      required String source,
      required String url,
      Value<int> rowid,
    });
typedef $$ClipCacheEntriesTableUpdateCompanionBuilder =
    ClipCacheEntriesCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> category,
      Value<int> durationMs,
      Value<String> source,
      Value<String> url,
      Value<int> rowid,
    });

class $$ClipCacheEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $ClipCacheEntriesTable> {
  $$ClipCacheEntriesTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ClipCacheEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ClipCacheEntriesTable> {
  $$ClipCacheEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ClipCacheEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClipCacheEntriesTable> {
  $$ClipCacheEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);
}

class $$ClipCacheEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClipCacheEntriesTable,
          ClipCacheEntry,
          $$ClipCacheEntriesTableFilterComposer,
          $$ClipCacheEntriesTableOrderingComposer,
          $$ClipCacheEntriesTableAnnotationComposer,
          $$ClipCacheEntriesTableCreateCompanionBuilder,
          $$ClipCacheEntriesTableUpdateCompanionBuilder,
          (
            ClipCacheEntry,
            BaseReferences<
              _$AppDatabase,
              $ClipCacheEntriesTable,
              ClipCacheEntry
            >,
          ),
          ClipCacheEntry,
          PrefetchHooks Function()
        > {
  $$ClipCacheEntriesTableTableManager(
    _$AppDatabase db,
    $ClipCacheEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClipCacheEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClipCacheEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClipCacheEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClipCacheEntriesCompanion(
                id: id,
                title: title,
                category: category,
                durationMs: durationMs,
                source: source,
                url: url,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String category,
                required int durationMs,
                required String source,
                required String url,
                Value<int> rowid = const Value.absent(),
              }) => ClipCacheEntriesCompanion.insert(
                id: id,
                title: title,
                category: category,
                durationMs: durationMs,
                source: source,
                url: url,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ClipCacheEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClipCacheEntriesTable,
      ClipCacheEntry,
      $$ClipCacheEntriesTableFilterComposer,
      $$ClipCacheEntriesTableOrderingComposer,
      $$ClipCacheEntriesTableAnnotationComposer,
      $$ClipCacheEntriesTableCreateCompanionBuilder,
      $$ClipCacheEntriesTableUpdateCompanionBuilder,
      (
        ClipCacheEntry,
        BaseReferences<_$AppDatabase, $ClipCacheEntriesTable, ClipCacheEntry>,
      ),
      ClipCacheEntry,
      PrefetchHooks Function()
    >;
typedef $$BroadcastOutboxTableCreateCompanionBuilder =
    BroadcastOutboxCompanion Function({
      required String id,
      required String specJson,
      required int createdAtMs,
      Value<bool> synced,
      Value<int> rowid,
    });
typedef $$BroadcastOutboxTableUpdateCompanionBuilder =
    BroadcastOutboxCompanion Function({
      Value<String> id,
      Value<String> specJson,
      Value<int> createdAtMs,
      Value<bool> synced,
      Value<int> rowid,
    });

class $$BroadcastOutboxTableFilterComposer
    extends Composer<_$AppDatabase, $BroadcastOutboxTable> {
  $$BroadcastOutboxTableFilterComposer({
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

  ColumnFilters<String> get specJson => $composableBuilder(
    column: $table.specJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BroadcastOutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $BroadcastOutboxTable> {
  $$BroadcastOutboxTableOrderingComposer({
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

  ColumnOrderings<String> get specJson => $composableBuilder(
    column: $table.specJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BroadcastOutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $BroadcastOutboxTable> {
  $$BroadcastOutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get specJson =>
      $composableBuilder(column: $table.specJson, builder: (column) => column);

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$BroadcastOutboxTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BroadcastOutboxTable,
          BroadcastOutboxData,
          $$BroadcastOutboxTableFilterComposer,
          $$BroadcastOutboxTableOrderingComposer,
          $$BroadcastOutboxTableAnnotationComposer,
          $$BroadcastOutboxTableCreateCompanionBuilder,
          $$BroadcastOutboxTableUpdateCompanionBuilder,
          (
            BroadcastOutboxData,
            BaseReferences<
              _$AppDatabase,
              $BroadcastOutboxTable,
              BroadcastOutboxData
            >,
          ),
          BroadcastOutboxData,
          PrefetchHooks Function()
        > {
  $$BroadcastOutboxTableTableManager(
    _$AppDatabase db,
    $BroadcastOutboxTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BroadcastOutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BroadcastOutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BroadcastOutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> specJson = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BroadcastOutboxCompanion(
                id: id,
                specJson: specJson,
                createdAtMs: createdAtMs,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String specJson,
                required int createdAtMs,
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BroadcastOutboxCompanion.insert(
                id: id,
                specJson: specJson,
                createdAtMs: createdAtMs,
                synced: synced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BroadcastOutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BroadcastOutboxTable,
      BroadcastOutboxData,
      $$BroadcastOutboxTableFilterComposer,
      $$BroadcastOutboxTableOrderingComposer,
      $$BroadcastOutboxTableAnnotationComposer,
      $$BroadcastOutboxTableCreateCompanionBuilder,
      $$BroadcastOutboxTableUpdateCompanionBuilder,
      (
        BroadcastOutboxData,
        BaseReferences<
          _$AppDatabase,
          $BroadcastOutboxTable,
          BroadcastOutboxData
        >,
      ),
      BroadcastOutboxData,
      PrefetchHooks Function()
    >;
typedef $$ScheduleOutboxTableCreateCompanionBuilder =
    ScheduleOutboxCompanion Function({
      required String id,
      required String specJson,
      required int createdAtMs,
      Value<bool> synced,
      Value<int> rowid,
    });
typedef $$ScheduleOutboxTableUpdateCompanionBuilder =
    ScheduleOutboxCompanion Function({
      Value<String> id,
      Value<String> specJson,
      Value<int> createdAtMs,
      Value<bool> synced,
      Value<int> rowid,
    });

class $$ScheduleOutboxTableFilterComposer
    extends Composer<_$AppDatabase, $ScheduleOutboxTable> {
  $$ScheduleOutboxTableFilterComposer({
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

  ColumnFilters<String> get specJson => $composableBuilder(
    column: $table.specJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ScheduleOutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $ScheduleOutboxTable> {
  $$ScheduleOutboxTableOrderingComposer({
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

  ColumnOrderings<String> get specJson => $composableBuilder(
    column: $table.specJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScheduleOutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScheduleOutboxTable> {
  $$ScheduleOutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get specJson =>
      $composableBuilder(column: $table.specJson, builder: (column) => column);

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$ScheduleOutboxTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScheduleOutboxTable,
          ScheduleOutboxData,
          $$ScheduleOutboxTableFilterComposer,
          $$ScheduleOutboxTableOrderingComposer,
          $$ScheduleOutboxTableAnnotationComposer,
          $$ScheduleOutboxTableCreateCompanionBuilder,
          $$ScheduleOutboxTableUpdateCompanionBuilder,
          (
            ScheduleOutboxData,
            BaseReferences<
              _$AppDatabase,
              $ScheduleOutboxTable,
              ScheduleOutboxData
            >,
          ),
          ScheduleOutboxData,
          PrefetchHooks Function()
        > {
  $$ScheduleOutboxTableTableManager(
    _$AppDatabase db,
    $ScheduleOutboxTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScheduleOutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScheduleOutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScheduleOutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> specJson = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScheduleOutboxCompanion(
                id: id,
                specJson: specJson,
                createdAtMs: createdAtMs,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String specJson,
                required int createdAtMs,
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScheduleOutboxCompanion.insert(
                id: id,
                specJson: specJson,
                createdAtMs: createdAtMs,
                synced: synced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ScheduleOutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScheduleOutboxTable,
      ScheduleOutboxData,
      $$ScheduleOutboxTableFilterComposer,
      $$ScheduleOutboxTableOrderingComposer,
      $$ScheduleOutboxTableAnnotationComposer,
      $$ScheduleOutboxTableCreateCompanionBuilder,
      $$ScheduleOutboxTableUpdateCompanionBuilder,
      (
        ScheduleOutboxData,
        BaseReferences<_$AppDatabase, $ScheduleOutboxTable, ScheduleOutboxData>,
      ),
      ScheduleOutboxData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ZoneCacheEntriesTableTableManager get zoneCacheEntries =>
      $$ZoneCacheEntriesTableTableManager(_db, _db.zoneCacheEntries);
  $$DeviceCacheEntriesTableTableManager get deviceCacheEntries =>
      $$DeviceCacheEntriesTableTableManager(_db, _db.deviceCacheEntries);
  $$ClipCacheEntriesTableTableManager get clipCacheEntries =>
      $$ClipCacheEntriesTableTableManager(_db, _db.clipCacheEntries);
  $$BroadcastOutboxTableTableManager get broadcastOutbox =>
      $$BroadcastOutboxTableTableManager(_db, _db.broadcastOutbox);
  $$ScheduleOutboxTableTableManager get scheduleOutbox =>
      $$ScheduleOutboxTableTableManager(_db, _db.scheduleOutbox);
}
