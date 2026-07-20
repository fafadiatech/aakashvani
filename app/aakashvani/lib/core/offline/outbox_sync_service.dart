import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aakashvani/core/connectivity/connectivity_provider.dart';
import 'package:aakashvani/core/database/cache_repository.dart';
import 'package:aakashvani/domain/models/broadcast.dart';
import 'package:aakashvani/domain/models/schedule.dart';
import 'package:aakashvani/features/auth/presentation/auth_provider.dart';
import 'package:aakashvani/features/broadcast/presentation/broadcast_provider.dart';
import 'package:aakashvani/features/schedule/presentation/schedule_provider.dart';

/// Watches connectivity and syncs pending outbox items when reconnected.
class OutboxSyncService {
  OutboxSyncService(this._ref) {
    _ref.listen<bool>(
      isOnlineProvider,
      (previous, current) {
        // Trigger sync when transitioning from offline to online
        if (current && previous == false) {
          _sync();
        }
      },
    );
  }

  final Ref _ref;

  Future<void> _sync() async {
    await Future.wait([
      _syncBroadcasts(),
      _syncSchedules(),
    ]);
  }

  Future<void> _syncBroadcasts() async {
    final cache = _ref.read(cacheRepositoryProvider);
    final pending = await cache.getPendingBroadcasts();
    if (pending.isEmpty) return;

    final user = _ref.read(currentUserProvider);
    if (user == null) return;

    final repo = _ref.read(broadcastRepositoryProvider);

    for (final entry in pending) {
      try {
        final map = jsonDecode(entry.specJson) as Map<String, dynamic>;
        final spec = _broadcastSpecFromMap(map);
        await repo.sendBroadcast(spec, user);
        await cache.markBroadcastSynced(entry.id);
      } catch (_) {
        // Leave in outbox to retry on next reconnect
      }
    }

    // Invalidate broadcasts list so the UI refreshes
    _ref.invalidate(broadcastsProvider);
  }

  Future<void> _syncSchedules() async {
    final cache = _ref.read(cacheRepositoryProvider);
    final pending = await cache.getPendingSchedules();
    if (pending.isEmpty) return;

    final user = _ref.read(currentUserProvider);
    if (user == null) return;

    final repo = _ref.read(scheduleRepositoryProvider);

    for (final entry in pending) {
      try {
        final map = jsonDecode(entry.specJson) as Map<String, dynamic>;
        final spec = _broadcastSpecFromMap(map['spec'] as Map<String, dynamic>);
        final when = ScheduleWhen(
          scheduledAt: DateTime.parse(map['nextFireAt'] as String),
          recurrence: RecurrenceType.values.firstWhere(
            (r) => r.name == (map['recurrence'] as String? ?? 'none'),
            orElse: () => RecurrenceType.none,
          ),
        );
        await repo.createSchedule(spec, when, user);
        await cache.markScheduleSynced(entry.id);
      } catch (_) {
        // Leave in outbox to retry on next reconnect
      }
    }

    // Invalidate schedules list so the UI refreshes
    _ref.invalidate(schedulesProvider);
  }

  BroadcastSpec _broadcastSpecFromMap(Map<String, dynamic> map) {
    final sourceMap = map['source'] as Map<String, dynamic>;
    final targetsMap = map['targets'] as Map<String, dynamic>;

    final source = BroadcastSource(
      type: BroadcastSourceType.values.firstWhere(
        (t) => t.name == (sourceMap['type'] as String),
        orElse: () => BroadcastSourceType.tts,
      ),
      text: sourceMap['text'] as String?,
      voiceId: sourceMap['voiceId'] as String?,
      clipId: sourceMap['clipId'] as String?,
    );

    final targets = BroadcastTargets(
      all: targetsMap['all'] as bool? ?? false,
      zoneIds: (targetsMap['zoneIds'] as List?)?.cast<String>() ?? [],
      deviceIds: (targetsMap['deviceIds'] as List?)?.cast<String>() ?? [],
    );

    final priority = BroadcastPriority.values.firstWhere(
      (p) => p.name == (map['priority'] as String),
      orElse: () => BroadcastPriority.normal,
    );

    return BroadcastSpec(source: source, targets: targets, priority: priority);
  }
}

/// Keep-alive provider so the sync service is initialised once and stays alive.
final outboxSyncProvider = Provider<OutboxSyncService>((ref) {
  return OutboxSyncService(ref);
});
