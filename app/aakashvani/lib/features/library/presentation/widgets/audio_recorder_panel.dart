import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:aakashvani/app/theme/app_theme.dart';

typedef AudioRecorderSaveCallback = Future<void> Function({
  required String title,
  required String category,
  required int durationMs,
  required String? filePath,
});

enum AudioRecorderStatus { idle, recording, stopped, saving, ready }

/// Shared mic UI used by Library > Record Clip and New Announcement > Record.
class AudioRecorderPanel extends StatefulWidget {
  final String primaryActionLabel;
  final AudioRecorderSaveCallback onSave;
  final String? readyMessage;

  const AudioRecorderPanel({
    super.key,
    required this.primaryActionLabel,
    required this.onSave,
    this.readyMessage,
  });

  @override
  State<AudioRecorderPanel> createState() => _AudioRecorderPanelState();
}

class _AudioRecorderPanelState extends State<AudioRecorderPanel>
    with TickerProviderStateMixin {
  final _recorder = AudioRecorder();
  final _titleCtrl = TextEditingController();
  String _category = 'announcements';
  AudioRecorderStatus _status = AudioRecorderStatus.idle;
  String? _recordedPath;
  Duration _elapsed = Duration.zero;
  Timer? _timer;
  bool _usedRealRecorder = false;
  String? _savedTitle;

  late final AnimationController _waveCtrl;

  @override
  void initState() {
    super.initState();
    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _waveCtrl.dispose();
    _recorder.dispose();
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<String> _recordingPath() async {
    final dir = await getTemporaryDirectory();
    return '${dir.path}/aakashvani_rec_${DateTime.now().millisecondsSinceEpoch}.m4a';
  }

  Future<void> _startRecording() async {
    bool hasPermission = false;
    try {
      hasPermission = await _recorder.hasPermission();
    } catch (_) {}

    setState(() {
      _status = AudioRecorderStatus.recording;
      _elapsed = Duration.zero;
      _usedRealRecorder = hasPermission;
      _recordedPath = null;
      _savedTitle = null;
    });

    if (hasPermission) {
      try {
        final path = await _recordingPath();
        await _recorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: path,
        );
      } catch (_) {
        _usedRealRecorder = false;
      }
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    String? path;
    if (_usedRealRecorder) {
      try {
        path = await _recorder.stop();
      } catch (_) {}
    }
    setState(() {
      _status = AudioRecorderStatus.stopped;
      _recordedPath = path;
    });
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a clip title')),
      );
      return;
    }
    setState(() => _status = AudioRecorderStatus.saving);

    try {
      await widget.onSave(
        title: title,
        category: _category,
        durationMs: _elapsed.inMilliseconds,
        filePath: _recordedPath,
      );
      if (!mounted) return;
      if (widget.readyMessage != null) {
        setState(() {
          _status = AudioRecorderStatus.ready;
          _savedTitle = title;
        });
      } else {
        // Parent (e.g. full-screen record) handles navigation after save.
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _status = AudioRecorderStatus.stopped);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save recording: $e')),
      );
    }
  }

  void _discard() {
    setState(() {
      _status = AudioRecorderStatus.idle;
      _elapsed = Duration.zero;
      _recordedPath = null;
      _savedTitle = null;
      _titleCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.sizeOf(context).height -
              MediaQuery.paddingOf(context).vertical -
              kToolbarHeight -
              120,
        ),
        child: switch (_status) {
          AudioRecorderStatus.idle => _IdleState(onRecord: _startRecording),
          AudioRecorderStatus.recording => _RecordingState(
              elapsed: _elapsed,
              waveCtrl: _waveCtrl,
              onStop: _stopRecording,
            ),
          AudioRecorderStatus.ready => _ReadyState(
              title: _savedTitle ?? '',
              message: widget.readyMessage ?? 'Recording ready',
              duration: _elapsed,
              onRerecord: _discard,
            ),
          AudioRecorderStatus.stopped ||
          AudioRecorderStatus.saving =>
            _StoppedState(
              elapsed: _elapsed,
              titleCtrl: _titleCtrl,
              category: _category,
              onCategoryChanged: (c) => setState(() => _category = c),
              onDiscard: _discard,
              onSave: _save,
              saving: _status == AudioRecorderStatus.saving,
              primaryActionLabel: widget.primaryActionLabel,
            ),
        },
      ),
    );
  }
}

// ── Idle ────────────────────────────────────────────────────────────────────

class _IdleState extends StatelessWidget {
  final VoidCallback onRecord;
  const _IdleState({required this.onRecord});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.mic_none_rounded, size: 80, color: cs.outline),
        const SizedBox(height: 24),
        Text(
          'Ready to Record',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Tap the button below to start recording your announcement.',
          textAlign: TextAlign.center,
          style: TextStyle(color: cs.outline),
        ),
        const SizedBox(height: 40),
        Center(
          child: GestureDetector(
            onTap: onRecord,
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.error,
                boxShadow: [
                  BoxShadow(
                    color: cs.error.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Icon(Icons.mic_rounded, color: cs.onError, size: 40),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Tap to start',
          textAlign: TextAlign.center,
          style: TextStyle(color: cs.outline, fontSize: 12),
        ),
      ],
    );
  }
}

// ── Recording ───────────────────────────────────────────────────────────────

class _RecordingState extends StatelessWidget {
  final Duration elapsed;
  final AnimationController waveCtrl;
  final VoidCallback onStop;

  const _RecordingState({
    required this.elapsed,
    required this.waveCtrl,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _formatDuration(elapsed),
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: cs.error,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: cs.error, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              'Recording…',
              style: TextStyle(color: cs.error, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 32),
        AnimatedBuilder(
          animation: waveCtrl,
          builder: (ctx, _) {
            return SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(20, (i) {
                  final phase = (i / 20) * math.pi * 2;
                  final amp = 0.2 +
                      0.8 *
                          (math
                                  .pow(
                                    math
                                        .sin(waveCtrl.value * math.pi + phase)
                                        .abs(),
                                    0.7,
                                  )
                                  .toDouble());
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: 4,
                    height: 60 * amp,
                    decoration: BoxDecoration(
                      color: cs.error.withValues(alpha: 0.7 + 0.3 * amp),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              ),
            );
          },
        ),
        const SizedBox(height: 40),
        Center(
          child: GestureDetector(
            onTap: onStop,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(shape: BoxShape.circle, color: cs.error),
              child: Icon(Icons.stop_rounded, color: cs.onError, size: 36),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Tap to stop',
          textAlign: TextAlign.center,
          style: TextStyle(color: cs.outline, fontSize: 12),
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

// ── Stopped / save ──────────────────────────────────────────────────────────

class _StoppedState extends StatelessWidget {
  final Duration elapsed;
  final TextEditingController titleCtrl;
  final String category;
  final ValueChanged<String> onCategoryChanged;
  final VoidCallback onDiscard;
  final VoidCallback onSave;
  final bool saving;
  final String primaryActionLabel;

  const _StoppedState({
    required this.elapsed,
    required this.titleCtrl,
    required this.category,
    required this.onCategoryChanged,
    required this.onDiscard,
    required this.onSave,
    required this.saving,
    required this.primaryActionLabel,
  });

  static const _categories = [
    'announcements',
    'greetings',
    'alerts',
    'chimes',
    'other',
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final secs = elapsed.inSeconds;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppSemanticColors.stateDone.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppSemanticColors.stateDone.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: AppSemanticColors.stateDone,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recording complete',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppSemanticColors.stateDone,
                    ),
                  ),
                  Text(
                    'Duration: ${secs}s',
                    style: TextStyle(fontSize: 12, color: cs.outline),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: titleCtrl,
          decoration: const InputDecoration(
            labelText: 'Clip Title',
            hintText: 'e.g. Lunch Announcement',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: category,
          decoration: const InputDecoration(
            labelText: 'Category',
            border: OutlineInputBorder(),
          ),
          items: _categories
              .map(
                (c) => DropdownMenuItem(
                  value: c,
                  child: Text(c[0].toUpperCase() + c.substring(1)),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) onCategoryChanged(v);
          },
        ),
        const SizedBox(height: 32),
        FilledButton.icon(
          onPressed: saving ? null : onSave,
          icon: saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.check_rounded),
          label: Text(saving ? 'Saving…' : primaryActionLabel),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: saving ? null : onDiscard,
          icon: const Icon(Icons.delete_outline_rounded),
          label: const Text('Discard & Re-record'),
        ),
      ],
    );
  }
}

// ── Ready (composer) ────────────────────────────────────────────────────────

class _ReadyState extends StatelessWidget {
  final String title;
  final String message;
  final Duration duration;
  final VoidCallback onRerecord;

  const _ReadyState({
    required this.title,
    required this.message,
    required this.duration,
    required this.onRerecord,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppSemanticColors.stateDone.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppSemanticColors.stateDone.withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: AppSemanticColors.stateDone,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppSemanticColors.stateDone,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 4),
              Text(
                '${duration.inSeconds}s',
                style: TextStyle(fontSize: 12, color: cs.outline),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: onRerecord,
          icon: const Icon(Icons.mic_rounded),
          label: const Text('Re-record'),
        ),
      ],
    );
  }
}
