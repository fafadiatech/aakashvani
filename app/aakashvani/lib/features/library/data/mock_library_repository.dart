import 'package:aakashvani/domain/models/audio_clip.dart';
import 'package:aakashvani/features/library/domain/i_library_repository.dart';
import 'package:aakashvani/mock/seed_data.dart';

class MockLibraryRepository implements ILibraryRepository {
  final _clips = List<AudioClip>.from(seedClips);
  int _nextId = seedClips.length + 1;

  @override
  Future<List<AudioClip>> getClips() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return List.unmodifiable(_clips);
  }

  @override
  Future<AudioClip> addClip({
    required String title,
    required String category,
    required int durationMs,
    required ClipSource source,
    String? filePath,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final clip = AudioClip(
      id: 'clip-$_nextId',
      title: title,
      category: category,
      durationMs: durationMs,
      source: source,
      url: filePath ??
          'mock://clips/${source.name}_${DateTime.now().millisecondsSinceEpoch}.m4a',
    );
    _clips.add(clip);
    _nextId++;
    return clip;
  }

  @override
  Future<void> deleteClip(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _clips.removeWhere((c) => c.id == id);
  }
}
