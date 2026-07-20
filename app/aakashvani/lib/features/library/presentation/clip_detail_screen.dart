import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:aakashvani/app/theme/app_theme.dart';
import 'package:aakashvani/domain/models/audio_clip.dart';
import 'package:aakashvani/domain/models/broadcast.dart';
import 'package:aakashvani/features/broadcast/presentation/broadcast_provider.dart';
import 'package:aakashvani/features/library/presentation/library_provider.dart';
import 'package:aakashvani/features/schedule/presentation/schedule_provider.dart';

class ClipDetailScreen extends ConsumerStatefulWidget {
  final String clipId;
  const ClipDetailScreen({super.key, required this.clipId});

  @override
  ConsumerState<ClipDetailScreen> createState() => _ClipDetailScreenState();
}

class _ClipDetailScreenState extends ConsumerState<ClipDetailScreen> {
  bool _playing = false;
  double _playProgress = 0;
  Timer? _playTimer;

  void _togglePlay(AudioClip clip) {
    if (_playing) {
      _playTimer?.cancel();
      setState(() {
        _playing = false;
        _playProgress = 0;
      });
      return;
    }
    setState(() {
      _playing = true;
      _playProgress = 0;
    });
    final totalMs = clip.durationMs;
    const steps = 50;
    final stepMs = totalMs ~/ steps;
    int elapsed = 0;
    _playTimer = Timer.periodic(Duration(milliseconds: stepMs), (t) {
      elapsed += stepMs;
      if (elapsed >= totalMs) {
        t.cancel();
        if (mounted) setState(() { _playing = false; _playProgress = 1; });
      } else {
        if (mounted) setState(() => _playProgress = elapsed / totalMs);
      }
    });
  }

  @override
  void dispose() {
    _playTimer?.cancel();
    super.dispose();
  }

  Future<void> _delete(AudioClip clip) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Clip'),
        content: Text('"${clip.title}" will be permanently deleted.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ref.read(libraryRepositoryProvider).deleteClip(clip.id);
    ref.invalidate(libraryClipsProvider);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final clipsAsync = ref.watch(libraryClipsProvider);

    return clipsAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(appBar: AppBar(), body: Center(child: Text('Error: $e'))),
      data: (clips) {
        final clip = clips.where((c) => c.id == widget.clipId).firstOrNull;
        if (clip == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Clip not found')),
          );
        }
        return _buildBody(clip);
      },
    );
  }

  Widget _buildBody(AudioClip clip) {
    final cs = Theme.of(context).colorScheme;
    final durationSec = clip.durationMs / 1000;
    final playedSec = durationSec * _playProgress;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clip Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Delete',
            onPressed: () => _delete(clip),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero icon
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: _categoryColor(clip.category, cs).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(_categoryIcon(clip.category),
                    size: 52, color: _categoryColor(clip.category, cs)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              clip.title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SourceBadge(source: clip.source),
                const SizedBox(width: 12),
                Text(_capitalise(clip.category), style: TextStyle(color: cs.outline, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 28),

            // Simulated waveform + playback
            _WaveformPlayer(
              playing: _playing,
              progress: _playProgress,
              durationMs: clip.durationMs,
              playedSec: playedSec,
              onToggle: () => _togglePlay(clip),
            ),
            const SizedBox(height: 28),

            // Metadata card
            _MetaCard(clip: clip),
            const SizedBox(height: 24),

            // Action buttons
            Text('Use this clip', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.campaign_rounded),
              label: const Text('Use in Broadcast'),
              onPressed: () {
                ref.read(composerDraftProvider.notifier)
                  ..reset()
                  ..updateSourceType(BroadcastSourceType.clip)
                  ..updateClip(clip.id);
                context.go('/home/compose');
              },
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              icon: const Icon(Icons.calendar_month_rounded),
              label: const Text('Use in Schedule'),
              onPressed: () {
                ref.read(scheduleDraftProvider.notifier)
                  ..reset()
                  ..updateSourceType(BroadcastSourceType.clip)
                  ..updateClip(clip.id);
                context.go('/tab1/new');
              },
            ),
          ],
        ),
      ),
    );
  }

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

  String _capitalise(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ── Simulated waveform player ──────────────────────────────────────────────

class _WaveformPlayer extends StatelessWidget {
  final bool playing;
  final double progress;
  final int durationMs;
  final double playedSec;
  final VoidCallback onToggle;

  const _WaveformPlayer({
    required this.playing,
    required this.progress,
    required this.durationMs,
    required this.playedSec,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final totalSec = durationMs / 1000;

    return Column(
      children: [
        // Waveform bars
        SizedBox(
          height: 56,
          child: CustomPaint(
            painter: _WaveformPainter(progress: progress, color: cs.primary),
            child: const SizedBox.expand(),
          ),
        ),
        const SizedBox(height: 8),
        // Progress bar
        LinearProgressIndicator(
          value: progress,
          borderRadius: BorderRadius.circular(4),
          minHeight: 4,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(_formatSec(playedSec), style: TextStyle(fontSize: 11, color: cs.outline)),
            const Spacer(),
            Text(_formatSec(totalSec), style: TextStyle(fontSize: 11, color: cs.outline)),
          ],
        ),
        const SizedBox(height: 12),
        // Play / pause button
        FilledButton.icon(
          onPressed: onToggle,
          icon: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded),
          label: Text(playing ? 'Pause' : 'Play Preview'),
          style: FilledButton.styleFrom(minimumSize: const Size(160, 44)),
        ),
      ],
    );
  }

  String _formatSec(double s) {
    final m = s.floor() ~/ 60;
    final sec = s.floor() % 60;
    return '${m.toString().padLeft(1, '0')}:${sec.toString().padLeft(2, '0')}';
  }
}

class _WaveformPainter extends CustomPainter {
  final double progress;
  final Color color;
  const _WaveformPainter({required this.progress, required this.color});

  static const _bars = [
    0.3, 0.5, 0.8, 0.6, 0.9, 0.4, 0.7, 0.5, 0.85, 0.6,
    0.4, 0.75, 0.55, 0.9, 0.45, 0.7, 0.35, 0.8, 0.6, 0.5,
    0.85, 0.4, 0.65, 0.9, 0.5, 0.75, 0.3, 0.55, 0.8, 0.45,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final barWidth = size.width / (_bars.length * 1.5);
    final gap = barWidth * 0.5;
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < _bars.length; i++) {
      final x = i * (barWidth + gap);
      final barFraction = (x + barWidth) / size.width;
      paint.color = barFraction <= progress
          ? color
          : color.withValues(alpha: 0.25);
      final barH = _bars[i] * size.height;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, (size.height - barH) / 2, barWidth, barH),
        const Radius.circular(3),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter old) => old.progress != progress;
}

// ── Metadata card ──────────────────────────────────────────────────────────

class _MetaCard extends StatelessWidget {
  final AudioClip clip;
  const _MetaCard({required this.clip});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        children: [
          _MetaRow(label: 'Duration', value: '${(clip.durationMs / 1000).toStringAsFixed(1)}s'),
          _MetaRow(label: 'Source', value: _sourceLabel(clip.source)),
          _MetaRow(label: 'Category', value: _capitalise(clip.category)),
          _MetaRow(label: 'ID', value: clip.id, isLast: true),
        ],
      ),
    );
  }

  String _sourceLabel(ClipSource s) => switch (s) {
        ClipSource.uploaded => 'Uploaded file',
        ClipSource.recorded => 'In-app recording',
        ClipSource.tts => 'Text-to-speech',
      };

  String _capitalise(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;
  const _MetaRow({required this.label, required this.value, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: 80,
              child: Text(label, style: TextStyle(fontSize: 12, color: cs.outline)),
            ),
            Expanded(
              child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 8),
          Divider(color: cs.outlineVariant, height: 1),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

// ── Reused widgets ─────────────────────────────────────────────────────────

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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: cs.onSecondaryContainer),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: cs.onSecondaryContainer,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
