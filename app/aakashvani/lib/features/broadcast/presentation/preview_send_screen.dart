import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:aakashvani/app/theme/app_theme.dart';
import 'package:aakashvani/core/connectivity/connectivity_provider.dart';
import 'package:aakashvani/core/database/cache_repository.dart';
import 'package:aakashvani/domain/models/broadcast.dart';
import 'package:aakashvani/features/auth/presentation/auth_provider.dart';
import 'package:aakashvani/domain/models/zone.dart';
import 'package:aakashvani/features/broadcast/presentation/broadcast_provider.dart';
import 'package:aakashvani/core/offline/offline_banner.dart';

class PreviewSendScreen extends ConsumerStatefulWidget {
  const PreviewSendScreen({super.key});

  @override
  ConsumerState<PreviewSendScreen> createState() => _PreviewSendScreenState();
}

class _PreviewSendScreenState extends ConsumerState<PreviewSendScreen> {
  bool _sending = false;

  Future<void> _send() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    setState(() => _sending = true);

    final isOnline = ref.read(isOnlineProvider);
    final draft = ref.read(composerDraftProvider);

    try {
      if (!isOnline) {
        // Save to outbox for later sync
        final id = 'bc-offline-${DateTime.now().millisecondsSinceEpoch}';
        final specJson = broadcastSpecToJson(draft.toSpec());
        await ref.read(cacheRepositoryProvider).addBroadcastToOutbox(id, specJson);
        // Refresh outbox count badge
        ref.invalidate(broadcastOutboxCountProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Saved to outbox — will send when online'),
              duration: Duration(seconds: 3),
            ),
          );
          context.go('/home');
        }
        return;
      }

      final repo = ref.read(broadcastRepositoryProvider);
      final broadcast = await repo.sendBroadcast(draft.toSpec(), user);
      ref.invalidate(broadcastsProvider);
      if (mounted) context.go('/home/status/${broadcast.id}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send: $e')));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(composerDraftProvider);
    final zones = ref.watch(zonesProvider).value ?? const <Zone>[];
    final targetDeviceCount = _estimateDeviceCount(draft, zones);
    final targetLabel = _targetLabel(draft, targetDeviceCount);

    return Scaffold(
      appBar: AppBar(title: const Text('Preview & Send')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const OfflineBanner(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SummaryCard(
                    icon: Icons.record_voice_over_rounded,
                    label: 'Message',
                    child: Text(
                      draft.sourceType == BroadcastSourceType.tts
                          ? '"${draft.ttsText}"'
                          : 'Audio clip selected',
                      style: draft.sourceType == BroadcastSourceType.tts
                          ? const TextStyle(fontStyle: FontStyle.italic)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SummaryCard(
                    icon: Icons.speaker_group_rounded,
                    label: 'Target',
                    child: Text(targetLabel),
                  ),
                  const SizedBox(height: 12),
                  _SummaryCard(
                    icon: Icons.flag_rounded,
                    label: 'Priority',
                    child: _PriorityChip(priority: draft.priority),
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: _sending ? null : _send,
                    icon: _sending
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.send_rounded),
                    label: Text(_sending ? 'Sending\u2026' : 'Send Now'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      backgroundColor: _priorityColor(draft.priority),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _estimateDeviceCount(ComposerDraft draft, List<Zone> zones) {
    final relevant = draft.targetAll
        ? zones
        : zones.where((z) => draft.targetZoneIds.contains(z.id));
    return relevant.fold<int>(0, (sum, z) => sum + z.deviceIds.length);
  }

  String _targetLabel(ComposerDraft draft, int deviceCount) {
    if (draft.targetAll) {
      return deviceCount > 0
          ? 'All zones ($deviceCount devices)'
          : 'All zones';
    }
    final zoneLabel = '${draft.targetZoneIds.length} zone(s)';
    return deviceCount > 0 ? '$zoneLabel · ~$deviceCount devices' : zoneLabel;
  }

  Color _priorityColor(BroadcastPriority p) => switch (p) {
        BroadcastPriority.normal    => AppSemanticColors.priorityNormal,
        BroadcastPriority.urgent    => AppSemanticColors.priorityUrgent,
        BroadcastPriority.emergency => AppSemanticColors.priorityEmergency,
      };
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget child;
  const _SummaryCard({required this.icon, required this.label, required this.child});

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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: cs.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 11,
                        color: cs.outline,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  final BroadcastPriority priority;
  const _PriorityChip({required this.priority});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (priority) {
      BroadcastPriority.normal    => ('Normal',    AppSemanticColors.priorityNormal),
      BroadcastPriority.urgent    => ('Urgent',    AppSemanticColors.priorityUrgent),
      BroadcastPriority.emergency => ('EMERGENCY', AppSemanticColors.priorityEmergency),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontWeight: FontWeight.w700, fontSize: 13)),
    );
  }
}
