import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aakashvani/domain/permissions.dart';
import 'package:aakashvani/features/auth/presentation/auth_provider.dart';
import 'package:aakashvani/features/activity/presentation/activity_feed_screen.dart';
import 'package:aakashvani/features/activity/presentation/status_board_screen.dart';

/// Role-aware shell: renders Activity Feed for Admin/Broadcaster,
/// Status Board for Viewer.
class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return const SizedBox.shrink();
    final permissions = Permissions.forUser(user);
    if (permissions.canViewOnly) return const StatusBoardScreen();
    return const ActivityFeedScreen();
  }
}
