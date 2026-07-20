import 'package:aakashvani/domain/models/broadcast.dart';
import 'package:aakashvani/domain/models/zone.dart';

Zone zoneFromJson(Map<String, dynamic> json, {List<String> deviceIds = const []}) {
  return Zone(
    id: json['id'] as String,
    name: json['name'] as String,
    deviceIds: deviceIds,
    defaultVolume: json['default_volume'] as int? ?? 80,
  );
}

Broadcast broadcastFromJson(
  Map<String, dynamic> json, {
  List<String> zoneIds = const [],
  List<String> deviceIds = const [],
}) {
  final sourceTypeName = json['source_type'] as String? ?? 'tts';
  final sourceType = BroadcastSourceType.values.byName(sourceTypeName);
  final clipId = json['clip'];
  final priorityName = json['priority'] as String? ?? 'normal';
  final stateName = json['state'] as String? ?? 'pending';

  return Broadcast(
    id: json['id'] as String,
    spec: BroadcastSpec(
      source: BroadcastSource(
        type: sourceType,
        text: json['tts_text'] as String?,
        voiceId: (json['tts_voice_id'] as String?)?.isNotEmpty == true
            ? json['tts_voice_id'] as String
            : null,
        clipId: clipId is String ? clipId : null,
      ),
      targets: BroadcastTargets(
        all: json['target_all'] as bool? ?? false,
        zoneIds: zoneIds,
        deviceIds: deviceIds,
      ),
      priority: BroadcastPriority.values.byName(priorityName),
      chimeId: (json['chime_id'] as String?)?.isNotEmpty == true
          ? json['chime_id'] as String
          : null,
    ),
    createdBy: json['created_by'] as String? ?? '',
    createdAt: DateTime.parse(json['created_at'] as String),
    state: BroadcastState.values.byName(stateName),
    acks: _acksFromJson(json['acks']),
  );
}

List<BroadcastAck> _acksFromJson(dynamic raw) {
  if (raw is! List) return const [];
  return raw.map((item) {
    final json = item as Map<String, dynamic>;
    final statusName = json['status'] as String? ?? 'pending';
    final acknowledgedAt = json['acknowledged_at'];
    return BroadcastAck(
      deviceId: json['device'] as String,
      status: AckStatus.values.byName(statusName),
      at: acknowledgedAt != null ? DateTime.tryParse(acknowledgedAt as String) : null,
    );
  }).toList();
}
