class Zone {
  final String id;
  final String name;
  final List<String> deviceIds;
  final int defaultVolume;

  const Zone({
    required this.id,
    required this.name,
    required this.deviceIds,
    required this.defaultVolume,
  });
}
