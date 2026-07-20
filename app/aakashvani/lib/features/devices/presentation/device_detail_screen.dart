import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aakashvani/app/theme/app_theme.dart';
import 'package:aakashvani/core/ws/ws_provider.dart';
import 'package:aakashvani/domain/models/device.dart';
import 'package:aakashvani/features/admin/presentation/admin_provider.dart';

class DeviceDetailScreen extends ConsumerStatefulWidget {
  final String deviceId;
  const DeviceDetailScreen({super.key, required this.deviceId});

  @override
  ConsumerState<DeviceDetailScreen> createState() =>
      _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends ConsumerState<DeviceDetailScreen> {
  bool _otaPushing = false;

  Future<void> _pushOta() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Push OTA Update'),
        content: const Text(
            'The device will reboot during the update and may be briefly unavailable. Continue?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Push Update'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _otaPushing = true);
    try {
      await ref.read(adminRepositoryProvider).pushOta(widget.deviceId);
      ref.invalidate(adminDevicesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('OTA update pushed. Device will reboot shortly.')),
        );
      }
    } finally {
      if (mounted) setState(() => _otaPushing = false);
    }
  }

  Future<void> _editVolume(int currentVolume) async {
    int vol = currentVolume;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set Volume'),
        content: StatefulBuilder(
          builder: (ctx, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${vol.round()}%',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              Slider(
                value: vol.toDouble(),
                min: 0,
                max: 100,
                divisions: 20,
                onChanged: (v) => setState(() => vol = v.round()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Set')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ref
        .read(adminRepositoryProvider)
        .updateDevice(widget.deviceId, volume: vol);
    ref.invalidate(adminDevicesProvider);
  }

  @override
  Widget build(BuildContext context) {
    final devices = ref.watch(deviceStatesProvider);
    final device =
        devices.where((d) => d.id == widget.deviceId).firstOrNull;
    final logsAsync =
        ref.watch(adminDeviceLogsProvider(widget.deviceId));
    final cs = Theme.of(context).colorScheme;

    if (device == null) {
      return Scaffold(
          appBar: AppBar(title: const Text('Device')),
          body: const Center(child: Text('Device not found')));
    }

    return Scaffold(
      appBar: AppBar(title: Text(device.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status card
          _InfoCard(
            child: Column(
              children: [
                _StatusRow(device: device),
                const Divider(height: 24),
                Row(children: [
                  Expanded(
                      child: _StatItem(
                          label: 'Model',
                          value: device.model.toUpperCase())),
                  Expanded(
                      child: _StatItem(
                          label: 'Firmware',
                          value: device.firmwareVersion)),
                  Expanded(
                      child: _StatItem(
                          label: 'Volume', value: '${device.volume}%')),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Volume control
          _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Volume',
                    style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                Row(children: [
                  Icon(Icons.volume_down_rounded,
                      color: cs.outline, size: 20),
                  Expanded(
                    child: Slider(
                      value: device.volume.toDouble(),
                      min: 0,
                      max: 100,
                      divisions: 20,
                      label: '${device.volume}%',
                      onChangeEnd: (v) => _editVolume(v.round()),
                      onChanged: (_) {},
                    ),
                  ),
                  Icon(Icons.volume_up_rounded,
                      color: cs.outline, size: 20),
                  const SizedBox(width: 8),
                  Text('${device.volume}%',
                      style:
                          TextStyle(color: cs.outline, fontSize: 13)),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // OTA
          _InfoCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Firmware Update',
                            style:
                                Theme.of(context).textTheme.labelLarge),
                        const SizedBox(height: 4),
                        Text(
                            'Current: v${device.firmwareVersion}  ·  Latest: v1.3.0',
                            style: TextStyle(
                                fontSize: 12, color: cs.outline)),
                      ]),
                ),
                OutlinedButton.icon(
                  onPressed: _otaPushing ? null : _pushOta,
                  icon: _otaPushing
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                              strokeWidth: 2))
                      : const Icon(Icons.system_update_rounded,
                          size: 16),
                  label: Text(_otaPushing ? 'Pushing…' : 'Push OTA'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Logs
          Text('Device Logs',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          logsAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e'),
            data: (logs) => Container(
              decoration: BoxDecoration(
                color: cs.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: cs.outlineVariant),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: logs
                    .map((l) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(l,
                              style: TextStyle(
                                fontSize: 11,
                                fontFamily: 'monospace',
                                color: l.contains('WARN')
                                    ? AppSemanticColors.stateStopped
                                    : l.contains('ERROR')
                                        ? cs.error
                                        : cs.onSurface,
                              )),
                        ))
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final Device device;
  const _StatusRow({required this.device});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: device.online ? AppSemanticColors.statusOnline : AppSemanticColors.statusOffline,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          device.online
              ? (device.playing ? 'Playing now' : 'Online · Standby')
              : 'Offline',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: device.online
                ? (device.playing ? cs.primary : AppSemanticColors.statusOnline)
                : AppSemanticColors.statusOffline,
          ),
        ),
        const Spacer(),
        Text('Last seen: ${_ago(device.lastSeen)}',
            style: TextStyle(fontSize: 11, color: cs.outline)),
      ],
    );
  }

  String _ago(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(children: [
      Text(value,
          style: const TextStyle(
              fontWeight: FontWeight.w700, fontSize: 15)),
      Text(label,
          style: TextStyle(fontSize: 11, color: cs.outline)),
    ]);
  }
}

class _InfoCard extends StatelessWidget {
  final Widget child;
  const _InfoCard({required this.child});

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
      child: child,
    );
  }
}
