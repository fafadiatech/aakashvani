import 'package:aakashvani/domain/models/broadcast.dart';

class AppSettings {
  final bool quietHoursEnabled;
  final int quietStartHour;
  final int quietStartMinute;
  final int quietEndHour;
  final int quietEndMinute;
  final BroadcastPriority defaultPriority;
  final String defaultVoiceId;

  const AppSettings({
    this.quietHoursEnabled = false,
    this.quietStartHour = 22,
    this.quietStartMinute = 0,
    this.quietEndHour = 7,
    this.quietEndMinute = 0,
    this.defaultPriority = BroadcastPriority.normal,
    this.defaultVoiceId = 'voice-en-f',
  });

  AppSettings copyWith({
    bool? quietHoursEnabled,
    int? quietStartHour,
    int? quietStartMinute,
    int? quietEndHour,
    int? quietEndMinute,
    BroadcastPriority? defaultPriority,
    String? defaultVoiceId,
  }) =>
      AppSettings(
        quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
        quietStartHour: quietStartHour ?? this.quietStartHour,
        quietStartMinute: quietStartMinute ?? this.quietStartMinute,
        quietEndHour: quietEndHour ?? this.quietEndHour,
        quietEndMinute: quietEndMinute ?? this.quietEndMinute,
        defaultPriority: defaultPriority ?? this.defaultPriority,
        defaultVoiceId: defaultVoiceId ?? this.defaultVoiceId,
      );
}
