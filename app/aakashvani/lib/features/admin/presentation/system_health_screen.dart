import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aakashvani/core/ws/ws_provider.dart';
import 'package:aakashvani/features/admin/presentation/admin_provider.dart';
import 'package:aakashvani/mock/seed_data.dart';

class SystemHealthScreen extends ConsumerWidget {
  const SystemHealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devices = ref.watch(deviceStatesProvider);
    final usersAsync = ref.watch(adminUsersProvider);
    final zonesAsync = ref.watch(adminZonesProvider);
    final cs = Theme.of(context).colorScheme;

    final online = devices.where((d) => d.online).length;
    final offline = devices.length - online;
    final playing = devices.where((d) => d.playing).length;

    // Firmware distribution
    final fwMap = <String, int>{};
    for (final d in devices) {
      fwMap[d.firmwareVersion] = (fwMap[d.firmwareVersion] ?? 0) + 1;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('System Health')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Overall status
          Row(children: [
            Expanded(
                child: _StatCard(
                    label: 'Devices',
                    value: '${devices.length}',
                    icon: Icons.speaker_rounded,
                    color: cs.primary)),
            const SizedBox(width: 10),
            Expanded(
                child: _StatCard(
                    label: 'Online',
                    value: '$online',
                    icon: Icons.check_circle_rounded,
                    color: Colors.green)),
            const SizedBox(width: 10),
            Expanded(
                child: _StatCard(
                    label: 'Offline',
                    value: '$offline',
                    icon: Icons.cancel_rounded,
                    color: cs.error)),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
                child: usersAsync.when(
              data: (u) => _StatCard(
                  label: 'Users',
                  value: '${u.length}',
                  icon: Icons.people_rounded,
                  color: Colors.blue),
              loading: () => const _StatCard(
                  label: 'Users',
                  value: '—',
                  icon: Icons.people_rounded,
                  color: Colors.blue),
              error: (_, __) => const _StatCard(
                  label: 'Users',
                  value: '?',
                  icon: Icons.people_rounded,
                  color: Colors.blue),
            )),
            const SizedBox(width: 10),
            Expanded(
                child: zonesAsync.when(
              data: (z) => _StatCard(
                  label: 'Zones',
                  value: '${z.length}',
                  icon: Icons.map_rounded,
                  color: Colors.teal),
              loading: () => const _StatCard(
                  label: 'Zones',
                  value: '—',
                  icon: Icons.map_rounded,
                  color: Colors.teal),
              error: (_, __) => const _StatCard(
                  label: 'Zones',
                  value: '?',
                  icon: Icons.map_rounded,
                  color: Colors.teal),
            )),
            const SizedBox(width: 10),
            Expanded(
                child: _StatCard(
                    label: 'Playing',
                    value: '$playing',
                    icon: Icons.volume_up_rounded,
                    color: cs.primary)),
          ]),
          const SizedBox(height: 20),

          // Online/offline bar
          Text('Device Status',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 20,
              child: Row(children: [
                if (online > 0)
                  Expanded(
                      flex: online,
                      child: Container(color: Colors.green)),
                if (offline > 0)
                  Expanded(
                      flex: offline,
                      child: Container(color: cs.error)),
              ]),
            ),
          ),
          const SizedBox(height: 6),
          Row(children: [
            _Legend(color: Colors.green, label: 'Online ($online)'),
            const SizedBox(width: 16),
            _Legend(color: cs.error, label: 'Offline ($offline)'),
          ]),
          const SizedBox(height: 20),

          // Firmware distribution
          Text('Firmware Distribution',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          ...fwMap.entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  SizedBox(
                      width: 60,
                      child: Text('v${e.key}',
                          style: TextStyle(
                              color: cs.outline, fontSize: 12))),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: devices.isEmpty
                            ? 0
                            : e.value / devices.length,
                        backgroundColor: cs.surfaceContainerHighest,
                        minHeight: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${e.value}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 12)),
                ]),
              )),
          const SizedBox(height: 20),

          // Per-zone breakdown
          Text('Zone Breakdown',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          ...seedZones.map((z) {
            final zDevices =
                devices.where((d) => d.zoneId == z.id).toList();
            final zOnline =
                zDevices.where((d) => d.online).length;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading:
                  Icon(Icons.map_rounded, color: cs.primary, size: 20),
              title: Text(z.name),
              subtitle: Text('$zOnline/${zDevices.length} online',
                  style:
                      TextStyle(fontSize: 12, color: cs.outline)),
              trailing: SizedBox(
                width: 80,
                child: LinearProgressIndicator(
                  value: zDevices.isEmpty
                      ? 0
                      : zOnline / zDevices.length,
                  backgroundColor: cs.surfaceContainerHighest,
                  color: Colors.green,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color)),
        Text(label,
            style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.outline)),
      ]),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    color:
                        Theme.of(context).colorScheme.outline)),
          ]);
}
