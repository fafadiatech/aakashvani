import 'package:drift/drift.dart';

// ── Zone cache ───────────────────────────────────────────────────────────────

class ZoneCacheEntries extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get deviceIdsJson => text()();
  IntColumn get defaultVolume => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

// ── Device cache ─────────────────────────────────────────────────────────────

class DeviceCacheEntries extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get zoneId => text()();
  BoolColumn get online => boolean()();
  BoolColumn get playing => boolean()();
  IntColumn get volume => integer()();
  IntColumn get lastSeenMs => integer()();
  TextColumn get firmwareVersion => text()();
  TextColumn get model => text()();

  @override
  Set<Column> get primaryKey => {id};
}

// ── Clip cache ────────────────────────────────────────────────────────────────

class ClipCacheEntries extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get category => text()();
  IntColumn get durationMs => integer()();
  TextColumn get source => text()(); // 'uploaded' | 'recorded' | 'tts'
  TextColumn get url => text()();

  @override
  Set<Column> get primaryKey => {id};
}

// ── Broadcast outbox ──────────────────────────────────────────────────────────

class BroadcastOutbox extends Table {
  TextColumn get id => text()();
  TextColumn get specJson => text()();
  IntColumn get createdAtMs => integer()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ── Schedule outbox ───────────────────────────────────────────────────────────

class ScheduleOutbox extends Table {
  TextColumn get id => text()();
  TextColumn get specJson => text()();
  IntColumn get createdAtMs => integer()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
