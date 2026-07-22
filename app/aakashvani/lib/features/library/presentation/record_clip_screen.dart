import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:aakashvani/domain/models/audio_clip.dart';
import 'package:aakashvani/features/library/presentation/library_provider.dart';
import 'package:aakashvani/features/library/presentation/widgets/audio_recorder_panel.dart';

class RecordClipScreen extends ConsumerWidget {
  const RecordClipScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Record Clip')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: AudioRecorderPanel(
          primaryActionLabel: 'Save to Library',
          onSave: ({
            required String title,
            required String category,
            required int durationMs,
            required String? filePath,
          }) async {
            final repo = ref.read(libraryRepositoryProvider);
            await repo.addClip(
              title: title,
              category: category,
              durationMs: durationMs,
              source: ClipSource.recorded,
              filePath: filePath,
            );
            ref.invalidate(libraryClipsProvider);
            if (context.mounted) context.pop();
          },
        ),
      ),
    );
  }
}
