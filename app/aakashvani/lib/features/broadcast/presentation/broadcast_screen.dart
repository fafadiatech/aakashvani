import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:aakashvani/app/theme/app_theme.dart';
import 'package:aakashvani/core/offline/offline_banner.dart';
import 'package:aakashvani/domain/models/broadcast.dart';
import 'package:aakashvani/domain/permissions.dart';
import 'package:aakashvani/features/auth/presentation/auth_provider.dart';
import 'package:aakashvani/features/broadcast/presentation/broadcast_provider.dart';

class BroadcastScreen extends ConsumerWidget {
  const BroadcastScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return const SizedBox.shrink();
    final permissions = Permissions.forUser(user);
    final broadcastsAsync = ref.watch(broadcastsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Broadcast'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _RoleBadge(permissions: permissions),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const OfflineBanner(),
          Expanded(
            child: broadcastsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (broadcasts) => broadcasts.isEmpty
                  ? _EmptyState(canBroadcast: permissions.canBroadcast)
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: broadcasts.length,
                      separatorBuilder: (ctx, i) => const SizedBox(height: 8),
                      itemBuilder: (ctx, i) =>
                          _BroadcastCard(broadcast: broadcasts[i]),
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: permissions.canBroadcast
          ? _OutboxFab(
              onPressed: () {
                ref.read(composerDraftProvider.notifier).reset();
                context.push('/home/compose');
              },
            )
          : null,
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final Permissions permissions;
  const _RoleBadge({required this.permissions});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final label = switch (permissions.role) {
      _ when permissions.canManageDevices => 'Admin',
      _ when permissions.canBroadcast => 'Broadcaster',
      _ => 'Viewer',
    };
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      visualDensity: VisualDensity.compact,
      backgroundColor: cs.secondaryContainer,
      labelStyle: TextStyle(color: cs.onSecondaryContainer),
      padding: EdgeInsets.zero,
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool canBroadcast;
  const _EmptyState({required this.canBroadcast});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.campaign_outlined, size: 72, color: cs.outline),
          const SizedBox(height: 16),
          Text('No broadcasts yet', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            canBroadcast
                ? 'Tap + to send your first announcement'
                : 'Broadcasts will appear here',
            style: TextStyle(color: cs.outline),
          ),
        ],
      ),
    );
  }
}

class _BroadcastCard extends StatelessWidget {
  final Broadcast broadcast;
  const _BroadcastCard({required this.broadcast});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/home/status/${broadcast.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _StateIcon(state: broadcast.state),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _sourceLabel(broadcast.spec.source),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _targetLabel(broadcast.spec.targets),
                      style: TextStyle(fontSize: 12, color: cs.outline),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _PriorityBadge(priority: broadcast.spec.priority),
                  const SizedBox(height: 4),
                  Text(
                    _ackSummary(broadcast.acks),
                    style: TextStyle(fontSize: 11, color: cs.outline),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _sourceLabel(BroadcastSource source) {
    if (source.type == BroadcastSourceType.tts) {
      return source.text ?? 'TTS message';
    }
    return 'Audio clip';
  }

  String _targetLabel(BroadcastTargets targets) {
    if (targets.all) return 'All zones';
    if (targets.zoneIds.isNotEmpty) return '${targets.zoneIds.length} zone(s)';
    return '${targets.deviceIds.length} device(s)';
  }

  String _ackSummary(List<BroadcastAck> acks) {
    final played = acks.where((a) => a.status == AckStatus.played).length;
    return '$played/${acks.length} played';
  }
}

class _StateIcon extends StatelessWidget {
  final BroadcastState state;
  const _StateIcon({required this.state});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (icon, color) = switch (state) {
      BroadcastState.playing => (Icons.volume_up_rounded, cs.primary),
      BroadcastState.done    => (Icons.check_circle_rounded, AppSemanticColors.stateDone),
      BroadcastState.stopped => (Icons.stop_circle_rounded, cs.error),
      BroadcastState.pending => (Icons.schedule_rounded, cs.outline),
    };
    return Icon(icon, color: color, size: 28);
  }
}

class _PriorityBadge extends StatelessWidget {
  final BroadcastPriority priority;
  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (priority) {
      BroadcastPriority.normal    => ('Normal', AppSemanticColors.priorityNormal),
      BroadcastPriority.urgent    => ('Urgent', AppSemanticColors.priorityUrgent),
      BroadcastPriority.emergency => ('Emergency', AppSemanticColors.priorityEmergency),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ── Outbox-aware FAB ──────────────────────────────────────────────────────────

class _OutboxFab extends ConsumerWidget {
  final VoidCallback onPressed;
  const _OutboxFab({required this.onPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countAsync = ref.watch(broadcastOutboxCountProvider);
    final pendingCount = countAsync.value ?? 0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        FloatingActionButton.extended(
          onPressed: onPressed,
          icon: const Icon(Icons.add),
          label: const Text('New Announcement'),
        ),
        if (pendingCount > 0)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppSemanticColors.priorityUrgent,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                '$pendingCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
