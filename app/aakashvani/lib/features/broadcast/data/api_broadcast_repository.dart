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

class ApiBroadcastRepository implements IBroadcastRepository {
  ApiBroadcastRepository(this._client);

  final ApiClient _client;

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
  Future<List<AudioClip>> getClips() async => const [];

  @override
  Future<List<Voice>> getVoices() async => const [];

  @override
  Future<Broadcast> sendBroadcast(BroadcastSpec spec, User sender) {
    throw UnimplementedError('Composer broadcasts are not wired to the API yet.');
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
    // Real-time delivery status is not available yet; emit current state once.
    final response =
        await _client.dio.get<Map<String, dynamic>>('/broadcasts/$id/');
    final data = response.data;
    if (data != null) {
      yield broadcastFromJson(data);
    }
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
