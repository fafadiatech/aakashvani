import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:aakashvani/app/theme/app_theme.dart';
import 'package:aakashvani/core/ws/ws_provider.dart';
import 'package:aakashvani/domain/models/device.dart';
import 'package:aakashvani/mock/seed_data.dart';

class DevicesScreen extends ConsumerWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devices = ref.watch(deviceStatesProvider);
    final cs = Theme.of(context).colorScheme;

    final onlineCount = devices.where((d) => d.online).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Devices'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Chip(
              label: Text('$onlineCount/${devices.length} online',
                  style: const TextStyle(fontSize: 11)),
              visualDensity: VisualDensity.compact,
              backgroundColor: cs.secondaryContainer,
              labelStyle: TextStyle(color: cs.onSecondaryContainer),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
      body: devices.isEmpty
          ? const Center(child: Text('No devices registered'))
          : CustomScrollView(
              slivers: [
                ...seedZones.map((zone) {
                  final zoneDevices =
                      devices.where((d) => d.zoneId == zone.id).toList();
                  if (zoneDevices.isEmpty) {
                    return const SliverToBoxAdapter(
                        child: SizedBox.shrink());
                  }
                  return SliverToBoxAdapter(
                    child: _ZoneSection(
                        zoneName: zone.name, devices: zoneDevices),
                  );
                }),
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/tab1/register'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Register Device'),
      ),
    );
  }
}

class _ZoneSection extends StatelessWidget {
  final String zoneName;
  final List<Device> devices;
  const _ZoneSection({required this.zoneName, required this.devices});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(zoneName,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w700,
                  )),
        ),
        ...devices.map((d) => _DeviceRow(device: d)),
        const Divider(height: 1),
      ],
    );
  }
}

class _DeviceRow extends StatelessWidget {
  final Device device;
  const _DeviceRow({required this.device});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      onTap: () => context.push('/tab1/device/${device.id}'),
      leading: Stack(
        children: [
          CircleAvatar(
            backgroundColor: device.online
                ? cs.primaryContainer
                : cs.surfaceContainerHighest,
            child: Icon(Icons.speaker_rounded,
                color: device.online ? cs.onPrimaryContainer : cs.outline,
                size: 20),
          ),
          if (device.playing)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                    color: cs.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: cs.surface, width: 1.5)),
              ),
            ),
        ],
      ),
      title: Text(device.name,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        '${device.model}  ·  fw ${device.firmwareVersion}',
        style: TextStyle(fontSize: 11, color: cs.outline),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: device.online ? AppSemanticColors.statusOnline : AppSemanticColors.statusOffline,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            device.online
                ? (device.playing ? 'Playing' : 'Online')
                : 'Offline',
            style: TextStyle(
              fontSize: 12,
              color: device.online
                  ? (device.playing ? cs.primary : AppSemanticColors.statusOnline)
                  : AppSemanticColors.statusOffline,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded, size: 18),
        ],
      ),
    );
  }
}
