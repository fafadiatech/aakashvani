import 'dart:async';
import 'package:aakashvani/core/notifications/notification_service.dart';
import 'package:aakashvani/domain/models/audio_clip.dart';
import 'package:aakashvani/domain/models/broadcast.dart';
import 'package:aakashvani/domain/models/user.dart';
import 'package:aakashvani/domain/models/voice.dart';
import 'package:aakashvani/domain/models/zone.dart';
import 'package:aakashvani/features/broadcast/domain/i_broadcast_repository.dart';
import 'package:aakashvani/mock/seed_data.dart';

const _seedVoices = [
  Voice(id: 'voice-en-f', label: 'English (Female)', languageCode: 'en-IN'),
  Voice(id: 'voice-en-m', label: 'English (Male)', languageCode: 'en-IN'),
  Voice(id: 'voice-hi-f', label: 'Hindi (Female)', languageCode: 'hi-IN'),
  Voice(id: 'voice-mr-f', label: 'Marathi (Female)', languageCode: 'mr-IN'),
];

final _seedBroadcasts = <String, Broadcast>{
  'bc-seed-1': Broadcast(
    id: 'bc-seed-1',
    spec: const BroadcastSpec(
      source: BroadcastSource(type: BroadcastSourceType.tts, text: 'Good morning! Cafeteria is open.'),
      targets: BroadcastTargets(zoneIds: ['zone-2']),
      priority: BroadcastPriority.normal,
    ),
    createdBy: 'user-broadcaster',
    createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    state: BroadcastState.done,
    acks: [
      BroadcastAck(deviceId: 'dev-3', status: AckStatus.played, at: DateTime.now().subtract(const Duration(hours: 3))),
      BroadcastAck(deviceId: 'dev-4', status: AckStatus.offline, at: DateTime.now().subtract(const Duration(hours: 3))),
    ],
  ),
  'bc-seed-2': Broadcast(
    id: 'bc-seed-2',
    spec: const BroadcastSpec(
      source: BroadcastSource(type: BroadcastSourceType.tts, text: 'Fire drill in 10 minutes. Please prepare.'),
      targets: BroadcastTargets(all: true),
      priority: BroadcastPriority.emergency,
    ),
    createdBy: 'user-admin',
    createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
    state: BroadcastState.done,
    acks: [
      BroadcastAck(deviceId: 'dev-1', status: AckStatus.played, at: DateTime.now().subtract(const Duration(hours: 1, minutes: 29))),
      BroadcastAck(deviceId: 'dev-2', status: AckStatus.played, at: DateTime.now().subtract(const Duration(hours: 1, minutes: 29))),
      BroadcastAck(deviceId: 'dev-3', status: AckStatus.played, at: DateTime.now().subtract(const Duration(hours: 1, minutes: 28))),
      BroadcastAck(deviceId: 'dev-4', status: AckStatus.offline, at: DateTime.now().subtract(const Duration(hours: 1, minutes: 28))),
      BroadcastAck(deviceId: 'dev-5', status: AckStatus.played, at: DateTime.now().subtract(const Duration(hours: 1, minutes: 27))),
      BroadcastAck(deviceId: 'dev-6', status: AckStatus.offline, at: DateTime.now().subtract(const Duration(hours: 1, minutes: 27))),
    ],
  ),
  'bc-seed-3': Broadcast(
    id: 'bc-seed-3',
    spec: const BroadcastSpec(
      source: BroadcastSource(type: BroadcastSourceType.tts, text: 'Building closes in 30 minutes.'),
      targets: BroadcastTargets(zoneIds: ['zone-1', 'zone-3']),
      priority: BroadcastPriority.urgent,
    ),
    createdBy: 'user-broadcaster',
    createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
    state: BroadcastState.done,
    acks: [
      BroadcastAck(deviceId: 'dev-1', status: AckStatus.played, at: DateTime.now().subtract(const Duration(minutes: 19))),
      BroadcastAck(deviceId: 'dev-2', status: AckStatus.played, at: DateTime.now().subtract(const Duration(minutes: 19))),
      BroadcastAck(deviceId: 'dev-5', status: AckStatus.played, at: DateTime.now().subtract(const Duration(minutes: 18))),
      BroadcastAck(deviceId: 'dev-6', status: AckStatus.failed, at: DateTime.now().subtract(const Duration(minutes: 18))),
    ],
  ),
};

class MockBroadcastRepository implements IBroadcastRepository {
  final _broadcasts = <String, Broadcast>{};
  final _streams = <String, StreamController<Broadcast>>{};

  MockBroadcastRepository() {
    _broadcasts.addAll(_seedBroadcasts);
  }

  @override
  Future<List<Zone>> getZones() async => List.unmodifiable(seedZones);

  @override
  Future<List<AudioClip>> getClips() async => List.unmodifiable(seedClips);

  @override
  Future<List<Voice>> getVoices() async => List.unmodifiable(_seedVoices);

  @override
  Future<List<Broadcast>> getBroadcasts() async =>
      _broadcasts.values.toList().reversed.toList();

  @override
  Future<Broadcast> sendBroadcast(BroadcastSpec spec, User sender) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final id = 'bc-${DateTime.now().millisecondsSinceEpoch}';
    final targetDeviceIds = _resolveDeviceIds(spec.targets);

    final acks = targetDeviceIds
        .map((did) => BroadcastAck(deviceId: did, status: AckStatus.pending))
        .toList();

    final broadcast = Broadcast(
      id: id,
      spec: spec,
      createdBy: sender.id,
      createdAt: DateTime.now(),
      state: BroadcastState.playing,
      acks: acks,
    );

    _broadcasts[id] = broadcast;
    final controller = StreamController<Broadcast>.broadcast();
    _streams[id] = controller;
    controller.add(broadcast);

    _simulateAcks(id, targetDeviceIds);
    return broadcast;
  }

  void _simulateAcks(String broadcastId, List<String> deviceIds) {
    for (var i = 0; i < deviceIds.length; i++) {
      Future.delayed(Duration(seconds: 1 + i * 2), () {
        if (!_broadcasts.containsKey(broadcastId)) return;
        final broadcast = _broadcasts[broadcastId]!;
        if (broadcast.state == BroadcastState.stopped) return;

        final device = seedDevices.firstWhere(
          (d) => d.id == deviceIds[i],
          orElse: () => seedDevices.first,
        );
        final ackStatus = device.online ? AckStatus.played : AckStatus.offline;

        final newAcks = List<BroadcastAck>.from(broadcast.acks);
        final idx = newAcks.indexWhere((a) => a.deviceId == deviceIds[i]);
        if (idx >= 0) {
          newAcks[idx] = newAcks[idx].copyWith(status: ackStatus, at: DateTime.now());
        }

        final allResolved = newAcks.every((a) => a.status != AckStatus.pending);
        final updated = broadcast.copyWith(
          acks: newAcks,
          state: allResolved ? BroadcastState.done : BroadcastState.playing,
        );

        _broadcasts[broadcastId] = updated;
        _streams[broadcastId]?.add(updated);

        if (allResolved) {
          final played = newAcks.where((a) => a.status == AckStatus.played).length;
          NotificationService.instance.showBroadcastComplete(
            broadcastId: broadcastId,
            message: broadcast.spec.source.text ?? 'Audio clip',
            playedCount: played,
            totalCount: newAcks.length,
          );
        }
      });
    }
  }

  @override
  Future<Broadcast> ringBell(String zoneId, User sender) {
    return sendBroadcast(
      BroadcastSpec(
        source: const BroadcastSource(type: BroadcastSourceType.clip, clipId: kBellClipId),
        targets: BroadcastTargets(zoneIds: [zoneId]),
        priority: BroadcastPriority.normal,
      ),
      sender,
    );
  }

  @override
  Future<void> stopBroadcast(String id) async {
    final broadcast = _broadcasts[id];
    if (broadcast == null) return;
    final updated = broadcast.copyWith(state: BroadcastState.stopped);
    _broadcasts[id] = updated;
    _streams[id]?.add(updated);
  }

  @override
  Stream<Broadcast> streamBroadcast(String id) {
    // For seeded broadcasts that already have a done state, return a one-shot stream
    final broadcast = _broadcasts[id];
    if (broadcast != null && _streams[id] == null) {
      final controller = StreamController<Broadcast>.broadcast();
      _streams[id] = controller;
      // Emit the current state immediately
      Future.microtask(() => controller.add(broadcast));
    }
    return _streams[id]?.stream ?? const Stream.empty();
  }

  List<String> _resolveDeviceIds(BroadcastTargets targets) {
    if (targets.all) return seedDevices.map((d) => d.id).toList();
    final fromZones = seedDevices
        .where((d) => targets.zoneIds.contains(d.zoneId))
        .map((d) => d.id);
    return {...fromZones, ...targets.deviceIds}.toList();
  }
}
