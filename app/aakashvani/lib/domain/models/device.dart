class Device {
  final String id;
  final String name;
  final String zoneId;
  final bool online;
  final bool playing;
  final int volume;
  final DateTime lastSeen;
  final String firmwareVersion;
  final String model;

  const Device({
    required this.id,
    required this.name,
    required this.zoneId,
    required this.online,
    required this.playing,
    required this.volume,
    required this.lastSeen,
    required this.firmwareVersion,
    required this.model,
  });
}
