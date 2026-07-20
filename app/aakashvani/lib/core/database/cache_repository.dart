import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aakashvani/domain/models/audio_clip.dart';
import 'package:aakashvani/domain/models/device.dart';
import 'package:aakashvani/domain/models/zone.dart';
import 'app_database.dart';
import 'database_provider.dart';

class CacheRepository {
  CacheRepository(this._db);

  final AppDatabase _db;

  // ── Zones ─────────────────────────────────────────────────────────────────

  Future<void> saveZones(List<Zone> zones) async {
    await _db.transaction(() async {
      await _db.delete(_db.zoneCacheEntries).go();
      for (final z in zones) {
        await _db.into(_db.zoneCacheEntries).insertOnConflictUpdate(
              ZoneCacheEntriesCompanion(
                id: Value(z.id),
                name: Value(z.name),
                deviceIdsJson: Value(jsonEncode(z.deviceIds)),
                defaultVolume: Value(z.defaultVolume),
              ),
            );
      }
    });
  }

  Future<List<Zone>> getCachedZones() async {
    final rows = await _db.select(_db.zoneCacheEntries).get();
    return rows.map((r) {
      final deviceIds = (jsonDecode(r.deviceIdsJson) as List).cast<String>();
      return Zone(
        id: r.id,
        name: r.name,
        deviceIds: deviceIds,
        defaultVolume: r.defaultVolume,
      );
    }).toList();
  }

  // ── Devices ───────────────────────────────────────────────────────────────

  Future<void> saveDevices(List<Device> devices) async {
    await _db.transaction(() async {
      await _db.delete(_db.deviceCacheEntries).go();
      for (final d in devices) {
        await _db.into(_db.deviceCacheEntries).insertOnConflictUpdate(
              DeviceCacheEntriesCompanion(
                id: Value(d.id),
                name: Value(d.name),
                zoneId: Value(d.zoneId),
                online: Value(d.online),
                playing: Value(d.playing),
                volume: Value(d.volume),
                lastSeenMs:
                    Value(d.lastSeen.millisecondsSinceEpoch),
                firmwareVersion: Value(d.firmwareVersion),
                model: Value(d.model),
              ),
            );
      }
    });
  }

  Future<List<Device>> getCachedDevices() async {
    final rows = await _db.select(_db.deviceCacheEntries).get();
    return rows.map((r) {
      return Device(
        id: r.id,
        name: r.name,
        zoneId: r.zoneId,
        online: r.online,
        playing: r.playing,
        volume: r.volume,
        lastSeen:
            DateTime.fromMillisecondsSinceEpoch(r.lastSeenMs),
        firmwareVersion: r.firmwareVersion,
        model: r.model,
      );
    }).toList();
  }

  // ── Clips ─────────────────────────────────────────────────────────────────

  Future<void> saveClips(List<AudioClip> clips) async {
    await _db.transaction(() async {
      await _db.delete(_db.clipCacheEntries).go();
      for (final c in clips) {
        await _db.into(_db.clipCacheEntries).insertOnConflictUpdate(
              ClipCacheEntriesCompanion(
                id: Value(c.id),
                title: Value(c.title),
                category: Value(c.category),
                durationMs: Value(c.durationMs),
                source: Value(c.source.name),
                url: Value(c.url),
              ),
            );
      }
    });
  }

  Future<List<AudioClip>> getCachedClips() async {
    final rows = await _db.select(_db.clipCacheEntries).get();
    return rows.map((r) {
      final source = ClipSource.values.firstWhere(
        (s) => s.name == r.source,
        orElse: () => ClipSource.uploaded,
      );
      return AudioClip(
        id: r.id,
        title: r.title,
        category: r.category,
        durationMs: r.durationMs,
        source: source,
        url: r.url,
      );
    }).toList();
  }

  // ── Broadcast outbox ──────────────────────────────────────────────────────

  Future<void> addBroadcastToOutbox(String id, String specJson) async {
    await _db.into(_db.broadcastOutbox).insertOnConflictUpdate(
          BroadcastOutboxCompanion(
            id: Value(id),
            specJson: Value(specJson),
            createdAtMs:
                Value(DateTime.now().millisecondsSinceEpoch),
            synced: const Value(false),
          ),
        );
  }

  Future<List<BroadcastOutboxData>> getPendingBroadcasts() async {
    return (_db.select(_db.broadcastOutbox)
          ..where((t) => t.synced.equals(false)))
        .get();
  }

  Future<void> markBroadcastSynced(String id) async {
    await (_db.update(_db.broadcastOutbox)
          ..where((t) => t.id.equals(id)))
        .write(const BroadcastOutboxCompanion(synced: Value(true)));
  }

  // ── Schedule outbox ───────────────────────────────────────────────────────

  Future<void> addScheduleToOutbox(String id, String specJson) async {
    await _db.into(_db.scheduleOutbox).insertOnConflictUpdate(
          ScheduleOutboxCompanion(
            id: Value(id),
            specJson: Value(specJson),
            createdAtMs:
                Value(DateTime.now().millisecondsSinceEpoch),
            synced: const Value(false),
          ),
        );
  }

  Future<List<ScheduleOutboxData>> getPendingSchedules() async {
    return (_db.select(_db.scheduleOutbox)
          ..where((t) => t.synced.equals(false)))
        .get();
  }

  Future<void> markScheduleSynced(String id) async {
    await (_db.update(_db.scheduleOutbox)
          ..where((t) => t.id.equals(id)))
        .write(const ScheduleOutboxCompanion(synced: Value(true)));
  }

  /// Count of unsynced broadcast outbox entries.
  Future<int> pendingBroadcastCount() async {
    final rows = await getPendingBroadcasts();
    return rows.length;
  }

  /// Count of unsynced schedule outbox entries.
  Future<int> pendingScheduleCount() async {
    final rows = await getPendingSchedules();
    return rows.length;
  }
}

final cacheRepositoryProvider = Provider<CacheRepository>((ref) {
  return CacheRepository(ref.watch(appDatabaseProvider));
});
