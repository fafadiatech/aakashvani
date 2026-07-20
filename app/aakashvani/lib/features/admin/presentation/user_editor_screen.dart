import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:aakashvani/domain/role.dart';
import 'package:aakashvani/features/admin/presentation/admin_provider.dart';

class UserEditorScreen extends ConsumerStatefulWidget {
  final String userId;
  const UserEditorScreen({super.key, required this.userId});

  @override
  ConsumerState<UserEditorScreen> createState() =>
      _UserEditorScreenState();
}

class _UserEditorScreenState extends ConsumerState<UserEditorScreen> {
  Role? _role;
  List<String> _zoneScope = [];
  bool _saving = false;
  bool _loaded = false;

  void _loadUser() {
    if (_loaded) return;
    final users = ref.read(adminUsersProvider).value ?? [];
    final u =
        users.where((u) => u.id == widget.userId).firstOrNull;
    if (u != null) {
      _role = u.role;
      _zoneScope = List.from(u.zoneScope);
      _loaded = true;
    }
  }

  Future<void> _save() async {
    if (_role == null) return;
    if (_role == Role.admin) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Grant Admin Access?'),
          content: const Text(
              'This will give the user full system access including device management and user control.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Confirm')),
          ],
        ),
      );
      if (ok != true || !mounted) return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(adminRepositoryProvider).updateUser(widget.userId,
          role: _role, zoneScope: _zoneScope);
      ref.invalidate(adminUsersProvider);
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(adminUsersProvider);
    final zonesAsync = ref.watch(adminZonesProvider);
    _loadUser();

    return Scaffold(
      appBar: AppBar(title: const Text('Edit User')),
      body: usersAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (users) {
          final user =
              users.where((u) => u.id == widget.userId).firstOrNull;
          if (user == null) {
            return const Center(child: Text('User not found'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // User header
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(child: Text(user.name[0])),
                title: Text(user.name,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(user.id,
                    style: TextStyle(
                        fontSize: 11,
                        color:
                            Theme.of(context).colorScheme.outline)),
              ),
              const SizedBox(height: 16),
              Text('Role',
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              ...Role.values.map((r) {
                final (label, desc) = switch (r) {
                  Role.admin =>
                    ('Administrator', 'Full system control'),
                  Role.broadcaster =>
                    ('Broadcaster', 'Send to assigned zones'),
                  Role.viewer => ('Viewer', 'Read-only access'),
                };
                return RadioListTile<Role>(
                  value: r,
                  groupValue: _role,
                  onChanged: (v) => setState(() => _role = v),
                  title: Text(label),
                  subtitle: Text(desc,
                      style: const TextStyle(fontSize: 12)),
                );
              }),
              if (_role == Role.broadcaster) ...[
                const SizedBox(height: 16),
                Text('Zone Access',
                    style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 4),
                Text('Leave empty to allow all zones',
                    style: TextStyle(
                        fontSize: 12,
                        color:
                            Theme.of(context).colorScheme.outline)),
                const SizedBox(height: 8),
                zonesAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) =>
                      const Text('Failed to load zones'),
                  data: (zones) => Column(
                    children: zones
                        .map((z) => CheckboxListTile(
                              dense: true,
                              title: Text(z.name),
                              value: _zoneScope.contains(z.id),
                              onChanged: (_) {
                                setState(() {
                                  if (_zoneScope.contains(z.id)) {
                                    _zoneScope.remove(z.id);
                                  } else {
                                    _zoneScope.add(z.id);
                                  }
                                });
                              },
                            ))
                        .toList(),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(50)),
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Save Changes'),
              ),
            ],
          );
        },
      ),
    );
  }
}
