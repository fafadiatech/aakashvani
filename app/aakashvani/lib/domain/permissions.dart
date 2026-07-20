import 'package:aakashvani/domain/role.dart';
import 'package:aakashvani/domain/models/user.dart';

enum AppTab { broadcast, schedule, library, activity, devices, settings, status, history }

class Permissions {
  final Role role;
  final List<String> zoneScope;

  const Permissions({required this.role, required this.zoneScope});

  factory Permissions.forUser(User user) =>
      Permissions(role: user.role, zoneScope: user.zoneScope);

  bool get canBroadcast => role == Role.admin || role == Role.broadcaster;
  bool get canRingBell => role == Role.admin || role == Role.broadcaster;
  bool get canManageDevices => role == Role.admin;
  bool get canManageUsers => role == Role.admin;
  bool get canManageZones => role == Role.admin;
  bool get canViewOnly => role == Role.viewer;

  List<AppTab> get tabs => switch (role) {
    Role.admin => [AppTab.broadcast, AppTab.devices, AppTab.activity, AppTab.settings],
    Role.broadcaster => [AppTab.broadcast, AppTab.schedule, AppTab.activity, AppTab.settings],
    Role.viewer => [AppTab.status, AppTab.schedule, AppTab.history, AppTab.settings],
  };
}
