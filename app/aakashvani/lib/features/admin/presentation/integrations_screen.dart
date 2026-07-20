import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aakashvani/domain/models/trigger.dart';
import 'package:aakashvani/features/admin/presentation/admin_provider.dart';

class IntegrationsScreen extends ConsumerWidget {
  const IntegrationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final triggersAsync = ref.watch(triggersProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Integrations & Triggers')),
      body: triggersAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (triggers) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: triggers.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (ctx, i) => _TriggerCard(trigger: triggers[i]),
        ),
      ),
    );
  }
}

class _TriggerCard extends ConsumerWidget {
  final Trigger trigger;
  const _TriggerCard({required this.trigger});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final condLabel = switch (trigger.condition) {
      TriggerCondition.deviceOffline => 'Device Offline',
      TriggerCondition.scheduleOverride => 'Schedule Override',
      TriggerCondition.manualWebhook => 'Webhook',
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cs.tertiaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.electrical_services_rounded,
                    color: cs.onTertiaryContainer, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(trigger.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(trigger.description,
                          style: TextStyle(
                              fontSize: 12, color: cs.outline)),
                      const SizedBox(height: 6),
                      Chip(
                        label: Text(condLabel,
                            style:
                                const TextStyle(fontSize: 10)),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                      ),
                    ]),
              ),
              Switch(
                value: trigger.enabled,
                onChanged: (v) async {
                  await ref
                      .read(adminRepositoryProvider)
                      .updateTrigger(trigger.id, enabled: v);
                  ref.invalidate(triggersProvider);
                },
              ),
            ]),
      ),
    );
  }
}
