import 'dart:async';
import 'dart:convert';

/// Simulates the Raspberry Pi hub's WebSocket stream.
/// Emits device.status events and occasional alert events.
class MockWsStream {
  final _controller = StreamController<String>.broadcast();
  Timer? _timer;
  int _tick = 0;

  // Cycle through devices to simulate varied states
  static const _deviceIds = ['dev-1', 'dev-2', 'dev-3', 'dev-4', 'dev-5', 'dev-6'];
  static const _onlineMap = {
    'dev-1': true, 'dev-2': true, 'dev-3': true,
    'dev-4': false, 'dev-5': true, 'dev-6': false,
  };

  Stream<String> get stream => _controller.stream;

  void start() {
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      _tick++;
      final deviceId = _deviceIds[_tick % _deviceIds.length];
      final baseOnline = _onlineMap[deviceId] ?? false;
      // Occasionally toggle online state for realism
      final online = baseOnline && (_tick % 7 != 0);
      final playing = online && (_tick % 5 == 0);

      _emit({
        'type': 'device.status',
        'deviceId': deviceId,
        'online': online,
        'playing': playing,
        'volume': 60 + (_tick % 4) * 5,
        'lastSeen': DateTime.now().toIso8601String(),
      });

      // Every 3rd tick, also emit an alert for an offline device
      if (!online && _tick % 3 == 0) {
        _emit({
          'type': 'alert',
          'alertType': 'device_offline',
          'deviceId': deviceId,
        });
      }
    });
  }

  void _emit(Map<String, dynamic> payload) {
    if (!_controller.isClosed) _controller.add(jsonEncode(payload));
  }

  void stop() {
    _timer?.cancel();
    if (!_controller.isClosed) _controller.close();
  }
}
