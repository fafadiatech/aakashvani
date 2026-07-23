enum BroadcastPriority { normal, urgent, emergency }

enum BroadcastState { pending, playing, done, stopped }

enum AckStatus { pending, played, failed, offline }

enum BroadcastSourceType { tts, clip }

class BroadcastSource {
  final BroadcastSourceType type;
  final String? text;
  final String? voiceId;
  final String? clipId;

  const BroadcastSource({required this.type, this.text, this.voiceId, this.clipId});
}

class BroadcastTargets {
  final bool all;
  final List<String> zoneIds;
  final List<String> deviceIds;

  const BroadcastTargets({
    this.all = false,
    this.zoneIds = const [],
    this.deviceIds = const [],
  });
}

class BroadcastSpec {
  final BroadcastSource source;
  final BroadcastTargets targets;
  final BroadcastPriority priority;
  final String? chimeId;

  const BroadcastSpec({
    required this.source,
    required this.targets,
    required this.priority,
    this.chimeId,
  });
}

class BroadcastAck {
  final String deviceId;
  final AckStatus status;
  final DateTime? at;
  final String? deviceName;
  final String? zoneName;

  const BroadcastAck({
    required this.deviceId,
    required this.status,
    this.at,
    this.deviceName,
    this.zoneName,
  });

  BroadcastAck copyWith({
    AckStatus? status,
    DateTime? at,
    String? deviceName,
    String? zoneName,
  }) =>
      BroadcastAck(
        deviceId: deviceId,
        status: status ?? this.status,
        at: at ?? this.at,
        deviceName: deviceName ?? this.deviceName,
        zoneName: zoneName ?? this.zoneName,
      );
}

class Broadcast {
  final String id;
  final BroadcastSpec spec;
  final String createdBy;
  final DateTime createdAt;
  final BroadcastState state;
  final List<BroadcastAck> acks;

  const Broadcast({
    required this.id,
    required this.spec,
    required this.createdBy,
    required this.createdAt,
    required this.state,
    required this.acks,
  });

  Broadcast copyWith({BroadcastState? state, List<BroadcastAck>? acks}) => Broadcast(
        id: id,
        spec: spec,
        createdBy: createdBy,
        createdAt: createdAt,
        state: state ?? this.state,
        acks: acks ?? this.acks,
      );
}
