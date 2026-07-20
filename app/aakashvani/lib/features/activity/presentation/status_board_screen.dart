import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aakashvani/domain/models/device.dart';
import 'package:aakashvani/core/ws/ws_provider.dart';
import 'package:aakashvani/mock/seed_data.dart';

class StatusBoardScreen extends ConsumerWidget {
  const StatusBoardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devices = ref.watch(deviceStatesProvider);
    final cs = Theme.of(context).colorScheme;

    final onlineCount = devices.where((d) => d.online).length;
    final playingCount = devices.where((d) => d.playing).length;
    final offlineCount = devices.length - onlineCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('System Status'),
        actions: [
          // Live indicator
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PulseDot(),
                const SizedBox(width: 6),
                Text('Live', style: TextStyle(fontSize: 12, color: cs.primary, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Health summary
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(child: _HealthCard(label: 'Online', value: '$onlineCount', color: Colors.green)),
                  const SizedBox(width: 10),
                  Expanded(child: _HealthCard(label: 'Offline', value: '$offlineCount', color: cs.error)),
                  const SizedBox(width: 10),
                  Expanded(child: _HealthCard(label: 'Playing', value: '$playingCount', color: cs.primary)),
                ],
              ),
            ),
          ),
          // Zone sections
          ...seedZones.map((zone) {
            final zoneDevices = devices.where((d) => d.zoneId == zone.id).toList();
            return SliverToBoxAdapter(
              child: _ZoneSection(zoneName: zone.name, devices: zoneDevices),
            );
          }),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

// ── Pulsing live indicator ─────────────────────────────────────────────────

class _PulseDot extends StatefulWidget {
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) => Container(
        width: 8, height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.green.withValues(alpha: _anim.value),
        ),
      ),
    );
  }
}

// ── Health card ────────────────────────────────────────────────────────────

class _HealthCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _HealthCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 12, color: cs.outline)),
        ],
      ),
    );
  }
}

// ── Zone section ───────────────────────────────────────────────────────────

class _ZoneSection extends StatelessWidget {
  final String zoneName;
  final List<Device> devices;
  const _ZoneSection({required this.zoneName, required this.devices});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final onlineInZone = devices.where((d) => d.online).length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(zoneName, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(width: 8),
              Text('$onlineInZone/${devices.length} online',
                  style: TextStyle(fontSize: 11, color: cs.outline)),
            ],
          ),
          const SizedBox(height: 8),
          ...devices.map((d) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _DeviceCard(device: d),
              )),
        ],
      ),
    );
  }
}

// ── Device card ────────────────────────────────────────────────────────────

class _DeviceCard extends StatelessWidget {
  final Device device;
  const _DeviceCard({required this.device});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final onlineColor = device.online ? Colors.green : cs.error;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: device.online ? cs.surfaceContainerLow : cs.surfaceContainerLowest,
        border: Border.all(
          color: device.online
              ? (device.playing ? cs.primary.withValues(alpha: 0.4) : cs.outlineVariant)
              : cs.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Online dot
          Container(
            width: 9, height: 9,
            decoration: BoxDecoration(color: onlineColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          // Name + status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(device.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: device.online ? null : cs.outline,
                    )),
                Text(
                  device.online
                      ? (device.playing ? 'Playing' : 'Standby')
                      : 'Offline · last seen ${_ago(device.lastSeen)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: device.playing ? cs.primary : cs.outline,
                    fontWeight: device.playing ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          // Volume
          if (device.online) ...[
            Icon(Icons.volume_up_rounded, size: 14, color: cs.outline),
            const SizedBox(width: 4),
            Text('${device.volume}%', style: TextStyle(fontSize: 11, color: cs.outline)),
          ],
          const SizedBox(width: 8),
          // Model badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(device.model, style: TextStyle(fontSize: 10, color: cs.outline)),
          ),
        ],
      ),
    );
  }

  String _ago(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }
}
