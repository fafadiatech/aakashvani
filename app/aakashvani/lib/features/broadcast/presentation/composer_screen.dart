import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:aakashvani/app/theme/app_theme.dart';
import 'package:aakashvani/domain/models/audio_clip.dart';
import 'package:aakashvani/domain/models/broadcast.dart';
import 'package:aakashvani/features/broadcast/presentation/broadcast_provider.dart';

class ComposerScreen extends ConsumerStatefulWidget {
  const ComposerScreen({super.key});

  @override
  ConsumerState<ComposerScreen> createState() => _ComposerScreenState();
}

class _ComposerScreenState extends ConsumerState<ComposerScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _tabs.addListener(() {
      if (!_tabs.indexIsChanging) {
        final type = _tabs.index == 0
            ? BroadcastSourceType.tts
            : BroadcastSourceType.clip;
        ref.read(composerDraftProvider.notifier).updateSourceType(type);
      }
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(composerDraftProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Announcement'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(icon: Icon(Icons.text_fields_rounded), text: 'TTS'),
            Tab(icon: Icon(Icons.library_music_rounded), text: 'Library'),
            Tab(icon: Icon(Icons.mic_rounded), text: 'Record'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _TtsTab(draft: draft),
          _LibraryTab(draft: draft),
          const _RecordTab(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: FilledButton(
            onPressed: draft.hasSource ? () => context.push('/home/target') : null,
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            child: const Text('Continue to Target'),
          ),
        ),
      ),
    );
  }
}

// ── TTS Tab ────────────────────────────────────────────────────────────────

class _TtsTab extends ConsumerStatefulWidget {
  final ComposerDraft draft;
  const _TtsTab({required this.draft});

  @override
  ConsumerState<_TtsTab> createState() => _TtsTabState();
}

class _TtsTabState extends ConsumerState<_TtsTab> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.draft.ttsText);
    _ctrl.addListener(
        () => ref.read(composerDraftProvider.notifier).updateTtsText(_ctrl.text));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final voices = ref.watch(voicesProvider);
    final draft = ref.watch(composerDraftProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Message', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _ctrl,
            maxLines: 5,
            maxLength: 500,
            decoration: const InputDecoration(
              hintText: 'Type your announcement here…',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),
          Text('Voice', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          voices.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Error: $e'),
            data: (list) => DropdownButtonFormField<String>(
              initialValue: draft.voiceId ?? list.first.id,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: list
                  .map((v) => DropdownMenuItem(value: v.id, child: Text(v.label)))
                  .toList(),
              onChanged: (id) =>
                  ref.read(composerDraftProvider.notifier).updateVoice(id),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Library Tab ────────────────────────────────────────────────────────────

class _LibraryTab extends ConsumerStatefulWidget {
  final ComposerDraft draft;
  const _LibraryTab({required this.draft});

  @override
  ConsumerState<_LibraryTab> createState() => _LibraryTabState();
}

class _LibraryTabState extends ConsumerState<_LibraryTab> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() => _query = _searchCtrl.text));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clipsAsync = ref.watch(clipsProvider);
    final draft = widget.draft;

    return clipsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (allClips) {
        final clips = _query.isEmpty
            ? allClips
            : allClips
                .where((c) => c.title.toLowerCase().contains(_query.toLowerCase()))
                .toList();
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: 'Search clips…',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () => _searchCtrl.clear(),
                        )
                      : null,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            Expanded(
              child: clips.isEmpty
                  ? Center(
                      child: Text(
                        _query.isEmpty ? 'No clips in library' : 'No clips match "$_query"',
                        style: TextStyle(color: Theme.of(context).colorScheme.outline),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: clips.length,
                      separatorBuilder: (ctx, i) => const SizedBox(height: 8),
                      itemBuilder: (ctx, i) {
                        final clip = clips[i];
                        final selected = draft.clipId == clip.id;
                        return _ClipPickerCard(
                          clip: clip,
                          selected: selected,
                          onTap: () => ref
                              .read(composerDraftProvider.notifier)
                              .updateClip(selected ? null : clip.id),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

// ── Clip picker card (matches Library screen's _ClipCard visuals) ──────────

class _ClipPickerCard extends StatelessWidget {
  final AudioClip clip;
  final bool selected;
  final VoidCallback onTap;
  const _ClipPickerCard({required this.clip, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final catColor = _categoryColor(clip.category, cs);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? cs.primary : cs.outlineVariant,
          width: selected ? 2 : 1,
        ),
        color: selected ? cs.primaryContainer.withValues(alpha: 0.15) : cs.surface,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Category-coloured icon badge — same as Library screen
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: catColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_categoryIcon(clip.category), color: catColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clip.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: selected ? cs.primary : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        _SourceBadge(source: clip.source),
                        const SizedBox(width: 8),
                        Text(
                          _capitalise(clip.category),
                          style: TextStyle(fontSize: 11, color: cs.outline),
                        ),
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
              selected
                  ? Icon(Icons.check_circle_rounded, color: cs.primary, size: 20)
                  : Icon(Icons.radio_button_unchecked_rounded, color: cs.outlineVariant, size: 20),
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
        'chimes'        => Icons.notifications_rounded,
        'announcements' => Icons.campaign_rounded,
        'greetings'     => Icons.waving_hand_rounded,
        'alerts'        => Icons.warning_rounded,
        _               => Icons.audiotrack_rounded,
      };
}

// ── Source badge (mirrors Library screen's _SourceBadge) ──────────────────

class _SourceBadge extends StatelessWidget {
  final ClipSource source;
  const _SourceBadge({required this.source});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (label, icon) = switch (source) {
      ClipSource.uploaded => ('Uploaded', Icons.upload_rounded),
      ClipSource.recorded => ('Recorded', Icons.mic_rounded),
      ClipSource.tts      => ('TTS', Icons.record_voice_over_rounded),
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

// ── Record Tab (Stub) ──────────────────────────────────────────────────────

class _RecordTab extends StatelessWidget {
  const _RecordTab();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.mic_none_rounded, size: 64, color: cs.outline),
          const SizedBox(height: 16),
          Text('In-app Recording', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Available in M4', style: TextStyle(color: cs.outline)),
        ],
      ),
    );
  }
}
