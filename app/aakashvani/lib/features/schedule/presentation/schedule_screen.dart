import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:aakashvani/app/theme/app_theme.dart';
import 'package:aakashvani/core/offline/offline_banner.dart';
import 'package:aakashvani/domain/models/broadcast.dart';
import 'package:aakashvani/domain/models/schedule.dart';
import 'package:aakashvani/domain/permissions.dart';
import 'package:aakashvani/features/auth/presentation/auth_provider.dart';
import 'package:aakashvani/features/schedule/presentation/schedule_provider.dart';

// ── Main screen ────────────────────────────────────────────────────────────

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  bool _showCalendar = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final permissions = user != null ? Permissions.forUser(user) : null;
    final schedulesAsync = ref.watch(schedulesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
        actions: [
          IconButton(
            tooltip: _showCalendar ? 'List view' : 'Calendar view',
            icon: Icon(_showCalendar
                ? Icons.list_rounded
                : Icons.calendar_month_rounded),
            onPressed: () => setState(() => _showCalendar = !_showCalendar),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const OfflineBanner(),
          Expanded(
            child: schedulesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  _ErrorState(onRetry: () => ref.invalidate(schedulesProvider)),
              data: (schedules) => _showCalendar
                  ? _CalendarView(schedules: schedules)
                  : _ListView(
                      schedules: schedules,
                      canEdit: permissions?.canBroadcast ?? false),
            ),
          ),
        ],
      ),
      floatingActionButton: (permissions?.canBroadcast ?? false)
          ? FloatingActionButton.extended(
              onPressed: () {
                ref.read(scheduleDraftProvider.notifier).reset();
                context.push('/tab1/new');
              },
              icon: const Icon(Icons.add),
              label: const Text('New Schedule'),
            )
          : null,
    );
  }
}

// ── List view ──────────────────────────────────────────────────────────────

class _ListView extends ConsumerWidget {
  final List<Schedule> schedules;
  final bool canEdit;
  const _ListView({required this.schedules, required this.canEdit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (schedules.isEmpty) {
      return _EmptyState(canEdit: canEdit);
    }

    // Sort: enabled first, then by nextFireAt
    final sorted = [...schedules]..sort((a, b) {
        if (a.enabled != b.enabled) return a.enabled ? -1 : 1;
        return a.nextFireAt.compareTo(b.nextFireAt);
      });

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(schedulesProvider),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: sorted.length,
        separatorBuilder: (ctx, i) => const SizedBox(height: 10),
        itemBuilder: (ctx, i) => _ScheduleCard(
          schedule: sorted[i],
          canEdit: canEdit,
        ),
      ),
    );
  }
}

class _ScheduleCard extends ConsumerWidget {
  final Schedule schedule;
  final bool canEdit;
  const _ScheduleCard({required this.schedule, required this.canEdit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: canEdit
            ? () {
                ref
                    .read(scheduleDraftProvider.notifier)
                    .loadFromSchedule(schedule);
                context.push('/tab1/edit/${schedule.id}');
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Priority color dot
              Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  color: _priorityColor(schedule.spec.priority),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      schedule.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded,
                            size: 13, color: cs.outline),
                        const SizedBox(width: 4),
                        Text(
                          schedule.when.description,
                          style:
                              TextStyle(fontSize: 12, color: cs.outline),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.speaker_group_rounded,
                            size: 13, color: cs.outline),
                        const SizedBox(width: 4),
                        Text(
                          _targetLabel(schedule.spec.targets),
                          style:
                              TextStyle(fontSize: 12, color: cs.outline),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (canEdit)
                    Switch(
                      value: schedule.enabled,
                      onChanged: (v) async {
                        await ref
                            .read(scheduleRepositoryProvider)
                            .updateSchedule(schedule.id, enabled: v);
                        ref.invalidate(schedulesProvider);
                      },
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Icon(
                        schedule.enabled
                            ? Icons.check_circle_rounded
                            : Icons.pause_circle_rounded,
                        color: schedule.enabled ? AppSemanticColors.stateDone : cs.outline,
                        size: 20,
                      ),
                    ),
                  _RecurrenceBadge(recurrence: schedule.when.recurrence),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _priorityColor(BroadcastPriority p) => switch (p) {
        BroadcastPriority.normal    => AppSemanticColors.priorityNormal,
        BroadcastPriority.urgent    => AppSemanticColors.priorityUrgent,
        BroadcastPriority.emergency => AppSemanticColors.priorityEmergency,
      };

  String _targetLabel(BroadcastTargets t) {
    if (t.all) return 'All zones';
    if (t.zoneIds.isNotEmpty) return '${t.zoneIds.length} zone(s)';
    return '${t.deviceIds.length} device(s)';
  }
}

class _RecurrenceBadge extends StatelessWidget {
  final RecurrenceType recurrence;
  const _RecurrenceBadge({required this.recurrence});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (recurrence == RecurrenceType.none) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: cs.tertiaryContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _shortLabel(recurrence),
        style: TextStyle(
            fontSize: 10,
            color: cs.onTertiaryContainer,
            fontWeight: FontWeight.w600),
      ),
    );
  }

  String _shortLabel(RecurrenceType r) => switch (r) {
        RecurrenceType.daily => 'Daily',
        RecurrenceType.weekdays => 'Weekdays',
        RecurrenceType.weekly => 'Weekly',
        RecurrenceType.monthly => 'Monthly',
        RecurrenceType.none => '',
      };
}

// ── Calendar view ──────────────────────────────────────────────────────────

class _CalendarView extends StatefulWidget {
  final List<Schedule> schedules;
  const _CalendarView({required this.schedules});

  @override
  State<_CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<_CalendarView> {
  DateTime _month = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now();

    return Column(
      children: [
        // Month navigation
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => setState(() {
                  _month = DateTime(_month.year, _month.month - 1);
                }),
              ),
              Expanded(
                child: Text(
                  _monthLabel(_month),
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => setState(() {
                  _month = DateTime(_month.year, _month.month + 1);
                }),
              ),
            ],
          ),
        ),
        // Day headers
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                .map((d) => Expanded(
                      child: Text(
                        d,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: (d == 'Sat' || d == 'Sun')
                              ? cs.outline
                              : cs.onSurface,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 4),
        // Calendar grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: _buildGrid(context, now, cs),
        ),
        const Divider(height: 24),
        // Schedules for selected day
        Expanded(
          child: _selectedDay == null
              ? Center(
                  child: Text('Tap a day to see schedules',
                      style: TextStyle(color: cs.outline)),
                )
              : _DayScheduleList(
                  day: _selectedDay!,
                  schedules: widget.schedules,
                ),
        ),
      ],
    );
  }

  Widget _buildGrid(BuildContext context, DateTime now, ColorScheme cs) {
    final firstDay = DateTime(_month.year, _month.month, 1);
    // Weekday 1=Mon … 7=Sun. Offset so Mon is index 0.
    final startOffset = (firstDay.weekday - 1) % 7;
    final daysInMonth = DateUtils.getDaysInMonth(_month.year, _month.month);
    final totalCells = startOffset + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: rows * 7,
      itemBuilder: (ctx, index) {
        final dayNum = index - startOffset + 1;
        if (dayNum < 1 || dayNum > daysInMonth) return const SizedBox.shrink();

        final date = DateTime(_month.year, _month.month, dayNum);
        final isToday = DateUtils.isSameDay(date, now);
        final isSelected =
            _selectedDay != null && DateUtils.isSameDay(date, _selectedDay!);
        final dotColors = _dotsForDay(date);

        return GestureDetector(
          onTap: () => setState(() {
            _selectedDay =
                DateUtils.isSameDay(date, _selectedDay) ? null : date;
          }),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? cs.primary
                  : isToday
                      ? cs.primaryContainer
                      : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '$dayNum',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        isToday ? FontWeight.w700 : FontWeight.normal,
                    color: isSelected
                        ? cs.onPrimary
                        : isToday
                            ? cs.onPrimaryContainer
                            : null,
                  ),
                ),
                if (dotColors.isNotEmpty && !isSelected)
                  Positioned(
                    bottom: 4,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: dotColors
                          .take(3)
                          .map((c) => Container(
                                width: 4,
                                height: 4,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 1),
                                decoration: BoxDecoration(
                                    color: c, shape: BoxShape.circle),
                              ))
                          .toList(),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Color> _dotsForDay(DateTime day) {
    final dots = <Color>[];
    for (final s in widget.schedules) {
      if (!s.enabled) continue;
      if (_scheduleFiresOn(s, day)) {
        dots.add(_priorityColor(s.spec.priority));
      }
    }
    return dots;
  }

  bool _scheduleFiresOn(Schedule s, DateTime day) {
    final base = s.when.scheduledAt;
    if (s.when.recurrence == RecurrenceType.none) {
      return DateUtils.isSameDay(base, day);
    }
    if (day.isBefore(DateTime(base.year, base.month, base.day))) return false;
    return switch (s.when.recurrence) {
      RecurrenceType.daily => true,
      RecurrenceType.weekdays => day.weekday <= 5,
      RecurrenceType.weekly => day.weekday == base.weekday,
      RecurrenceType.monthly => day.day == base.day,
      RecurrenceType.none => false,
    };
  }

  Color _priorityColor(BroadcastPriority p) => switch (p) {
        BroadcastPriority.normal    => AppSemanticColors.priorityNormal,
        BroadcastPriority.urgent    => AppSemanticColors.priorityUrgent,
        BroadcastPriority.emergency => AppSemanticColors.priorityEmergency,
      };

  String _monthLabel(DateTime dt) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[dt.month - 1]} ${dt.year}';
  }
}

class _DayScheduleList extends StatelessWidget {
  final DateTime day;
  final List<Schedule> schedules;
  const _DayScheduleList({required this.day, required this.schedules});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    bool firesOn(Schedule s) {
      final base = s.when.scheduledAt;
      if (!s.enabled) return false;
      if (s.when.recurrence == RecurrenceType.none) {
        return DateUtils.isSameDay(base, day);
      }
      if (day.isBefore(DateTime(base.year, base.month, base.day))) return false;
      return switch (s.when.recurrence) {
        RecurrenceType.daily => true,
        RecurrenceType.weekdays => day.weekday <= 5,
        RecurrenceType.weekly => day.weekday == base.weekday,
        RecurrenceType.monthly => day.day == base.day,
        RecurrenceType.none => false,
      };
    }

    final daySchedules = schedules.where(firesOn).toList()
      ..sort((a, b) =>
          a.when.scheduledAt.compareTo(b.when.scheduledAt));

    if (daySchedules.isEmpty) {
      return Center(
        child: Text('No schedules on this day',
            style: TextStyle(color: cs.outline)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            '${day.day}/${day.month}/${day.year}',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: daySchedules.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 8),
            itemBuilder: (ctx, i) {
              final s = daySchedules[i];
              final fireHH =
                  s.when.scheduledAt.hour.toString().padLeft(2, '0');
              final fireMM =
                  s.when.scheduledAt.minute.toString().padLeft(2, '0');
              return ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                tileColor: cs.surfaceContainerLow,
                leading: CircleAvatar(
                  backgroundColor:
                      _pColor(s.spec.priority).withValues(alpha: 0.15),
                  child: Icon(Icons.schedule_rounded,
                      color: _pColor(s.spec.priority), size: 18),
                ),
                title: Text(s.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                subtitle: Text('$fireHH:$fireMM',
                    style: const TextStyle(fontSize: 12)),
                trailing: Icon(
                  Icons.check_circle_rounded,
                  color: s.enabled ? AppSemanticColors.stateDone : cs.outline,
                  size: 18,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _pColor(BroadcastPriority p) => switch (p) {
        BroadcastPriority.normal    => AppSemanticColors.priorityNormal,
        BroadcastPriority.urgent    => AppSemanticColors.priorityUrgent,
        BroadcastPriority.emergency => AppSemanticColors.priorityEmergency,
      };
}

// ── Empty state ────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool canEdit;
  const _EmptyState({required this.canEdit});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today_rounded, size: 64, color: cs.outline),
          const SizedBox(height: 16),
          Text('No schedules yet',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            canEdit
                ? 'Tap + to create your first schedule'
                : 'Schedules will appear here',
            style: TextStyle(color: cs.outline),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            const Text('Failed to load schedules'),
            const SizedBox(height: 8),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      );
}
