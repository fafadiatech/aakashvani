import 'package:aakashvani/domain/models/app_settings.dart';
import 'package:aakashvani/domain/models/broadcast.dart';
import 'package:aakashvani/domain/models/device.dart';
import 'package:aakashvani/domain/models/trigger.dart';
import 'package:aakashvani/domain/models/user.dart';
import 'package:aakashvani/domain/models/zone.dart';
import 'package:aakashvani/domain/role.dart';
import 'package:aakashvani/features/admin/domain/i_admin_repository.dart';
import 'package:aakashvani/mock/seed_data.dart';

final _seedTriggers = <String, Trigger>{
  'trig-1': const Trigger(
    id: 'trig-1',
    name: 'Device Offline Alert',
    description:
        'Announce when a device goes offline for more than 5 minutes.',
    enabled: true,
    condition: TriggerCondition.deviceOffline,
    spec: BroadcastSpec(
      source: BroadcastSource(
          type: BroadcastSourceType.tts,
          text: 'Warning: a speaker has gone offline.'),
      targets: BroadcastTargets(all: true),
      priority: BroadcastPriority.urgent,
    ),
  ),
  'trig-2': const Trigger(
    id: 'trig-2',
    name: 'Webhook Broadcast',
    description: 'Trigger a broadcast via external HTTP webhook.',
    enabled: false,
    condition: TriggerCondition.manualWebhook,
    spec: BroadcastSpec(
      source: BroadcastSource(
          type: BroadcastSourceType.tts,
          text: 'Attention: external event triggered.'),
      targets: BroadcastTargets(all: true),
      priority: BroadcastPriority.normal,
    ),
  ),
};

class MockAdminRepository implements IAdminRepository {
  final _users = List<User>.from(seedUsers);
  final _zones = List<Zone>.from(seedZones);
  final _devices = List<Device>.from(seedDevices);
  final _triggers = Map<String, Trigger>.from(_seedTriggers);
  AppSettings _settings = const AppSettings();
  int _nextZoneId = 4;
  int _nextDeviceId = 7;

  @override
  Future<List<User>> getUsers() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_users);
  }

  @override
  Future<User> updateUser(String id,
      {Role? role, List<String>? zoneScope}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _users.indexWhere((u) => u.id == id);
    if (idx < 0) throw StateError('User $id not found');
    final u = _users[idx];
    final updated = User(
      id: u.id,
      name: u.name,
      role: role ?? u.role,
      zoneScope: zoneScope ?? u.zoneScope,
      token: u.token,
    );
    _users[idx] = updated;
    return updated;
  }

  @override
  Future<List<Zone>> getZones() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_zones);
  }

  @override
  Future<Zone> createZone(
      {required String name, required int defaultVolume}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final z = Zone(
        id: 'zone-$_nextZoneId',
        name: name,
        deviceIds: [],
        defaultVolume: defaultVolume);
    _zones.add(z);
    _nextZoneId++;
    return z;
  }

  @override
  Future<Zone> updateZone(String id,
      {String? name, int? defaultVolume}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _zones.indexWhere((z) => z.id == id);
    if (idx < 0) throw StateError('Zone $id not found');
    final z = _zones[idx];
    final updated = Zone(
      id: z.id,
      name: name ?? z.name,
      deviceIds: z.deviceIds,
      defaultVolume: defaultVolume ?? z.defaultVolume,
    );
    _zones[idx] = updated;
    return updated;
  }

  @override
  Future<void> deleteZone(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _zones.removeWhere((z) => z.id == id);
  }

  @override
  Future<List<Device>> getDevices() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_devices);
  }

  @override
  Future<Device> registerDevice(
      {required String name,
      required String zoneId,
      required String model}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final d = Device(
      id: 'dev-$_nextDeviceId',
      name: name,
      zoneId: zoneId,
      online: false,
      playing: false,
      volume: 70,
      lastSeen: DateTime.now(),
      firmwareVersion: '1.2.0',
      model: model,
    );
    _devices.add(d);
    _nextDeviceId++;
    return d;
  }

  @override
  Future<Device> updateDevice(String id,
      {String? name, String? zoneId, int? volume}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _devices.indexWhere((d) => d.id == id);
    if (idx < 0) throw StateError('Device $id not found');
    final d = _devices[idx];
    final updated = Device(
      id: d.id,
      name: name ?? d.name,
      zoneId: zoneId ?? d.zoneId,
      online: d.online,
      playing: d.playing,
      volume: volume ?? d.volume,
      lastSeen: d.lastSeen,
      firmwareVersion: d.firmwareVersion,
      model: d.model,
    );
    _devices[idx] = updated;
    return updated;
  }

  @override
  Future<void> pushOta(String id) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final idx = _devices.indexWhere((d) => d.id == id);
    if (idx >= 0) {
      final d = _devices[idx];
      _devices[idx] = Device(
        id: d.id,
        name: d.name,
        zoneId: d.zoneId,
        online: d.online,
        playing: d.playing,
        volume: d.volume,
        lastSeen: DateTime.now(),
        firmwareVersion: '1.3.0',
        model: d.model,
      );
    }
  }

  @override
  Future<List<String>> getDeviceLogs(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    return [
      '[${_ts(now.subtract(const Duration(minutes: 2)))}] INFO  Device booted successfully',
      '[${_ts(now.subtract(const Duration(minutes: 5)))}] INFO  Connected to MQTT broker',
      '[${_ts(now.subtract(const Duration(minutes: 10)))}] INFO  Volume set to 70%',
      '[${_ts(now.subtract(const Duration(minutes: 15)))}] WARN  Audio buffer underrun (recovered)',
      '[${_ts(now.subtract(const Duration(minutes: 30)))}] INFO  Received broadcast bc-seed-2',
      '[${_ts(now.subtract(const Duration(hours: 1)))}] INFO  Firmware version 1.2.0 active',
      '[${_ts(now.subtract(const Duration(hours: 2)))}] INFO  OTA check: up to date',
    ];
  }

  @override
  Future<AppSettings> getSettings() async => _settings;

  @override
  Future<AppSettings> updateSettings(AppSettings settings) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _settings = settings;
    return _settings;
  }

  @override
  Future<List<Trigger>> getTriggers() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _triggers.values.toList();
  }

  @override
  Future<Trigger> updateTrigger(String id, {bool? enabled}) async {
    final t = _triggers[id];
    if (t == null) throw StateError('Trigger $id not found');
    final updated = t.copyWith(enabled: enabled);
    _triggers[id] = updated;
    return updated;
  }

  String _ts(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}
