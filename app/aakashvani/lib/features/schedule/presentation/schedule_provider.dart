import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aakashvani/domain/models/broadcast.dart';
import 'package:aakashvani/domain/models/schedule.dart';
import 'package:aakashvani/features/schedule/data/mock_schedule_repository.dart';
import 'package:aakashvani/features/schedule/domain/i_schedule_repository.dart';

final scheduleRepositoryProvider = Provider<IScheduleRepository>((ref) {
  return MockScheduleRepository();
});

final schedulesProvider = FutureProvider<List<Schedule>>((ref) {
  return ref.read(scheduleRepositoryProvider).getSchedules();
});

// ── Schedule Draft (for the editor) ────────────────────────────────────────

class ScheduleDraft {
  // Source (mirrors ComposerDraft fields)
  final BroadcastSourceType sourceType;
  final String ttsText;
  final String? voiceId;
  final String? clipId;
  // Target + priority
  final bool targetAll;
  final List<String> targetZoneIds;
  final BroadcastPriority priority;
  // When
  final DateTime scheduledAt;
  final RecurrenceType recurrence;
  // Edit mode
  final String? editingId;

  ScheduleDraft({
    this.sourceType = BroadcastSourceType.tts,
    this.ttsText = '',
    this.voiceId,
    this.clipId,
    this.targetAll = false,
    this.targetZoneIds = const [],
    this.priority = BroadcastPriority.normal,
    DateTime? scheduledAt,
    this.recurrence = RecurrenceType.none,
    this.editingId,
  }) : scheduledAt = scheduledAt ??
            DateTime.now()
                .add(const Duration(hours: 1))
                .copyWith(second: 0, millisecond: 0, microsecond: 0);

  bool get hasSource =>
      (sourceType == BroadcastSourceType.tts && ttsText.trim().isNotEmpty) ||
      (sourceType == BroadcastSourceType.clip && clipId != null);

  bool get hasTarget => targetAll || targetZoneIds.isNotEmpty;

  bool get isValid => hasSource && hasTarget;

  ScheduleDraft copyWith({
    BroadcastSourceType? sourceType,
    String? ttsText,
    String? voiceId,
    String? clipId,
    bool? targetAll,
    List<String>? targetZoneIds,
    BroadcastPriority? priority,
    DateTime? scheduledAt,
    RecurrenceType? recurrence,
    String? editingId,
  }) =>
      ScheduleDraft(
        sourceType: sourceType ?? this.sourceType,
        ttsText: ttsText ?? this.ttsText,
        voiceId: voiceId ?? this.voiceId,
        clipId: clipId ?? this.clipId,
        targetAll: targetAll ?? this.targetAll,
        targetZoneIds: targetZoneIds ?? this.targetZoneIds,
        priority: priority ?? this.priority,
        scheduledAt: scheduledAt ?? this.scheduledAt,
        recurrence: recurrence ?? this.recurrence,
        editingId: editingId ?? this.editingId,
      );

  BroadcastSpec toSpec() => BroadcastSpec(
        source: BroadcastSource(
          type: sourceType,
          text: sourceType == BroadcastSourceType.tts ? ttsText.trim() : null,
          voiceId: voiceId,
          clipId: sourceType == BroadcastSourceType.clip ? clipId : null,
        ),
        targets: BroadcastTargets(all: targetAll, zoneIds: targetZoneIds),
        priority: priority,
      );

  ScheduleWhen toWhen() => ScheduleWhen(
        scheduledAt: scheduledAt,
        recurrence: recurrence,
      );

  /// Build a draft from an existing Schedule for editing
  factory ScheduleDraft.fromSchedule(Schedule s) {
    final src = s.spec.source;
    return ScheduleDraft(
      editingId: s.id,
      sourceType: src.type,
      ttsText: src.text ?? '',
      voiceId: src.voiceId,
      clipId: src.clipId,
      targetAll: s.spec.targets.all,
      targetZoneIds: List.from(s.spec.targets.zoneIds),
      priority: s.spec.priority,
      scheduledAt: s.when.scheduledAt,
      recurrence: s.when.recurrence,
    );
  }
}

class ScheduleDraftNotifier extends Notifier<ScheduleDraft> {
  @override
  ScheduleDraft build() => ScheduleDraft();

  void reset() => state = ScheduleDraft();

  void loadFromSchedule(Schedule s) => state = ScheduleDraft.fromSchedule(s);

  void updateSourceType(BroadcastSourceType t) =>
      state = state.copyWith(sourceType: t, clipId: null);
  void updateTtsText(String v) => state = state.copyWith(ttsText: v);
  void updateVoice(String? v) => state = state.copyWith(voiceId: v);
  void updateClip(String? v) => state = state.copyWith(clipId: v);
  void updateTargetAll(bool v) =>
      state = state.copyWith(targetAll: v, targetZoneIds: []);
  void toggleZone(String id) {
    final zones = List<String>.from(state.targetZoneIds);
    if (zones.contains(id)) {
      zones.remove(id);
    } else {
      zones.add(id);
    }
    state = state.copyWith(targetZoneIds: zones, targetAll: false);
  }

  void updatePriority(BroadcastPriority p) =>
      state = state.copyWith(priority: p);
  void updateScheduledAt(DateTime dt) =>
      state = state.copyWith(scheduledAt: dt);
  void updateRecurrence(RecurrenceType r) =>
      state = state.copyWith(recurrence: r);
}

final scheduleDraftProvider =
    NotifierProvider<ScheduleDraftNotifier, ScheduleDraft>(
  ScheduleDraftNotifier.new,
);
