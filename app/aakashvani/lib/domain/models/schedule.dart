import 'package:aakashvani/domain/models/broadcast.dart';

enum RecurrenceType { none, daily, weekdays, weekly, monthly }

extension RecurrenceTypeLabel on RecurrenceType {
  String get label => switch (this) {
        RecurrenceType.none => 'One-time',
        RecurrenceType.daily => 'Every day',
        RecurrenceType.weekdays => 'Weekdays (Mon–Fri)',
        RecurrenceType.weekly => 'Every week',
        RecurrenceType.monthly => 'Every month',
      };
}

class ScheduleWhen {
  final DateTime scheduledAt; // date + time for first/only occurrence
  final RecurrenceType recurrence;

  const ScheduleWhen({
    required this.scheduledAt,
    this.recurrence = RecurrenceType.none,
  });

  ScheduleWhen copyWith({DateTime? scheduledAt, RecurrenceType? recurrence}) =>
      ScheduleWhen(
        scheduledAt: scheduledAt ?? this.scheduledAt,
        recurrence: recurrence ?? this.recurrence,
      );

  /// Returns a human-readable description like "Daily at 08:30"
  String get description {
    final hh = scheduledAt.hour.toString().padLeft(2, '0');
    final mm = scheduledAt.minute.toString().padLeft(2, '0');
    final time = '$hh:$mm';
    if (recurrence == RecurrenceType.none) {
      final d = scheduledAt;
      return '${d.day}/${d.month}/${d.year} at $time';
    }
    return '${recurrence.label} at $time';
  }
}

class Schedule {
  final String id;
  final BroadcastSpec spec;
  final ScheduleWhen when;
  final bool enabled;

  const Schedule({
    required this.id,
    required this.spec,
    required this.when,
    required this.enabled,
  });

  Schedule copyWith({BroadcastSpec? spec, ScheduleWhen? when, bool? enabled}) =>
      Schedule(
        id: id,
        spec: spec ?? this.spec,
        when: when ?? this.when,
        enabled: enabled ?? this.enabled,
      );

  String get title {
    final src = spec.source;
    if (src.type == BroadcastSourceType.tts &&
        src.text != null &&
        src.text!.isNotEmpty) {
      return src.text!;
    }
    return 'Audio clip';
  }

  /// The next datetime this schedule will fire (simplified: returns scheduledAt for one-off,
  /// or next occurrence based on recurrence type).
  DateTime get nextFireAt {
    final now = DateTime.now();
    final base = when.scheduledAt;
    if (when.recurrence == RecurrenceType.none) return base;

    // Find next occurrence after now
    DateTime candidate =
        DateTime(now.year, now.month, now.day, base.hour, base.minute);
    while (!candidate.isAfter(now)) {
      candidate = switch (when.recurrence) {
        RecurrenceType.daily ||
        RecurrenceType.weekdays =>
          candidate.add(const Duration(days: 1)),
        RecurrenceType.weekly => candidate.add(const Duration(days: 7)),
        RecurrenceType.monthly => DateTime(candidate.year,
            candidate.month + 1, candidate.day, base.hour, base.minute),
        RecurrenceType.none => candidate,
      };
      // For weekdays, skip weekends
      if (when.recurrence == RecurrenceType.weekdays) {
        while (candidate.weekday == DateTime.saturday ||
            candidate.weekday == DateTime.sunday) {
          candidate = candidate.add(const Duration(days: 1));
        }
      }
    }
    return candidate;
  }
}
