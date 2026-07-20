import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:aakashvani/app/theme/app_theme.dart';
import 'package:aakashvani/domain/models/user.dart';
import 'package:aakashvani/domain/role.dart';
import 'package:aakashvani/features/admin/presentation/admin_provider.dart';

class UsersScreen extends ConsumerWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(adminUsersProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: usersAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (users) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (ctx, i) => _UserCard(user: users[i]),
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final User user;
  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (roleLabel, roleColor) = switch (user.role) {
      Role.admin       => ('Admin',       AppSemanticColors.roleAdmin),
      Role.broadcaster => ('Broadcaster', AppSemanticColors.roleBroadcaster),
      Role.viewer      => ('Viewer',      AppSemanticColors.roleViewer),
    };
    return Card(
      child: ListTile(
        onTap: () => context.push('/tab3/users/${user.id}'),
        leading: CircleAvatar(
          backgroundColor: roleColor.withValues(alpha: 0.15),
          child: Text(user.name[0].toUpperCase(),
              style: TextStyle(
                  color: roleColor, fontWeight: FontWeight.w700)),
        ),
        title: Text(user.name,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          user.zoneScope.isEmpty
              ? 'All zones'
              : '${user.zoneScope.length} zone(s)',
          style: TextStyle(fontSize: 12, color: cs.outline),
        ),
        trailing: Chip(
          label: Text(roleLabel,
              style: const TextStyle(fontSize: 11)),
          backgroundColor: roleColor.withValues(alpha: 0.12),
          labelStyle: TextStyle(
              color: roleColor, fontWeight: FontWeight.w600),
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
