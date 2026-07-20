import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:aakashvani/app/theme/app_theme.dart';
import 'package:aakashvani/core/offline/offline_banner.dart';
import 'package:aakashvani/domain/models/audio_clip.dart';
import 'package:aakashvani/features/library/presentation/library_provider.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      ref.read(clipSearchQueryProvider.notifier).set(_searchCtrl.text);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredAsync = ref.watch(filteredClipsProvider);
    final categoriesAsync = ref.watch(clipCategoriesProvider);
    final selectedCategory = ref.watch(clipCategoryFilterProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Library')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OfflineBanner(),
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search clips…',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchCtrl.clear();
                          ref.read(clipSearchQueryProvider.notifier).set('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Category filter chips
          categoriesAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (err, st) => const SizedBox.shrink(),
            data: (categories) => SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _CategoryChip(
                    label: 'All',
                    selected: selectedCategory == null,
                    onTap: () => ref.read(clipCategoryFilterProvider.notifier).set(null),
                  ),
                  ...categories.map((cat) => _CategoryChip(
                        label: _capitalise(cat),
                        selected: selectedCategory == cat,
                        onTap: () => ref.read(clipCategoryFilterProvider.notifier).set(
                            selectedCategory == cat ? null : cat),
                      )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Clip count label
          filteredAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (err, st) => const SizedBox.shrink(),
            data: (clips) => Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Text(
                '${clips.length} clip${clips.length == 1 ? '' : 's'}',
                style: TextStyle(fontSize: 12, color: cs.outline),
              ),
            ),
          ),
          // Clip list
          Expanded(
            child: filteredAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (clips) => clips.isEmpty
                  ? _EmptyState(hasFilter: selectedCategory != null || _searchCtrl.text.isNotEmpty)
                  : RefreshIndicator(
                      onRefresh: () async => ref.invalidate(libraryClipsProvider),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        itemCount: clips.length,
                        separatorBuilder: (ctx, idx) => const SizedBox(height: 8),
                        itemBuilder: (ctx, i) => _ClipCard(clip: clips[i]),
                      ),
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddOptions(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Clip'),
      ),
    );
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.mic_rounded),
              title: const Text('Record new clip'),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/tab2/record');
              },
            ),
            ListTile(
              leading: const Icon(Icons.upload_file_rounded),
              title: const Text('Upload audio file'),
              subtitle: const Text('Simulated in mock mode'),
              onTap: () {
                Navigator.pop(ctx);
                _simulateUpload(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _simulateUpload(BuildContext context) async {
    // In mock mode: immediately add a placeholder uploaded clip
    final repo = ref.read(libraryRepositoryProvider);
    await repo.addClip(
      title: 'Uploaded Clip ${DateTime.now().millisecondsSinceEpoch % 10000}',
      category: 'announcements',
      durationMs: 4000 + (DateTime.now().millisecondsSinceEpoch % 6000),
      source: ClipSource.uploaded,
      url: 'mock://clips/upload_${DateTime.now().millisecondsSinceEpoch}.mp3',
    );
    ref.invalidate(libraryClipsProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Clip uploaded (simulated)')),
      );
    }
  }

  String _capitalise(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ── Category filter chip ────────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _CategoryChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

// ── Clip list card ─────────────────────────────────────────────────────────

class _ClipCard extends StatelessWidget {
  final AudioClip clip;
  const _ClipCard({required this.clip});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/tab2/detail/${clip.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Waveform icon with category color
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _categoryColor(clip.category, cs).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _categoryIcon(clip.category),
                  color: _categoryColor(clip.category, cs),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(clip.title,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        _SourceBadge(source: clip.source),
                        const SizedBox(width: 8),
                        Text(_capitalise(clip.category),
                            style: TextStyle(fontSize: 11, color: cs.outline)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _duration(clip.durationMs),
                style: TextStyle(fontSize: 12, color: cs.outline, fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, color: cs.outline, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  String _duration(int ms) {
    final s = (ms / 1000).round();
    final m = s ~/ 60;
    final sec = s % 60;
    if (m > 0) return '${m}m ${sec.toString().padLeft(2, '0')}s';
    return '${s}s';
  }

  String _capitalise(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  Color _categoryColor(String cat, ColorScheme cs) => switch (cat) {
        'chimes'        => AppSemanticColors.categoryChimes,
        'announcements' => AppSemanticColors.categoryAnnouncements,
        'greetings'     => AppSemanticColors.categoryGreetings,
        'alerts'        => AppSemanticColors.categoryAlerts,
        _               => cs.primary,
      };

  IconData _categoryIcon(String cat) => switch (cat) {
        'chimes' => Icons.notifications_rounded,
        'announcements' => Icons.campaign_rounded,
        'greetings' => Icons.waving_hand_rounded,
        'alerts' => Icons.warning_rounded,
        _ => Icons.audiotrack_rounded,
      };
}

// ── Source badge ───────────────────────────────────────────────────────────

class _SourceBadge extends StatelessWidget {
  final ClipSource source;
  const _SourceBadge({required this.source});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (label, icon) = switch (source) {
      ClipSource.uploaded => ('Uploaded', Icons.upload_rounded),
      ClipSource.recorded => ('Recorded', Icons.mic_rounded),
      ClipSource.tts => ('TTS', Icons.record_voice_over_rounded),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: cs.outline),
        const SizedBox(width: 2),
        Text(label, style: TextStyle(fontSize: 11, color: cs.outline)),
      ],
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool hasFilter;
  const _EmptyState({required this.hasFilter});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.library_music_outlined, size: 64, color: cs.outline),
          const SizedBox(height: 16),
          Text(
            hasFilter ? 'No clips match your filter' : 'No audio clips yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            hasFilter ? 'Try adjusting search or category' : 'Tap + to add your first clip',
            style: TextStyle(color: cs.outline),
          ),
        ],
      ),
    );
  }
}
