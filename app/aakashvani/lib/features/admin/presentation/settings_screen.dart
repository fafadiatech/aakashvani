import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aakashvani/domain/models/app_settings.dart';
import 'package:aakashvani/domain/models/broadcast.dart';
import 'package:aakashvani/features/admin/presentation/admin_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  AppSettings? _settings;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(appSettingsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Global Settings'),
        actions: [
          TextButton(
            onPressed: (_settings != null && !_saving) ? _save : null,
            child: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save'),
          ),
        ],
      ),
      body: settingsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (s) {
          _settings ??= s;
          final cur = _settings!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Quiet hours
              _Section(title: 'Quiet Hours', children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Enable Quiet Hours'),
                  subtitle: const Text(
                      'Block normal-priority broadcasts during this window'),
                  value: cur.quietHoursEnabled,
                  onChanged: (v) => setState(
                      () => _settings = cur.copyWith(quietHoursEnabled: v)),
                ),
                if (cur.quietHoursEnabled) ...[
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(
                        child: _TimeButton(
                      label: 'Start',
                      hour: cur.quietStartHour,
                      minute: cur.quietStartMinute,
                      onPicked: (h, m) => setState(() => _settings =
                          cur.copyWith(
                              quietStartHour: h, quietStartMinute: m)),
                    )),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _TimeButton(
                      label: 'End',
                      hour: cur.quietEndHour,
                      minute: cur.quietEndMinute,
                      onPicked: (h, m) => setState(() => _settings =
                          cur.copyWith(
                              quietEndHour: h, quietEndMinute: m)),
                    )),
                  ]),
                ],
              ]),
              const SizedBox(height: 16),
              // Default priority
              _Section(title: 'Defaults', children: [
                Text('Default Broadcast Priority',
                    style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 8),
                SegmentedButton<BroadcastPriority>(
                  segments: const [
                    ButtonSegment(
                        value: BroadcastPriority.normal,
                        label: Text('Normal')),
                    ButtonSegment(
                        value: BroadcastPriority.urgent,
                        label: Text('Urgent')),
                    ButtonSegment(
                        value: BroadcastPriority.emergency,
                        label: Text('Emergency')),
                  ],
                  selected: {cur.defaultPriority},
                  onSelectionChanged: (v) => setState(() =>
                      _settings =
                          cur.copyWith(defaultPriority: v.first)),
                ),
              ]),
            ],
          );
        },
      ),
    );
  }

  Future<void> _save() async {
    if (_settings == null) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(adminRepositoryProvider)
          .updateSettings(_settings!);
      ref.invalidate(appSettingsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Settings saved')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _TimeButton extends StatelessWidget {
  final String label;
  final int hour, minute;
  final void Function(int h, int m) onPicked;
  const _TimeButton(
      {required this.label,
      required this.hour,
      required this.minute,
      required this.onPicked});

  @override
  Widget build(BuildContext context) {
    final hh = hour.toString().padLeft(2, '0');
    final mm = minute.toString().padLeft(2, '0');
    return OutlinedButton.icon(
      icon: const Icon(Icons.access_time_rounded, size: 16),
      label: Text('$label  $hh:$mm'),
      onPressed: () async {
        final t = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(hour: hour, minute: minute),
        );
        if (t != null) onPicked(t.hour, t.minute);
      },
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

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
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ...children,
          ]),
    );
  }
}
