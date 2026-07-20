import 'package:aakashvani/domain/models/app_settings.dart';
import 'package:aakashvani/domain/models/device.dart';
import 'package:aakashvani/domain/models/trigger.dart';
import 'package:aakashvani/domain/models/user.dart';
import 'package:aakashvani/domain/models/zone.dart';
import 'package:aakashvani/domain/role.dart';

abstract interface class IAdminRepository {
  // Users
  Future<List<User>> getUsers();
  Future<User> updateUser(String id, {Role? role, List<String>? zoneScope});

  // Zones
  Future<List<Zone>> getZones();
  Future<Zone> createZone({required String name, required int defaultVolume});
  Future<Zone> updateZone(String id, {String? name, int? defaultVolume});
  Future<void> deleteZone(String id);

  // Devices
  Future<List<Device>> getDevices();
  Future<Device> registerDevice(
      {required String name, required String zoneId, required String model});
  Future<Device> updateDevice(String id,
      {String? name, String? zoneId, int? volume});
  Future<void> pushOta(String id);
  Future<List<String>> getDeviceLogs(String id);

  // Settings
  Future<AppSettings> getSettings();
  Future<AppSettings> updateSettings(AppSettings settings);

  // Triggers
  Future<List<Trigger>> getTriggers();
  Future<Trigger> updateTrigger(String id, {bool? enabled});
}
