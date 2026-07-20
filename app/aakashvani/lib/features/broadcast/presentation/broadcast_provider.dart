import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aakashvani/core/audio/bell_service.dart';
import 'package:aakashvani/core/database/cache_repository.dart';
import 'package:aakashvani/domain/models/audio_clip.dart';
import 'package:aakashvani/domain/models/broadcast.dart';
import 'package:aakashvani/domain/models/voice.dart';
import 'package:aakashvani/domain/models/zone.dart';
import 'package:aakashvani/features/auth/presentation/auth_provider.dart';
import 'package:aakashvani/core/config.dart';
import 'package:aakashvani/core/api/api_client.dart';
import 'package:aakashvani/features/broadcast/data/api_broadcast_repository.dart';
import 'package:aakashvani/features/broadcast/data/mock_broadcast_repository.dart';
import 'package:aakashvani/features/broadcast/domain/i_broadcast_repository.dart';

// Singleton repository
final broadcastRepositoryProvider = Provider<IBroadcastRepository>((ref) {
  if (AppConfig.useMock) {
    return MockBroadcastRepository();
  }
  final client = ref.watch(apiClientProvider);
  return ApiBroadcastRepository(client);
});

final zonesProvider = FutureProvider<List<Zone>>((ref) {
  return ref.read(broadcastRepositoryProvider).getZones();
});

final clipsProvider = FutureProvider<List<AudioClip>>((ref) {
  return ref.read(broadcastRepositoryProvider).getClips();
});

final voicesProvider = FutureProvider<List<Voice>>((ref) {
  return ref.read(broadcastRepositoryProvider).getVoices();
});

final broadcastsProvider = FutureProvider<List<Broadcast>>((ref) {
  return ref.read(broadcastRepositoryProvider).getBroadcasts();
});

final broadcastDetailProvider =
    StreamProvider.family<Broadcast, String>((ref, id) {
  return ref.read(broadcastRepositoryProvider).streamBroadcast(id);
});

// ── Composer Draft ─────────────────────────────────────────────────────────

class ComposerDraft {
  final BroadcastSourceType sourceType;
  final String ttsText;
  final String? voiceId;
  final String? clipId;
  final bool targetAll;
  final List<String> targetZoneIds;
  final BroadcastPriority priority;

  const ComposerDraft({
    this.sourceType = BroadcastSourceType.tts,
    this.ttsText = '',
    this.voiceId,
    this.clipId,
    this.targetAll = false,
    this.targetZoneIds = const [],
    this.priority = BroadcastPriority.normal,
  });

  bool get hasSource =>
      (sourceType == BroadcastSourceType.tts && ttsText.trim().isNotEmpty) ||
      (sourceType == BroadcastSourceType.clip && clipId != null);

  bool get hasTarget => targetAll || targetZoneIds.isNotEmpty;

  ComposerDraft copyWith({
    BroadcastSourceType? sourceType,
    String? ttsText,
    String? voiceId,
    String? clipId,
    bool? targetAll,
    List<String>? targetZoneIds,
    BroadcastPriority? priority,
  }) =>
      ComposerDraft(
        sourceType: sourceType ?? this.sourceType,
        ttsText: ttsText ?? this.ttsText,
        voiceId: voiceId ?? this.voiceId,
        clipId: clipId ?? this.clipId,
        targetAll: targetAll ?? this.targetAll,
        targetZoneIds: targetZoneIds ?? this.targetZoneIds,
        priority: priority ?? this.priority,
      );

  BroadcastSpec toSpec() => BroadcastSpec(
        source: BroadcastSource(
          type: sourceType,
          text: sourceType == BroadcastSourceType.tts ? ttsText.trim() : null,
          voiceId: voiceId,
          clipId: sourceType == BroadcastSourceType.clip ? clipId : null,
        ),
        targets: BroadcastTargets(
          all: targetAll,
          zoneIds: targetZoneIds,
        ),
        priority: priority,
      );
}

class ComposerDraftNotifier extends Notifier<ComposerDraft> {
  @override
  ComposerDraft build() => const ComposerDraft();

  void reset() => state = const ComposerDraft();
  void updateSourceType(BroadcastSourceType t) =>
      state = state.copyWith(sourceType: t, clipId: null);
  void updateTtsText(String text) => state = state.copyWith(ttsText: text);
  void updateVoice(String? id) => state = state.copyWith(voiceId: id);
  void updateClip(String? id) => state = state.copyWith(clipId: id);
  void updateTargetAll(bool v) =>
      state = state.copyWith(targetAll: v, targetZoneIds: []);
  void toggleZone(String zoneId) {
    final zones = List<String>.from(state.targetZoneIds);
    if (zones.contains(zoneId)) {
      zones.remove(zoneId);
    } else {
      zones.add(zoneId);
    }
    state = state.copyWith(targetZoneIds: zones, targetAll: false);
  }

  void updatePriority(BroadcastPriority p) => state = state.copyWith(priority: p);
}

final composerDraftProvider =
    NotifierProvider<ComposerDraftNotifier, ComposerDraft>(
  ComposerDraftNotifier.new,
);

// ── Outbox count ──────────────────────────────────────────────────────────────

final broadcastOutboxCountProvider = FutureProvider<int>((ref) async {
  return ref.watch(cacheRepositoryProvider).pendingBroadcastCount();
});

// ── Bell Mode ─────────────────────────────────────────────────────────────────

enum BellZoneStatus { idle, loading, success, error }

class BellState {
  final Map<String, BellZoneStatus> zoneStatuses;
  const BellState({this.zoneStatuses = const {}});

  BellState withStatus(String zoneId, BellZoneStatus s) =>
      BellState(zoneStatuses: {...zoneStatuses, zoneId: s});
}

class BellNotifier extends Notifier<BellState> {
  @override
  BellState build() => const BellState();

  Future<void> ring(String zoneId) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    state = state.withStatus(zoneId, BellZoneStatus.loading);

    // Play local audio feedback immediately — does not block or affect bell result
    unawaited(ref.read(bellServiceProvider).ring());

    try {
      await ref.read(broadcastRepositoryProvider).ringBell(zoneId, user);
      ref.invalidate(broadcastsProvider);
      state = state.withStatus(zoneId, BellZoneStatus.success);

      // Auto-revert to idle after 2 s so the row is ready for another ring
      await Future.delayed(const Duration(seconds: 2));
      if (state.zoneStatuses[zoneId] == BellZoneStatus.success) {
        state = state.withStatus(zoneId, BellZoneStatus.idle);
      }
    } catch (_) {
      state = state.withStatus(zoneId, BellZoneStatus.error);
    }
  }

  void reset() => state = const BellState();
}

final bellNotifierProvider =
    NotifierProvider<BellNotifier, BellState>(BellNotifier.new);

// ── BroadcastSpec → JSON helper ───────────────────────────────────────────────

String broadcastSpecToJson(BroadcastSpec spec) {
  return jsonEncode({
    'source': {
      'type': spec.source.type.name,
      'text': spec.source.text,
      'voiceId': spec.source.voiceId,
      'clipId': spec.source.clipId,
    },
    'targets': {
      'all': spec.targets.all,
      'zoneIds': spec.targets.zoneIds,
      'deviceIds': spec.targets.deviceIds,
    },
    'priority': spec.priority.name,
  });
}
