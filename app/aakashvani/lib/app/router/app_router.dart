import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:aakashvani/domain/models/user.dart';
import 'package:aakashvani/domain/permissions.dart';
import 'package:aakashvani/domain/role.dart';
import 'package:aakashvani/features/auth/presentation/auth_provider.dart';
import 'package:aakashvani/features/auth/presentation/login_screen.dart';
import 'package:aakashvani/features/broadcast/presentation/bell_bottom_sheet.dart';
import 'package:aakashvani/features/broadcast/presentation/broadcast_provider.dart';
import 'package:aakashvani/features/broadcast/presentation/broadcast_screen.dart';
import 'package:aakashvani/features/broadcast/presentation/composer_screen.dart';
import 'package:aakashvani/features/broadcast/presentation/target_priority_screen.dart';
import 'package:aakashvani/features/broadcast/presentation/preview_send_screen.dart';
import 'package:aakashvani/features/broadcast/presentation/delivery_status_screen.dart';
import 'package:aakashvani/features/schedule/presentation/schedule_screen.dart';
import 'package:aakashvani/features/schedule/presentation/schedule_editor_screen.dart';
import 'package:aakashvani/features/library/presentation/clip_detail_screen.dart';
import 'package:aakashvani/features/library/presentation/record_clip_screen.dart';
import 'package:aakashvani/features/activity/presentation/activity_screen.dart';
import 'package:aakashvani/features/devices/presentation/devices_screen.dart';
import 'package:aakashvani/features/devices/presentation/device_detail_screen.dart';
import 'package:aakashvani/features/devices/presentation/register_device_screen.dart';
import 'package:aakashvani/features/admin/presentation/admin_screen.dart' show SettingsHubScreen;
import 'package:aakashvani/features/admin/presentation/users_screen.dart';
import 'package:aakashvani/features/admin/presentation/user_editor_screen.dart';
import 'package:aakashvani/features/admin/presentation/zones_screen.dart';
import 'package:aakashvani/features/admin/presentation/zone_editor_screen.dart';
import 'package:aakashvani/features/admin/presentation/settings_screen.dart';
import 'package:aakashvani/features/admin/presentation/system_health_screen.dart';
import 'package:aakashvani/features/admin/presentation/integrations_screen.dart';

// A ChangeNotifier that listens to Riverpod state for GoRouter refreshListenable
class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this._ref) {
    _ref.listen(currentUserProvider, (prev, next) => notifyListeners());
  }
  final Ref _ref;
  User? get currentUser => _ref.read(currentUserProvider);
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);

  return GoRouter(
    refreshListenable: notifier,
    initialLocation: '/login',
    redirect: (context, state) {
      final user = notifier.currentUser;
      final onLogin = state.matchedLocation == '/login';
      if (user == null && !onLogin) return '/login';
      if (user != null && onLogin) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/broadcast/:id',
        builder: (_, state) =>
            DeliveryStatusScreen(broadcastId: state.pathParameters['id']!),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const _BranchScreen(branchIndex: 0),
              routes: [
                GoRoute(path: 'compose', builder: (ctx, st) => const ComposerScreen()),
                GoRoute(path: 'target', builder: (ctx, st) => const TargetPriorityScreen()),
                GoRoute(path: 'preview', builder: (ctx, st) => const PreviewSendScreen()),
                GoRoute(
                  path: 'status/:id',
                  builder: (_, state) =>
                      DeliveryStatusScreen(broadcastId: state.pathParameters['id']!),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/tab1',
              builder: (context, state) => const _BranchScreen(branchIndex: 1),
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (context, state) => const ScheduleEditorScreen(),
                ),
                GoRoute(
                  path: 'edit/:id',
                  builder: (_, state) =>
                      ScheduleEditorScreen(scheduleId: state.pathParameters['id']),
                ),
                GoRoute(
                  path: 'device/:id',
                  builder: (_, state) =>
                      DeviceDetailScreen(deviceId: state.pathParameters['id']!),
                ),
                GoRoute(
                  path: 'register',
                  builder: (_, _) => const RegisterDeviceScreen(),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/tab2',
              builder: (context, state) => const _BranchScreen(branchIndex: 2),
              routes: [
                GoRoute(
                  path: 'detail/:id',
                  builder: (_, state) =>
                      ClipDetailScreen(clipId: state.pathParameters['id']!),
                ),
                GoRoute(
                  path: 'record',
                  builder: (ctx, st) => const RecordClipScreen(),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/tab3',
              builder: (context, state) => const _BranchScreen(branchIndex: 3),
              routes: [
                GoRoute(
                  path: 'broadcast/:id',
                  builder: (_, state) =>
                      DeliveryStatusScreen(broadcastId: state.pathParameters['id']!),
                ),
                GoRoute(
                  path: 'users',
                  builder: (_, _) => const UsersScreen(),
                ),
                GoRoute(
                  path: 'users/:id',
                  builder: (_, state) =>
                      UserEditorScreen(userId: state.pathParameters['id']!),
                ),
                GoRoute(
                  path: 'zones',
                  builder: (_, _) => const ZonesScreen(),
                ),
                GoRoute(
                  path: 'zones/new',
                  builder: (_, _) => const ZoneEditorScreen(),
                ),
                GoRoute(
                  path: 'zones/:id',
                  builder: (_, state) =>
                      ZoneEditorScreen(zoneId: state.pathParameters['id']),
                ),
                GoRoute(
                  path: 'settings',
                  builder: (_, _) => const SettingsScreen(),
                ),
                GoRoute(
                  path: 'health',
                  builder: (_, _) => const SystemHealthScreen(),
                ),
                GoRoute(
                  path: 'integrations',
                  builder: (_, _) => const IntegrationsScreen(),
                ),
              ],
            ),
          ]),
        ],
      ),
    ],
  );
});

// Tab definition
class _TabDef {
  final String label;
  final IconData icon;
  final Widget screen;
  const _TabDef({required this.label, required this.icon, required this.screen});
}

List<_TabDef> _tabsForRole(Role role) => switch (role) {
  Role.admin => [
    _TabDef(label: 'Broadcast', icon: Icons.campaign_rounded, screen: const BroadcastScreen()),
    _TabDef(label: 'Devices', icon: Icons.speaker_rounded, screen: const DevicesScreen()),
    _TabDef(label: 'Activity', icon: Icons.history_rounded, screen: const ActivityScreen()),
    _TabDef(label: 'Settings', icon: Icons.settings_rounded, screen: const SettingsHubScreen()),
  ],
  Role.broadcaster => [
    _TabDef(label: 'Broadcast', icon: Icons.campaign_rounded, screen: const BroadcastScreen()),
    _TabDef(label: 'Schedule', icon: Icons.calendar_month_rounded, screen: const ScheduleScreen()),
    _TabDef(label: 'Activity', icon: Icons.history_rounded, screen: const ActivityScreen()),
    _TabDef(label: 'Settings', icon: Icons.settings_rounded, screen: const SettingsHubScreen()),
  ],
  Role.viewer => [
    _TabDef(label: 'Status', icon: Icons.dashboard_rounded, screen: const ActivityScreen()),
    _TabDef(label: 'Schedule', icon: Icons.calendar_month_rounded, screen: const ScheduleScreen()),
    _TabDef(label: 'History', icon: Icons.history_rounded, screen: const ActivityScreen()),
    _TabDef(label: 'Settings', icon: Icons.settings_rounded, screen: const SettingsHubScreen()),
  ],
};

/// ConsumerWidget that reads the user and renders the appropriate screen for
/// the given branch index.
class _BranchScreen extends ConsumerWidget {
  final int branchIndex;
  const _BranchScreen({required this.branchIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return const SizedBox.shrink();
    final tabs = _tabsForRole(user.role);
    if (branchIndex >= tabs.length) return const SizedBox.shrink();
    return tabs[branchIndex].screen;
  }
}

/// Shell widget: wraps the navigation shell with a role-aware NavigationBar.
class _AppShell extends ConsumerWidget {
  final StatefulNavigationShell shell;
  const _AppShell({required this.shell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return const SizedBox.shrink();
    final tabs = _tabsForRole(user.role);
    final permissions = Permissions.forUser(user);
    final currentIndex = shell.currentIndex.clamp(0, tabs.length - 1);

    void onSelect(int i) {
      if (i < tabs.length) shell.goBranch(i);
    }

    return Scaffold(
      body: shell,
      bottomNavigationBar: permissions.canRingBell
          ? _HeroNavBar(
              tabs: tabs,
              currentBranchIndex: currentIndex,
              onBranchSelected: onSelect,
            )
          : NavigationBar(
              selectedIndex: currentIndex,
              onDestinationSelected: onSelect,
              destinations: tabs
                  .map((t) =>
                      NavigationDestination(icon: Icon(t.icon), label: t.label))
                  .toList(),
            ),
    );
  }
}

// ── Hero nav bar (Admin + Broadcaster only) ────────────────────────────────────

/// A custom bottom navigation bar that inserts the Bell hero button in the
/// centre slot. Real branch tabs are mapped around it:
///   visual: [0, 1, 🔔, 2, 3]
///   branch: [0, 1,  –, 2, 3]
class _HeroNavBar extends ConsumerWidget {
  final List<_TabDef> tabs;
  final int currentBranchIndex;
  final ValueChanged<int> onBranchSelected;

  const _HeroNavBar({
    required this.tabs,
    required this.currentBranchIndex,
    required this.onBranchSelected,
  });

  // Bell occupies the middle visual slot
  int get _bellAt => tabs.length ~/ 2;

  // Branch index → visual position (shift right past the bell slot)
  int _visualFor(int branch) => branch < _bellAt ? branch : branch + 1;

  // Visual position → branch index (null if bell was tapped)
  int? _branchFor(int visual) {
    if (visual == _bellAt) return null;
    return visual < _bellAt ? visual : visual - 1;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final selectedVisual = _visualFor(currentBranchIndex);
    final totalVisual = tabs.length + 1; // tabs + 1 bell slot

    return Material(
      color: cs.surface,
      elevation: 3,
      shadowColor: cs.shadow,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            children: List.generate(totalVisual, (visual) {
              if (visual == _bellAt) {
                return const Expanded(child: Center(child: _BellHeroButton()));
              }
              final branch = _branchFor(visual)!;
              final tab = tabs[branch];
              return Expanded(
                child: _NavItem(
                  icon: tab.icon,
                  label: tab.label,
                  selected: visual == selectedVisual,
                  onTap: () => onBranchSelected(branch),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _BellHeroButton extends ConsumerWidget {
  const _BellHeroButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () {
        ref.read(bellNotifierProvider.notifier).reset();
        showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (_) => const BellBottomSheet(),
        );
      },
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: cs.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: cs.primary.withValues(alpha: 0.45),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(Icons.notifications_rounded, color: cs.onPrimary, size: 26),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = selected ? cs.primary : cs.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: selected ? cs.primaryContainer : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
