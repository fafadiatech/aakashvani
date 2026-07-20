import 'dart:convert';

sealed class WsEvent {
  const WsEvent();

  factory WsEvent.fromJson(Map<String, dynamic> json) {
    return switch (json['type'] as String) {
      'device.status' => DeviceStatusEvent(
          deviceId: json['deviceId'] as String,
          online: json['online'] as bool,
          playing: json['playing'] as bool,
          volume: (json['volume'] as num).toInt(),
          lastSeen: DateTime.parse(json['lastSeen'] as String),
        ),
      'broadcast.ack' => BroadcastAckEvent(
          broadcastId: json['broadcastId'] as String,
          deviceId: json['deviceId'] as String,
          status: json['status'] as String,
        ),
      'broadcast.state' => BroadcastStateEvent(
          broadcastId: json['broadcastId'] as String,
          state: json['state'] as String,
        ),
      'alert' => AlertEvent(
          alertType: json['alertType'] as String,
          deviceId: json['deviceId'] as String?,
        ),
      _ => UnknownEvent(raw: json['type'] as String? ?? 'unknown'),
    };
  }

  static WsEvent? tryParse(String raw) {
    try {
      return WsEvent.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}

class DeviceStatusEvent extends WsEvent {
  final String deviceId;
  final bool online;
  final bool playing;
  final int volume;
  final DateTime lastSeen;
  const DeviceStatusEvent({
    required this.deviceId,
    required this.online,
    required this.playing,
    required this.volume,
    required this.lastSeen,
  });
}

class BroadcastAckEvent extends WsEvent {
  final String broadcastId;
  final String deviceId;
  final String status;
  const BroadcastAckEvent({required this.broadcastId, required this.deviceId, required this.status});
}

class BroadcastStateEvent extends WsEvent {
  final String broadcastId;
  final String state;
  const BroadcastStateEvent({required this.broadcastId, required this.state});
}

class AlertEvent extends WsEvent {
  final String alertType;
  final String? deviceId;
  const AlertEvent({required this.alertType, this.deviceId});
}

class UnknownEvent extends WsEvent {
  final String raw;
  const UnknownEvent({required this.raw});
}
