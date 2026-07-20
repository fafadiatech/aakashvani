import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aakashvani/app/theme/app_theme.dart';
import 'package:aakashvani/domain/models/zone.dart';
import 'package:aakashvani/domain/permissions.dart';
import 'package:aakashvani/features/auth/presentation/auth_provider.dart';
import 'package:aakashvani/features/broadcast/presentation/broadcast_provider.dart';

/// Modal bottom sheet for Bell Mode.
/// Open via:
///   showModalBottomSheet(context: context, builder: (_) => const BellBottomSheet());
class BellBottomSheet extends ConsumerWidget {
  const BellBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return const SizedBox.shrink();

    final permissions = Permissions.forUser(user);
    final bellState = ref.watch(bellNotifierProvider);
    final zonesAsync = ref.watch(zonesProvider);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.notifications_active_rounded,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text('Ring Bell',
                    style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                Text(
                  'Select a zone',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          zonesAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Could not load zones: $e'),
            ),
            data: (allZones) {
              // Admins see all zones; broadcasters see only their zoneScope
              final zones = permissions.canManageDevices
                  ? allZones
                  : allZones
                      .where((z) => user.zoneScope.contains(z.id))
                      .toList();

              if (zones.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('No zones available'),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: zones.length,
                itemBuilder: (ctx, i) => _ZoneBellRow(
                  zone: zones[i],
                  status: bellState.zoneStatuses[zones[i].id] ??
                      BellZoneStatus.idle,
                  onRing: () =>
                      ref.read(bellNotifierProvider.notifier).ring(zones[i].id),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ZoneBellRow extends StatelessWidget {
  final Zone zone;
  final BellZoneStatus status;
  final VoidCallback onRing;

  const _ZoneBellRow({
    required this.zone,
    required this.status,
    required this.onRing,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final Widget trailing = switch (status) {
      BellZoneStatus.idle => Icon(Icons.notifications_rounded, color: cs.primary),
      BellZoneStatus.loading => const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      BellZoneStatus.success => const Icon(Icons.check_circle_rounded, color: AppSemanticColors.stateDone),
      BellZoneStatus.error => Icon(Icons.error_rounded, color: cs.error),
    };

    return ListTile(
      leading: const Icon(Icons.speaker_group_rounded),
      title: Text(zone.name),
      subtitle: Text('${zone.deviceIds.length} speaker(s)'),
      trailing: Padding(
        padding: const EdgeInsets.only(right: 4),
        child: trailing,
      ),
      onTap: status == BellZoneStatus.idle ? onRing : null,
    );
  }
}
