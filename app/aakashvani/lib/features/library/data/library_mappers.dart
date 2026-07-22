import 'package:aakashvani/domain/models/audio_clip.dart';

AudioClip audioClipFromJson(Map<String, dynamic> json) {
  final sourceName = json['source'] as String? ?? 'uploaded';
  final source = ClipSource.values.firstWhere(
    (s) => s.name == sourceName,
    orElse: () => ClipSource.uploaded,
  );
  final url = json['url'] as String? ??
      json['file'] as String? ??
      '';

  return AudioClip(
    id: json['id'] as String,
    title: json['title'] as String? ?? '',
    category: json['category'] as String? ?? '',
    durationMs: json['duration_ms'] as int? ?? 0,
    source: source,
    url: url,
  );
}
