import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:aakashvani/domain/models/zone.dart';
import 'package:aakashvani/features/admin/presentation/admin_provider.dart';

class ZonesScreen extends ConsumerWidget {
  const ZonesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zonesAsync = ref.watch(adminZonesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Zones')),
      body: zonesAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (zones) => zones.isEmpty
            ? const Center(child: Text('No zones configured'))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: zones.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, i) => _ZoneCard(zone: zones[i]),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/tab3/zones/new'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Zone'),
      ),
    );
  }
}

class _ZoneCard extends StatelessWidget {
  final Zone zone;
  const _ZoneCard({required this.zone});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        onTap: () => context.push('/tab3/zones/${zone.id}'),
        leading: CircleAvatar(
          backgroundColor: cs.tertiaryContainer,
          child: Icon(Icons.map_rounded,
              color: cs.onTertiaryContainer, size: 20),
        ),
        title: Text(zone.name,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
            '${zone.deviceIds.length} device(s) · default ${zone.defaultVolume}%',
            style: TextStyle(fontSize: 12, color: cs.outline)),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
