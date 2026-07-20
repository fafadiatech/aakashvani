import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:aakashvani/app/theme/app_theme.dart';
import 'package:aakashvani/domain/models/broadcast.dart';
import 'package:aakashvani/domain/models/schedule.dart';
import 'package:aakashvani/domain/permissions.dart';
import 'package:aakashvani/features/auth/presentation/auth_provider.dart';
import 'package:aakashvani/features/broadcast/presentation/broadcast_provider.dart';
import 'package:aakashvani/features/schedule/presentation/schedule_provider.dart';

class ScheduleEditorScreen extends ConsumerStatefulWidget {
  final String? scheduleId; // null = new schedule
  const ScheduleEditorScreen({super.key, this.scheduleId});

  @override
  ConsumerState<ScheduleEditorScreen> createState() =>
      _ScheduleEditorScreenState();
}

class _ScheduleEditorScreenState extends ConsumerState<ScheduleEditorScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _sourceTabs;
  late final TextEditingController _ttsCtrl;
  bool _saving = false;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(scheduleDraftProvider);
    _sourceTabs = TabController(length: 2, vsync: this);
    _sourceTabs.index =
        draft.sourceType == BroadcastSourceType.tts ? 0 : 1;
    _ttsCtrl = TextEditingController(text: draft.ttsText);
    _ttsCtrl.addListener(
        () => ref.read(scheduleDraftProvider.notifier).updateTtsText(_ttsCtrl.text));
    _sourceTabs.addListener(() {
      if (!_sourceTabs.indexIsChanging) {
        ref.read(scheduleDraftProvider.notifier).updateSourceType(
            _sourceTabs.index == 0
                ? BroadcastSourceType.tts
                : BroadcastSourceType.clip);
      }
    });
  }

  @override
  void dispose() {
    _sourceTabs.dispose();
    _ttsCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final draft = ref.read(scheduleDraftProvider);
    final user = ref.read(currentUserProvider);
    if (user == null || !draft.isValid) return;
    setState(() => _saving = true);
    try {
      final repo = ref.read(scheduleRepositoryProvider);
      if (draft.editingId != null) {
        await repo.updateSchedule(draft.editingId!,
            spec: draft.toSpec(), when: draft.toWhen());
      } else {
        await repo.createSchedule(draft.toSpec(), draft.toWhen(), user);
      }
      ref.invalidate(schedulesProvider);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Schedule'),
        content:
            const Text('This schedule will be permanently removed.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _deleting = true);
    try {
      final editingId = ref.read(scheduleDraftProvider).editingId;
      if (editingId != null) {
        await ref
            .read(scheduleRepositoryProvider)
            .deleteSchedule(editingId);
        ref.invalidate(schedulesProvider);
        if (mounted) context.pop();
      }
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(scheduleDraftProvider);
    final user = ref.watch(currentUserProvider);
    final permissions = user != null ? Permissions.forUser(user) : null;
    final isEditing = widget.scheduleId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Schedule' : 'New Schedule'),
        actions: [
          if (isEditing)
            IconButton(
              icon: _deleting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.delete_outline_rounded),
              tooltip: 'Delete',
              onPressed: _deleting ? null : _delete,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Section 1: Source ──────────────────────────────────────────
          _SectionCard(
            title: 'Message',
            icon: Icons.record_voice_over_rounded,
            child: Column(
              children: [
                TabBar(
                  controller: _sourceTabs,
                  tabs: const [
                    Tab(text: 'Text-to-Speech'),
                    Tab(text: 'Library Clip'),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 180,
                  child: TabBarView(
                    controller: _sourceTabs,
                    children: [
                      _TtsSection(ctrl: _ttsCtrl, draft: draft),
                      _LibrarySection(draft: draft),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Section 2: Target & Priority ───────────────────────────────
          _SectionCard(
            title: 'Target & Priority',
            icon: Icons.speaker_group_rounded,
            child: _TargetPrioritySection(
                draft: draft, permissions: permissions),
          ),
          const SizedBox(height: 16),

          // ── Section 3: When ────────────────────────────────────────────
          _SectionCard(
            title: 'When',
            icon: Icons.schedule_rounded,
            child: _WhenSection(draft: draft),
          ),
          const SizedBox(height: 24),

          // ── Save button ────────────────────────────────────────────────
          FilledButton.icon(
            onPressed: (draft.isValid && !_saving) ? _save : null,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.save_rounded),
            label: Text(_saving
                ? 'Saving…'
                : isEditing
                    ? 'Save Changes'
                    : 'Create Schedule'),
            style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50)),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── Source sub-widgets ─────────────────────────────────────────────────────

class _TtsSection extends ConsumerWidget {
  final TextEditingController ctrl;
  final ScheduleDraft draft;
  const _TtsSection({required this.ctrl, required this.draft});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voices = ref.watch(voicesProvider);
    return Column(
      children: [
        Expanded(
          child: TextField(
            controller: ctrl,
            maxLines: null,
            expands: true,
            maxLength: 500,
            decoration: const InputDecoration(
              hintText: 'Type your announcement…',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
              counterText: '',
            ),
          ),
        ),
        const SizedBox(height: 8),
        voices.when(
          loading: () => const LinearProgressIndicator(),
          error: (e, st) => const SizedBox.shrink(),
          data: (list) => DropdownButtonFormField<String>(
            initialValue: draft.voiceId ??
                (list.isNotEmpty ? list.first.id : null),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              labelText: 'Voice',
            ),
            items: list
                .map((v) =>
                    DropdownMenuItem(value: v.id, child: Text(v.label)))
                .toList(),
            onChanged: (id) =>
                ref.read(scheduleDraftProvider.notifier).updateVoice(id),
          ),
        ),
      ],
    );
  }
}

class _LibrarySection extends ConsumerWidget {
  final ScheduleDraft draft;
  const _LibrarySection({required this.draft});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clipsAsync = ref.watch(clipsProvider);
    final cs = Theme.of(context).colorScheme;
    return clipsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) =>
          const Center(child: Text('Failed to load clips')),
      data: (clips) => ListView.builder(
        itemCount: clips.length,
        itemBuilder: (ctx, i) {
          final clip = clips[i];
          final selected = draft.clipId == clip.id;
          return ListTile(
            dense: true,
            title: Text(clip.title,
                style: TextStyle(
                    fontWeight:
                        selected ? FontWeight.w600 : null)),
            subtitle: Text(
                '${clip.category} · ${(clip.durationMs / 1000).toStringAsFixed(1)}s'),
            leading: Icon(Icons.audiotrack_rounded,
                color: selected ? cs.primary : cs.outline,
                size: 18),
            trailing: selected
                ? Icon(Icons.check_circle_rounded,
                    color: cs.primary, size: 18)
                : null,
            onTap: () => ref
                .read(scheduleDraftProvider.notifier)
                .updateClip(selected ? null : clip.id),
          );
        },
      ),
    );
  }
}

// ── Target & Priority section ──────────────────────────────────────────────

class _TargetPrioritySection extends ConsumerWidget {
  final ScheduleDraft draft;
  final Permissions? permissions;
  const _TargetPrioritySection(
      {required this.draft, required this.permissions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zonesAsync = ref.watch(zonesProvider);
    return zonesAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (e, st) => const Text('Failed to load zones'),
      data: (zones) {
        final visible = (permissions?.canManageDevices ?? false)
            ? zones
            : zones.where((z) {
                final user = ref.read(currentUserProvider);
                return user?.zoneScope.contains(z.id) ?? false;
              }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (permissions?.canManageDevices ?? false)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('All Zones',
                    style: TextStyle(fontSize: 14)),
                value: draft.targetAll,
                onChanged: (v) => ref
                    .read(scheduleDraftProvider.notifier)
                    .updateTargetAll(v),
              ),
            if (!draft.targetAll)
              ...visible.map((z) => CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(z.name,
                        style: const TextStyle(fontSize: 14)),
                    subtitle: Text('${z.deviceIds.length} speakers',
                        style: const TextStyle(fontSize: 11)),
                    value: draft.targetZoneIds.contains(z.id),
                    onChanged: (_) => ref
                        .read(scheduleDraftProvider.notifier)
                        .toggleZone(z.id),
                  )),
            const SizedBox(height: 12),
            Text('Priority',
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Row(
              children: BroadcastPriority.values.map((p) {
                final selected = draft.priority == p;
                final (label, color) = switch (p) {
                  BroadcastPriority.normal    => ('Normal',    AppSemanticColors.priorityNormal),
                  BroadcastPriority.urgent    => ('Urgent',    AppSemanticColors.priorityUrgent),
                  BroadcastPriority.emergency => ('Emergency', AppSemanticColors.priorityEmergency),
                };
                return Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 3),
                    child: GestureDetector(
                      onTap: () => ref
                          .read(scheduleDraftProvider.notifier)
                          .updatePriority(p),
                      child: AnimatedContainer(
                        duration:
                            const Duration(milliseconds: 150),
                        padding:
                            const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: selected
                                  ? color
                                  : Theme.of(context)
                                      .colorScheme
                                      .outlineVariant,
                              width: selected ? 2 : 1),
                          color: selected
                              ? color.withValues(alpha: 0.1)
                              : null,
                        ),
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 11,
                              color: selected
                                  ? color
                                  : Theme.of(context)
                                      .colorScheme
                                      .outline,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.normal),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}

// ── When section ───────────────────────────────────────────────────────────

class _WhenSection extends ConsumerWidget {
  final ScheduleDraft draft;
  const _WhenSection({required this.draft});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(scheduleDraftProvider.notifier);

    final hh = draft.scheduledAt.hour.toString().padLeft(2, '0');
    final mm = draft.scheduledAt.minute.toString().padLeft(2, '0');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date row
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today_rounded, size: 16),
                label: Text(
                    '${draft.scheduledAt.day}/${draft.scheduledAt.month}/${draft.scheduledAt.year}'),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: draft.scheduledAt,
                    firstDate: DateTime.now()
                        .subtract(const Duration(days: 1)),
                    lastDate: DateTime.now()
                        .add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    notifier.updateScheduledAt(
                      draft.scheduledAt.copyWith(
                          year: picked.year,
                          month: picked.month,
                          day: picked.day),
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.access_time_rounded, size: 16),
                label: Text('$hh:$mm'),
                onPressed: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(
                        hour: draft.scheduledAt.hour,
                        minute: draft.scheduledAt.minute),
                  );
                  if (picked != null) {
                    notifier.updateScheduledAt(
                      draft.scheduledAt.copyWith(
                          hour: picked.hour, minute: picked.minute),
                    );
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Recurrence',
            style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        DropdownButtonFormField<RecurrenceType>(
          initialValue: draft.recurrence,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            isDense: true,
          ),
          items: RecurrenceType.values
              .map((r) =>
                  DropdownMenuItem(value: r, child: Text(r.label)))
              .toList(),
          onChanged: (r) {
            if (r != null) notifier.updateRecurrence(r);
          },
        ),
      ],
    );
  }
}

// ── Shared card wrapper ────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _SectionCard(
      {required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: cs.primary),
              const SizedBox(width: 8),
              Text(title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: cs.primary, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
