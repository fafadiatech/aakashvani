import 'package:aakashvani/domain/models/broadcast.dart';
import 'package:aakashvani/domain/models/schedule.dart';
import 'package:aakashvani/domain/models/user.dart';
import 'package:aakashvani/features/schedule/domain/i_schedule_repository.dart';

final _seedSchedules = <String, Schedule>{
  'sch-1': Schedule(
    id: 'sch-1',
    spec: const BroadcastSpec(
      source: BroadcastSource(
          type: BroadcastSourceType.tts,
          text: 'Good morning! Cafeteria is now open.'),
      targets: BroadcastTargets(zoneIds: ['zone-2']),
      priority: BroadcastPriority.normal,
    ),
    when: ScheduleWhen(
      scheduledAt:
          DateTime.now().copyWith(hour: 8, minute: 30, second: 0),
      recurrence: RecurrenceType.weekdays,
    ),
    enabled: true,
  ),
  'sch-2': Schedule(
    id: 'sch-2',
    spec: const BroadcastSpec(
      source: BroadcastSource(
          type: BroadcastSourceType.tts,
          text: 'Building closes in 30 minutes. Please wrap up.'),
      targets: BroadcastTargets(all: true),
      priority: BroadcastPriority.urgent,
    ),
    when: ScheduleWhen(
      scheduledAt:
          DateTime.now().copyWith(hour: 17, minute: 30, second: 0),
      recurrence: RecurrenceType.weekdays,
    ),
    enabled: true,
  ),
  'sch-3': Schedule(
    id: 'sch-3',
    spec: const BroadcastSpec(
      source: BroadcastSource(
          type: BroadcastSourceType.tts,
          text: 'Fire drill today at 2 PM. Please proceed to exits.'),
      targets: BroadcastTargets(all: true),
      priority: BroadcastPriority.emergency,
    ),
    when: ScheduleWhen(
      scheduledAt: DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day + 3, 14, 0),
      recurrence: RecurrenceType.none,
    ),
    enabled: false,
  ),
};

class MockScheduleRepository implements IScheduleRepository {
  final _schedules = Map<String, Schedule>.from(_seedSchedules);
  int _nextId = 4;

  @override
  Future<List<Schedule>> getSchedules() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _schedules.values.toList();
  }

  @override
  Future<Schedule> getSchedule(String id) async {
    final s = _schedules[id];
    if (s == null) throw StateError('Schedule $id not found');
    return s;
  }

  @override
  Future<Schedule> createSchedule(
      BroadcastSpec spec, ScheduleWhen when, User creator) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final id = 'sch-$_nextId';
    _nextId++;
    final s = Schedule(id: id, spec: spec, when: when, enabled: true);
    _schedules[id] = s;
    return s;
  }

  @override
  Future<Schedule> updateSchedule(String id,
      {BroadcastSpec? spec, ScheduleWhen? when, bool? enabled}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final existing = _schedules[id];
    if (existing == null) throw StateError('Schedule $id not found');
    final updated = existing.copyWith(spec: spec, when: when, enabled: enabled);
    _schedules[id] = updated;
    return updated;
  }

  @override
  Future<void> deleteSchedule(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _schedules.remove(id);
  }
}
