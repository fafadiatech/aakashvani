import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:aakashvani/app/theme/app_theme.dart';
import 'package:aakashvani/domain/permissions.dart';
import 'package:aakashvani/domain/role.dart';
import 'package:aakashvani/features/auth/presentation/auth_provider.dart';

class SettingsHubScreen extends ConsumerWidget {
  const SettingsHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final cs = Theme.of(context).colorScheme;
    final permissions = user != null ? Permissions.forUser(user) : null;

    final roleLabel = switch (user?.role) {
      Role.admin => 'Administrator',
      Role.broadcaster => 'Broadcaster',
      Role.viewer => 'Viewer',
      null => '',
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Signed-in card
          if (user != null)
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                CircleAvatar(
                  backgroundColor: cs.primary,
                  child: Text(user.name[0],
                      style: TextStyle(color: cs.onPrimary)),
                ),
                const SizedBox(width: 12),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600)),
                      Text(roleLabel,
                          style: TextStyle(
                              fontSize: 12, color: cs.outline)),
                    ]),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    ref
                        .read(currentUserProvider.notifier)
                        .setUser(null);
                    context.go('/login');
                  },
                  child: const Text('Sign Out'),
                ),
              ]),
            ),

          // Menu grid — admin sees full grid; others see Appearance only
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              if (permissions?.canManageUsers ?? false) ...[
                _MenuCard(
                    icon: Icons.people_rounded,
                    label: 'Users',
                    subtitle: 'Manage roles & access',
                    color: AppSemanticColors.roleBroadcaster,
                    onTap: () => context.push('/tab3/users')),
                _MenuCard(
                    icon: Icons.map_rounded,
                    label: 'Zones',
                    subtitle: 'Speakers & groupings',
                    color: AppSemanticColors.roleViewer,
                    onTap: () => context.push('/tab3/zones')),
                _MenuCard(
                    icon: Icons.electrical_services_rounded,
                    label: 'Integrations',
                    subtitle: 'Triggers & webhooks',
                    color: AppSemanticColors.cardIntegrations,
                    onTap: () => context.push('/tab3/integrations')),
                _MenuCard(
                    icon: Icons.tune_rounded,
                    label: 'App Settings',
                    subtitle: 'Defaults & quiet hours',
                    color: AppSemanticColors.roleAdmin,
                    onTap: () => context.push('/tab3/settings')),
                _MenuCard(
                    icon: Icons.monitor_heart_rounded,
                    label: 'System Health',
                    subtitle: 'Status & diagnostics',
                    color: AppSemanticColors.statusOnline,
                    onTap: () => context.push('/tab3/health')),
              ],
              _MenuCard(
                  icon: Icons.dark_mode_rounded,
                  label: 'Appearance',
                  subtitle: 'Theme mode',
                  color: AppSemanticColors.cardAppearance,
                  onTap: () => _showThemePicker(context, ref)),
            ],
          ),
        ],
      ),
    );
  }

  void _showThemePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.wb_sunny_rounded),
              title: const Text('Light'),
              onTap: () {
                ref
                    .read(themeModeProvider.notifier)
                    .setThemeMode(ThemeMode.light);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode_rounded),
              title: const Text('Dark'),
              onTap: () {
                ref
                    .read(themeModeProvider.notifier)
                    .setThemeMode(ThemeMode.dark);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_brightness_rounded),
              title: const Text('System default'),
              onTap: () {
                ref
                    .read(themeModeProvider.notifier)
                    .setThemeMode(ThemeMode.system);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const _MenuCard(
      {required this.icon,
      required this.label,
      required this.subtitle,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const Spacer(),
            Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: color)),
            const SizedBox(height: 2),
            Text(subtitle,
                style: TextStyle(fontSize: 11, color: cs.outline),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
