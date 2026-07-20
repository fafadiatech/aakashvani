import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:aakashvani/app/theme/app_theme.dart';
import 'package:aakashvani/domain/models/broadcast.dart';
import 'package:aakashvani/features/broadcast/presentation/broadcast_provider.dart';

class ActivityFeedScreen extends ConsumerWidget {
  const ActivityFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final broadcastsAsync = ref.watch(broadcastsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(broadcastsProvider),
          ),
        ],
      ),
      body: broadcastsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorState(onRetry: () => ref.invalidate(broadcastsProvider)),
        data: (broadcasts) => broadcasts.isEmpty
            ? _EmptyState()
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(broadcastsProvider),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: broadcasts.length,
                  separatorBuilder: (ctx, i) => const SizedBox(height: 10),
                  itemBuilder: (ctx, i) => _BroadcastRow(broadcast: broadcasts[i]),
                ),
              ),
      ),
    );
  }
}

class _BroadcastRow extends StatelessWidget {
  final Broadcast broadcast;
  const _BroadcastRow({required this.broadcast});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final played = broadcast.acks.where((a) => a.status == AckStatus.played).length;
    final total = broadcast.acks.length;
    final failed = broadcast.acks.where((a) => a.status == AckStatus.failed || a.status == AckStatus.offline).length;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/broadcast/${broadcast.id}'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // State dot
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: _StateDot(state: broadcast.state),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _sourceLabel(broadcast.spec.source),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(children: [
                      Icon(Icons.access_time_rounded, size: 12, color: cs.outline),
                      const SizedBox(width: 4),
                      Text(_timeAgo(broadcast.createdAt),
                          style: TextStyle(fontSize: 11, color: cs.outline)),
                      const SizedBox(width: 10),
                      Icon(Icons.speaker_group_rounded, size: 12, color: cs.outline),
                      const SizedBox(width: 4),
                      Text(_targetLabel(broadcast.spec.targets),
                          style: TextStyle(fontSize: 11, color: cs.outline)),
                    ]),
                    const SizedBox(height: 6),
                    // Ack progress bar
                    if (total > 0)
                      Row(children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: played / total,
                              backgroundColor: cs.surfaceContainerHighest,
                              color: failed > 0 ? AppSemanticColors.stateStopped : AppSemanticColors.stateDone,
                              minHeight: 5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('$played/$total',
                            style: TextStyle(fontSize: 11, color: cs.outline, fontWeight: FontWeight.w600)),
                      ]),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _PriorityBadge(priority: broadcast.spec.priority),
            ],
          ),
        ),
      ),
    );
  }

  String _sourceLabel(BroadcastSource src) =>
      src.type == BroadcastSourceType.tts ? (src.text ?? 'TTS') : 'Audio clip';

  String _targetLabel(BroadcastTargets t) {
    if (t.all) return 'All zones';
    if (t.zoneIds.isNotEmpty) return '${t.zoneIds.length} zone(s)';
    return '${t.deviceIds.length} device(s)';
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _StateDot extends StatelessWidget {
  final BroadcastState state;
  const _StateDot({required this.state});

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      BroadcastState.playing => AppSemanticColors.statePlaying,
      BroadcastState.done    => AppSemanticColors.stateDone,
      BroadcastState.stopped => AppSemanticColors.stateStopped,
      BroadcastState.pending => AppSemanticColors.statePending,
    };
    return Container(
      width: 10, height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final BroadcastPriority priority;
  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (priority) {
      BroadcastPriority.normal    => ('Normal',    AppSemanticColors.priorityNormal),
      BroadcastPriority.urgent    => ('Urgent',    AppSemanticColors.priorityUrgent),
      BroadcastPriority.emergency => ('Emergency', AppSemanticColors.priorityEmergency),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.history_rounded, size: 64, color: cs.outline),
        const SizedBox(height: 16),
        Text('No activity yet', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text('Broadcasts will appear here', style: TextStyle(color: cs.outline)),
      ]),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline, size: 48),
          const SizedBox(height: 16),
          const Text('Failed to load activity'),
          const SizedBox(height: 8),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ]),
      );
}
