import 'package:aakashvani/domain/models/schedule.dart';
import 'package:aakashvani/domain/models/broadcast.dart';
import 'package:aakashvani/domain/models/user.dart';

abstract interface class IScheduleRepository {
  Future<List<Schedule>> getSchedules();
  Future<Schedule> getSchedule(String id);
  Future<Schedule> createSchedule(
      BroadcastSpec spec, ScheduleWhen when, User creator);
  Future<Schedule> updateSchedule(String id,
      {BroadcastSpec? spec, ScheduleWhen? when, bool? enabled});
  Future<void> deleteSchedule(String id);
}
