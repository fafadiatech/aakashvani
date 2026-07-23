import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:aakashvani/app/theme/app_theme.dart';
import 'package:aakashvani/domain/models/broadcast.dart';
import 'package:aakashvani/features/broadcast/presentation/broadcast_provider.dart';

class DeliveryStatusScreen extends ConsumerWidget {
  final String broadcastId;
  const DeliveryStatusScreen({super.key, required this.broadcastId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final broadcastAsync = ref.watch(broadcastDetailProvider(broadcastId));

    return broadcastAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Status')),
        body: Center(child: Text('Error: $e')),
      ),
      data: (broadcast) => _StatusBody(broadcast: broadcast, broadcastId: broadcastId),
    );
  }
}

class _StatusBody extends ConsumerWidget {
  final Broadcast broadcast;
  final String broadcastId;

  const _StatusBody({required this.broadcast, required this.broadcastId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final isPlaying = broadcast.state == BroadcastState.playing;
    final played = broadcast.acks.where((a) => a.status == AckStatus.played).length;
    final total = broadcast.acks.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Status'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        actions: [
          if (isPlaying)
            TextButton.icon(
              onPressed: () async {
                await ref.read(broadcastRepositoryProvider).stopBroadcast(broadcastId);
              },
              icon: Icon(Icons.stop_rounded, color: cs.error),
              label: Text('Stop', style: TextStyle(color: cs.error)),
            ),
        ],
      ),
      body: Column(
        children: [
          // Status banner
          _StatusBanner(state: broadcast.state, played: played, total: total),
          // Source summary
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Icon(Icons.record_voice_over_rounded, size: 16, color: cs.outline),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    broadcast.spec.source.type == BroadcastSourceType.tts
                        ? '"${broadcast.spec.source.text}"'
                        : 'Audio clip',
                    style: TextStyle(color: cs.outline, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _PriorityBadge(priority: broadcast.spec.priority),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                Text('Device Acknowledgements',
                    style: Theme.of(context).textTheme.labelLarge),
                const Spacer(),
                Text('$played / $total',
                    style: TextStyle(
                        color: cs.primary, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: broadcast.acks.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 6),
              itemBuilder: (ctx, i) => _AckRow(ack: broadcast.acks[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final BroadcastState state;
  final int played;
  final int total;

  const _StatusBanner(
      {required this.state, required this.played, required this.total});

  @override
  Widget build(BuildContext context) {
    final (label, icon, color) = switch (state) {
      BroadcastState.playing => ('Broadcasting…',     Icons.volume_up_rounded,    AppSemanticColors.statePlaying),
      BroadcastState.done    => ('Broadcast Complete', Icons.check_circle_rounded, AppSemanticColors.stateDone),
      BroadcastState.stopped => ('Broadcast Stopped',  Icons.stop_circle_rounded,  AppSemanticColors.stateStopped),
      BroadcastState.pending => ('Pending…',           Icons.schedule_rounded,     AppSemanticColors.statePending),
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: color.withValues(alpha: 0.1),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          if (state == BroadcastState.playing)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: color),
            )
          else
            Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(label,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w600, fontSize: 15)),
          const Spacer(),
          SizedBox(
            width: 80,
            child: LinearProgressIndicator(
              value: total > 0 ? played / total : 0,
              backgroundColor: color.withValues(alpha: 0.2),
              color: color,
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ),
    );
  }
}

class _AckRow extends StatelessWidget {
  final BroadcastAck ack;
  const _AckRow({required this.ack});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final deviceLabel = ack.deviceName?.isNotEmpty == true
        ? ack.deviceName!
        : _shortDeviceId(ack.deviceId);
    final zoneLabel = ack.zoneName?.isNotEmpty == true ? ack.zoneName! : 'Unknown zone';

    final (statusLabel, statusIcon, statusColor) = switch (ack.status) {
      AckStatus.pending => ('Waiting…', Icons.hourglass_top_rounded, cs.outline),
      AckStatus.played  => ('Played',   Icons.check_circle_rounded,  AppSemanticColors.stateDone),
      AckStatus.failed  => ('Failed',   Icons.error_rounded,          cs.error),
      AckStatus.offline => ('Offline',  Icons.wifi_off_rounded,       AppSemanticColors.stateStopped),
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: statusColor.withValues(alpha: 0.07),
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.speaker_rounded, size: 20, color: cs.outline),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(deviceLabel,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text(zoneLabel,
                    style: TextStyle(fontSize: 11, color: cs.outline)),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (ack.status == AckStatus.pending)
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                      strokeWidth: 1.5, color: statusColor),
                )
              else
                Icon(statusIcon, color: statusColor, size: 16),
              const SizedBox(width: 4),
              Text(statusLabel,
                  style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  String _shortDeviceId(String id) {
    if (id.length <= 8) return 'Device $id';
    return 'Device ${id.substring(0, 8)}';
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(4)),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}
