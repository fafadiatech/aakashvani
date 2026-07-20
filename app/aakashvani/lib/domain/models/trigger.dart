import 'package:aakashvani/domain/models/broadcast.dart';

enum TriggerCondition { deviceOffline, scheduleOverride, manualWebhook }

class Trigger {
  final String id;
  final String name;
  final String description;
  final bool enabled;
  final TriggerCondition condition;
  final BroadcastSpec spec;

  const Trigger({
    required this.id,
    required this.name,
    required this.description,
    required this.enabled,
    required this.condition,
    required this.spec,
  });

  Trigger copyWith({bool? enabled}) => Trigger(
        id: id,
        name: name,
        description: description,
        enabled: enabled ?? this.enabled,
        condition: condition,
        spec: spec,
      );
}
