enum ClipSource { uploaded, recorded, tts }

class AudioClip {
  final String id;
  final String title;
  final String category;
  final int durationMs;
  final ClipSource source;
  final String url;

  const AudioClip({
    required this.id,
    required this.title,
    required this.category,
    required this.durationMs,
    required this.source,
    required this.url,
  });
}
