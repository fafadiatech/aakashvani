import 'package:aakashvani/domain/models/audio_clip.dart';

abstract interface class ILibraryRepository {
  Future<List<AudioClip>> getClips();
  Future<AudioClip> addClip({
    required String title,
    required String category,
    required int durationMs,
    required ClipSource source,
    String? filePath,
  });
  Future<void> deleteClip(String id);
}
