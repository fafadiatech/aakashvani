import 'dart:async';

import 'package:dio/dio.dart';
import 'package:aakashvani/core/api/api_client.dart';
import 'package:aakashvani/domain/models/audio_clip.dart';
import 'package:aakashvani/domain/models/broadcast.dart';
import 'package:aakashvani/domain/models/user.dart';
import 'package:aakashvani/domain/models/voice.dart';
import 'package:aakashvani/domain/models/zone.dart';
import 'package:aakashvani/features/broadcast/data/broadcast_mappers.dart';
import 'package:aakashvani/features/broadcast/domain/i_broadcast_repository.dart';
import 'package:aakashvani/features/library/data/library_mappers.dart';

class ApiBroadcastRepository implements IBroadcastRepository {
  ApiBroadcastRepository(this._client);

  final ApiClient _client;

  static const _pollInterval = Duration(seconds: 2);
  static const _maxPollDuration = Duration(minutes: 5);

  @override
  Future<List<Zone>> getZones() async {
    final zonesResponse = await _client.dio.get<dynamic>('/zones/');
    final devicesByZone = await _fetchDevicesByZone();

    return extractList(zonesResponse.data).map((item) {
      final json = item as Map<String, dynamic>;
      final zoneId = json['id'] as String;
      return zoneFromJson(json, deviceIds: devicesByZone[zoneId] ?? const []);
    }).toList();
  }

  Future<Map<String, List<String>>> _fetchDevicesByZone() async {
    try {
      final devicesResponse = await _client.dio.get<dynamic>('/devices/');
      final devicesByZone = <String, List<String>>{};
      for (final item in extractList(devicesResponse.data)) {
        final device = item as Map<String, dynamic>;
        final zoneId = device['zone'] as String?;
        if (zoneId == null) continue;
        devicesByZone.putIfAbsent(zoneId, () => []).add(device['id'] as String);
      }
      return devicesByZone;
    } on DioException catch (e) {
      // Device list is admin-only; broadcasters still get zones without counts.
      if (e.response?.statusCode == 403) return {};
      rethrow;
    }
  }

  @override
  Future<List<AudioClip>> getClips() async {
    final response = await _client.dio.get<dynamic>('/library/clips/');
    return extractList(response.data)
        .map((item) => audioClipFromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Voice>> getVoices() async {
    final response = await _client.dio.get<dynamic>('/library/voices/');
    return extractList(response.data)
        .map((item) => voiceFromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Broadcast> sendBroadcast(BroadcastSpec spec, User sender) async {
    try {
      final data = <String, dynamic>{
        'source_type': spec.source.type.name,
        'priority': spec.priority.name,
        'target_all': spec.targets.all,
        'zone_targets': spec.targets.zoneIds,
        'device_targets': spec.targets.deviceIds,
        if (spec.chimeId != null && spec.chimeId!.isNotEmpty)
          'chime_id': spec.chimeId,
      };

      if (spec.source.type == BroadcastSourceType.tts) {
        data['tts_text'] = spec.source.text ?? '';
        data['tts_voice_id'] = spec.source.voiceId ?? '';
        data['clip'] = null;
      } else {
        data['tts_text'] = '';
        data['tts_voice_id'] = '';
        data['clip'] = spec.source.clipId;
      }

      final response = await _client.dio.post<Map<String, dynamic>>(
        '/broadcasts/',
        data: data,
      );
      final body = response.data;
      if (body == null) {
        throw Exception('Empty response from server.');
      }
      return broadcastFromJson(
        body,
        zoneIds: spec.targets.zoneIds,
        deviceIds: spec.targets.deviceIds,
      );
    } on DioException catch (e) {
      throw Exception(_dioMessage(e));
    }
  }

  @override
  Future<Broadcast> ringBell(String zoneId, User sender) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        '/broadcasts/ring-bell/',
        data: {
          'zone_targets': [zoneId],
          'target_all': false,
          'chime_id': 'bell',
          'priority': 'normal',
        },
      );
      final data = response.data;
      if (data == null) {
        throw Exception('Empty response from server.');
      }
      return broadcastFromJson(data, zoneIds: [zoneId]);
    } on DioException catch (e) {
      throw Exception(_dioMessage(e));
    }
  }

  @override
  Future<void> stopBroadcast(String id) async {
    await _client.dio.post<void>('/broadcasts/$id/stop/');
  }

  @override
  Future<List<Broadcast>> getBroadcasts() async {
    final response = await _client.dio.get<dynamic>('/broadcasts/');
    return extractList(response.data).map((item) {
      return broadcastFromJson(item as Map<String, dynamic>);
    }).toList();
  }

  @override
  Stream<Broadcast> streamBroadcast(String id) async* {
    final deadline = DateTime.now().add(_maxPollDuration);
    Broadcast? previous;

    while (DateTime.now().isBefore(deadline)) {
      try {
        final response =
            await _client.dio.get<Map<String, dynamic>>('/broadcasts/$id/');
        final data = response.data;
        if (data != null) {
          final broadcast = broadcastFromJson(data);
          final changed = previous == null ||
              previous.state != broadcast.state ||
              !_acksEqual(previous.acks, broadcast.acks);
          if (changed) {
            yield broadcast;
            previous = broadcast;
          }
          if (broadcast.state == BroadcastState.done ||
              broadcast.state == BroadcastState.stopped) {
            return;
          }
        }
      } on DioException catch (e) {
        if (previous == null) throw Exception(_dioMessage(e));
        // Keep polling through transient errors after first successful fetch.
      }
      await Future<void>.delayed(_pollInterval);
    }

    if (previous != null) {
      yield previous;
    }
  }

  bool _acksEqual(List<BroadcastAck> a, List<BroadcastAck> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].deviceId != b[i].deviceId ||
          a[i].status != b[i].status ||
          a[i].at != b[i].at) {
        return false;
      }
    }
    return true;
  }

  String _dioMessage(DioException e) {
    final detail = e.response?.data;
    if (detail is Map && detail['detail'] != null) {
      return detail['detail'].toString();
    }
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return 'Could not reach the server. Check your network and API URL.';
    }
    return e.message ?? 'Request failed.';
  }
}
