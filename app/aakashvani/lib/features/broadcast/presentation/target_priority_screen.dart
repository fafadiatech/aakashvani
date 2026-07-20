import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:aakashvani/app/theme/app_theme.dart';
import 'package:aakashvani/domain/models/broadcast.dart';
import 'package:aakashvani/domain/models/zone.dart';
import 'package:aakashvani/domain/permissions.dart';
import 'package:aakashvani/features/auth/presentation/auth_provider.dart';
import 'package:aakashvani/features/broadcast/presentation/broadcast_provider.dart';

class TargetPriorityScreen extends ConsumerWidget {
  const TargetPriorityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(composerDraftProvider);
    final user = ref.watch(currentUserProvider);
    final zonesAsync = ref.watch(zonesProvider);
    final permissions = user != null ? Permissions.forUser(user) : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Target & Priority')),
      body: zonesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (zones) {
          final visibleZones = (permissions?.canManageDevices ?? false)
              ? zones
              : zones
                  .where((z) => user?.zoneScope.contains(z.id) ?? false)
                  .toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // All zones toggle (admin only)
              if (permissions?.canManageDevices ?? false) ...[
                _SectionHeader('Scope'),
                SwitchListTile(
                  title: const Text('All Zones'),
                  subtitle: const Text('Broadcast to every speaker on the network'),
                  value: draft.targetAll,
                  onChanged: (v) =>
                      ref.read(composerDraftProvider.notifier).updateTargetAll(v),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                const SizedBox(height: 8),
              ],
              if (!draft.targetAll) ...[
                _SectionHeader('Zones'),
                ...visibleZones.map((z) => _ZoneTile(zone: z, draft: draft)),
              ],
              const SizedBox(height: 16),
              _SectionHeader('Priority'),
              const SizedBox(height: 8),
              Row(
                children: BroadcastPriority.values.map((p) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _PriorityCard(
                        priority: p,
                        selected: draft.priority == p,
                        onTap: () => ref
                            .read(composerDraftProvider.notifier)
                            .updatePriority(p),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: FilledButton(
            onPressed: draft.hasTarget ? () => context.push('/home/preview') : null,
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            child: const Text('Continue to Preview'),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(title,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: Theme.of(context).colorScheme.primary)),
      );
}

class _ZoneTile extends ConsumerWidget {
  final Zone zone;
  final ComposerDraft draft;
  const _ZoneTile({required this.zone, required this.draft});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = draft.targetZoneIds.contains(zone.id);
    final cs = Theme.of(context).colorScheme;
    return CheckboxListTile(
      title: Text(zone.name),
      subtitle: Text('${zone.deviceIds.length} speakers'),
      value: selected,
      onChanged: (_) =>
          ref.read(composerDraftProvider.notifier).toggleZone(zone.id),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      activeColor: cs.primary,
    );
  }
}

class _PriorityCard extends StatelessWidget {
  final BroadcastPriority priority;
  final bool selected;
  final VoidCallback onTap;

  const _PriorityCard(
      {required this.priority, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (label, icon, color) = switch (priority) {
      BroadcastPriority.normal    => ('Normal',    Icons.volume_down_rounded,   AppSemanticColors.priorityNormal),
      BroadcastPriority.urgent    => ('Urgent',    Icons.priority_high_rounded, AppSemanticColors.priorityUrgent),
      BroadcastPriority.emergency => ('Emergency', Icons.warning_rounded,       AppSemanticColors.priorityEmergency),
    };
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selected ? color : cs.outlineVariant,
              width: selected ? 2 : 1),
          color: selected ? color.withValues(alpha: 0.1) : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? color : cs.outline, size: 24),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.normal,
                    color: selected ? color : cs.outline)),
          ],
        ),
      ),
    );
  }
}
