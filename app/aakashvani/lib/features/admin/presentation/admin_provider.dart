import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aakashvani/domain/models/app_settings.dart';
import 'package:aakashvani/domain/models/device.dart';
import 'package:aakashvani/domain/models/trigger.dart';
import 'package:aakashvani/domain/models/user.dart';
import 'package:aakashvani/domain/models/zone.dart';
import 'package:aakashvani/features/admin/data/mock_admin_repository.dart';
import 'package:aakashvani/features/admin/domain/i_admin_repository.dart';

final adminRepositoryProvider = Provider<IAdminRepository>((ref) {
  return MockAdminRepository();
});

final adminUsersProvider = FutureProvider<List<User>>((ref) {
  return ref.read(adminRepositoryProvider).getUsers();
});

final adminZonesProvider = FutureProvider<List<Zone>>((ref) {
  return ref.read(adminRepositoryProvider).getZones();
});

final adminDevicesProvider = FutureProvider<List<Device>>((ref) {
  return ref.read(adminRepositoryProvider).getDevices();
});

final adminDeviceLogsProvider =
    FutureProvider.family<List<String>, String>((ref, id) {
  return ref.read(adminRepositoryProvider).getDeviceLogs(id);
});

final appSettingsProvider = FutureProvider<AppSettings>((ref) {
  return ref.read(adminRepositoryProvider).getSettings();
});

final triggersProvider = FutureProvider<List<Trigger>>((ref) {
  return ref.read(adminRepositoryProvider).getTriggers();
});
