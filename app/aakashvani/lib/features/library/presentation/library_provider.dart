import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aakashvani/domain/models/audio_clip.dart';
import 'package:aakashvani/features/library/data/mock_library_repository.dart';
import 'package:aakashvani/features/library/domain/i_library_repository.dart';

final libraryRepositoryProvider = Provider<ILibraryRepository>((ref) {
  return MockLibraryRepository();
});

final libraryClipsProvider = FutureProvider<List<AudioClip>>((ref) {
  return ref.read(libraryRepositoryProvider).getClips();
});

// Search query — empty string means no filter
class _StringNotifier extends Notifier<String> {
  @override
  String build() => '';
  void set(String v) => state = v;
}

final clipSearchQueryProvider =
    NotifierProvider<_StringNotifier, String>(_StringNotifier.new);

// Category filter — null means 'All'
class _NullableStringNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? v) => state = v;
}

final clipCategoryFilterProvider =
    NotifierProvider<_NullableStringNotifier, String?>(
        _NullableStringNotifier.new);

// Derived: filtered + searched clips
final filteredClipsProvider = Provider<AsyncValue<List<AudioClip>>>((ref) {
  final clipsAsync = ref.watch(libraryClipsProvider);
  final query = ref.watch(clipSearchQueryProvider).toLowerCase().trim();
  final category = ref.watch(clipCategoryFilterProvider);

  return clipsAsync.whenData((clips) {
    var filtered = clips.toList();
    if (category != null) {
      filtered = filtered.where((c) => c.category == category).toList();
    }
    if (query.isNotEmpty) {
      filtered = filtered
          .where((c) =>
              c.title.toLowerCase().contains(query) ||
              c.category.toLowerCase().contains(query))
          .toList();
    }
    return filtered;
  });
});

// All distinct categories in the library
final clipCategoriesProvider = Provider<AsyncValue<List<String>>>((ref) {
  return ref.watch(libraryClipsProvider).whenData(
        (clips) => clips.map((c) => c.category).toSet().toList()..sort(),
      );
});
