import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Wraps flutter_local_notifications. Call [init] once at app startup.
/// Deep-link payloads are route strings (e.g. '/broadcast/bc-123').
class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  // Callback set by the app to handle notification taps
  void Function(String route)? onNotificationTap;

  static const _channelId = 'aakashvani_alerts';
  static const _channelName = 'Aakashvani Alerts';

  Future<void> init() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          onNotificationTap?.call(payload);
        }
      },
    );

    // Create Android notification channel
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: 'Broadcast and device alerts',
            importance: Importance.high,
          ),
        );
  }

  Future<void> showBroadcastComplete({
    required String broadcastId,
    required String message,
    required int playedCount,
    required int totalCount,
  }) async {
    await _plugin.show(
      id: broadcastId.hashCode,
      title: 'Broadcast Complete',
      body: '$message — $playedCount/$totalCount devices played',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          icon: '@mipmap/ic_launcher',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: '/broadcast/$broadcastId',
    );
  }

  Future<void> showDeviceOfflineAlert({
    required String deviceId,
    required String deviceName,
  }) async {
    await _plugin.show(
      id: deviceId.hashCode,
      title: 'Device Offline',
      body: '$deviceName is not responding',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          icon: '@mipmap/ic_launcher',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: '/broadcast/none',
    );
  }
}
